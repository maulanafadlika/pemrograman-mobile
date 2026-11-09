// Kartu ringkasan harian + progress target tabungan beranimasi.
import 'package:flutter/material.dart';

import '../models/kegiatan.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';

class RingkasanCard extends StatelessWidget {
  final Ringkasan ringkasan;
  final String judul;

  const RingkasanCard({
    super.key,
    required this.ringkasan,
    this.judul = 'Tabungan hari ini',
  });

  @override
  Widget build(BuildContext context) {
    final r = ringkasan;
    final teks = Theme.of(context).textTheme;
    final minus = r.tabungan < 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(judul, style: teks.labelLarge),
            const SizedBox(height: 4),
            Text(
              rupiah(r.tabungan),
              style: teks.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: minus
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            if (minus) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pengeluaran melebihi pemasukan. Yuk, lebih hemat!',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            ValueListenableBuilder<int>(
              valueListenable: targetTabungan,
              builder: (context, target, _) =>
                  _ProgresTarget(tabungan: r.tabungan, target: target),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _Angka(
                    label: 'Pemasukan',
                    nilai: rupiah(r.pemasukan),
                    warna: Colors.green,
                  ),
                ),
                Expanded(
                  child: _Angka(
                    label: 'Pengeluaran',
                    nilai: rupiah(r.pengeluaran),
                    warna: Colors.red,
                  ),
                ),
                Expanded(
                  child: _Angka(
                    label: 'Selesai',
                    nilai: '${r.selesai}/${r.jumlahKegiatan}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Angka extends StatelessWidget {
  final String label;
  final String nilai;
  final Color? warna;

  const _Angka({required this.label, required this.nilai, this.warna});

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: teks.bodySmall),
        const SizedBox(height: 2),
        Text(
          nilai,
          style: teks.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: warna,
          ),
        ),
      ],
    );
  }
}

class _ProgresTarget extends StatelessWidget {
  final int tabungan;
  final int target;

  const _ProgresTarget({required this.tabungan, required this.target});

  @override
  Widget build(BuildContext context) {
    final porsi = (tabungan / target).clamp(0.0, 1.0);
    final tercapai = tabungan >= target;
    final teks = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Batang bergerak halus dari nilai lama ke nilai baru.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: porsi),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, nilai, _) => LinearProgressIndicator(
            value: nilai,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
            color: tercapai ? Colors.green : null,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          // Bawaan AnimatedSwitcher menaruh anak di tengah; di sini rata kiri.
          layoutBuilder: (sekarang, sebelumnya) => Stack(
            alignment: Alignment.centerLeft,
            // ?sekarang = masukkan ke list hanya bila tidak null.
            children: [...sebelumnya, ?sekarang],
          ),
          child: tercapai
              ? Text(
                  'Target ${rupiah(target)} tercapai. Hebat, pertahankan! 🎉',
                  key: const ValueKey('tercapai'),
                  style: teks.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  '${(porsi * 100).round()}% dari target ${rupiah(target)}',
                  key: const ValueKey('belum'),
                  style: teks.bodySmall,
                ),
        ),
      ],
    );
  }
}
