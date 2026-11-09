import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Alamat bawaan. `10.0.2.2` = localhost laptop dari emulator Android.
/// Bisa diganti saat build: --dart-define=API_URL=http://192.168.1.10:8001
const apiUrlBawaan = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8001',
);

/// Batas waktu tunggu setiap permintaan ke server.
const batasWaktu = Duration(seconds: 10);

const _kunciApiUrl = 'api_url';

/// Alamat API yang sedang dipakai; berubah bila diatur di Pengaturan.
final apiUrl = ValueNotifier<String>(apiUrlBawaan);

/// Dipanggil sekali di main() sebelum runApp.
Future<void> muatApiUrl() async {
  final prefs = await SharedPreferences.getInstance();
  apiUrl.value = prefs.getString(_kunciApiUrl) ?? apiUrlBawaan;
}

/// Menyimpan alamat baru (tanpa garis miring di akhir).
Future<void> simpanApiUrl(String url) async {
  final bersih = url.trim().replaceAll(RegExp(r'/+$'), '');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kunciApiUrl, bersih);
  apiUrl.value = bersih;
}

/// Validasi format URL untuk TextFormField.
String? validasiUrl(String? nilai) {
  final teks = nilai?.trim() ?? '';
  if (teks.isEmpty) return 'Alamat wajib diisi';
  final uri = Uri.tryParse(teks);
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    return 'Format: http://host:port, misalnya http://10.0.2.2:8001';
  }
  return null;
}