# FlazSpeedMonitoring

Aplikasi bash untuk monitoring kecepatan internet upload dan download secara berkala dengan interval yang dapat dikonfigurasi.

## Copyright & License

**Copyright © 2024 Mulyawan Sentosa - FlazHost.Com**

Program ini dilisensikan di bawah **GNU General Public License v3.0 (GPL-3.0)**

- ✅ **Gratis digunakan** untuk keperluan pribadi dan komersial
- ✅ **Boleh dimodifikasi** dan didistribusikan ulang
- ✅ **Kode sumber terbuka** dan harus tetap terbuka
- ⚠️ **Tanpa garansi** - gunakan dengan risiko sendiri

Lihat [LICENSE](https://www.gnu.org/licenses/gpl-3.0.html) untuk detail lengkap.

## Persyaratan

Script ini memerlukan `speedtest-cli` untuk berfungsi. Install dengan salah satu cara berikut:

### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install speedtest-cli
```

### Menggunakan pip:
```bash
pip install speedtest-cli
```

### Menggunakan snap:
```bash
sudo snap install speedtest-cli
```

## Cara Penggunaan

1. Jalankan script:
```bash
./flazspeedmonitor.sh
```

2. Pilih interval speedtest:
   - **1 menit, 2 menit, 5 menit, 10 menit, 15 menit, 30 menit**
   - **Custom interval** (input manual dalam menit)

3. Pilih durasi monitoring:
   - **Opsi 1**: Masukkan waktu akhir (format HH:MM, 24-jam)
   - **Opsi 2**: Masukkan durasi dalam jam
   - **Opsi 3**: Jalankan terus-menerus (hentikan dengan Ctrl+C)

4. Script akan:
   - Melakukan speed test sesuai interval yang dipilih
   - Menyimpan hasil ke file `speed_results.csv`
   - Menampilkan progress secara real-time

## Format Output CSV

File `speed_results.csv` berisi kolom-kolom berikut:
- `Timestamp`: Unix timestamp
- `Date`: Tanggal (YYYY-MM-DD)
- `Time`: Waktu (HH:MM:SS)
- `Download_Speed_Mbps`: Kecepatan download dalam Mbps
- `Upload_Speed_Mbps`: Kecepatan upload dalam Mbps
- `Ping_ms`: Latency dalam milliseconds
- `Server_Location`: Lokasi server test
- `ISP`: Internet Service Provider

## Contoh Penggunaan

```bash
# Jalankan script
./flazspeedmonitor.sh

# Pilih interval (misalnya 2 menit)
Select interval option (1-7): 2

# Pilih durasi (misalnya 2 jam)
Select option (1/2/3): 2
Enter duration in hours: 2

# Script akan berjalan selama 2 jam dengan interval 2 menit
```

## Fitur

- ✅ **Interval fleksibel** - 1, 2, 5, 10, 15, 30 menit atau custom
- ✅ Input fleksibel untuk durasi monitoring
- ✅ Penyimpanan hasil dalam format CSV
- ✅ Penanganan error jika test gagal
- ✅ Summary hasil real-time
- ✅ Graceful exit dengan Ctrl+C
- ✅ Validasi format input

## Visualisasi Data

File `index.html` disediakan untuk memvisualisasikan data hasil monitoring dalam bentuk grafik interaktif.

### Cara Menggunakan Dashboard:

1. **Buka dashboard**:
   ```bash
   # Buka file index.html di browser
   firefox index.html
   # atau
   google-chrome index.html
   # atau
   xdg-open index.html
   ```

2. **Auto-load data**: Dashboard akan secara otomatis memuat file `speed_results.csv` jika berada di direktori yang sama

3. **Manual upload**: Jika file CSV tidak ditemukan, Anda dapat mengupload file CSV secara manual menggunakan file input

### Fitur Dashboard:

- ✅ **Grafik garis interaktif** dengan Chart.js
- ✅ **Multi-axis chart**: Speed (Mbps) di kiri, Ping (ms) di kanan
- ✅ **Real-time statistics**: Rata-rata download, upload, ping, dan total tes
- ✅ **Responsive design** yang mobile-friendly
- ✅ **Auto-loading** CSV dari direktori yang sama
- ✅ **Manual file upload** jika diperlukan

### Komponen Visualisasi:

- **Line Chart**: Menampilkan trend download speed, upload speed, dan ping over time
- **Statistics Cards**: Menampilkan ringkasan data (rata-rata dan total)
- **Dual Y-Axis**: Speed dalam Mbps (kiri) dan Ping dalam ms (kanan)
- **Time Labels**: Menampilkan tanggal dan waktu untuk setiap data point

## Tips

- Pastikan koneksi internet stabil saat menjalankan
- File CSV akan dibuat otomatis di direktori yang sama
- Gunakan Ctrl+C untuk menghentikan monitoring kapan saja
- Hasil test yang gagal akan ditandai sebagai "ERROR" dalam CSV
- Gunakan dashboard HTML untuk analisis visual yang lebih mudah# FlazSpeedMonitoring
