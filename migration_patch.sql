-- ============================================================
--  Uni Gift Studio — MIGRATION PATCH
--  Jalankan query ini di phpMyAdmin masing-masing
--  (DB kamu: unigiftstudio | DB teman: unigiftstudio_db)
--
--  Yang dilakukan:
--    1. Hapus tabel filaments & printers (tidak dipakai lagi)
--    2. Tambah tabel contributors (fitur baru)
--    3. Fix bug data (email format, role kosong, index duplikat)
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- LANGKAH 1: Hapus tabel yang tidak dipakai lagi
-- ============================================================
DROP TABLE IF EXISTS `filaments`;
DROP TABLE IF EXISTS `printers`;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- LANGKAH 2: Tambah tabel contributors (cek dulu kalau sudah ada)
-- ============================================================
CREATE TABLE IF NOT EXISTS `contributors` (
  `id`              int(11)      NOT NULL AUTO_INCREMENT,
  `nama_organisasi` varchar(200) NOT NULL,
  `tipe_organisasi` varchar(100) DEFAULT NULL,
  `nama_pic`        varchar(100) DEFAULT NULL,
  `email`           varchar(100) NOT NULL,
  `nomor_wa`        varchar(20)  DEFAULT NULL,
  `tier`            enum('Bronze','Silver','Gold') DEFAULT 'Silver',
  `pesan`           text         DEFAULT NULL,
  `status`          enum('pending','disetujui','ditolak') DEFAULT 'pending',
  `catatan_admin`   text         DEFAULT NULL,
  `created_at`      timestamp    NOT NULL DEFAULT current_timestamp(),
  `updated_at`      timestamp    NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- LANGKAH 3: Fix bug — khusus DB kamu (amde)
--   Email tersimpan dalam format markdown [text](mailto:...)
-- ============================================================
UPDATE `users` SET `email` = 'amadea@unigift.com'
  WHERE `email` LIKE '%amadea@unigift.com%' AND `email` != 'amadea@unigift.com';

UPDATE `users` SET `email` = 'rizky@email.com'
  WHERE `email` LIKE '%rizky@email.com%' AND `email` != 'rizky@email.com';

UPDATE `users` SET `email` = 'lesti@email.com'
  WHERE `email` LIKE '%lesti@email.com%' AND `email` != 'lesti@email.com';

UPDATE `users` SET `email` = 'budi@email.com'
  WHERE `email` LIKE '%budi@email.com%' AND `email` != 'budi@email.com';

UPDATE `users` SET `email` = 'naura@email.com'
  WHERE `email` LIKE '%naura@email.com%' AND `email` != 'naura@email.com';

UPDATE `users` SET `email` = 'andi@email.com'
  WHERE `email` LIKE '%andi@email.com%' AND `email` != 'andi@email.com';

-- ============================================================
-- LANGKAH 5: Bersihkan index duplikat — khusus DB kamu (amde)
--   (Kalau index tidak ada, query ALTER akan error — ini normal, skip saja)
-- ============================================================

-- Hapus index duplikat di tabel products
SET @exist_prod = (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'products'
    AND index_name = 'kode_produk_2'
);
SET @sql_prod = IF(@exist_prod > 0,
  'ALTER TABLE `products` DROP INDEX `kode_produk_2`',
  'SELECT "index kode_produk_2 tidak ada, skip" AS info'
);
PREPARE stmt FROM @sql_prod;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Hapus index duplikat di tabel users
SET @exist_usr = (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'users'
    AND index_name = 'email_2'
);
SET @sql_usr = IF(@exist_usr > 0,
  'ALTER TABLE `users` DROP INDEX `email_2`',
  'SELECT "index email_2 tidak ada, skip" AS info'
);
PREPARE stmt FROM @sql_usr;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- LANGKAH 6: Pastikan kolom kurir & nomor_resi ada di orders
--   (Kalau sudah ada tidak akan error karena pakai IF NOT EXISTS)
-- ============================================================
ALTER TABLE `orders`
  ADD COLUMN IF NOT EXISTS `kurir`      varchar(100) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `nomor_resi` varchar(100) DEFAULT NULL;

-- ============================================================
-- Selesai! Verifikasi:
--   SELECT TABLE_NAME FROM information_schema.TABLES
--   WHERE TABLE_SCHEMA = DATABASE()
--   ORDER BY TABLE_NAME;
-- ============================================================
