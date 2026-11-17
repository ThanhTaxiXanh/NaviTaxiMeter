package vn.navitaximeter

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.concurrent.Callable
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger

/** Contract-level JVM tests; writer fakes do NOT prove SQLite durability. */
class TripCheckpointProtocolTest {
    private val fence = TripSessionFence("test-session-A", 701L)

    private fun sample(
        sequence: Long,
        nanos: Long,
        session: TripSessionFence = fence,
        accuracy: Double = 4.0,
        speed: Double = 32.0,
        mock: Boolean = false
    ) = GpsCheckpointCandidate(
        session, sequence, nanos, accuracy, speed, mock
    )

    private fun receipt(request: GpsCheckpointCandidate) =
        CheckpointCommitReceipt(
            request.fence, request.sequence,
            "test-db-commit-${request.sequence}"
        )

    private fun ready(
        writer: AtomicTripCheckpointWriter
    ): TripCheckpointProtocol {
        val protocol = TripCheckpointProtocol(writer)
        assertTrue(protocol.requestStart(fence))
        assertTrue(protocol.serviceAcknowledged(fence, 300L))
        assertTrue(protocol.beginGpsAcquisition(fence))
        assertTrue(protocol.trustedGnssAvailable(fence))
        return protocol
    }

    @Test
    fun serviceAckMustMatchSessionAndBeFresh() {
        val p = TripCheckpointProtocol(AtomicTripCheckpointWriter { receipt(it) })
        val stale = fence.copy(generation = fence.generation + 1L)
        assertEquals(TripProtocolPhase.IDLE, p.phase)
        assertTrue(p.requestStart(fence))
        assertFalse(p.requestStart(stale))
        assertFalse(p.serviceAcknowledged(stale, 0L))
        assertFalse(p.serviceAcknowledged(fence, -1L))
        assertFalse(p.serviceAcknowledged(fence, 7001L))
        assertEquals(TripProtocolPhase.START_REQUESTED, p.phase)
        assertTrue(p.serviceAcknowledged(fence, 7000L))
        assertFalse(p.serviceAcknowledged(fence, 100L))
        assertFalse(p.beginGpsAcquisition(stale))
        assertTrue(p.beginGpsAcquisition(fence))
        assertFalse(p.trustedGnssAvailable(stale))
        assertTrue(p.trustedGnssAvailable(fence))
        assertEquals(TripProtocolPhase.ACTIVE, p.phase)
    }

    @Test
    fun checkpointAckAppearsOnlyAfterWriterReturnsCommittedReceipt() {
        val trace = mutableListOf<String>()
        val p = ready(AtomicTripCheckpointWriter {
            trace.add("begin-transaction")
            trace.add("sqlite-commit-success")
            receipt(it)
        })
        assertEquals(-1L, p.lastSequence)
        assertEquals(emptyList<String>(), trace)
        val ack = p.checkpoint(sample(0L, 1_000_000_000L))
        assertEquals(listOf("begin-transaction", "sqlite-commit-success"), trace)
        assertEquals("test-db-commit-0", ack.databaseCheckpointId)
        assertEquals(0L, p.lastSequence)
        assertEquals(TripProtocolPhase.ACTIVE, p.phase)
    }

    @Test
    fun duplicateIdenticalFixDoesNotWriteAgain() {
        val writes = AtomicInteger()
        val p = ready(AtomicTripCheckpointWriter {
            writes.incrementAndGet()
            receipt(it)
        })
        val first = sample(0L, 1_000_000_000L)
        val ack = p.checkpoint(first)
        assertEquals(ack, p.checkpoint(first))
        assertEquals(1, writes.get())
        assertEquals(0L, p.lastSequence)
    }

    @Test
    fun conflictingDuplicateSuspendsWithoutNewWrite() {
        val writes = AtomicInteger()
        val p = ready(AtomicTripCheckpointWriter {
            writes.incrementAndGet()
            receipt(it)
        })
        p.checkpoint(sample(0L, 1_000_000_000L))
        assertThrows(IllegalStateException::class.java) {
            p.checkpoint(sample(0L, 1_000_000_000L, speed = 54.0))
        }
        assertEquals(1, writes.get())
        assertEquals("conflicting_replay", p.suspensionReason)
        assertEquals(TripProtocolPhase.SUSPENDED, p.phase)
    }

    @Test
    fun skippedSequenceNeverReachesWriter() {
        val writes = AtomicInteger()
        val p = ready(AtomicTripCheckpointWriter {
            writes.incrementAndGet()
            receipt(it)
        })
        assertThrows(IllegalStateException::class.java) {
            p.checkpoint(sample(1L, 1_000_000_000L))
        }
        assertEquals(0, writes.get())
        assertEquals(TripProtocolPhase.SUSPENDED, p.phase)
        assertEquals(-1L, p.lastSequence)
    }

    @Test
    fun timestampRollbackOrTwelveSecondGapSuspends() {
        val writer = AtomicTripCheckpointWriter { receipt(it) }
        val rollback = ready(writer)
        rollback.checkpoint(sample(0L, 1_000_000_000L))
        assertThrows(IllegalStateException::class.java) {
            rollback.checkpoint(sample(1L, 999_999_999L))
        }
        assertEquals("stale_or_gapped_gnss", rollback.suspensionReason)

        val gap = ready(writer)
        gap.checkpoint(sample(0L, 1_000_000_000L))
        assertThrows(IllegalStateException::class.java) {
            gap.checkpoint(sample(1L, 13_000_000_001L))
        }
        assertEquals(TripProtocolPhase.SUSPENDED, gap.phase)
    }

    @Test
    fun mockedOrInaccurateSamplesNeverReachWriter() {
        for (candidate in listOf(
            sample(0L, 1_000_000_000L, mock = true),
            sample(0L, 1_000_000_000L, accuracy = Double.NaN),
            sample(0L, 1_000_000_000L, accuracy = 42.0),
            sample(0L, 1_000_000_000L, speed = Double.POSITIVE_INFINITY),
            sample(0L, 1_000_000_000L, speed = -1.0)
        )) {
            val writes = AtomicInteger()
            val p = ready(AtomicTripCheckpointWriter {
                writes.incrementAndGet()
                receipt(it)
            })
            assertThrows(IllegalStateException::class.java) {
                p.checkpoint(candidate)
            }
            assertEquals(0, writes.get())
            assertEquals(TripProtocolPhase.SUSPENDED, p.phase)
        }
    }

    @Test
    fun sqliteFailureEvenAfterPossibleCommitDoesNotAckAndCannotResume() {
        val p = ready(AtomicTripCheckpointWriter {
            throw IllegalStateException("SQLite transaction/transport uncertain")
        })
        assertThrows(IllegalStateException::class.java) {
            p.checkpoint(sample(0L, 1_000_000_000L))
        }
        assertEquals("checkpoint_unconfirmed", p.suspensionReason)
        assertEquals(-1L, p.lastSequence)
        assertEquals(TripProtocolPhase.SUSPENDED, p.phase)
        assertFalse(p.requestStart(fence))
        assertFalse(p.serviceAcknowledged(fence, 0L))
        assertThrows(IllegalStateException::class.java) {
            p.checkpoint(sample(0L, 1_000_000_000L))
        }
    }

    @Test
    fun forgedOrMismatchingCommitReceiptIsRejected() {
        val cases = listOf(
            CheckpointCommitReceipt(fence, 12L, "wrong-sequence"),
            CheckpointCommitReceipt(fence.copy(generation = 702L), 0L, "wrong-lease"),
            CheckpointCommitReceipt(fence, 0L, "")
        )
        cases.forEach { mismatch ->
            val p = ready(AtomicTripCheckpointWriter { mismatch })
            assertThrows(IllegalStateException::class.java) {
                p.checkpoint(sample(0L, 1_000_000_000L))
            }
            assertEquals("checkpoint_mismatch", p.suspensionReason)
            assertEquals(-1L, p.lastSequence)
        }
    }

    @Test
    fun staleGenerationDoesNotAffectActiveSession() {
        val writes = AtomicInteger()
        val p = ready(AtomicTripCheckpointWriter {
            writes.incrementAndGet()
            receipt(it)
        })
        val old = fence.copy(generation = 700L)
        assertThrows(SecurityException::class.java) {
            p.checkpoint(sample(0L, 1_000_000_000L, session = old))
        }
        assertFalse(p.suspend(old, "stale-notification"))
        assertEquals(TripProtocolPhase.ACTIVE, p.phase)
        assertEquals(0, writes.get())
        assertNotNull(p.checkpoint(sample(0L, 1_000_000_000L)))
        assertEquals(1, writes.get())
    }

    @Test
    fun recoveryIsAlwaysPausedAndHasNoAutomaticResume() {
        val writer = AtomicTripCheckpointWriter { receipt(it) }
        val p = TripCheckpointProtocol.recoveredPaused(writer, fence, 8L)
        assertEquals(TripProtocolPhase.SUSPENDED, p.phase)
        assertEquals("recovered_paused", p.suspensionReason)
        assertEquals(8L, p.lastSequence)
        assertFalse(p.requestStart(fence))
        assertFalse(p.serviceAcknowledged(fence, 0L))
        assertFalse(p.trustedGnssAvailable(fence))
        assertThrows(IllegalStateException::class.java) {
            p.checkpoint(sample(9L, 10_000_000_000L))
        }
    }

    @Test
    fun permissionOrServiceFailureSuspendsWithoutAutoResume() {
        val p = ready(AtomicTripCheckpointWriter { receipt(it) })
        assertTrue(p.suspend(fence, "service-heartbeat-lost"))
        assertEquals("service-heartbeat-lost", p.suspensionReason)
        assertEquals(TripProtocolPhase.SUSPENDED, p.phase)
        assertFalse(p.trustedGnssAvailable(fence))
        assertFalse(p.beginGpsAcquisition(fence))
        assertThrows(IllegalStateException::class.java) {
            p.checkpoint(sample(0L, 1_000_000_000L))
        }
    }

    @Test
    fun simultaneousIdenticalCheckpointEventsCommitOnce() {
        val writes = AtomicInteger()
        val p = ready(AtomicTripCheckpointWriter {
            writes.incrementAndGet()
            Thread.sleep(15L)
            receipt(it)
        })
        val pool = Executors.newFixedThreadPool(8)
        try {
            val futures = (0 until 8).map {
                pool.submit(Callable {
                    p.checkpoint(sample(0L, 1_000_000_000L))
                })
            }
            val acks = futures.map { it.get(10L, TimeUnit.SECONDS) }
            assertTrue(acks.all { it == acks.first() })
            assertEquals(1, writes.get())
            assertEquals(0L, p.lastSequence)
        } finally {
            pool.shutdownNow()
        }
    }
}
