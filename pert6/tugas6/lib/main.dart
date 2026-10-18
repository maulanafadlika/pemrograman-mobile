import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const profilNama = 'Fadlika';
const profilNim = '20230801194';
const profilJurusan = 'Teknik Informatika';
const profilBio = 'Mahasiswa yang suka mengaji.';

class Skill {
  final String nama;
  final double level; // 0.0 - 1.0
  const Skill(this.nama, this.level);
}

const daftarSkill = [
  Skill('Laravel', 0.85),
  Skill('React', 0.70),
  Skill('NestJS', 0.60),
  Skill('Flutter', 0.60),
];

class Proyek {
  final String judul;
  final String kategori;
  final String deskripsi;
  final IconData ikon;
  final List<String> teknologi;

  const Proyek({
    required this.judul,
    required this.kategori,
    required this.deskripsi,
    required this.ikon,
    required this.teknologi,
  });
}

const daftarProyek = [
  Proyek(
    judul: 'Bank Sampah',
    kategori: 'Web',
    deskripsi:
    'Aplikasi manajemen bank sampah: setoran sampah, saldo nasabah, dan laporan.',
    ikon: Icons.recycling,
    teknologi: ['Laravel', 'Livewire', 'MySQL'],
  ),
  Proyek(
    judul: 'REST API Produk',
    kategori: 'Backend',
    deskripsi: 'API CRUD produk dengan panel admin Filament di dalam Docker.',
    ikon: Icons.api,
    teknologi: ['Laravel', 'Filament', 'Docker'],
  ),
  Proyek(
    judul: 'Dashboard Web',
    kategori: 'Web',
    deskripsi: 'Dashboard admin dengan frontend React dan backend NestJS.',
    ikon: Icons.dashboard,
    teknologi: ['React', 'NestJS'],
  ),
  Proyek(
    judul: 'Iron Track',
    kategori: 'Mobile',
    deskripsi: 'Aplikasi mobile pelacakan siklus menstruasi, pemantauan anemia, dan konsultasi AI kesehatan..',
    ikon: Icons.bloodtype,
    teknologi: ['Flutter', 'Provider'],
  ),
  Proyek(
    judul: 'Catatan Saya',
    kategori: 'Mobile',
    deskripsi: 'Aplikasi catatan offline dengan database SQLite.',
    ikon: Icons.note_alt,
    teknologi: ['Flutter', 'sqflite'],
  ),
];

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);
const pilihanWarna = <Color>[
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Muat pilihan tema terakhir
  final gelap = prefs.getBool('gelap') ?? false;
  final idxWarna = prefs.getInt('warna') ?? 0;
  themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light;
  seedColor.value = pilihanWarna[idxWarna];

  // Simpan otomatis setiap kali berubah
  themeMode.addListener(() {
    prefs.setBool('gelap', themeMode.value == ThemeMode.dark);
  });
  seedColor.addListener(() {
    prefs.setInt('warna', pilihanWarna.indexOf(seedColor.value));
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Profil Saya',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {'/': (_) => const ShellPage()},
          onGenerateRoute: (settings) {
            if (settings.name == '/proyek') {
              final proyek = settings.arguments as Proyek;
              return MaterialPageRoute(
                builder: (_) => DetailProyekPage(proyek: proyek),
                settings: settings,
              );
            }
            return null;
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('404')),
              body: Center(
                child: Text(
                  '404 - Halaman tidak ditemukan\n${settings.name}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _halaman = [ProfilTab(), ProyekTab(), PengaturanTab()];
  static const _judul = ['Profil', 'Proyek', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Proyek',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class ProfilTab extends StatefulWidget {
  const ProfilTab({super.key});

  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _denyut;
  late final Animation<double> _skala;

  @override
  void initState() {
    super.initState();
    _denyut = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _skala = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _denyut, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _denyut.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ScaleTransition(
            scale: _skala,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: warna.primaryContainer,
              child: Icon(
                Icons.person,
                size: 56,
                color: warna.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profilNama,
          textAlign: TextAlign.center,
          style: tema.textTheme.headlineSmall,
        ),
        Text(
          '$profilNim • $profilJurusan',
          textAlign: TextAlign.center,
          style: tema.textTheme.bodyMedium?.copyWith(
            color: warna.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          profilBio,
          textAlign: TextAlign.center,
          style: tema.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text('Keahlian', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final s in daftarSkill) BarSkill(skill: s),
      ],
    );
  }
}

class BarSkill extends StatelessWidget {
  final Skill skill;

  const BarSkill({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: skill.level),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOut,
        builder: (context, nilai, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(skill.nama, style: tema.textTheme.bodyLarge),
                  const Spacer(),
                  Text(
                    '${(nilai * 100).round()}%',
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: nilai,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProyekTab extends StatefulWidget {
  const ProyekTab({super.key});

  @override
  State<ProyekTab> createState() => _ProyekTabState();
}

class _ProyekTabState extends State<ProyekTab> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    final kategori = [
      'Semua',
      ...{for (final p in daftarProyek) p.kategori},
    ];
    final data = _filter == 'Semua'
        ? daftarProyek
        : daftarProyek.where((p) => p.kategori == _filter).toList();

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final k in kategori)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(k),
                    selected: _filter == k,
                    onSelected: (_) => setState(() => _filter = k),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ListView.builder(
              key: ValueKey(_filter),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: data.length,
              itemBuilder: (context, i) {
                final p = data[i];
                return Card(
                  child: ListTile(
                    leading: Hero(
                      tag: 'proyek-${p.judul}',
                      child: CircleAvatar(
                        backgroundColor: warna.primaryContainer,
                        child: Icon(p.ikon, color: warna.onPrimaryContainer),
                      ),
                    ),
                    title: Text(p.judul),
                    subtitle: Text(p.kategori),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/proyek', arguments: p);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DetailProyekPage extends StatelessWidget {
  final Proyek proyek;

  const DetailProyekPage({super.key, required this.proyek});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(proyek.judul)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Hero(
              tag: 'proyek-${proyek.judul}',
              child: CircleAvatar(
                radius: 56,
                backgroundColor: warna.primaryContainer,
                child: Icon(
                  proyek.ikon,
                  size: 56,
                  color: warna.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            proyek.judul,
            textAlign: TextAlign.center,
            style: tema.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Center(child: Chip(label: Text(proyek.kategori))),
          const SizedBox(height: 16),
          Text(proyek.deskripsi, style: tema.textTheme.bodyLarge),
          const SizedBox(height: 24),
          Text('Teknologi', style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in proyek.teknologi) Chip(label: Text(t)),
            ],
          ),
        ],
      ),
    );
  }
}

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        final tema = Theme.of(context);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (v) {
                themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            const SizedBox(height: 8),
            Text('Warna tema', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                for (final c in pilihanWarna)
                  GestureDetector(
                    onTap: () => seedColor.value = c,
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: seedColor.value == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Pilihan tema tersimpan otomatis.',
              style: tema.textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}