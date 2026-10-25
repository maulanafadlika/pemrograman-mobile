// Halaman Laporan: mode Harian (pilih tanggal, ringkasan, per kategori, 7 hari)
// dan mode Bulanan (laporan arus kas + grafik batang).
import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';
import '../widgets/laporan_bulanan.dart';
import '../widgets/ringkasan_card.dart';

class _DataLaporan {
  final Ringkasan ringkasan;
  final Map<String, int> perKategori;
  final Map<String, Ringkasan> tujuhHari;

  const _DataLaporan(this.ringkasan, this.perKategori, this.tujuhHari);
}

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String _tanggal = hariIni();
  bool _bulanan = false;
  late Future<_DataLaporan> _future;

  @override
  void initState() {
    super.initState();
    _future = _ambil();
    versiData.addListener(_muat);
  }

  @override
  void dispose() {
    versiData.removeListener(_muat);
    super.dispose();
  }

  Future<_DataLaporan> _ambil() async {
    final t = _tanggal;
    return _DataLaporan(
      await DbHelper.ringkasan(t),
      await DbHelper.pengeluaranPerKategori(t),
      await DbHelper.tujuhHari(t),
    );
  }

  void _muat() {
    setState(() {
      _future = _ambil();
    });
  }

  void _gantiTanggal(String tanggal) {
    _tanggal = tanggal;
    _muat();
  }

  void _geser(int hari) {
    final d = dariTanggalDb(_tanggal);
    _gantiTanggal(keTanggalDb(DateTime(d.year, d.month, d.day + hari)));
  }

  Future<void> _pilihTanggal() async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: dariTanggalDb(_tanggal),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (dipilih != null) _gantiTanggal(keTanggalDb(dipilih));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Harian'),
                    icon: Icon(Icons.today),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Bulanan'),
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
                selected: {_bulanan},
                onSelectionChanged: (pilihan) =>
                    setState(() => _bulanan = pilihan.first),
              ),
            ),
          ),
          Expanded(
            child: _bulanan
                ? LaporanBulananView(
                    onPilihTanggal: (tanggal) {
                      _bulanan = false;
                      _gantiTanggal(tanggal);
                    },
                  )
                : _laporanHarian(),
          ),
        ],
      ),
    );
  }

  Widget _laporanHarian() {
    return FutureBuilder<_DataLaporan>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Hari sebelumnya',
                    onPressed: () => _geser(-1),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _pilihTanggal,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(tanggalPanjang(_tanggal)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Hari berikutnya',
                    onPressed: () => _geser(1),
                  ),
                ],
              ),
            ),
            RingkasanCard(ringkasan: data.ringkasan, judul: 'Tabungan'),
            const _JudulBagian('Pengeluaran per kategori'),
            if (data.perKategori.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Tidak ada pengeluaran pada tanggal ini.'),
              )
            else
              for (final e in data.perKategori.entries)
                _BarisKategori(
                  kategori: e.key,
                  total: e.value,
                  porsi: e.value / data.ringkasan.pengeluaran,
                ),
            const _JudulBagian('7 hari terakhir'),
            for (final e in data.tujuhHari.entries)
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                selected: e.key == _tanggal,
                title: Text(tanggalPendek(e.key)),
                // Hari tanpa kegiatan ditandai '–' agar mudah dibedakan
                // dari hari yang tabungannya tepat Rp 0.
                trailing: Text(
                  e.value.jumlahKegiatan == 0 ? '–' : rupiah(e.value.tabungan),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: e.value.tabungan < 0 ? Colors.red : null,
                  ),
                ),
                onTap: () => _gantiTanggal(e.key),
              ),
          ],
        );
      },
    );
  }
}

class _JudulBagian extends StatelessWidget {
  final String teks;

  const _JudulBagian(this.teks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(teks, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _BarisKategori extends StatelessWidget {
  final String kategori;
  final int total;
  final double porsi; // 0..1 terhadap total pengeluaran

  const _BarisKategori({
    required this.kategori,
    required this.total,
    required this.porsi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(kategori)),
              Text(
                rupiah(total),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: porsi,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
