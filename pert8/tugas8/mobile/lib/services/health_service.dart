import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

enum KondisiServer { sehat, databaseMati }

class StatusServer {
  final KondisiServer kondisi;
  final String waktuServer;
  final String? mysqlVersion;
  final String? detail;
  final Duration latensi;

  const StatusServer({
    required this.kondisi,
    required this.waktuServer,
    required this.mysqlVersion,
    required this.detail,
    required this.latensi,
  });

  bool get databaseHidup => kondisi == KondisiServer.sehat;
}

/// Memanggil GET /health.
/// - 200 → API dan database hidup.
/// - 503 → API hidup, database mati (bukan galat jaringan).
/// - kode lain / gagal terhubung → melempar Exception (API dianggap mati).
Future<StatusServer> cekServer({http.Client? client, String? baseUrl}) async {
  final c = client ?? http.Client();
  final url = baseUrl ?? apiUrl.value;
  final jam = Stopwatch()..start();
  try {
    final res = await c.get(Uri.parse('$url/health')).timeout(batasWaktu);
    jam.stop();
    if (res.statusCode != 200 && res.statusCode != 503) {
      throw Exception('Server membalas kode ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return StatusServer(
      kondisi: res.statusCode == 200
          ? KondisiServer.sehat
          : KondisiServer.databaseMati,
      waktuServer: data['waktu_server'] as String? ?? '-',
      mysqlVersion: data['mysql_version'] as String?,
      detail: data['detail'] as String?,
      latensi: jam.elapsed,
    );
  } finally {
    if (client == null) c.close();
  }
}