import 'package:flutter/material.dart';

import '../core/taximeter_engine.dart';
import '../domain/confirmed_tariffs.dart';

class TariffManagementPage extends StatefulWidget {
  const TariffManagementPage({super.key, this.store});
  final ConfirmedTariffStore? store;

  @override
  State<TariffManagementPage> createState() => _TariffManagementPageState();
}

class _TariffManagementPageState extends State<TariffManagementPage> {
  late final ConfirmedTariffStore _store =
      widget.store ?? ConfirmedTariffStore();

  ConfirmedTariffBook? _book;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final book = await _store.read();
      if (mounted) setState(() => _book = book);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Không thể đọc bảng giá đã lưu: $e');
      }
    }
  }

  Future<void> _save(ConfirmedTariffBook next) async {
    setState(() => _busy = true);
    try {
      await _store.write(next);
      if (mounted) setState(() { _book = next; _error = null; });
    } catch (e) {
      if (mounted) setState(() => _error = 'Lưu bảng giá thất bại: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit([ConfirmedTariff? entry]) async {
    if (_busy || _book == null) return;
    final result = await showDialog<ConfirmedTariff>(
      context: context,
      builder: (_) => TariffEditorDialog(existing: entry),
    );
    if (result == null || !mounted) return;
    await _save(_book!.save(result));
  }

  Future<void> _remove(ConfirmedTariff entry) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) =>
      AlertDialog(
        title: const Text('Xóa bảng giá?'),
        content: Text('Xóa "${entry.tariff.name}" khỏi danh mục? '
            'Hóa đơn chuyến cũ vẫn được giữ trong SQLite.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (yes == true && mounted && _book != null) {
      await _save(_book!.remove(entry.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = _book;
    return Scaffold(
      appBar: AppBar(title: const Text('Bảng giá taxi')),
      floatingActionButton: book == null || _busy
          ? null : FloatingActionButton.extended(
              onPressed: () => _edit(),
              icon: const Icon(Icons.add),
              label: const Text('Thêm bảng giá'),
            ),
      body: book == null
          ? Center(child: _error == null
              ? const CircularProgressIndicator()
              : Text(_error!, textAlign: TextAlign.center))
          : ListView(padding: const EdgeInsets.all(16), children: [
              const Text('Chỉ sử dụng bảng giá do tài xế nhập và xác nhận. '
                  'Đây chưa phải đồng hồ thu cước đang hoạt động.'),
              if (_error != null) Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.orange)),
              ),
              const SizedBox(height: 16),
              if (book.profiles.isEmpty)
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Chưa có bảng giá'),
                  subtitle: Text('Bấm Thêm bảng giá để nhập đơn giá thật.'),
                ),
              for (final p in book.profiles)
                Card(child: Column(children: [
                  ListTile(
                    title: Text(p.tariff.name),
                    subtitle: Text('Mở cửa: ${p.tariff.baseFare.toStringAsFixed(0)}đ'
                        ' · ${p.tariff.baseDistanceKm} km'
                        ' · ${p.tariff.fareTiers?.length ?? 2} bậc giá'),
                    leading: Icon(book.activeId == p.id
                        ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                    onTap: _busy ? null : () => _save(book.select(p.id)),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: _busy ? null : () => _edit(p),
                        child: const Text('Sửa')),
                    TextButton(onPressed: _busy ? null : () => _remove(p),
                        child: const Text('Xóa')),
                  ]),
                ])),
              const SizedBox(height: 100),
            ]),
    );
  }
}

class _BandFields {
  _BandFields({double? upperKm, double? pricePerKm})
      : cap = TextEditingController(text: upperKm?.toString() ?? ''),
        rate = TextEditingController(text: pricePerKm?.toString() ?? '');
  final TextEditingController cap;
  final TextEditingController rate;
  void dispose() { cap.dispose(); rate.dispose(); }
}

class TariffEditorDialog extends StatefulWidget {
  const TariffEditorDialog({super.key, this.existing});
  final ConfirmedTariff? existing;

  @override
  State<TariffEditorDialog> createState() => _TariffEditorDialogState();
}

class _TariffEditorDialogState extends State<TariffEditorDialog> {
  late final _name = TextEditingController(text: widget.existing?.tariff.name ?? '');
  late final _base = TextEditingController(
      text: widget.existing?.tariff.baseFare.toString() ?? '');
  late final _included = TextEditingController(
      text: widget.existing?.tariff.baseDistanceKm.toString() ?? '');
  late final _waiting = TextEditingController(
      text: widget.existing?.tariff.waitingFeePerHour.toString() ?? '');
  late final _grace = TextEditingController(
      text: widget.existing?.tariff.waitingGraceMinutes.toString() ?? '5');
  late final List<_BandFields> _bands = [
    for (final tier in widget.existing?.tariff.effectiveFareTiers ??
        const [FareTier(upToKm: null, ratePerKm: 0)])
      _BandFields(upperKm: tier.upToKm,
          pricePerKm: tier.ratePerKm == 0 ? null : tier.ratePerKm),
  ];
  bool _confirmed = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose(); _base.dispose(); _included.dispose();
    _waiting.dispose(); _grace.dispose();
    for (final band in _bands) { band.dispose(); }
    super.dispose();
  }

  double number(TextEditingController controller, String field) {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value < 0) {
      throw FormatException('$field phải là số không âm hợp lệ');
    }
    return value;
  }

  void _addBand() {
    if (_bands.length >= 12) return;
    setState(() => _bands.add(_BandFields()));
  }

  void _deleteBand(int index) {
    if (_bands.length <= 1) return;
    setState(() => _bands.removeAt(index).dispose());
  }

  void _submit() {
    try {
      if (!_confirmed) {
        throw const FormatException('Phải xác nhận đã đối chiếu bảng giá');
      }
      final name = _name.text.trim();
      if (name.isEmpty) throw const FormatException('Cần nhập tên bảng giá');
      final base = number(_base, 'Phí mở cửa');
      final included = number(_included, 'Km mở cửa');
      final waiting = number(_waiting, 'Phí chờ theo giờ');
      final grace = number(_grace, 'Phút miễn phí chờ');
      final tiers = <FareTier>[];
      for (var i = 0; i < _bands.length; i++) {
        final last = i == _bands.length - 1;
        tiers.add(FareTier(
          upToKm: last ? null : number(_bands[i].cap, 'Km cuối bậc ${i + 1}'),
          ratePerKm: number(_bands[i].rate, 'Đơn giá bậc ${i + 1}'),
        ));
      }
      final threshold = tiers.first.upToKm ?? included;
      final tariff = TariffConfig(
        name: name,
        baseFare: base,
        baseDistanceKm: included,
        perKmRate: tiers.first.ratePerKm,
        longDistanceThresholdKm: threshold,
        longDistancePerKmRate: tiers.last.ratePerKm,
        waitingFeePerHour: waiting,
        waitingGraceMinutes: grace,
        fareTiers: tiers,
      );
      final saved = ConfirmedTariff(
        id: widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        tariff: tariff,
        confirmedAtUtc: DateTime.now().toUtc(),
      );
      saved.validate();
      Navigator.pop(context, saved);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('FormatException: ', ''));
    }
  }

  Widget _field(String label, TextEditingController c, {bool numeric = true}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.existing == null ? 'Thêm bảng giá' : 'Sửa bảng giá'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Tên bảng giá / hãng taxi', _name, numeric: false),
          _field('Phí mở cửa (đồng)', _base),
          _field('Số km trong phí mở cửa', _included),
          _field('Phí chờ (đồng/giờ)', _waiting),
          _field('Miễn phí chờ (phút)', _grace),
          const Text('Bậc giá theo km từ đầu chuyến',
              style: TextStyle(fontWeight: FontWeight.bold)),
          for (var i = 0; i < _bands.length; i++) ...[
            const SizedBox(height: 10),
            Text('Bậc ${i + 1}'),
            if (i != _bands.length - 1)
              _field('Đến km thứ (lũy kế)', _bands[i].cap)
            else
              const Text('Đến hết hành trình', style: TextStyle(fontSize: 12)),
            _field('Đơn giá (đồng/km)', _bands[i].rate),
            if (_bands.length > 1)
              TextButton(onPressed: () => _deleteBand(i),
                  child: const Text('Bỏ bậc này')),
          ],
          TextButton.icon(onPressed: _bands.length >= 12 ? null : _addBand,
              icon: const Icon(Icons.add),
              label: const Text('Thêm bậc giá')),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tôi đã đối chiếu và xác nhận bảng giá này'),
            value: _confirmed,
            onChanged: (value) =>
                setState(() => _confirmed = value ?? false),
          ),
          if (_error != null) Text(_error!,
              style: const TextStyle(color: Colors.orange)),
          const Text('Không áp dụng bảng giá mẫu khi dữ liệu trống.',
              style: TextStyle(fontSize: 12)),
        ],
      )),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context),
          child: const Text('Hủy')),
      FilledButton(onPressed: _submit, child: const Text('Xác nhận & lưu')),
    ],
  );
}
