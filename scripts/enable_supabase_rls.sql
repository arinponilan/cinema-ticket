-- Jalankan di Supabase Dashboard > SQL Editor.
-- Ini hanya menyalakan Row Level Security (RLS) supaya tabel tidak lagi
-- ditandai UNRESTRICTED. Tidak mengubah struktur tabel atau logic aplikasi.
--
-- Catatan:
-- - Jangan pakai FORCE ROW LEVEL SECURITY untuk project ini.
-- - Backend Spring Boot saat ini memakai koneksi database langsung
--   (DB_USERNAME=postgres...), jadi RLS tidak mengubah logic OOP di kode.
-- - Kalau suatu saat Flutter langsung query Supabase pakai anon/auth key,
--   tambahkan policy SELECT/INSERT/UPDATE yang sesuai.

ALTER TABLE IF EXISTS public.advertisements ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.booking_seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.movies ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.users ENABLE ROW LEVEL SECURITY;
