// Form tambah/ubah kegiatan: nama, tanggal, jenis keuangan, nominal, kategori.
// Mode ubah bila route menerima argumen Kegiatan.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

class FormKegiatanPage extends StatefulWidget {
  const FormKegiatanPage({super.key});

  @override
  State<FormKegiatanPage> createState() => _FormKegiatanPageState();
}

class _FormKegiatanPageState extends State<FormKegiatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _nominalController = TextEditingController();

  Kegiatan? _lama; // null = mode tambah
  String _tanggal = hariIni();
  Tipe _tipe = Tipe.tanpa;
  String? _kategori;
  bool _sudahDibaca = false;
  bool _menyimpan = false;
  // Setelah gagal simpan pertama, pesan galat diperbarui setiap input berubah.
  AutovalidateMode _autoValidasi = AutovalidateMode.disabled;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Argumen route baru bisa dibaca di sini (bukan di initState).
    if (_sudahDibaca) return;
    _sudahDibaca = true;

    final k = ModalRoute.of(context)?.settings.arguments as Kegiatan?;
    if (k == null) return;
    _lama = k;
    _judulController.text = k.judul;
    _tanggal = k.tanggal;
    _tipe = k.tipe;
    if (k.tipe != Tipe.tanpa) _nominalController.text = '${k.nominal}';
    if (k.tipe == Tipe.pengeluaran) _kategori = k.kategori;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: dariTanggalDb(_tanggal),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (dipilih != null) {
      setState(() => _tanggal = keTanggalDb(dipilih));
    }
  }

  String? _validasiNominal(String? nilai) {
    final teks = nilai?.trim() ?? '';
    if (teks.isEmpty) return 'Nominal wajib diisi';
    final angka = int.tryParse(teks);
    if (angka == null || angka <= 0) return 'Nominal harus lebih dari 0';
    return null;
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autoValidasi = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() => _menyimpan = true);

    // Field yang tidak relevan untuk jenisnya disimpan sebagai 0 / '-'.
    final kegiatan = Kegiatan(
      id: _lama?.id,
      judul: _judulController.text.trim(),
      tanggal: _tanggal,
      selesai: _lama?.selesai ?? false,
      tipe: _tipe,
      nominal: _tipe == Tipe.tanpa ? 0 : int.parse(_nominalController.text),
      kategori: _tipe == Tipe.pengeluaran ? _kategori! : '-',
    );

    if (_lama == null) {
      await DbHelper.tambah(kegiatan);
    } else {
      await DbHelper.ubah(kegiatan);
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _lama == null ? 'Kegiatan ditambahkan' : 'Kegiatan diubah',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_lama == null ? 'Tambah Kegiatan' : 'Ubah Kegiatan'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _autoValidasi,
        // ListView agar form tidak tertutup keyboard.
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Nama kegiatan',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (nilai) => (nilai == null || nilai.trim().isEmpty)
                  ? 'Nama kegiatan wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pilihTanggal,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(tanggalPanjang(_tanggal)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Jenis keuangan',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<Tipe>(
              segments: const [
                ButtonSegment(value: Tipe.tanpa, label: Text('Tidak')),
                ButtonSegment(value: Tipe.pemasukan, label: Text('Masuk')),
                ButtonSegment(value: Tipe.pengeluaran, label: Text('Keluar')),
              ],
              selected: {_tipe},
              onSelectionChanged: (pilihan) =>
                  setState(() => _tipe = pilihan.first),
            ),
            if (_tipe != Tipe.tanpa) ...[
              const SizedBox(height: 24),
              TextFormField(
                controller: _nominalController,
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validasiNominal,
              ),
            ],
            if (_tipe == Tipe.pengeluaran) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final k in daftarKategori)
                    DropdownMenuItem(value: k, child: Text(k)),
                ],
                onChanged: (nilai) => setState(() => _kategori = nilai),
                validator: (nilai) => nilai == null ? 'Pilih kategori' : null,
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
