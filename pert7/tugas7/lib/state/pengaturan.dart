// Pengaturan aplikasi: mode gelap, warna tema, target tabungan (shared_preferences).
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const targetBawaan = 20000;
const targetMin = 5000;
const targetMaks = 100000;

const pilihanWarna = <Color>[
  Colors.teal,
  Colors.indigo,
  Colors.deepOrange,
  Colors.pink,
  Colors.purple,
];

final modeGelap = ValueNotifier<bool>(false);
final warnaTema = ValueNotifier<Color>(pilihanWarna.first);
final targetTabungan = ValueNotifier<int>(targetBawaan);

/// Dipanggil sekali di main() sebelum runApp: muat nilai tersimpan,
/// lalu simpan otomatis setiap kali nilainya berubah.
Future<void> muatPengaturan() async {
  final prefs = await SharedPreferences.getInstance();

  modeGelap.value = prefs.getBool('gelap') ?? false;
  final idxWarna = prefs.getInt('warna') ?? 0;
  warnaTema.value = pilihanWarna[idxWarna.clamp(0, pilihanWarna.length - 1)];
  targetTabungan.value = (prefs.getInt('target') ?? targetBawaan).clamp(
    targetMin,
    targetMaks,
  );

  modeGelap.addListener(() {
    prefs.setBool('gelap', modeGelap.value);
  });
  warnaTema.addListener(() {
    prefs.setInt('warna', pilihanWarna.indexOf(warnaTema.value));
  });
  targetTabungan.addListener(() {
    prefs.setInt('target', targetTabungan.value);
  });
}

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
  );
}
