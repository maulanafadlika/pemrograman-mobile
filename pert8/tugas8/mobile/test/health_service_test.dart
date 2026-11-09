import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tabungku/services/health_service.dart';

const _url = 'http://uji.local';

void main() {
  test('200: API dan database sehat', () async {
    final client = MockClient((req) async {
      expect(req.url.path, '/health');
      return http.Response(
        jsonEncode({
          'status': 'ok',
          'waktu_server': '2026-11-09T14:52:35',
          'database': 'ok',
          'mysql_version': '8.4.13',
        }),
        200,
      );
    });

    final s = await cekServer(client: client, baseUrl: _url);
    expect(s.kondisi, KondisiServer.sehat);
    expect(s.databaseHidup, isTrue);
    expect(s.mysqlVersion, '8.4.13');
  });

  test('503: API hidup, database mati (bukan galat jaringan)', () async {
    final client = MockClient((req) async {
      return http.Response(
        jsonEncode({
          'status': 'degraded',
          'waktu_server': '2026-11-09T14:53:07',
          'database': 'error',
          'mysql_version': null,
          'detail': "Can't connect to MySQL server on 'mysql'",
        }),
        503,
      );
    });

    final s = await cekServer(client: client, baseUrl: _url);
    expect(s.kondisi, KondisiServer.databaseMati);
    expect(s.databaseHidup, isFalse);
    expect(s.detail, contains('MySQL'));
  });

  test('kode lain (500): dianggap galat', () async {
    final client = MockClient((req) async {
      return http.Response('Internal Server Error', 500);
    });

    expect(
      cekServer(client: client, baseUrl: _url),
      throwsA(isA<Exception>()),
    );
  });
}