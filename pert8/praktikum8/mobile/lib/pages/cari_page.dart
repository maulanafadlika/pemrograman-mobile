// Halaman Cari: pencarian nama kegiatan (LIKE) + filter jenis & kategori (WHERE),
// mencakup semua tanggal.
import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';
import '../widgets/kegiatan_tile.dart';

class CariPage extends StatefulWidget {
  const CariPage({super.key});

  @override
  State<CariPage> createState() => _CariPageState();
}

class _CariPageState extends State<CariPage> {
  final _kataController = TextEditingController();
  Tipe? _tipe; // null = semua jenis
  String? _kategori; // null = semua kategori (hanya untuk pengeluaran)
  late Future<List<Kegiatan>> _future;

  @override
  void initState() {
    super.initState();
    _future = _ambil();
    versiData.addListener(_muat);
  }

  @override
  void dispose() {
    versiData.removeListener(_muat);
    _kataController.dispose();
    super.dispose();
  }

  Future<List<Kegiatan>> _ambil() => DbHelper.cari(
    kata: _kataController.text,
    tipe: _tipe,
    kategori: _kategori,
  );

  void _muat() {
    setState(() {
      _future = _ambil();
    });
  }

  void _pilihTipe(Tipe? tipe) {
    _tipe = tipe;
    if (tipe != Tipe.pengeluaran) _kategori = null; // kategori khusus keluar
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _kataController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari nama kegiatan…',
            border: InputBorder.none,
          ),
          onChanged: (_) => _muat(),
        ),
        actions: [
          if (_kataController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Hapus teks',
              onPressed: () {
                _kataController.clear();
                _muat();
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BarisChip(
            children: [
              ChoiceChip(
                label: const Text('Semua'),
                selected: _tipe == null,
                onSelected: (_) => _pilihTipe(null),
              ),
              for (final t in Tipe.values)
                ChoiceChip(
                  label: Text(t.label),
                  selected: _tipe == t,
                  onSelected: (_) => _pilihTipe(t),
                ),
            ],
          ),
          if (_tipe == Tipe.pengeluaran)
            _BarisChip(
              children: [
                ChoiceChip(
                  label: const Text('Semua kategori'),
                  selected: _kategori == null,
                  onSelected: (_) {
                    _kategori = null;
                    _muat();
                  },
                ),
                for (final k in daftarKategori)
                  ChoiceChip(
                    label: Text(k),
                    selected: _kategori == k,
                    onSelected: (_) {
                      _kategori = k;
                      _muat();
                    },
                  ),
              ],
            ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Kegiatan>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat data: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hasil = snapshot.data!;
                if (hasil.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'Tidak ada kegiatan yang cocok.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView(
                  children: [
                    _RingkasanHasil(hasil),
                    for (final k in hasil)
                      KegiatanTile(
                        key: ValueKey(k.id),
                        kegiatan: k,
                        tampilkanTanggal: true,
                        onSelesai: (nilai) =>
                            DbHelper.ubah(k.copyWith(selesai: nilai)),
                        onUbah: () =>
                            Navigator.pushNamed(context, '/form', arguments: k),
                        onHapus: () => hapusDenganKonfirmasi(context, k),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Deretan chip yang bisa digeser ke samping.
class _BarisChip extends StatelessWidget {
  final List<Widget> children;

  const _BarisChip({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          for (final c in children)
            Padding(padding: const EdgeInsets.only(right: 8), child: c),
        ],
      ),
    );
  }
}

/// Jumlah hasil + total uang dari hasil yang sedang tampil. Dihitung di Dart
/// karena datanya memang sudah dimuat untuk ditampilkan.
class _RingkasanHasil extends StatelessWidget {
  final List<Kegiatan> hasil;

  const _RingkasanHasil(this.hasil);

  @override
  Widget build(BuildContext context) {
    var masuk = 0;
    var keluar = 0;
    for (final k in hasil) {
      if (k.tipe == Tipe.pemasukan) masuk += k.nominal;
      if (k.tipe == Tipe.pengeluaran) keluar += k.nominal;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        [
          '${hasil.length} kegiatan',
          if (masuk > 0) '+${rupiah(masuk)}',
          if (keluar > 0) '-${rupiah(keluar)}',
        ].join(' · '),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
