import 'package:flutter/material.dart';

class Kontak {
  final String nama;
  final String telepon;
  final String email;

  const Kontak(this.nama, this.telepon, this.email);
}

const daftarKontak = [
  Kontak('Andi Pratama', '0812-3456-7890', 'andi@gmail.com'),
  Kontak('Budi Santoso', '0813-1111-2222', 'budi@gmail.com'),
  Kontak('Citra Lestari', '0857-3333-4444', 'citra@gmail.com'),
  Kontak('Dewi Anggraini', '0821-5555-6666', 'dewi@gmail.com'),
  Kontak('Eko Saputra', '0896-7777-8888', 'eko@gmail.com'),
  Kontak('Fajar Nugraha', '0819-9999-0000', 'fajar@gmail.com'),
];

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Kontak',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const KontakPage(),
    );
  }
}

class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kontak')),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final kontak = daftarKontak[index];
          return ListTile(
            leading: CircleAvatar(child: Text(kontak.nama[0])),
            title: Text(kontak.nama),
            subtitle: Text(kontak.telepon),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailKontakPage(kontak: kontak)),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailKontakPage extends StatelessWidget {
  final Kontak kontak;

  const DetailKontakPage({super.key, required this.kontak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kontak.nama)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(kontak.nama[0], style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Nama'),
            subtitle: Text(kontak.nama),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Telepon'),
            subtitle: Text(kontak.telepon),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(kontak.email),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }
}