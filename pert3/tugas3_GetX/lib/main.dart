import 'package:flutter/material.dart';

// Model data transaksi
class Transaksi {
  final String judul;
  final String tanggal;
  final String nominal;
  final bool masuk; // true = pemasukan, false = penarikan

  const Transaksi(this.judul, this.tanggal, this.nominal, this.masuk);
}

// Data transaksi statis (hard-coded)
const daftarTransaksi = [
  Transaksi('Setoran awal', '01 Nov 2026', 'Rp 1.000.000', true),
  Transaksi('Menabung mingguan', '05 Nov 2026', 'Rp 250.000', true),
  Transaksi('Tarik untuk beli buku', '07 Nov 2026', 'Rp 150.000', false),
  Transaksi('Menabung mingguan', '12 Nov 2026', 'Rp 250.000', true),
];

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TabungKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const RingkasanPage(),
    );
  }
}

class RingkasanPage extends StatelessWidget {
  const RingkasanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan judul halaman
      appBar: AppBar(title: const Text('Ringkasan Tabungan')),
      // ListView agar halaman bisa digulir sehingga tidak overflow
      // pada layar pendek atau saat ponsel diputar (landscape)
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bagian 1: kartu ringkasan tabungan
          _kartuTabungan(),
          const SizedBox(height: 16),

          // Bagian 2: baris tombol kategori
          _barisKategori(),
          const SizedBox(height: 24),

          // Bagian 3: judul dan daftar transaksi
          const Text(
            'Transaksi Terakhir',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final t in daftarTransaksi) _itemTransaksi(t),
        ],
      ),
    );
  }

  // Kartu berisi nama tabungan, saldo, dan target (Card > Column > Row)
  Widget _kartuTabungan() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris ikon + nama tabungan
            const Row(
              children: [
                Icon(Icons.savings, color: Colors.teal),
                SizedBox(width: 8),
                // Expanded agar nama panjang turun ke baris baru, tidak overflow
                Expanded(
                  child: Text(
                    'Tabungan Pendidikan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Saldo saat ini
            const Text('Saldo', style: TextStyle(color: Colors.grey)),
            const Text(
              'Rp 1.350.000',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Baris target: label di kiri, nominal di kanan
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Target', style: TextStyle(color: Colors.grey)),
                Text(
                  'Rp 5.000.000',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Baris berisi tiga tombol kategori dengan lebar sama (Expanded)
  Widget _barisKategori() {
    return Row(
      children: [
        Expanded(child: _tombolKategori(Icons.add_circle, 'Menabung')),
        const SizedBox(width: 12),
        Expanded(child: _tombolKategori(Icons.remove_circle, 'Tarik')),
        const SizedBox(width: 12),
        Expanded(child: _tombolKategori(Icons.history, 'Riwayat')),
      ],
    );
  }

  // Satu tombol kategori: Container berwarna berisi ikon dan label
  Widget _tombolKategori(IconData ikon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(ikon, color: Colors.teal),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }

  // Satu item transaksi: judul, tanggal, dan nominal
  Widget _itemTransaksi(Transaksi t) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(t.masuk ? Icons.arrow_downward : Icons.arrow_upward),
        ),
        title: Text(t.judul),
        subtitle: Text(t.tanggal),
        trailing: Text(
          '${t.masuk ? '+' : '-'} ${t.nominal}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: t.masuk ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}