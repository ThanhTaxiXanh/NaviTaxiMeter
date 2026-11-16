package vn.navitaximeter

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/** Pure JVM metadata tests, NOT GNSS hardware attestation or device proof. */
class GnssFixTrustGateTest {
    private fun sample(
        fix: Long = 10_000_000_000L,
        now: Long = fix + 500_000_000L,
        provider: String? = "gps",
        fine: Boolean = true,
        mock: Boolean = false,
        accuracy: Float? = 4f,
        latitude: Double = 21.0,
        longitude: Double = 106.0
    ) = GnssFixEvidence(
        provider, fine, mock, fix, now, accuracy, latitude, longitude
    )

    @Test fun acceptsOrderedFreshGpsWithFinePermission() {
        val gate = GnssFixTrustGate()
        assertTrue(gate.accepts(sample()))
        assertTrue(gate.accepts(sample(fix = 16_000_000_000L)))
        assertTrue(gate.accepts(sample(fix = 28_000_000_000L)))
    }

    @Test fun networkOrCoarseFixNeverCountsAsTrustedGps() {
        for (bad in listOf(
            sample(provider = "network"),
            sample(provider = "fused"),
            sample(provider = null),
            sample(fine = false),
            sample(provider = "network", fine = false)
        )) {
            val gate = GnssFixTrustGate()
            assertFalse(gate.accepts(bad))
            // A good-looking GPS fix must not silently auto-resume after loss.
            assertFalse(gate.accepts(sample(fix = 11_000_000_000L)))
        }
    }

    @Test fun simulatedOrImpossibleGpsFixSuspends() {
        for (bad in listOf(
            sample(mock = true),
            sample(accuracy = null),
            sample(accuracy = Float.NaN),
            sample(accuracy = Float.POSITIVE_INFINITY),
            sample(accuracy = -1f),
            sample(accuracy = 30.1f),
            sample(latitude = Double.NaN),
            sample(latitude = 90.1),
            sample(longitude = -180.1)
        )) {
            assertFalse(GnssFixTrustGate().accepts(bad))
        }
    }

    @Test fun futureStaleOrMissingMonotonicFixSuspends() {
        for (bad in listOf(
            sample(fix = 0L),
            sample(fix = -100L),
            sample(now = 9_999_999_999L),
            sample(now = 22_000_000_001L)
        )) {
            assertFalse(GnssFixTrustGate().accepts(bad))
        }
        assertTrue(GnssFixTrustGate().accepts(sample(now = 22_000_000_000L)))
    }

    @Test fun duplicateRollbackOrGapLocksFutureAcceptance() {
        val invalidLater = listOf(
            sample(fix = 10_000_000_000L),
            sample(fix = 9_999_999_999L),
            sample(fix = 22_000_000_001L)
        )
        invalidLater.forEach { candidate ->
            val gate = GnssFixTrustGate()
            assertTrue(gate.accepts(sample()))
            assertFalse(gate.accepts(candidate))
            assertFalse(gate.accepts(sample(fix = 11_000_000_000L)))
        }
        val continuous = GnssFixTrustGate()
        assertTrue(continuous.accepts(sample()))
        assertTrue(continuous.accepts(sample(fix = 22_000_000_000L)))
    }

    @Test fun onlyFreshServiceGateCanAcceptAfterFault() {
        val oldServiceGate = GnssFixTrustGate()
        assertTrue(oldServiceGate.accepts(sample()))
        assertFalse(oldServiceGate.accepts(sample(provider = "network")))
        assertFalse(oldServiceGate.accepts(sample(fix = 11_000_000_000L)))
        val explicitlyRestartedGate = GnssFixTrustGate()
        assertTrue(explicitlyRestartedGate.accepts(sample(fix = 11_000_000_000L)))
    }

    @Test fun safetyHealthFreshnessRequiresBothLiveOwnerAndTrustedState() {
        assertTrue(GnssHealthPublication.isFresh(true, "trusted_gps", 0L))
        assertTrue(GnssHealthPublication.isFresh(true, "trusted_gps", 12_000L))
        assertFalse(GnssHealthPublication.isFresh(false, "trusted_gps", 100L))
        assertFalse(GnssHealthPublication.isFresh(true, "trusted_gps", -1L))
        assertFalse(GnssHealthPublication.isFresh(true, "trusted_gps", 12_001L))
    }

    @Test fun oldFreshFixIsInvalidWhenSafetyServiceReportsFaultOrStop() {
        val invalidStates = listOf(
            "untrusted_gps", "provider_disabled", "permission_revoked",
            "owner_lost", "stop_requested", "service_unavailable",
            "acquiring", "stopped"
        )
        invalidStates.forEach { state ->
            assertFalse(
                "No state other than trusted_gps may publish a fresh fix: $state",
                GnssHealthPublication.isFresh(true, state, 1L)
            )
        }
        // A heartbeat may remain recent during onDestroy; that is not GPS.
        assertFalse(GnssHealthPublication.isFresh(true, "provider_disabled", 0L))
        assertFalse(GnssHealthPublication.isFresh(true, "permission_revoked", 0L))
    }
}
