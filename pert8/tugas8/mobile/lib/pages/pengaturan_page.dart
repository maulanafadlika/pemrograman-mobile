// Halaman Pengaturan: slider target, saklar mode gelap, pilihan warna tema,
// alamat API, dan status server.
import 'package:flutter/material.dart';

import '../config/api_config.dart';
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

  Future<void> _ubahAlamatApi() async {
    final kontrol = TextEditingController(text: apiUrl.value);
    final kunciForm = GlobalKey<FormState>();

    final hasil = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alamat API'),
        content: Form(
          key: kunciForm,
          child: TextFormField(
            controller: kontrol,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              hintText: 'http://10.0.2.2:8001',
              helperText: 'HP fisik: http://IP-LAPTOP:8001',
            ),
            validator: validasiUrl,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, apiUrlBawaan),
            child: const Text('Bawaan'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (kunciForm.currentState!.validate()) {
                Navigator.pop(context, kontrol.text);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (hasil != null) {
      await simpanApiUrl(hasil);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alamat API disimpan: ${apiUrl.value}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListenableBuilder(
        listenable: Listenable.merge(
          [modeGelap, warnaTema, targetTabungan, apiUrl],
        ),
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
              const Divider(height: 32),
              const _JudulBagian('Server'),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Alamat API'),
                subtitle: Text(apiUrl.value),
                trailing: const Icon(Icons.edit_outlined),
                onTap: _ubahAlamatApi,
              ),
              ListTile(
                leading: const Icon(Icons.dns),
                title: const Text('Status server'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/status'),
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