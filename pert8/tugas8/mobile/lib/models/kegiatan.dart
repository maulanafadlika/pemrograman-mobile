// Model data: enum Tipe, class Kegiatan (toMap/fromMap), class Ringkasan.

enum Tipe {
  tanpa('Tidak'),
  pemasukan('Pemasukan'),
  pengeluaran('Pengeluaran');

  const Tipe(this.label);

  final String label;
}

const daftarKategori = ['Makan', 'Transport', 'Belajar', 'Hiburan', 'Lainnya'];

class Kegiatan {
  final int? id;
  final String judul;
  final String tanggal; // yyyy-MM-dd
  final bool selesai;
  final Tipe tipe;
  final int nominal; // 0 bila tipe tanpa
  final String kategori; // '-' bila bukan pengeluaran

  const Kegiatan({
    this.id,
    required this.judul,
    required this.tanggal,
    this.selesai = false,
    this.tipe = Tipe.tanpa,
    this.nominal = 0,
    this.kategori = '-',
  });

  Kegiatan copyWith({
    int? id,
    String? judul,
    String? tanggal,
    bool? selesai,
    Tipe? tipe,
    int? nominal,
    String? kategori,
  }) {
    return Kegiatan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      tanggal: tanggal ?? this.tanggal,
      selesai: selesai ?? this.selesai,
      tipe: tipe ?? this.tipe,
      nominal: nominal ?? this.nominal,
      kategori: kategori ?? this.kategori,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'judul': judul,
    'tanggal': tanggal,
    'selesai': selesai ? 1 : 0,
    'tipe': tipe.name,
    'nominal': nominal,
    'kategori': kategori,
  };

  factory Kegiatan.fromMap(Map<String, Object?> m) => Kegiatan(
    id: m['id'] as int,
    judul: m['judul'] as String,
    tanggal: m['tanggal'] as String,
    selesai: (m['selesai'] as int) == 1,
    tipe: Tipe.values.byName(m['tipe'] as String),
    nominal: m['nominal'] as int,
    kategori: m['kategori'] as String,
  );
}

class Ringkasan {
  final int jumlahKegiatan;
  final int selesai;
  final int pemasukan;
  final int pengeluaran;

  const Ringkasan({
    required this.jumlahKegiatan,
    required this.selesai,
    required this.pemasukan,
    required this.pengeluaran,
  });

  static const kosong = Ringkasan(
    jumlahKegiatan: 0,
    selesai: 0,
    pemasukan: 0,
    pengeluaran: 0,
  );

  int get tabungan => pemasukan - pengeluaran;
}

/// Laporan arus kas satu bulan:
/// saldo awal + penerimaan - pengeluaran = saldo akhir.
class LaporanBulanan {
  final int tahun;
  final int bulan;
  final int saldoAwal;
  final Map<String, int> pemasukanPerSumber;
  final Map<String, int> pengeluaranPerKategori;
  final Map<String, Ringkasan> perHari;

  const LaporanBulanan({
    required this.tahun,
    required this.bulan,
    required this.saldoAwal,
    required this.pemasukanPerSumber,
    required this.pengeluaranPerKategori,
    required this.perHari,
  });

  int get totalPemasukan =>
      pemasukanPerSumber.values.fold(0, (jumlah, n) => jumlah + n);

  int get totalPengeluaran =>
      pengeluaranPerKategori.values.fold(0, (jumlah, n) => jumlah + n);

  int get surplus => totalPemasukan - totalPengeluaran;

  int get saldoAkhir => saldoAwal + surplus;

  int get jumlahKegiatan =>
      perHari.values.fold(0, (jumlah, r) => jumlah + r.jumlahKegiatan);
}
