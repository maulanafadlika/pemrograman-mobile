from datetime import datetime

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from sqlalchemy import text

from .database import engine

app = FastAPI(title="TabungKu API", version="0.1.0")


@app.get("/")
def beranda():
    return {"pesan": "Selamat datang di TabungKu API. Dokumentasi: /docs"}


@app.get("/info")
def info():
    """Informasi dasar aplikasi dan server."""
    return {
        "nama_aplikasi": app.title,
        "versi": app.version,
        "zona_waktu": datetime.now().astimezone().tzname(),
    }


@app.get("/health")
def health():
    """Memeriksa API dan koneksi database. 503 bila database tidak dapat dihubungi."""
    waktu = datetime.now().isoformat(timespec="seconds")
    try:
        with engine.connect() as conn:
            versi = conn.execute(text("SELECT VERSION()")).scalar()
    except Exception as e:
        return JSONResponse(
            status_code=503,
            content={
                "status": "degraded",
                "waktu_server": waktu,
                "database": "error",
                "mysql_version": None,
                "detail": str(e),
            },
        )
    return {
        "status": "ok",
        "waktu_server": waktu,
        "database": "ok",
        "mysql_version": versi,
    }