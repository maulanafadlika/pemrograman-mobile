// Satu baris kegiatan: checkbox selesai, judul, nominal, tombol hapus.
import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

/// Dialog konfirmasi lalu hapus. Dipakai halaman Hari Ini dan Cari.
Future<void> hapusDenganKonfirmasi(
  BuildContext context,
  Kegiatan kegiatan,
) async {
  final yakin = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus kegiatan?'),
      content: Text('"${kegiatan.judul}" akan dihapus permanen.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (yakin != true) return;

  await DbHelper.hapus(kegiatan.id!);
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('"${kegiatan.judul}" dihapus')));
}

class KegiatanTile extends StatelessWidget {
  final Kegiatan kegiatan;
  final ValueChanged<bool> onSelesai;
  final VoidCallback onUbah;
  final VoidCallback onHapus;
  final bool tampilkanTanggal; // untuk daftar lintas tanggal (hasil cari)

  const KegiatanTile({
    super.key,
    required this.kegiatan,
    required this.onSelesai,
    required this.onUbah,
    required this.onHapus,
    this.tampilkanTanggal = false,
  });

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final k = kegiatan;

    return ListTile(
      leading: Checkbox(
        value: k.selesai,
        onChanged: (nilai) => onSelesai(nilai ?? false),
      ),
      title: Text(
        k.judul,
        style: k.selesai
            ? const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              )
            : null,
      ),
      subtitle: Text(
        [
          // Di hasil cari tanggal lebih penting; jenis sudah terlihat dari
          // tanda +/- dan warna nominal, jadi labelnya tidak diulang.
          if (tampilkanTanggal) tanggalPendek(k.tanggal) else k.tipe.label,
          if (k.tipe == Tipe.pengeluaran) k.kategori,
        ].join(' · '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (k.tipe != Tipe.tanpa)
            Text(
              '${k.tipe == Tipe.pemasukan ? '+' : '-'}${rupiah(k.nominal)}',
              style: teks.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: k.tipe == Tipe.pemasukan ? Colors.green : Colors.red,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus',
            onPressed: onHapus,
          ),
        ],
      ),
      onTap: onUbah,
    );
  }
}
