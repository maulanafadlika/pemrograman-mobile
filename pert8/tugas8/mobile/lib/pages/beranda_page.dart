// Halaman Hari Ini: kartu ringkasan + daftar kegiatan hari ini + tombol tambah.
import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';
import '../widgets/kegiatan_tile.dart';
import '../widgets/ringkasan_card.dart';

class _DataHari {
  final List<Kegiatan> daftar;
  final Ringkasan ringkasan;

  const _DataHari(this.daftar, this.ringkasan);
}

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late Future<_DataHari> _future;

  @override
  void initState() {
    super.initState();
    _future = _ambil();
    versiData.addListener(_muat);
  }

  @override
  void dispose() {
    versiData.removeListener(_muat);
    super.dispose();
  }

  Future<_DataHari> _ambil() async {
    final tgl = hariIni();
    return _DataHari(await DbHelper.pada(tgl), await DbHelper.ringkasan(tgl));
  }

  void _muat() {
    setState(() {
      _future = _ambil(); // Future baru -> FutureBuilder memuat ulang
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hari Ini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari kegiatan',
            onPressed: () => Navigator.pushNamed(context, '/cari'),
          ),
        ],
      ),
      body: FutureBuilder<_DataHari>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final daftar = snapshot.data!.daftar;
          return ListView(
            padding: const EdgeInsets.only(bottom: 88), // ruang untuk FAB
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  tanggalPanjang(hariIni()),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              RingkasanCard(ringkasan: snapshot.data!.ringkasan),
              if (daftar.isEmpty)
                const _KondisiKosong()
              else
                for (final k in daftar)
                  KegiatanTile(
                    key: ValueKey(k.id),
                    kegiatan: k,
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
    );
  }
}

class _KondisiKosong extends StatelessWidget {
  const _KondisiKosong();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        children: [
          Icon(Icons.checklist, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Belum ada kegiatan hari ini.\nTekan tombol + untuk menambah.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
