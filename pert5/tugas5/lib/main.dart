import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() => runApp(const MyApp());

const kategoriList = [
  'Makanan',
  'Transportasi',
  'Hiburan',
  'Belanja',
  'Lainnya',
];

String formatRupiah(int nilai) {
  final s = nilai.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final posDariKanan = s.length - i;
    buf.write(s[i]);
    if (posDariKanan > 1 && posDariKanan % 3 == 1) buf.write('.');
  }
  return 'Rp $buf';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatat Pengeluaran',
      home: const PengeluaranPage(),
    );
  }
}

class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;

  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'nama': nama,
    'jumlah': jumlah,
    'kategori': kategori,
    'tanggal': tanggal,
  };

  factory Pengeluaran.fromMap(Map<String, Object?> m) => Pengeluaran(
    id: m['id'] as int,
    nama: m['nama'] as String,
    jumlah: m['jumlah'] as int,
    kategori: m['kategori'] as String,
    tanggal: m['tanggal'] as String,
  );
}

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'pengeluaran.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pengeluaran('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'nama TEXT NOT NULL, '
          'jumlah INTEGER NOT NULL, '
          'kategori TEXT NOT NULL, '
          'tanggal TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }

  static Future<int> tambah(Pengeluaran p) async {
    final db = await database;
    return db.insert('pengeluaran', p.toMap());
  }

  static Future<List<Pengeluaran>> semua({String kategori = 'Semua'}) async {
    final db = await database;
    final rows = await db.query(
      'pengeluaran',
      where: kategori == 'Semua' ? null : 'kategori = ?',
      whereArgs: kategori == 'Semua' ? null : [kategori],
      orderBy: 'tanggal DESC, id DESC',
    );
    return rows.map(Pengeluaran.fromMap).toList();
  }

  static Future<int> totalSemua({String kategori = 'Semua'}) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT SUM(jumlah) as total FROM pengeluaran '
      '${kategori == 'Semua' ? '' : 'WHERE kategori = ?'}',
      kategori == 'Semua' ? [] : [kategori],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  static Future<int> ubah(Pengeluaran p) async {
    final db = await database;
    return db.update(
      'pengeluaran',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    return db.delete('pengeluaran', where: 'id = ?', whereArgs: [id]);
  }
}

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  late Future<List<Pengeluaran>> _future;
  int _total = 0;
  String _filterKategori = 'Semua';

  @override
  void initState() {
    super.initState();
    _future = DbHelper.semua();
    _muatFilterTersimpan();
  }

  Future<void> _muatFilterTersimpan() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _filterKategori = prefs.getString('filterKategori') ?? 'Semua';
    });
    _muat();
  }

  Future<void> _ubahFilter(String? nilai) async {
    if (nilai == null) return;
    setState(() => _filterKategori = nilai);
    _muat();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('filterKategori', nilai);
  }

  void _muat() {
    setState(() {
      _future = DbHelper.semua(kategori: _filterKategori);
    });
    DbHelper.totalSemua(kategori: _filterKategori).then((t) {
      if (!mounted) return;
      setState(() => _total = t);
    });
  }

  Future<void> _buka([Pengeluaran? item]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormPengeluaranPage(pengeluaran: item)),
    );
    if (!mounted) return;
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencatat Pengeluaran')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _filterKategori == 'Semua'
                      ? 'Total pengeluaran'
                      : 'Total ($_filterKategori)',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  formatRupiah(_total),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<String>(
              key: ValueKey(_filterKategori),
              initialValue: _filterKategori,
              decoration: const InputDecoration(
                labelText: 'Filter kategori',
                border: OutlineInputBorder(),
              ),
              items: [
                'Semua',
                ...kategoriList,
              ].map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
              onChanged: _ubahFilter,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pengeluaran>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Galat: ${snapshot.error}'));
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text('Belum ada pengeluaran'));
                }
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final item = data[i];
                    return ListTile(
                      title: Text(item.nama),
                      subtitle: Text('${item.kategori} • ${item.tanggal}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(formatRupiah(item.jumlah)),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final yakin = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hapus pengeluaran ini?'),
                                  content: Text(item.nama),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                              if (yakin != true) return;
                              await DbHelper.hapus(item.id!);
                              if (!mounted) return;
                              _muat();
                            },
                          ),
                        ],
                      ),
                      onTap: () => _buka(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormPengeluaranPage extends StatefulWidget {
  final Pengeluaran? pengeluaran;

  const FormPengeluaranPage({super.key, this.pengeluaran});

  @override
  State<FormPengeluaranPage> createState() => _FormPengeluaranPageState();
}

class _FormPengeluaranPageState extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _jumlah;
  late String _kategori;
  late DateTime _tanggal;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.pengeluaran?.nama ?? '');
    _jumlah = TextEditingController(
      text: widget.pengeluaran != null
          ? widget.pengeluaran!.jumlah.toString()
          : '',
    );
    _kategori = widget.pengeluaran?.kategori ?? kategoriList.first;
    _tanggal = widget.pengeluaran != null
        ? DateTime.parse(widget.pengeluaran!.tanggal)
        : DateTime.now();
  }

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (hasil == null) return;
    setState(() => _tanggal = hasil);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final item = Pengeluaran(
      id: widget.pengeluaran?.id,
      nama: _nama.text.trim(),
      jumlah: int.parse(_jumlah.text.trim()),
      kategori: _kategori,
      tanggal: _tanggal.toIso8601String().substring(0, 10),
    );
    if (widget.pengeluaran == null) {
      await DbHelper.tambah(item);
    } else {
      await DbHelper.ubah(item);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.pengeluaran == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(baru ? 'Pengeluaran Baru' : 'Ubah Pengeluaran'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama pengeluaran',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Jumlah wajib diisi';
                final n = int.tryParse(v.trim());
                if (n == null) return 'Jumlah harus berupa angka';
                if (n <= 0) return 'Jumlah harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: kategoriList
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _kategori = v);
              },
              validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal'),
              subtitle: Text(_tanggal.toIso8601String().substring(0, 10)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pilihTanggal,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
