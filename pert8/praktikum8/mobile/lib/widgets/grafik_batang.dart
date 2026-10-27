// Grafik batang tabungan harian (tanpa paket): batang naik = surplus (hijau),
// batang turun = defisit (merah), dipisah garis nol.
import 'package:flutter/material.dart';

import '../models/kegiatan.dart';
import '../utils/format.dart';

class GrafikBatang extends StatelessWidget {
  final Map<String, Ringkasan> perHari;
  final ValueChanged<String>? onPilih;

  const GrafikBatang({super.key, required this.perHari, this.onPilih});

  static const _tinggiSisi = 70.0; // tinggi maksimum di atas/bawah garis nol

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    final teksKecil = Theme.of(context).textTheme.labelSmall;
    final maks = perHari.values.fold(
      0,
      (m, r) => r.tabungan.abs() > m ? r.tabungan.abs() : m,
    );

    if (maks == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Belum ada transaksi pada bulan ini.')),
      );
    }

    // Batang tumbuh dari 0 setiap kali data (bulan) berganti.
    return TweenAnimationBuilder<double>(
      key: ValueKey(perHari.keys.first),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skala: ${rupiah(maks)}', style: teksKecil),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in perHari.entries)
                Expanded(
                  child: GestureDetector(
                    onTap: onPilih == null ? null : () => onPilih!(e.key),
                    child: _Batang(
                      tabungan: e.value.tabungan,
                      porsi: e.value.tabungan.abs() / maks * t,
                      hari: dariTanggalDb(e.key).day,
                      warnaGaris: skema.outline,
                      gayaLabel: teksKecil,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Batang extends StatelessWidget {
  final int tabungan;
  final double porsi; // 0..1
  final int hari;
  final Color warnaGaris;
  final TextStyle? gayaLabel;

  const _Batang({
    required this.tabungan,
    required this.porsi,
    required this.hari,
    required this.warnaGaris,
    required this.gayaLabel,
  });

  @override
  Widget build(BuildContext context) {
    const tinggi = GrafikBatang._tinggiSisi;
    final tampilkanLabel = hari == 1 || hari % 5 == 0;

    return Column(
      children: [
        SizedBox(
          height: tinggi,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _isi(tabungan > 0 ? porsi * tinggi : 0, Colors.green),
          ),
        ),
        Container(height: 1, color: warnaGaris), // garis nol
        SizedBox(
          height: tinggi,
          child: Align(
            alignment: Alignment.topCenter,
            child: _isi(tabungan < 0 ? porsi * tinggi : 0, Colors.red),
          ),
        ),
        const SizedBox(height: 4),
        // Kolom batang terlalu sempit untuk angka 2 digit; OverflowBox
        // membiarkan label melebar ke kiri-kanan tanpa terlipat.
        SizedBox(
          height: 16,
          child: OverflowBox(
            maxWidth: 24,
            child: Text(
              tampilkanLabel ? '$hari' : '',
              textAlign: TextAlign.center,
              style: gayaLabel,
            ),
          ),
        ),
      ],
    );
  }

  Widget _isi(double tinggi, Color warna) => Container(
    height: tinggi,
    margin: const EdgeInsets.symmetric(horizontal: 1),
    decoration: BoxDecoration(
      color: warna,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
