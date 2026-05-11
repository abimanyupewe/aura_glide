# **Product Requirements Document (PRD)**

**Project Name:** AuraGlide \- The Calming Puzzle  
**Platform:** Mobile (Android/iOS) via Flutter  
**Status:** Draft / Planning  
**Author:** Solo Developer 

## **1\. Executive Summary**

**AuraGlide** adalah game puzzle *match-3 offline* yang berfokus pada pengalaman visual dan interaksi yang menenangkan (*calming/zen*). Berbeda dengan game puzzle pada umumnya yang menggunakan elemen waktu, suara berisik, atau peringatan agresif, AuraGlide menggunakan prinsip desain **Intentional Minimalism**. Tujuan teknis dari proyek ini adalah untuk mendemonstrasikan penguasaan manipulasi UI/UX Flutter tingkat lanjut (animasi modern 60FPS) dan penerapan **Clean Architecture** serta logika State Management (Riverpod) yang terstruktur untuk portofolio level *Internship/Pre-Skripsi*.

## **2\. Product Vision & Design Language**

* **Vibe/Mood:** Tenang, elegan, memuaskan (*satisfying*), tanpa tekanan.  
* **Warna (Palette):** Latar belakang *off-white* (krem sangat lembut). Blok menggunakan palet pastel (Mint Green, Baby Blue, Soft Peach, Lilac).  
* **Bentuk:** Kotak bersudut lengkung sempurna (borderRadius), tanpa *border*, tanpa *shadow* kasar.  
* **Tipografi:** Sans-serif yang membulat (Quicksand / Nunito) berwarna abu-abu lembut.  
* **Animasi Modern (Micro-interactions):** \* Menggunakan **Physics-based Animations (Spring Simulation)**. Pergerakan blok tidak akan kaku, melainkan memiliki pantulan (*bounciness*) organik layaknya objek fisik yang direnggangkan.  
  * **Squish Effect:** Saat blok disentuh (di-hold), blok akan sedikit mengecil (scale 0.95) memberikan *haptic visual feedback* yang responsif ala UI modern.

## **3\. Core Mechanics (Gameplay Loop)**

1. **Papan Permainan (Grid):** Matriks berukuran 6x6 atau 8x8 yang terisi penuh oleh blok warna.  
2. **Interaksi Utama:** Pemain melakukan *swipe* (usap) pada sebuah blok ke salah satu dari 4 arah (Atas, Bawah, Kiri, Kanan). Blok yang di-*swipe* akan bertukar posisi dengan blok di sebelahnya secara mulus.  
3. **Kondisi Match:** Jika pertukaran menghasilkan 3 atau lebih blok berwarna sama secara vertikal atau horizontal, blok tersebut akan "pecah" (menghilang perlahan dengan *fade out* dan menyusut).  
4. **Gravitasi & Refill:** Blok di atas area yang kosong akan meluncur turun untuk mengisi ruang. Blok baru dengan warna acak akan muncul dari luar batas atas layar.

## **4\. Functional Requirements**

### **4.1. Zen Scoring System**

* **Base Match:** Cocok 3 blok \= \+10 Poin. (Setiap blok tambahan dalam satu baris \= \+5 poin).  
* **Cascade Multiplier:** Jika blok jatuh (*gravity*) dan otomatis memicu *match* baru tanpa interaksi pemain, poin digandakan (Match ke-1 \= 1x, Match ke-2 \= 2x, dst).  
* **Floating Score UI:** Teks poin (misal: "+10") muncul melayang ke atas dan memudar secara halus dari titik tengah blok yang hancur.  
* **Main Score Display:** Angka total skor di atas layar yang bertambah dengan animasi *rolling/tween* (tidak meloncat kaku).

### **4.2. State & Persistensi Data (Offline)**

* **High Score:** Sistem secara lokal menyimpan skor tertinggi pemain menggunakan *Local Storage*.  
* **Save State (Opsional \- Target Lanjutan):** Menyimpan status matriks terakhir saat aplikasi ditutup agar bisa dilanjutkan nanti.

## **5\. Non-Functional Requirements (Tech Specs)**

* **Framework:** Flutter (Widget-based murni, tanpa Flame Engine).  
* **Arsitektur & Best Practices (MANDATORY):** \* Wajib menerapkan **Clean Architecture** dengan pemisahan struktur folder yang tegas: domain (Entities, UseCases), data (Repositories, Data Sources), dan presentation (UI, Riverpod Providers).  
  * Mengikuti prinsip **SOLID** dan kode yang **DRY (Don't Repeat Yourself)**.  
  * Menggunakan aturan *linting* ketat (misal: flutter\_lints atau very\_good\_analysis).  
* **State Management:** **Riverpod**. Wajib memisahkan Provider berdasarkan layer arsitektur (jangan mencampur logika *Business Rule* di dalam UI).  
* **Performa:** Harus berjalan stabil di **60 FPS**. Re-render layar hanya boleh terjadi pada sel matriks yang bergerak/berubah state, bukan memuat ulang seluruh *Grid*. Menggunakan widget AnimatedBuilder atau RepaintBoundary jika diperlukan untuk optimasi.  
* **Local DB:** shared\_preferences atau hive (hanya untuk menyimpan angka High Score, diimplementasikan di layer data).

## **6\. Out of Scope (Fitur yang DITOLAK untuk versi 1.0)**

Agar proyek selesai dengan cepat dan kualitas portofolio terjaga, fitur berikut **TIDAK AKAN** dibuat:

* Timer atau batasan waktu (merusak tema *calming*).  
* *Leaderboard Online* / Login akun (membutuhkan backend, tidak fokus pada offline-first).  
* Sistem nyawa / Energi (membutuhkan monetisasi).

## **7\. Implementation Milestones (Roadmap)**

* **Fase 1: Setup Arsitektur & Engine Dasar (Dart Murni)**  
  * Setup struktur folder Clean Architecture (domain, data, presentation).  
  * Membuat entitas (*Entity*) struktur data Array 2D di layer domain.  
  * Membuat *Use Case* untuk algoritma *Swap* (tukar posisi) dan algoritma deteksi *Match-3*.  
* **Fase 2: UI & Gesture (Presentation Layer)**  
  * Membangun UI Papan Grid.  
  * Menyematkan GestureDetector untuk membaca sentuhan (*scale down effect*) dan usapan (*PanUpdate*).  
  * Menghubungkan interaksi UI dengan *Use Case* Logika Matriks menggunakan Riverpod.  
* **Fase 3: Animasi Modern, Persistensi Data, & Polishing**  
  * Mengimplementasikan repositori (*Repository*) di layer data untuk menyimpan High Score.  
  * Mengimplementasikan SpringSimulation pada pergerakan *swap* dan gravitasi blok agar terasa organik.  
  * Menambahkan *floating points* dan animasi skor atas.  
  * Merapikan palet warna pastel dan memastikan kode bersih tanpa *linter warnings*.