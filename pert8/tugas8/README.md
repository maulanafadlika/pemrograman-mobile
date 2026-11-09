# TabungKu Cloud — Tugas Pertemuan 8

Docker Compose (MySQL + FastAPI + Adminer) dan halaman Status Server di Flutter.

**Disusun oleh:** Mokhamad Fadlika Maulana — 20230801194

## Struktur

```
tugas8/
├── docker-compose.yml   # mysql, api, adminer
├── .env.example         # contoh kredensial (salin menjadi .env)
├── backend/             # FastAPI
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/             # main.py, config.py, database.py
└── mobile/              # aplikasi Flutter TabungKu
```

## Layanan dan port

| Layanan | Alamat dari laptop | Keterangan |
|---|---|---|
| API (FastAPI) | http://localhost:8001 | Swagger: http://localhost:8001/docs |
| MySQL 8.4 | localhost:3307 | User `tabungku`, DB `tabungku` |
| Adminer | http://localhost:8081 | Server: `mysql` |

> Port API di laptop memakai **8001** (bukan 8000 seperti di modul) karena port 8000 sudah dipakai aplikasi lain. Port di dalam container tetap 8000.

## Menjalankan backend

Prasyarat: Docker + Docker Compose (di sini dijalankan dari WSL Ubuntu).

```bash
cp .env.example .env          # sesuaikan password bila perlu
docker compose up -d --build
docker compose ps             # tunggu mysql "healthy"
```

Cek: buka http://localhost:8001/health dan http://localhost:8001/docs.

### Endpoint

| Endpoint | Keterangan |
|---|---|
| `GET /` | Pesan sambutan |
| `GET /info` | Nama aplikasi, versi, zona waktu server |
| `GET /health` | Status API dan database (`SELECT VERSION()`) |

Respons `/health`:

- **200** — API dan database sehat:
  ```json
  {"status":"ok","waktu_server":"...","database":"ok","mysql_version":"8.4.13"}
  ```
- **503** — API hidup, database tidak dapat dihubungi:
  ```json
  {"status":"degraded","waktu_server":"...","database":"error","mysql_version":null,"detail":"..."}
  ```

Uji kondisi database mati:

```bash
docker compose stop mysql
curl -i http://localhost:8001/health    # 503
docker compose start mysql
```

## Menjalankan aplikasi Flutter

```bash
cd mobile
flutter pub get
flutter run                                              # emulator Android (http://10.0.2.2:8001)
flutter run --dart-define=API_URL=http://IP-LAPTOP:8001  # HP fisik, satu Wi-Fi dengan laptop
```

Alamat API juga dapat diubah dari aplikasi: **Pengaturan → Server → Alamat API**. Format URL divalidasi dan alamat disimpan dengan `shared_preferences`, sehingga tetap ada setelah aplikasi ditutup. Tombol **Bawaan** mengembalikan alamat default.

Halaman **Pengaturan → Status server** menampilkan status API dan Database secara terpisah:

| Respons `/health` | Tampilan |
|---|---|
| 200 | API ✅, Database ✅ — "Semua layanan normal" |
| 503 | API ✅, Database ❌ — "API hidup, database mati" |
| Kode lain / tidak terhubung | API ❌, Database tidak diketahui |

## Pengujian

```bash
cd mobile
flutter test
```

Unit test (`test/health_service_test.dart`) memakai `MockClient` untuk tiga kasus: sehat (200), database mati (503), dan kode lain (500).

## Perintah berguna

| Perintah | Kegunaan |
|---|---|
| `docker compose logs -f api` | Melihat log API |
| `docker compose exec mysql mysql -utabungku -p tabungku` | Klien MySQL |
| `docker compose down` | Hentikan layanan (data tetap ada di volume) |
| `docker compose down -v` | Hentikan layanan dan hapus seluruh data database |

## Catatan

- Berkas `.env` tidak di-commit (tercantum di `.gitignore`).
- Kode Python di `backend/app` di-bind mount ke container, sehingga perubahan langsung dimuat ulang oleh `uvicorn --reload`. Variabel `WATCHFILES_FORCE_POLLING=true` diperlukan karena proyek berada di drive Windows yang diakses dari WSL.
