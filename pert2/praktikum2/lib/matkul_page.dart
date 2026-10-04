import 'package:flutter/material.dart';

class MataKuliah {
  final String nama;
  final int sks;
  final String deskripsi;

  const MataKuliah(this.nama, this.sks, this.deskripsi);

  int get biaya => sks * 150000;
}

const daftarMatkul = [
  MataKuliah('Pemrograman Mobile', 3, 'Membuat aplikasi mobile menggunakan Flutter dan Dart.'),
  MataKuliah('Basis Data', 3, 'Merancang dan mengelola database relasional dengan SQL.'),
  MataKuliah('Pendidikan Karakter Unggul', 8, 'Pembentukan karakter, etika dan belajar menjadi orang baik.'),
  MataKuliah('Seminar Proposal', 2, 'Menyusun dan mempresentasikan proposal tugas akhir.'),
  MataKuliah('Pemrograman Web', 3, 'Membangun aplikasi web dengan HTML, CSS, dan framework backend.'),
  MataKuliah('Pemrograman Berorientasi Objek', 3, 'Konsep class, object, inheritance, dan polymorphism.'),
  MataKuliah('Kalkulus 2', 3, 'Integral, deret, dan penerapannya.'),
  MataKuliah('Matematika Diskrit', 3, 'Logika, himpunan, relasi, graf, dan kombinatorika.'),
  MataKuliah('Algoritma dan Pemrograman', 3, 'Dasar logika pemrograman dan penyusunan algoritma.'),
  MataKuliah('Sistem Operasi', 3, 'Manajemen proses, memori, dan file pada sistem operasi.'),
  MataKuliah('Bahasa Inggris 1', 2, 'Kemampuan dasar membaca dan menulis bahasa Inggris.'),
];

String formatRibuan(int angka) {
  final s = angka.toString();
  final hasil = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    hasil.write(s[i]);
    final sisa = s.length - i - 1;
    if (sisa > 0 && sisa % 3 == 0) {
      hasil.write('.');
    }
  }
  return hasil.toString();
}

class MatkulPage extends StatelessWidget {
  const MatkulPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Mata Kuliah')),
      body: ListView.builder(
        itemCount: daftarMatkul.length,
        itemBuilder: (context, index) {
          final item = daftarMatkul[index];
          return Container (
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.school),
              title: Text(item.nama),
              subtitle: Text('${item.sks} SKS • Rp ${formatRibuan(item.biaya)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailMatkulPage(matkul: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailMatkulPage extends StatelessWidget {
  final MataKuliah matkul;

  const DetailMatkulPage({super.key, required this.matkul});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(matkul.nama)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 80),
            const SizedBox(height: 16),
            Text(matkul.nama, style: const TextStyle(fontSize: 24)),
            Text('${matkul.sks} SKS'),
            Text('Rp ${formatRibuan(matkul.biaya)}'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(matkul.deskripsi, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
