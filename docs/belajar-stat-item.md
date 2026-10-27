# Belajar: Memakai `StatItem` dari `profilePage.dart`

Catatan proses debugging + perbaikan pada proyek **kartuprofiledigital**.

---

## 1. Masalah awal

`lib/models/StatItem.dart`:

```dart
class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  ...
}
```

`lib/models/profilePage.dart`:

```dart
import './StatItem.dart';   // import-nya sudah ada

...
_StatItem(label: 'Postingan', value: '48'),
```

Error yang muncul:

```
The method '_StatItem' isn't defined for the type '_ProfilePageState'.
```

Pertanyaan besarnya: **import-nya sudah benar, kenapa masih error?**

---

## 2. Konsep kunci: underscore = private per-LIBRARY, bukan per-file/class

Di Dart:

- Nama yang diawali `_` (class, variabel, fungsi) bersifat **private**.
- Private di Dart berlaku pada level **library**.
- Satu file `.dart` = satu library (selama tidak memakai `part`).
- Jadi `_StatItem` hanya bisa dipakai **di dalam file `StatItem.dart` itu sendiri**.

Akibatnya:

| Hal | Status |
|---|---|
| `import './StatItem.dart';` | Bisa jalan, tapi... |
| Isi file ikut masuk namespace | Hanya yang **publik** (tanpa `_`) |
| `_StatItem` bisa dipakai di `profilePage.dart` | ❌ Tidak bisa |

> **Poin belajar:** Menambah `import` tidak membuat nama private menjadi publik.
> Urutan yang benar: **buka akses nama class dulu → baru import bisa berguna.**

---

## 3. Perbaikan

### Langkah 1 — Jadikan class publik

`lib/models/StatItem.dart`:

```dart
class StatItem extends StatelessWidget {          // _StatItem -> StatItem
  const StatItem({super.key, required this.label, required this.value});
  //             ^^^^^^^^^^ tambah super.key

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: textTheme.titleLarge),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}
```

Dua perubahan di sini:

1. `_StatItem` → `StatItem` — hapus underscore supaya bisa diakses lintas file.
2. Tambah `super.key` — supaya widget tetap bisa diberi `key` (praktik standar Flutter,
   dan lint `use_key_in_widget_constructors` akan menegur kalau tidak ada).

### Langkah 2 — Import dengan gaya `package:`

`lib/models/profilePage.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:kartuprofiledigital/models/StatItem.dart';
```

Ada 2 gaya import yang sama-sama sah:

```dart
// Relative
import './StatItem.dart';
import '../models/StatItem.dart';

// Absolute (package)
import 'package:kartuprofiledigital/models/StatItem.dart';
```

`flutter_lints` (aktif di project ini) menyarankan gaya **`package:`**.
Nama package diambil dari `name:` di `pubspec.yaml` → `kartuprofiledigital`.

### Langkah 3 — Ubah pemakaiannya

`lib/models/profilePage.dart`:

```dart
const Card(
  child: Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatItem(label: 'Postingan', value: '48'),
        StatItem(label: 'Pengikut', value: '1200'),
        StatItem(label: 'Mengikuti', value: '320'),
      ],
    ),
  ),
),
```

Constructor `StatItem` tetap `const`, jadi `const Card(...)` di atasnya masih valid.

### Langkah 4 — Betulkan typo di `main.dart`

Ketemu bug tak sengaja (ini yang bikin `flutter analyze` exit 1):

```dart
// SEBELUM — kurang titik koma
import './models/profilePage.dart'

// SESUDAH
import './models/profilePage.dart';
```

Setiap statement Dart **wajib** diakhiri `;`, termasuk `import`.

---

## 4. Alternatif: pakai `part` / `part of`

Kalau kamu memang mau `_StatItem` tetap private, gabungkan kedua file jadi satu library:

`lib/models/StatItem.dart`:

```dart
part of 'profilePage.dart';
// JANGAN tulis import di sini — file part tidak boleh punya import sendiri.
```

`lib/models/profilePage.dart`:

```dart
import 'package:flutter/material.dart';

part 'StatItem.dart';
```

Dengan cara ini kedua file jadi **satu library**, jadi `_StatItem` bisa dipakai keduanya.

| | Ganti jadi publik | `part` / `part of` |
|---|---|---|
| Kerumitan | Rendah | Sedang |
| Bisa dipakai file lain | ✅ Ya | ❌ Terbatas pada library itu |
| Cocok untuk | Widget yang dipakai ulang | File besar yang dipecah |
| Rekomendasi | untuk kasus kartu profil | jarang dipakai di project kecil |

---

## 5. Cara verifikasi

```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
```

Hasil bersih (hanya info nama file):

```
info - The file name 'StatItem.dart' isn't a lower_case_with_underscores identifier.
info - The file name 'profilePage.dart' isn't a lower_case_with_underscores identifier.
```

Keduanya cuma **info style**, bukan error — aplikasi tetap jalan.
Kalau mau hilang, rename jadi `stat_item.dart` dan `profile_page.dart`.

---

## 6. Ringkasan pelajaran

1. **Underscore = private per-library.** Import tidak menembus batas private.
2. Urutan perbaikan: **publikkan nama dulu → baru import berguna.**
3. Selalu tambah `super.key` di widget constructor.
4. Gaya import disarankan: `package:nama_package/path/file.dart`.
5. Typo kecil (titik koma hilang) mematikan seluruh hasil analisis — baca pesan error
   pertama dengan teliti, sering kali akar masalahnya di situ.
6. Diagnostics di editor bisa **stale**; `flutter analyze` adalah sumber kebenaran.

---

## 7. Kesalahan umum yang mirip

| Gejala | Kemungkinan penyebab |
|---|---|
| `isn't defined for the type ...` | Nama masih `_private` di file lain |
| `Unused import` | Import ada tapi class-nya belum publik / belum dipakai |
| `Invalid constant value` | Nama tidak dikenali di dalam `const` list (bukan masalah `const`-nya) |
| `Expected to find ';'` | Statement sebelumnya kurang `;` |
| `Target of URI doesn't exist` | Path import salah / nama package salah |

> Ketika `Unused import` dan `isn't defined` muncul **bersamaan**, hampir pasti akar
> masalahnya adalah **nama class masih private** — bukan masalah path import.
