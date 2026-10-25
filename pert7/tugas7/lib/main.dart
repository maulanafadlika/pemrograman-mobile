import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/cari_page.dart';
import 'pages/form_kegiatan_page.dart';
import 'pages/shell_page.dart';
import 'state/pengaturan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID'); // nama hari/bulan bahasa Indonesia
  await muatPengaturan();
  runApp(const TabungKuApp());
}

class TabungKuApp extends StatelessWidget {
  const TabungKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([modeGelap, warnaTema]),
      builder: (context, _) {
        return MaterialApp(
          title: 'TabungKu',
          debugShowCheckedModeBanner: false,
          theme: buatTema(warnaTema.value, Brightness.light),
          darkTheme: buatTema(warnaTema.value, Brightness.dark),
          themeMode: modeGelap.value ? ThemeMode.dark : ThemeMode.light,
          // Teks bawaan Material (date picker, tooltip, dll.) berbahasa Indonesia.
          locale: const Locale('id', 'ID'),
          supportedLocales: const [Locale('id', 'ID')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          initialRoute: '/',
          routes: {
            '/': (context) => const ShellPage(),
            '/form': (context) => const FormKegiatanPage(),
            '/cari': (context) => const CariPage(),
          },
        );
      },
    );
  }
}
