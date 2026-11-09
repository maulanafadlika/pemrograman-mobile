import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/health_service.dart';

class StatusServerPage extends StatefulWidget {
  const StatusServerPage({super.key});

  @override
  State<StatusServerPage> createState() => _StatusServerPageState();
}

class _StatusServerPageState extends State<StatusServerPage> {
  late Future<StatusServer> _future;

  @override
  void initState() {
    super.initState();
    _future = cekServer();
  }

  void _periksaLagi() {
    setState(() {
      _future = cekServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Server')),
      body: FutureBuilder<StatusServer>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final s = snapshot.data;
          final apiHidup = !snapshot.hasError && s != null;
          // null = tidak diketahui (API tidak bisa dihubungi).
          final bool? dbHidup = apiHidup ? s.databaseHidup : null;

          final String ringkasan;
          if (!apiHidup) {
            ringkasan = 'Server tidak dapat dihubungi';
          } else if (dbHidup!) {
            ringkasan = 'Semua layanan normal';
          } else {
            ringkasan = 'API hidup, database mati';
          }

          final pesan = snapshot.hasError ? '${snapshot.error}' : s?.detail;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                ringkasan,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _BarisStatus(
                label: 'API',
                hidup: apiHidup,
                keterangan: apiHidup
                    ? 'Terhubung (${s.latensi.inMilliseconds} ms)'
                    : 'Tidak dapat dihubungi',
              ),
              _BarisStatus(
                label: 'Database',
                hidup: dbHidup,
                keterangan: dbHidup == null
                    ? 'Tidak diketahui (API tidak terhubung)'
                    : dbHidup
                    ? 'Terhubung, MySQL ${s!.mysqlVersion ?? '-'}'
                    : 'Tidak dapat dihubungi',
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Alamat API'),
                subtitle: Text(apiUrl.value),
              ),
              if (apiHidup)
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Waktu server'),
                  subtitle: Text(s.waktuServer),
                ),
              if (pesan != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    pesan,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: FilledButton.icon(
                  onPressed: _periksaLagi,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Periksa lagi'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BarisStatus extends StatelessWidget {
  final String label;
  final bool? hidup;
  final String keterangan;

  const _BarisStatus({
    required this.label,
    required this.hidup,
    required this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    final (ikon, warna) = switch (hidup) {
      true => (Icons.check_circle, Colors.green),
      false => (Icons.cancel, Colors.red),
      null => (Icons.help_outline, Colors.grey),
    };
    return Card(
      child: ListTile(
        leading: Icon(ikon, color: warna, size: 32),
        title: Text(label),
        subtitle: Text(keterangan),
      ),
    );
  }
}