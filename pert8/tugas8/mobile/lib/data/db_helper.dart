// Akses SQLite: CRUD tabel kegiatan, pencarian, dan query laporan
// (ringkasan, per kategori, per hari, bulanan).
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/kegiatan.dart';
import '../utils/format.dart';

/// Dinaikkan setiap tambah/ubah/hapus. Halaman yang menampilkan data
/// mendengarkannya (addListener) lalu memuat ulang datanya.
final versiData = ValueNotifier<int>(0);

class DbHelper {
  static Future<Database>? _db;

  static Future<Database> get _database => _db ??= _buka();

  static Future<Database> _buka() async {
    final lokasi = join(await getDatabasesPath(), 'tabungku.db');
    return openDatabase(
      lokasi,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE kegiatan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          judul TEXT NOT NULL,
          tanggal TEXT NOT NULL,
          selesai INTEGER NOT NULL DEFAULT 0,
          tipe TEXT NOT NULL,
          nominal INTEGER NOT NULL DEFAULT 0,
          kategori TEXT NOT NULL DEFAULT '-'
        )
      '''),
    );
  }

  static void _beritahu() => versiData.value++;

  static Future<int> tambah(Kegiatan kegiatan) async {
    final db = await _database;
    final id = await db.insert('kegiatan', kegiatan.toMap()..remove('id'));
    _beritahu();
    return id;
  }

  /// Semua kegiatan pada satu tanggal; yang belum selesai di atas.
  static Future<List<Kegiatan>> pada(String tanggal) async {
    final db = await _database;
    final hasil = await db.query(
      'kegiatan',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
      orderBy: 'selesai, id',
    );
    return hasil.map(Kegiatan.fromMap).toList();
  }

  static Future<void> ubah(Kegiatan kegiatan) async {
    final db = await _database;
    await db.update(
      'kegiatan',
      kegiatan.toMap(),
      where: 'id = ?',
      whereArgs: [kegiatan.id],
    );
    _beritahu();
  }

  static Future<void> hapus(int id) async {
    final db = await _database;
    await db.delete('kegiatan', where: 'id = ?', whereArgs: [id]);
    _beritahu();
  }

  /// Pencarian lintas tanggal: [kata] dicocokkan ke judul dengan LIKE,
  /// [tipe] dan [kategori] menjadi syarat WHERE tambahan bila diisi.
  /// Hasil terbaru di atas.
  static Future<List<Kegiatan>> cari({
    String kata = '',
    Tipe? tipe,
    String? kategori,
  }) async {
    final syarat = <String>[];
    final nilai = <Object>[];
    if (kata.trim().isNotEmpty) {
      syarat.add('judul LIKE ?');
      nilai.add('%${kata.trim()}%'); // % = cocok dengan teks apa saja
    }
    if (tipe != null) {
      syarat.add('tipe = ?');
      nilai.add(tipe.name);
    }
    if (kategori != null) {
      syarat.add('kategori = ?');
      nilai.add(kategori);
    }

    final db = await _database;
    final hasil = await db.query(
      'kegiatan',
      where: syarat.isEmpty ? null : syarat.join(' AND '),
      whereArgs: nilai.isEmpty ? null : nilai,
      orderBy: 'tanggal DESC, id DESC',
    );
    return hasil.map(Kegiatan.fromMap).toList();
  }

  // ---------- Query laporan ----------

  // Kolom ringkasan dipakai bersama oleh ringkasan() dan ringkasanPerHari().
  // CASE WHEN memilah pemasukan/pengeluaran; COALESCE mengganti NULL
  // (saat tidak ada data) dengan 0.
  static const _kolomRingkasan = '''
    COUNT(*) AS jumlah,
    COALESCE(SUM(selesai), 0) AS selesai,
    COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0) AS masuk,
    COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0) AS keluar
  ''';

  static Ringkasan _keRingkasan(Map<String, Object?> baris) => Ringkasan(
    jumlahKegiatan: baris['jumlah'] as int,
    selesai: baris['selesai'] as int,
    pemasukan: baris['masuk'] as int,
    pengeluaran: baris['keluar'] as int,
  );

  static Future<Ringkasan> ringkasan(String tanggal) async {
    final db = await _database;
    final hasil = await db.rawQuery(
      'SELECT $_kolomRingkasan FROM kegiatan WHERE tanggal = ?',
      [tanggal],
    );
    return _keRingkasan(hasil.first);
  }

  /// Total pengeluaran per kategori dari [dari] s.d. [sampai] (bawaan: satu
  /// hari saja), terbesar dulu. Tanggal yyyy-MM-dd bisa dibandingkan sebagai
  /// teks, jadi BETWEEN langsung bekerja.
  static Future<Map<String, int>> pengeluaranPerKategori(
    String dari, [
    String? sampai,
  ]) async {
    final db = await _database;
    final hasil = await db.rawQuery(
      '''
      SELECT kategori, SUM(nominal) AS total
      FROM kegiatan
      WHERE tanggal BETWEEN ? AND ? AND tipe = 'pengeluaran'
      GROUP BY kategori
      ORDER BY total DESC
    ''',
      [dari, sampai ?? dari],
    );
    return {for (final b in hasil) b['kategori'] as String: b['total'] as int};
  }

  /// Ringkasan setiap hari dari [dari] s.d. [sampai], urut dari yang terlama.
  /// Hari tanpa kegiatan tetap ada dengan nilai 0.
  static Future<Map<String, Ringkasan>> ringkasanPerHari(
    String dari,
    String sampai,
  ) async {
    final akhir = dariTanggalDb(sampai);
    final daftarTanggal = <String>[];
    for (
      var d = dariTanggalDb(dari);
      !d.isAfter(akhir);
      d = DateTime(d.year, d.month, d.day + 1)
    ) {
      daftarTanggal.add(keTanggalDb(d));
    }

    final db = await _database;
    final hasil = await db.rawQuery(
      '''
      SELECT tanggal, $_kolomRingkasan
      FROM kegiatan
      WHERE tanggal BETWEEN ? AND ?
      GROUP BY tanggal
    ''',
      [dari, sampai],
    );

    final perTanggal = {
      for (final b in hasil) b['tanggal'] as String: _keRingkasan(b),
    };
    return {
      for (final t in daftarTanggal) t: perTanggal[t] ?? Ringkasan.kosong,
    };
  }

  /// Ringkasan 7 hari yang berakhir di [sampai].
  static Future<Map<String, Ringkasan>> tujuhHari(String sampai) {
    final akhir = dariTanggalDb(sampai);
    final dari = DateTime(akhir.year, akhir.month, akhir.day - 6);
    return ringkasanPerHari(keTanggalDb(dari), sampai);
  }

  /// Laporan arus kas satu bulan (lihat class LaporanBulanan).
  static Future<LaporanBulanan> laporanBulanan(int tahun, int bulan) async {
    final dari = keTanggalDb(DateTime(tahun, bulan, 1));
    final sampai = keTanggalDb(DateTime(tahun, bulan + 1, 0)); // hari terakhir
    final db = await _database;

    // Saldo awal = akumulasi (pemasukan - pengeluaran) sebelum bulan ini.
    final saldo = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal
                               WHEN tipe = 'pengeluaran' THEN -nominal
                          END), 0) AS saldo
      FROM kegiatan
      WHERE tanggal < ?
    ''',
      [dari],
    );

    // Penerimaan dikelompokkan per sumber (judul kegiatan pemasukan).
    final masuk = await db.rawQuery(
      '''
      SELECT judul, SUM(nominal) AS total
      FROM kegiatan
      WHERE tanggal BETWEEN ? AND ? AND tipe = 'pemasukan'
      GROUP BY judul
      ORDER BY total DESC
    ''',
      [dari, sampai],
    );

    return LaporanBulanan(
      tahun: tahun,
      bulan: bulan,
      saldoAwal: saldo.first['saldo'] as int,
      pemasukanPerSumber: {
        for (final b in masuk) b['judul'] as String: b['total'] as int,
      },
      pengeluaranPerKategori: await pengeluaranPerKategori(dari, sampai),
      perHari: await ringkasanPerHari(dari, sampai),
    );
  }
}
