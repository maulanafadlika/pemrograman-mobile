import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 1',
      home: const CounterPage(),
      // Scaffold(
      //     appBar: AppBar(title: const Text('Hello Bebs')),
      //   //   body: const Center(
      //   //     child: Text('Halo, nama saya Mokh!', style: TextStyle(fontSize: 24)),
      //   //   ),
      //   // ),
      //     body: Center(
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: const [
      //           Icon(Icons.flutter_dash, size: 80, color: Colors.blue),
      //           SizedBox(height: 16),
      //           Text('Halo, nama saya Fadlika Maulana!', style: TextStyle(fontSize: 24)),
      //           Text('NIM: 20230801194'),
      //         ],
      //       ),
      //     ),
      //   )
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Saya')),
      backgroundColor: Colors.blue,
      body: Center(
        child: Text('$_count', style: const TextStyle(fontSize: 48)),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // tambah
          FloatingActionButton(
            onPressed: () => setState(() => _count++ ),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          // kurang
          FloatingActionButton(
            onPressed: () {
              if (_count > 0) setState(() => _count--);
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 12),
          // reset
          FloatingActionButton(
            onPressed: () => setState(() => _count = 0),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
