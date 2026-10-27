// Halaman Pengaturan: slider target, saklar mode gelap, pilihan warna tema.
import 'package:flutter/material.dart';

import '../state/pengaturan.dart';
import '../utils/format.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  // Nilai slider selama digeser; baru disimpan saat jari dilepas
  // agar shared_preferences tidak ditulis puluhan kali.
  double? _targetDigeser;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListenableBuilder(
        listenable: Listenable.merge([modeGelap, warnaTema, targetTabungan]),
        builder: (context, _) {
          final target = _targetDigeser ?? targetTabungan.value.toDouble();

          return ListView(
            children: [
              const _JudulBagian('Tampilan'),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Mode gelap'),
                value: modeGelap.value,
                onChanged: (nilai) => modeGelap.value = nilai,
              ),
              const ListTile(
                leading: Icon(Icons.palette_outlined),
                title: Text('Warna tema'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final warna in pilihanWarna)
                      _BulatanWarna(
                        warna: warna,
                        dipilih: warna == warnaTema.value,
                        onTap: () => warnaTema.value = warna,
                      ),
                  ],
                ),
              ),
              const Divider(height: 32),
              const _JudulBagian('Menabung'),
              ListTile(
                leading: const Icon(Icons.savings_outlined),
                title: const Text('Target tabungan harian'),
                trailing: Text(
                  rupiah(target.round()),
                  style: teks.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Slider(
                value: target,
                min: targetMin.toDouble(),
                max: targetMaks.toDouble(),
                divisions: (targetMaks - targetMin) ~/ 5000,
                label: rupiah(target.round()),
                onChanged: (nilai) => setState(() => _targetDigeser = nilai),
                onChangeEnd: (nilai) {
                  targetTabungan.value = nilai.round();
                  setState(() => _targetDigeser = null);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Kartu ringkasan membandingkan tabungan harian '
                  'dengan target ini.',
                  style: teks.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _JudulBagian extends StatelessWidget {
  final String teks;

  const _JudulBagian(this.teks);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        teks,
        style: tema.textTheme.labelLarge?.copyWith(
          color: tema.colorScheme.primary,
        ),
      ),
    );
  }
}

class _BulatanWarna extends StatelessWidget {
  final Color warna;
  final bool dipilih;
  final VoidCallback onTap;

  const _BulatanWarna({
    required this.warna,
    required this.dipilih,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: warna,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: dipilih ? 3 : 0,
            style: dipilih ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: dipilih ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
