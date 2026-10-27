// Utilitas format: tanggal (yyyy-MM-dd untuk database) dan rupiah (Rp 20.000).
import 'package:intl/intl.dart';

final _formatDb = DateFormat('yyyy-MM-dd');
final _formatRupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

/// DateTime -> '2026-10-20' (format yang disimpan di database).
String keTanggalDb(DateTime waktu) => _formatDb.format(waktu);

/// '2026-10-20' -> DateTime.
DateTime dariTanggalDb(String teks) => DateTime.parse(teks);

/// Tanggal hari ini dalam format database.
String hariIni() => keTanggalDb(DateTime.now());

/// '2026-10-20' -> 'Selasa, 20 Oktober 2026'.
/// Butuh initializeDateFormatting('id_ID') di main().
String tanggalPanjang(String tanggalDb) =>
    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dariTanggalDb(tanggalDb));

/// '2026-10-20' -> '20 Oktober 2026'.
String tanggalTanpaHari(String tanggalDb) =>
    DateFormat('d MMMM yyyy', 'id_ID').format(dariTanggalDb(tanggalDb));

/// '2026-10-20' -> 'Sel, 20 Okt'.
String tanggalPendek(String tanggalDb) =>
    DateFormat('EEE, d MMM', 'id_ID').format(dariTanggalDb(tanggalDb));

/// 20000 -> 'Rp 20.000'.
String rupiah(int nominal) => _formatRupiah.format(nominal);

/// Format akuntansi: angka negatif ditulis dalam kurung.
/// -25000 -> '(Rp 25.000)', 25000 -> 'Rp 25.000'.
String rupiahAkuntansi(int nominal) =>
    nominal < 0 ? '(${rupiah(-nominal)})' : rupiah(nominal);

/// (2026, 10) -> 'Oktober 2026'.
String namaBulan(int tahun, int bulan) =>
    DateFormat('MMMM yyyy', 'id_ID').format(DateTime(tahun, bulan));
