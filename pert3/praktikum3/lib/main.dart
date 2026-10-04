// import 'package:flutter/material.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Praktikum 3',
//       theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
//       home: const FormPage(),
//     );
//   }
// }
//
// class InputPage extends StatefulWidget {
//   const InputPage({super.key});
//
//   @override
//   State<InputPage> createState() => _InputPageState();
// }
//
// class _InputPageState extends State<InputPage> {
//   final _controller = TextEditingController();
//   String _salam = '';
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Input Dasar')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: const InputDecoration(
//                 labelText: 'Nama',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() => _salam = 'Halo, ${_controller.text}!');
//               },
//               child: const Text('Sapa'),
//             ),
//             const SizedBox(height: 12),
//             Text(_salam, style: const TextStyle(fontSize: 20)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class FormPage extends StatefulWidget {
//   const FormPage({super.key});
//
//   @override
//   State<FormPage> createState() => _FormPageState();
// }
//
// class _FormPageState extends State<FormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nama = TextEditingController();
//   final _email = TextEditingController();
//   String? _jurusan;
//   bool _setuju = false;
//
//   @override
//   void dispose() {
//     _nama.dispose();
//     _email.dispose();
//     super.dispose();
//   }
//
//   void _kirim() {
//     if (_formKey.currentState!.validate()) {
//       final jurusan = _jurusan ?? '-';
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Terdaftar: ${_nama.text} ($jurusan)')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Form Pendaftaran')),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//           TextFormField(
//           controller: _nama,
//           decoration: const InputDecoration(
//             labelText: 'Nama lengkap',
//             border: OutlineInputBorder(),
//           ),
//           validator: (v) =>
//           (v == null || v
//               .trim()
//               .isEmpty) ? 'Nama wajib diisi' : null,
//         ),
//         const SizedBox(height: 12),
//         TextFormField(
//           controller: _email,
//           keyboardType: TextInputType.emailAddress,
//           decoration: const InputDecoration(
//             labelText: 'Email',
//             border: OutlineInputBorder(),
//           ),
//           validator: (v) {
//             if (v == null || !v.contains('@')) return 'Email tidak valid';
//             return null;
//           },
//         ),
//         const SizedBox(height: 12),
//         DropdownButtonFormField<String>(
//             decoration: const InputDecoration(
//               labelText: 'Jurusan',
//               border: OutlineInputBorder(),
//             ),
//             items: const [
//               DropdownMenuItem(value: 'TI', child: Text('Teknik Informatika')),
//               DropdownMenuItem(value: 'SI', child: Text('Sistem Informasi')),
//               DropdownMenuItem(value: 'TE', child: Text('Teknik Elektro')),
//             ],
//             onChanged: (v) => setState(() => _jurusan = v),
//         validator: (v) => v == null ? 'Pilih jurusan' : null,
//       ),
//       CheckboxListTile(
//         title: const Text('Saya menyetujui ketentuan'),
//         value: _setuju,
//         controlAffinity: ListTileControlAffinity.leading,
//         onChanged: (v) => setState(() => _setuju = v ?? false),
//       ),
//       ElevatedButton(
//         onPressed: _setuju ? _kirim : null,
//         child: const Text('Daftar'),
//       ),
//       ],
//     ),)
//     ,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Tugas {
  String judul;
  bool selesai;

  Tugas(this.judul, {this.selesai = false});
}

class TugasModel extends ChangeNotifier {
  final List<Tugas> _items = [];

  List<Tugas> get items => List.unmodifiable(_items);

  int get jumlahSelesai =>
      _items
          .where((t) => t.selesai)
          .length;

  void tambah(String judul) {
    _items.add(Tugas(judul));
    notifyListeners();
  }

  void toggle(int index) {
    _items[index].selesai = !_items[index].selesai;
    notifyListeners();
  }

  void hapus(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void hapusSelesai() {
    _items.removeWhere((t) => t.selesai);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => TugasModel(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Tugas',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const TugasPage(),
    );
  }
}

class TugasPage extends StatelessWidget {
  const TugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TugasModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Tugas (${model.jumlahSelesai}/${model.items.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus yang selesai',
            onPressed: () => context.read<TugasModel>().hapusSelesai(),
          ),
        ],
      ),
      body: model.items.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
        itemCount: model.items.length,
        itemBuilder: (context, i) {
          final t = model.items[i];
          return ListTile(
            leading: Checkbox(
              value: t.selesai,
              onChanged: (_) => context.read<TugasModel>().toggle(i),
            ),
            title: Text(
              t.judul,
              style: TextStyle(
                decoration: t.selesai ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => context.read<TugasModel>().hapus(i),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TambahPage extends StatefulWidget {
  const TambahPage({super.key});

  @override
  State<TambahPage> createState() => _TambahPageState();
}

// class _TambahPageState extends State<TambahPage> {
//   final _controller = TextEditingController();
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _simpan() {
//     final judul = _controller.text.trim();
//     if (judul.isEmpty) return;
//     context.read<TugasModel>().tambah(judul);
//     Navigator.pop(context);
//   }

class _TambahPageState extends State<TambahPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    context.read<TugasModel>().tambah(_controller.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas ditambahkan')), // Latihan 3
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Judul tugas',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v
                      .trim()
                      .length < 3) {
                    return 'Judul minimal 3 karakter';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _simpan(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(title: const Text('Tambah Tugas')),
//     body: Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           TextField(
//             controller: _controller,
//             autofocus: true,
//             decoration: const InputDecoration(
//               labelText: 'Judul tugas',
//               border: OutlineInputBorder(),
//             ),
//             onSubmitted: (_) => _simpan(),
//           ),
//           const SizedBox(height: 12),
//           ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
//         ],
//       ),
//     ),
//   );
// }}
