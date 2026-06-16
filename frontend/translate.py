import os

files = [
    'lib/src/pages/admin_shell_page.dart',
    'lib/src/pages/booking_flow_pages.dart',
    'lib/src/models/cinema_models.dart'
]

replacements = {
    "'Add New Movie'": "'Tambah Film'",
    "'Add New Schedule'": "'Tambah Jadwal'",
    "'Add Ads'": "'Tambah Iklan'",
    "'Delete Ad'": "'Hapus Iklan'",
    "'Are you sure you want to delete this ad?'": "'Yakin ingin menghapus iklan ini?'",
    "'Cancel'": "'Batal'",
    "'Delete'": "'Hapus'",
    "'Failed to delete ad: '": "'Gagal menghapus iklan: '",
    "'No banners found'": "'Tidak ada banner'",
    "'Import banner from laptop'": "'Impor banner dari laptop'",
    "'Banner image is required'": "'Gambar banner wajib diisi'",
    "'Save ad failed: '": "'Gagal menyimpan iklan: '",
    "'Save Ad'": "'Simpan Iklan'",
    "labelText: 'Title'": "labelText: 'Judul'",
    "labelText: 'Sort order'": "labelText: 'Urutan Sortir'",
    "hintText: 'e.g. 1'": "hintText: 'Contoh: 1'",
    "'Now Showing'": "'Sedang Tayang'",
    "'Coming Soon'": "'Segera Tayang'",
    "'Available'": "'Tersedia'",
    "'Reserved'": "'Terisi'",
    "'Selected'": "'Dipilih'",
    "'SCREEN'": "'LAYAR'",
    "'Summary'": "'Ringkasan'",
    "'Select Format & Studio'": "'Pilih Format & Studio'",
    "'Select Seats'": "'Pilih Kursi'",
    "'Select Date'": "'Pilih Tanggal'",
    "'Buy Ticket'": "'Beli Tiket'",
    "'Book Ticket'": "'Pesan Tiket'",
    "'Total Payment'": "'Total Pembayaran'",
    "'Payment Failed'": "'Pembayaran Gagal'",
    "'Confirm & Pay'": "'Konfirmasi & Bayar'",
    "'Success'": "'Sukses'",
    "'Tickets booked successfully!'": "'Tiket berhasil dipesan!'",
    "'Almost full'": "'Hampir penuh'",
    "'Schedule #'": "'Jadwal #'",
}

for filepath in files:
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            content = f.read()
        
        for k, v in replacements.items():
            content = content.replace(k, v)
            
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Translated {filepath}")
    else:
        print(f"File not found: {filepath}")
