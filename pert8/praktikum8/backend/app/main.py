from datetime import datetime

from fastapi import FastAPI

app = FastAPI(title="TabungKu API", version="0.1.0")


@app.get("/")
def beranda():
    return {"pesan": "Selamat datang di TabungKu API. Dokumentasi: /docs"}


@app.get("/health")
def health():
    """Dipakai aplikasi Flutter untuk memastikan server dapat dihubungi."""
    return {"status": "ok", "waktu_server": datetime.now().isoformat(timespec="seconds")}

@app.get("/info")
def info():
    """Informasi dasar aplikasi dan server."""
    return {
        "nama_aplikasi": app.title,
        "versi": app.version,
        "zona_waktu": datetime.now().astimezone().tzname(),
    }
