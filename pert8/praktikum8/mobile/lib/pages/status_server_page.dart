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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<StatusServer>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }

              final terhubung = !snapshot.hasError && snapshot.hasData;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    terhubung ? Icons.cloud_done : Icons.cloud_off,
                    size: 80,
                    color: terhubung ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    terhubung ? 'Server terhubung' : 'Server tidak terhubung',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Alamat API: $apiUrl'),
                  if (terhubung) ...[
                    Text('Waktu server: ${snapshot.data!.waktuServer}'),
                    Text('Latensi: ${snapshot.data!.latensi.inMilliseconds} ms'),
                  ] else
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _periksaLagi,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Periksa lagi'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}