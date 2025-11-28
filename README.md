# 🏔️ Hello everyone, We are GunDex!

## 👥 Anggota Kelompok D03
- M. Adella Fathir Supriadi (2406495640)
- Rasyad Zulham Rabani (2406348540)
- Fairuz Akhtar Randrasyah (2406403955)
- Muhammad Alfa Mubarok (2406431391)
- Moch Raydzan (2406432482)

## 🌋 Apa itu GunDex Mobile?
GunDex (Gunung Index) kini hadir dalam bentuk aplikasi mobile berbasis Flutter yang dirancang khusus untuk para pendaki gunung dan pencinta alam di Indonesia. Aplikasi ini terintegrasi langsung dengan backend Django yang telah dibuat sebelumnya, memanfaatkan pertukaran data berbasis JSON untuk menghadirkan pengalaman pengguna yang cepat dan responsif di perangkat seluler.

Sebagai solusi portabel, GunDex Mobile memungkinkan pendaki untuk mengakses informasi gunung, mencatat aktivitas, dan mengelola keinginan pendakian mereka langsung dari genggaman, bahkan saat sedang dalam perjalanan menuju basecamp.

Melalui aplikasi GunDex, pengguna dapat dengan mudah:

🔎 Menjelajahi data gunung di Indonesia yang diambil secara real-time dari server melalui API.

🎯 Menyimpan daftar impian pendakian di Wishlist yang tersinkronisasi otomatis dengan database pusat.

🥾 Mencatat riwayat pendakian melalui antarmuka mobile yang ramah pengguna.

📰 Membaca artikel pendakian di mana saja dengan tampilan mobile-friendly.

💬 Login dan Autentikasi yang aman menggunakan integrasi layanan web Django.

Secara teknis, GunDex Mobile berfungsi sebagai client yang melakukan request (GET/POST) ke server Django. Server akan merespons dengan data dalam format JSON, yang kemudian diolah (parsing) oleh Flutter untuk ditampilkan menjadi antarmuka aplikasi yang menarik.

## 📕 Daftar Modul & Integrasi Layanan
👤 User (Autentikasi & Profil)
Dikerjakan oleh Fairuz Akhtar Randrasyah Fitur ini menangani autentikasi pengguna antara aplikasi Flutter dan server Django. Menggunakan library HTTP (seperti pbp_django_auth atau http), modul ini mengelola proses login, register, dan logout dengan mengirimkan kredensial ke endpoint API Django.

Implementasi Mobile: Aplikasi akan menyimpan sesi pengguna (cookies/token) sehingga pengguna tidak perlu login berulang kali. Halaman profil akan mengambil data pengguna (JSON) dari server untuk menampilkan nama, foto, dan biodata secara real-time.

🏔️ Explore Gunung
Dikerjakan oleh Rasyad Zulham Rabani Fitur Explore Gunung adalah halaman utama aplikasi yang menampilkan daftar gunung. Modul ini melakukan fetch data secara asynchronous ke endpoint JSON Django yang berisi seluruh data gunung.

Implementasi Mobile: Data JSON yang diterima (nama, lokasi, ketinggian) akan di-parsing menjadi model objek Dart dan ditampilkan menggunakan ListView atau GridView di Flutter. Saat pengguna memilih salah satu gunung, aplikasi akan mengambil detail spesifik gunung tersebut dari server untuk ditampilkan di halaman detail.

💡 Artikel
Dikerjakan oleh M. Adella Fathir Supriadi Fitur ini menyajikan wawasan pendakian dalam genggaman. Aplikasi akan memanggil API untuk mendapatkan daftar artikel terbaru.

Implementasi Mobile: Menggunakan widget FutureBuilder untuk memuat daftar judul dan ringkasan artikel dari JSON. Ketika artikel diklik, aplikasi akan menavigasi ke halaman baca (Read View) yang menyusun isi konten artikel agar nyaman dibaca di layar ponsel, lengkap dengan gambar pendukung yang URL-nya diambil dari database.

🎯 Wishlist
Dikerjakan oleh Muhammad Alfa Mubarok Fitur Wishlist memungkinkan pengguna menandai gunung impian. Integrasi ini melibatkan pengiriman data (POST request) dari Flutter ke Django saat tombol "Add to Wishlist" ditekan.

Implementasi Mobile: Halaman Wishlist akan melakukan filter data JSON untuk hanya menampilkan gunung yang telah ditandai oleh pengguna yang sedang login. Pengguna dapat menghapus item dari wishlist dengan melakukan swipe atau menekan tombol hapus, yang akan mengirimkan permintaan penghapusan ke server secara instan tanpa perlu refresh halaman secara penuh.

🥾 Log Pendakian
Dikerjakan oleh Moch Raydzan Fitur ini mengubah ponsel menjadi jurnal pendakian digital. Modul ini menyediakan formulir input (Form Widget) di Flutter untuk mencatat tanggal, jalur, dan kondisi pendakian.

Implementasi Mobile: Saat pengguna menekan tombol "Simpan Log", aplikasi akan mengemas data input menjadi format JSON dan mengirimkannya melalui metode POST ke server Django. Data ini kemudian divalidasi dan disimpan di database. Pengguna dapat melihat riwayat pendakian mereka kembali melalui halaman History yang mengambil data log pribadi mereka dari server.

🛠️ Arsitektur Teknis
Frontend: Flutter (Dart)

Backend: Django Framework (Python)

Communication: HTTP Request

Data Format: JSON (JavaScript Object Notation)

State Management: Mengelola status loading, error, dan data success saat mengambil data dari PWS.

## 📊 Initial Dataset
GunDex menggunakan dataset buatan sendiri yang berisi daftar gunung di Indonesia, mencakup nama gunung, lokasi, dan ketinggian.
Dataset dapat diakses melalui tautan berikut:
🔗 [GunDex Dataset – Google Sheets](https://docs.google.com/spreadsheets/d/10qIMDxK_dvc9FtDuoi80lleCl2Q33aeeAP5z4ca3opY/edit?gid=0#gid=0)

Beberapa data dikumpulkan dan disusun ulang dengan mengutip sumber terpercaya seperti

https://astacala.org/jalur-pendakian-gunung/

https://datagunung.com

## 🧍‍♂️🧗‍♀️ Jenis Pengguna
🛠️ Admin  
Admin memiliki peran sebagai pengelola utama sistem. Mereka bertanggung jawab untuk menambah dan memperbarui data gunung, mengelola artikel pendakian, serta memantau aktivitas pengguna. Selain itu, admin juga memastikan bahwa setiap konten yang tampil di GunDex akurat dan sesuai dengan tujuan platform, yaitu menjadi sumber informasi terpercaya bagi pendaki di seluruh Indonesia.  

🥾 Hiker  
Hiker adalah pengguna umum yang memanfaatkan seluruh fitur GunDex. Mereka dapat melihat daftar gunung, menambah gunung ke wishlist, mencatat log pendakian pribadi, membaca artikel, dan mengelola akun mereka sendiri. Dengan akun pribadi, setiap hiker bisa menyimpan jejak pendakiannya dan membangun arsip perjalanan mereka dari waktu ke waktu. GunDex membantu para pendaki untuk tetap terhubung dengan alam, komunitas, dan diri mereka sendiri. Karena setiap pendakian punya cerita yang layak untuk diingat.

## Alur pengintegrasian dengan web service
Aplikasi Flutter tidak berkomunikasi langsung dengan database. Semua data dikirim dan diterima melalui Django Gundex yang berjalan di PWS (Pacil Web Service) menggunakan request HTTP dengan format JSON. Django menangani autentikasi pengguna, validasi input, logika bisnis, serta operasi baca tulis ke database melalui Django ORM (Object Relational Mapping).

Alur integrasinya adalah sebagai berikut:

1. Flutter mengirimkan request HTTP (GET, POST, PUT, DELETE) ke endpoint Django yang telah disiapkan untuk keperluan seperti mengambil data gunung, mengelola wishlist, atau mencatat log pendakian.
2. Django menerima request tersebut, melakukan autentikasi dan otorisasi berdasarkan akun pengguna yang sama dengan versi web, lalu memproses permintaan menggunakan logika bisnis dan ORM.
3. Django mengembalikan response berupa JSON kepada aplikasi Flutter. Flutter kemudian mengolah data tersebut dan menampilkannya sebagai antarmuka bagi pengguna.

Dengan pendekatan ini, aplikasi Flutter dan aplikasi web GUNDEX menggunakan backend dan database yang sama. PWS berfungsi sebagai platform hosting untuk Django dan tidak menambahkan lapisan logika baru. Pendekatan ini memastikan konsistensi data antar platform dan mempermudah pemeliharaan aplikasi.

## Link PWS dan design
https://rasyad.zulham-gundex.pbp.cs.ui.ac.id

https://www.figma.com/design/pBlQu8uLwuBH9aJQWKuQR0/Grand-Design?m=auto&t=gsURRZSHrJvA3pdE-1
