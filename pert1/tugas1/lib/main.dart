import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Tugas 1',
      debugShowCheckedModeBanner: false,
      home: KartuPage(),
    );
  }
}

class KartuPage extends StatelessWidget {
  const KartuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kartu Perkenalan')),
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.account_box_outlined, size: 100, color: Colors.white),
            SizedBox(height: 48),
            Text('Mokhamad Fadlika Maulana', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            Text('NIM: 20230801194', style: TextStyle(fontSize: 20, color: Colors.white)),
            SizedBox(height: 4),
            Text('Jurusan: Teknik Informatika', style: TextStyle(fontSize: 20, color: Colors.white)),
            SizedBox(height: 4),
            Text('Hobi: Mengaji', style: TextStyle(fontSize: 50, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}