// Laporan bulanan: laporan arus kas (format akuntansi) + grafik batang harian.
import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';
import 'grafik_batang.dart';

class LaporanBulananView extends StatefulWidget {
  /// Dipanggil saat batang grafik diketuk (membuka laporan harian tanggal itu).
  final ValueChanged<String> onPilihTanggal;

  const LaporanBulananView({super.key, required this.onPilihTanggal});

  @override
  State<LaporanBulananView> createState() => _LaporanBulananViewState();
}

class _LaporanBulananViewState extends State<LaporanBulananView> {
  int _tahun = DateTime.now().year;
  int _bulan = DateTime.now().month;
  late Future<LaporanBulanan> _future;

  @override
  void initState() {
    super.initState();
    _future = DbHelper.laporanBulanan(_tahun, _bulan);
    versiData.addListener(_muat);
  }

  @override
  void dispose() {
    versiData.removeListener(_muat);
    super.dispose();
  }

  void _muat() {
    setState(() {
      _future = DbHelper.laporanBulanan(_tahun, _bulan);
    });
  }

  void _geserBulan(int arah) {
    final d = DateTime(_tahun, _bulan + arah); // DateTime merapikan bulan 13/0
    _tahun = d.year;
    _bulan = d.month;
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LaporanBulanan>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final lap = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Bulan sebelumnya',
                    onPressed: () => _geserBulan(-1),
                  ),
                  Expanded(
                    child: Text(
                      namaBulan(_tahun, _bulan),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Bulan berikutnya',
                    onPressed: () => _geserBulan(1),
                  ),
                ],
              ),
            ),
            _LaporanArusKas(lap),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Surplus/defisit harian',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    GrafikBatang(
                      perHari: lap.perHari,
                      onPilih: widget.onPilihTanggal,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hijau = surplus, merah = defisit. '
                      'Ketuk batang untuk melihat laporan hari itu.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Laporan arus kas dengan kaidah penyajian akuntansi:
/// kepala 3 baris, kolom rincian & kolom total, angka negatif dalam kurung,
/// garis tunggal sebelum subtotal, garis ganda di bawah saldo akhir.
class _LaporanArusKas extends StatelessWidget {
  final LaporanBulanan lap;

  const _LaporanArusKas(this.lap);

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final awalBulan = keTanggalDb(DateTime(lap.tahun, lap.bulan, 1));
    final akhirBulan = keTanggalDb(DateTime(lap.tahun, lap.bulan + 1, 0));
    final tglAwal = tanggalTanpaHari(awalBulan);
    final tglAkhir = tanggalTanpaHari(akhirBulan);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kepala laporan: entitas, nama laporan, periode.
            Text(
              'TabungKu',
              textAlign: TextAlign.center,
              style: teks.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Laporan Arus Kas Pribadi',
              textAlign: TextAlign.center,
              style: teks.titleSmall,
            ),
            Text(
              'Untuk Bulan yang Berakhir $tglAkhir',
              textAlign: TextAlign.center,
              style: teks.bodySmall,
            ),
            const Divider(height: 24),
            _BarisAkun(
              'Saldo awal per $tglAwal',
              total: lap.saldoAwal,
              tebal: true,
            ),
            const SizedBox(height: 12),
            const _BarisAkun('Penerimaan kas', tebal: true),
            if (lap.pemasukanPerSumber.isEmpty)
              const _BarisAkun('Tidak ada penerimaan', menjorok: true),
            for (final e in lap.pemasukanPerSumber.entries)
              _BarisAkun(e.key, rincian: e.value, menjorok: true),
            _BarisAkun(
              'Jumlah penerimaan',
              total: lap.totalPemasukan,
              menjorok: true,
              garisAtasRincian: lap.pemasukanPerSumber.isNotEmpty,
            ),
            const SizedBox(height: 12),
            const _BarisAkun('Pengeluaran kas', tebal: true),
            if (lap.pengeluaranPerKategori.isEmpty)
              const _BarisAkun('Tidak ada pengeluaran', menjorok: true),
            for (final e in lap.pengeluaranPerKategori.entries)
              _BarisAkun(e.key, rincian: e.value, menjorok: true),
            _BarisAkun(
              'Jumlah pengeluaran',
              total: -lap.totalPengeluaran, // pengurang -> dalam kurung
              menjorok: true,
              garisAtasRincian: lap.pengeluaranPerKategori.isNotEmpty,
            ),
            const SizedBox(height: 12),
            _BarisAkun(
              lap.surplus < 0 ? 'Defisit bulan ini' : 'Surplus bulan ini',
              total: lap.surplus,
              tebal: true,
              garisAtasTotal: true,
            ),
            _BarisAkun(
              'Saldo akhir per $tglAkhir',
              total: lap.saldoAkhir,
              tebal: true,
              garisGanda: true,
            ),
            const Divider(height: 28),
            Text('Catatan atas laporan', style: teks.labelLarge),
            const SizedBox(height: 4),
            Text(
              '1. Dicatat dari ${lap.jumlahKegiatan} kegiatan pada periode ini, '
              'termasuk yang belum selesai (sesuai aturan bisnis).\n'
              '2. Angka dalam kurung ( ) adalah pengurang atau defisit.\n'
              '3. Saldo awal = akumulasi tabungan sebelum $tglAwal.'
              '${lap.totalPemasukan > 0 ? '\n4. Rasio menabung: ${(lap.surplus * 100 / lap.totalPemasukan).round()}% dari penerimaan.' : ''}',
              style: teks.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu baris laporan: label | kolom rincian | kolom total.
class _BarisAkun extends StatelessWidget {
  final String label;
  final int? rincian;
  final int? total;
  final bool tebal;
  final bool menjorok;
  final bool garisAtasRincian; // garis di bawah rincian terakhir
  final bool garisAtasTotal; // garis tunggal sebelum total
  final bool garisGanda; // garis ganda di bawah angka akhir

  const _BarisAkun(
    this.label, {
    this.rincian,
    this.total,
    this.tebal = false,
    this.menjorok = false,
    this.garisAtasRincian = false,
    this.garisAtasTotal = false,
    this.garisGanda = false,
  });

  static const _lebarKolom = 92.0;

  @override
  Widget build(BuildContext context) {
    final dasar = Theme.of(context).textTheme.bodySmall;
    final gaya = tebal ? dasar?.copyWith(fontWeight: FontWeight.bold) : dasar;
    final warnaGaris = Theme.of(context).colorScheme.onSurface;

    Widget angka(int? nilai, {bool garisAtas = false, bool ganda = false}) {
      final sel = Container(
        width: _lebarKolom,
        padding: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          border: Border(
            top: garisAtas ? BorderSide(color: warnaGaris) : BorderSide.none,
            bottom: ganda ? BorderSide(color: warnaGaris) : BorderSide.none,
          ),
        ),
        child: Text(
          nilai == null ? '' : rupiahAkuntansi(nilai),
          textAlign: TextAlign.right,
          style: gaya?.copyWith(color: (nilai ?? 0) < 0 ? Colors.red : null),
        ),
      );
      if (!ganda) return sel;
      // Garis kedua di bawah garis pertama -> garis ganda.
      return Column(
        children: [
          sel,
          const SizedBox(height: 2),
          Container(width: _lebarKolom, height: 1, color: warnaGaris),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: menjorok ? 12 : 0, top: 1, bottom: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(label, style: gaya)),
          const SizedBox(width: 8),
          angka(rincian, garisAtas: garisAtasRincian),
          const SizedBox(width: 8),
          angka(total, garisAtas: garisAtasTotal, ganda: garisGanda),
        ],
      ),
    );
  }
}
