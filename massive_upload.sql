-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 24-01-2025 a las 23:52:35
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `massive_upload`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `DisperseTemporalPersonData` ()   BEGIN
    DECLARE person_id INT;

    -- Insertar personas únicas, evitando nombres vacíos
    INSERT INTO person (nombre, paterno, materno)
    SELECT DISTINCT nombre, paterno, materno
    FROM temporal_person
    WHERE nombre IS NOT NULL AND nombre != ''
      AND paterno IS NOT NULL AND paterno != ''
      AND materno IS NOT NULL AND materno != ''
      AND NOT EXISTS (
          SELECT 1
          FROM person
          WHERE person.nombre = temporal_person.nombre
            AND person.paterno = temporal_person.paterno
            AND person.materno = temporal_person.materno
      );

    -- Insertar teléfonos únicos, evitando valores vacíos
    INSERT INTO phone (phone, person_id)
    SELECT DISTINCT t.telefono, p.id
    FROM temporal_person t
    INNER JOIN person p
      ON p.nombre = t.nombre
      AND p.paterno = t.paterno
      AND p.materno = t.materno
    WHERE t.telefono IS NOT NULL AND t.telefono != ''
      AND NOT EXISTS (
          SELECT 1
          FROM phone ph
          WHERE ph.phone = t.telefono
            AND ph.person_id = p.id
      );

    -- Insertar direcciones únicas, evitando valores vacíos
    INSERT INTO address (calle, numero_exterior, numero_interior, colonia, cp, person_id)
    SELECT DISTINCT t.calle, t.numero_exterior, t.numero_interior, t.colonia, t.cp, p.id
    FROM temporal_person t
    INNER JOIN person p
      ON p.nombre = t.nombre
      AND p.paterno = t.paterno
      AND p.materno = t.materno
    WHERE t.calle IS NOT NULL AND t.calle != ''
      AND t.colonia IS NOT NULL AND t.colonia != ''
      AND t.cp IS NOT NULL AND t.cp != ''
      AND NOT EXISTS (
          SELECT 1
          FROM address a
          WHERE a.calle = t.calle
            AND a.numero_exterior = t.numero_exterior
            AND a.numero_interior = t.numero_interior
            AND a.colonia = t.colonia
            AND a.cp = t.cp
            AND a.person_id = p.id
      );

    -- Limpiar la tabla temporal
    TRUNCATE TABLE temporal_person;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetPeople` (IN `startIndex` INT, IN `pageSize` INT)   BEGIN
    SELECT 
        p.id, 
        p.nombre, 
        p.paterno, 
        p.materno
    FROM person p
    LIMIT startIndex, pageSize;

    SELECT 
        COUNT(*) AS totalRecords
    FROM person;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `address`
--

CREATE TABLE `address` (
  `id` int(10) UNSIGNED NOT NULL,
  `calle` varchar(255) DEFAULT NULL,
  `numero_exterior` varchar(10) DEFAULT NULL,
  `numero_interior` varchar(10) DEFAULT NULL,
  `colonia` varchar(255) DEFAULT NULL,
  `cp` varchar(10) DEFAULT NULL,
  `person_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `address`
--

INSERT INTO `address` (`id`, `calle`, `numero_exterior`, `numero_interior`, `colonia`, `cp`, `person_id`) VALUES
(2, 'Avenida Siempre Viva', '456', '3', 'Colonia Reforma', '54321', 2),
(4, 'Bulevar Las Palmas', '321', '3', 'Colonia Industrial', '98765', 4),
(3, 'Calle del Sol', '789', '1', 'Colonia Jardines', '67890', 3),
(1, 'Calle Falsa', '123', '2', 'Colo nia Centro', '12345', 1),
(6, 'Dormilones', '981', '', 'Colo Santa Barbara', '56055', 3),
(7, 'Libertad', '35', '502- c', 'Cuauhtemoc', '5000521', 6),
(5, 'Pasaje de la Luna', '654', '', 'Colonia América', '11223', 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000001_create_cache_table', 1),
(2, '2014_10_12_000000_create_users_table', 1),
(3, '2014_10_12_100000_create_password_resets_table', 1),
(4, '2016_06_01_000001_create_oauth_auth_codes_table', 1),
(5, '2016_06_01_000002_create_oauth_access_tokens_table', 1),
(6, '2016_06_01_000003_create_oauth_refresh_tokens_table', 1),
(7, '2016_06_01_000004_create_oauth_clients_table', 1),
(8, '2016_06_01_000005_create_oauth_personal_access_clients_table', 1),
(9, '2019_08_19_000000_create_failed_jobs_table', 1),
(10, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(11, '2025_01_22_102450_create_oauth_auth_codes_table', 1),
(12, '2025_01_22_102451_create_oauth_access_tokens_table', 1),
(13, '2025_01_22_102452_create_oauth_refresh_tokens_table', 1),
(14, '2025_01_22_102453_create_oauth_clients_table', 1),
(15, '2025_01_22_102454_create_oauth_personal_access_clients_table', 1),
(16, '2025_01_23_062501_create_temporal_person_table', 1),
(17, '2025_01_23_062559_create_person_table', 1),
(18, '2025_01_23_062744_create_phone_table', 1),
(19, '2025_01_23_062908_create_address_table', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oauth_access_tokens`
--

CREATE TABLE `oauth_access_tokens` (
  `id` varchar(100) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `client_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `scopes` text DEFAULT NULL,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `oauth_access_tokens`
--

INSERT INTO `oauth_access_tokens` (`id`, `user_id`, `client_id`, `name`, `scopes`, `revoked`, `created_at`, `updated_at`, `expires_at`) VALUES
('05c8c0ef84d6a9f5e5845b2b2123ef226f0ac38a5c65fb3005ce59965a3c4bd14ac024dd4013b798', 1, 2, NULL, '[]', 0, '2025-01-24 12:28:37', '2025-01-24 12:28:37', '2026-01-24 06:28:37'),
('12be649ed3fc1d647bf3f1dbe6faffdc376d9610bc0fa158f0f2e2453bc116d0a037cdbe67275389', 1, 2, NULL, '[]', 0, '2025-01-24 12:18:58', '2025-01-24 12:18:58', '2026-01-24 06:18:58'),
('139e46130ff46081d9ba3a91a5810ea1290163ba52a20fe42fb0956c1a60da8d6d9a7c31f7b989e0', 1, 2, NULL, '[]', 0, '2025-01-24 12:39:27', '2025-01-24 12:39:27', '2026-01-24 06:39:27'),
('149db9ba8732aa14fb8747530756f998fee0960daf60d4029363c5d6f02227121a3005c59a40931e', 1, 2, NULL, '[]', 0, '2025-01-24 16:03:18', '2025-01-24 16:03:18', '2026-01-24 10:03:18'),
('1677effe763d33a5d741a41f2d9d8e33c3e4297500370007a5b56919a08890912e4e83ba3f29807c', 1, 2, NULL, '[]', 0, '2025-01-24 17:23:32', '2025-01-24 17:23:32', '2026-01-24 11:23:32'),
('1f3f5e6cbf2cd59f97d44ef9fe78f3ed3ac421f60a8fcf2beab6f2fe4b0a75bf071679625eca3a2a', 1, 2, NULL, '[]', 0, '2025-01-24 12:17:34', '2025-01-24 12:17:34', '2026-01-24 06:17:34'),
('2f66a85fe853ad63d5520b23cd7c16f691a2da6618c64272769b41d379910fe969680e3d3d23820e', 1, 2, NULL, '[]', 0, '2025-01-24 12:44:24', '2025-01-24 12:44:24', '2026-01-24 06:44:24'),
('2fc890d04dd11cda8c0b48e23f944020e5a504489a5b27ca9c60c74c9bed3d4f6c5a55089c8d7069', 1, 2, NULL, '[]', 0, '2025-01-24 12:42:57', '2025-01-24 12:42:57', '2026-01-24 06:42:57'),
('357e450ce922aa8e396df0d03761beecc23ad69a2c5a84d22b0ce324c01d0ee79ffb35af3712d4cd', 1, 2, NULL, '[]', 0, '2025-01-24 07:24:04', '2025-01-24 07:24:04', '2026-01-24 01:24:04'),
('3648fe0f4350196a0ebc75e024c2022a4c48f480949228250ea6c31d6971358aa2f9f6f8c8168525', 1, 2, NULL, '[]', 0, '2025-01-24 17:16:27', '2025-01-24 17:16:27', '2026-01-24 11:16:27'),
('36ff5e878c924a63ddce6386c91c9425a1285b8ee0ec6c26ef175a1a08f29705bf649a81d04dc781', 1, 2, NULL, '[]', 0, '2025-01-24 12:25:06', '2025-01-24 12:25:06', '2026-01-24 06:25:06'),
('3b1b4c6ec74eaf0d2c9f43b1f53499a641d6bbd762ac848914809c23c98c69dc4309a2b0d23f1681', 1, 2, NULL, '[]', 0, '2025-01-24 12:40:27', '2025-01-24 12:40:27', '2026-01-24 06:40:27'),
('3fa919dd305a339f0dfe7cb548a74e95daad1780bbf31a6eb0f67fe61823088aa9b20a38507548e4', 1, 2, NULL, '[]', 0, '2025-01-24 12:22:42', '2025-01-24 12:22:42', '2026-01-24 06:22:42'),
('3fc11e4339d580b64dc678f108ef2ce127bb39fbdf10e6eea2e342f302d00daa8460ae0517dd59e4', 1, 2, NULL, '[]', 0, '2025-01-24 12:19:09', '2025-01-24 12:19:09', '2026-01-24 06:19:09'),
('448dd7b79e73b13856cee6486dc09c022e96ae6ee72e5399bdf203d1891eb2d8a01285d9804a3638', 1, 2, NULL, '[]', 0, '2025-01-24 12:30:37', '2025-01-24 12:30:37', '2026-01-24 06:30:37'),
('481e504829ca2833190243e114b43217d45c8d9193a86347e31fb413a29ca42c766ecde6049a5870', 1, 2, NULL, '[]', 0, '2025-01-24 17:14:57', '2025-01-24 17:14:57', '2026-01-24 11:14:57'),
('4d2929fbf0322427f211b6836e0a2e2dcd694c990e9907a1050b9429b9481dccaf8c41d1337ede8b', 1, 2, NULL, '[]', 0, '2025-01-24 12:35:29', '2025-01-24 12:35:29', '2026-01-24 06:35:29'),
('5596bfbf8f6c299344ec0e8f7b673e79f380c2700055c12b50fc66144b911398469b987af2f1d40a', 1, 2, NULL, '[]', 0, '2025-01-24 15:01:39', '2025-01-24 15:01:39', '2026-01-24 09:01:39'),
('5cb3beb0d0d326bee5e526783dbc0a1aa1e2553b373f9509ee3e5ece7114e7db234adc528fc8cc9f', 1, 2, NULL, '[]', 0, '2025-01-24 12:39:43', '2025-01-24 12:39:43', '2026-01-24 06:39:43'),
('5d510d5d19e2998ee0447e300d07b9e2dae63c0527bdb91ab83519e21f3d5c27f4f05c44d48d8dc7', 1, 2, NULL, '[]', 0, '2025-01-24 12:37:09', '2025-01-24 12:37:09', '2026-01-24 06:37:09'),
('5ed02cd1c2613e5b81f740843595d889d5b8927bf333de49412c110ceee54a19a5aca2a39fd6ab61', 1, 2, NULL, '[]', 0, '2025-01-24 07:26:22', '2025-01-24 07:26:22', '2026-01-24 01:26:22'),
('5fc37e810d33f3ab4e0dd42869f6286bd2daff329b63ab0e75a4c419d8b624ed0d6741044d67581b', 1, 2, NULL, '[]', 0, '2025-01-24 17:19:44', '2025-01-24 17:19:44', '2026-01-24 11:19:44'),
('6679d4d44772eec2b84e1cb1992bdd02eff0584d229a45a3d9d5d4924b4e69b1ecf2fc17fabd3b26', 1, 2, NULL, '[]', 0, '2025-01-24 12:42:28', '2025-01-24 12:42:28', '2026-01-24 06:42:28'),
('68ed3076982fe771cc3df5a43a4dcf3c5106e7c7c262ec1f0221a34016fc5719ce09a8484a88db69', 1, 2, NULL, '[]', 0, '2025-01-24 07:26:40', '2025-01-24 07:26:40', '2026-01-24 01:26:40'),
('7015f639693a4fbdd746e1243ecdcdfec76cf614b4545624e6ebd633765ae877f29f4b3a19acf2ba', 1, 2, NULL, '[]', 0, '2025-01-24 12:34:59', '2025-01-24 12:34:59', '2026-01-24 06:34:59'),
('708fb3b7e4c1caeff0555a5f2af84d252144bed2f8d9c43467a09c38ee6da8ca193985b1a4c2168b', 1, 2, NULL, '[]', 0, '2025-01-24 12:25:22', '2025-01-24 12:25:22', '2026-01-24 06:25:22'),
('7f2e28e8e2ef81a9a75748a99d89de28323ff7a9a510b2c5f7c05a98c5201d1dbe7515e11ee7ba84', 1, 2, NULL, '[]', 0, '2025-01-24 14:44:15', '2025-01-24 14:44:15', '2026-01-24 08:44:15'),
('833e501865be7d37e7ee82816551a6ef00d64ce73edcf3d0e06f013663ed06835500d4977856d6b5', 1, 2, NULL, '[]', 0, '2025-01-24 17:24:33', '2025-01-24 17:24:33', '2026-01-24 11:24:33'),
('88c9b2fb15fc551f6aee08d600a4d3325b18f9807e16134a1d7c87c060cd66e39b6e43feca63fcc5', 1, 2, NULL, '[]', 0, '2025-01-24 12:30:06', '2025-01-24 12:30:06', '2026-01-24 06:30:06'),
('8b58655abaf0912501b7d420ab966560ca847dab1162c3b778934d95d493c5032acf1d3a684791c7', 1, 2, NULL, '[]', 0, '2025-01-24 13:47:42', '2025-01-24 13:47:42', '2026-01-24 07:47:42'),
('9dba704025ce71a8917ef2cfb5376956693cc16c39b2ca13ae10fdc90d5c222370904151ae4149fe', 1, 2, NULL, '[]', 0, '2025-01-24 12:15:18', '2025-01-24 12:15:18', '2026-01-24 06:15:18'),
('9e0eb420698c1e279c94051bbf004f97d4c8bf09e5dd54923621f73ed4f87657d0d38bbb63885ca8', 1, 2, NULL, '[]', 0, '2025-01-24 11:39:30', '2025-01-24 11:39:30', '2026-01-24 05:39:30'),
('a5193eeb8d2a9d3cb0fc4059245afa80ea5f58ba05a04b0f2357230e328a6cc42623d41a3d7fef7f', 1, 2, NULL, '[]', 0, '2025-01-24 12:39:41', '2025-01-24 12:39:41', '2026-01-24 06:39:41'),
('a960983e69c878f6269f8f75458510fccd406340e68445e93c2a1c12cc6061d2c23388f41bc24f60', 2, 2, NULL, '[]', 0, '2025-01-24 15:00:46', '2025-01-24 15:00:46', '2026-01-24 09:00:46'),
('b227765476619a39832681a7ea332e75bfcda5077834336dae445e8c88e871a5329739d01c1bf988', 1, 2, NULL, '[]', 0, '2025-01-24 12:41:36', '2025-01-24 12:41:36', '2026-01-24 06:41:36'),
('b50c369061f3b25841c8d2d326ebf733cd8041e8b94539e64d48f29550621a3cca194f3224b86c7c', 2, 2, NULL, '[]', 0, '2025-01-24 07:36:18', '2025-01-24 07:36:18', '2026-01-24 01:36:18'),
('b73867ef5163c76672ea030d0e90a2ad8a0c787992159d7e941f737f5e8dbbe87f2146c48c1f7710', 1, 2, NULL, '[]', 0, '2025-01-24 12:25:28', '2025-01-24 12:25:28', '2026-01-24 06:25:28'),
('bd3cd16d3660833ad704bfb923d01538b57e167e8a925ba5f3a0ed04fbe2391b95a19664d5811802', 1, 2, NULL, '[]', 0, '2025-01-24 12:19:32', '2025-01-24 12:19:32', '2026-01-24 06:19:32'),
('bf95a17cf523dbe0581152e9316ca0505e29d85b4102b3f992e70e5aaa853fca1a90dc0321ae068c', 1, 2, NULL, '[]', 0, '2025-01-24 12:29:17', '2025-01-24 12:29:17', '2026-01-24 06:29:17'),
('c3955876fc2342da473c0bd334eb98570329a4ea6a8c916f3a0db13b4306ab161575a37a9de085d1', 1, 2, NULL, '[]', 0, '2025-01-24 12:41:44', '2025-01-24 12:41:44', '2026-01-24 06:41:44'),
('c8cac6cd7c442a3969f0f41184a4c819082800945cd0b02eb7f9e843083a4845573c7ed1aae69c95', 1, 2, NULL, '[]', 0, '2025-01-24 07:18:30', '2025-01-24 07:18:30', '2026-01-24 01:18:30'),
('cccdc6d4a04da654b0ab8ba2591f329468826af50db91bf8c012422cd19b013b161344b9f28ebfb7', 1, 2, NULL, '[]', 0, '2025-01-24 12:29:59', '2025-01-24 12:29:59', '2026-01-24 06:29:59'),
('d2bdd7da5f1c5ef6e48133f71f29c9d1ee2d4996194fef80ca1212de4fb128884ad215d4e75dd506', 1, 2, NULL, '[]', 0, '2025-01-24 12:40:04', '2025-01-24 12:40:04', '2026-01-24 06:40:04'),
('e15d5deb15b085dd43501c92bbf25463cc746622e59b099d0d54c7e8f7b4b23fc9fffbf1f7b30b8f', 1, 2, NULL, '[]', 0, '2025-01-24 12:31:47', '2025-01-24 12:31:47', '2026-01-24 06:31:47'),
('e427a9cf252a456904f56d28ca39342b2197cf709350c0e343d71e34e6081be217c4023e7f76a101', 1, 2, NULL, '[]', 0, '2025-01-24 12:23:38', '2025-01-24 12:23:38', '2026-01-24 06:23:38'),
('ee7366e52703f91704707bc0c807b41663eb3762de83dee7816e3b44b231aafbdf5921341a1997d6', 1, 2, NULL, '[]', 0, '2025-01-24 07:28:00', '2025-01-24 07:28:00', '2026-01-24 01:28:00'),
('f1dc3d721ba600432bf06ff469d3f88d052a73e89abd8e22fbf84485b0aaf15978e769600cd407ca', 1, 2, NULL, '[]', 0, '2025-01-24 07:08:01', '2025-01-24 07:08:01', '2026-01-24 01:08:01'),
('f7874b112dd109379ca5b48240f5d3268b17cc4cf19fc266de226b71bd51444e4f9b87362655ec22', 1, 2, NULL, '[]', 0, '2025-01-24 12:39:19', '2025-01-24 12:39:19', '2026-01-24 06:39:19'),
('fb79a51bdc01b77fefa2e170e0a7317058ee701e3b58ca275501d87d6845ad067fcfc40a941290aa', 1, 2, NULL, '[]', 0, '2025-01-24 16:03:52', '2025-01-24 16:03:52', '2026-01-24 10:03:52');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oauth_auth_codes`
--

CREATE TABLE `oauth_auth_codes` (
  `id` varchar(100) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `client_id` bigint(20) UNSIGNED NOT NULL,
  `scopes` text DEFAULT NULL,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oauth_clients`
--

CREATE TABLE `oauth_clients` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `secret` varchar(100) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `redirect` text NOT NULL,
  `personal_access_client` tinyint(1) NOT NULL,
  `password_client` tinyint(1) NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `oauth_clients`
--

INSERT INTO `oauth_clients` (`id`, `user_id`, `name`, `secret`, `provider`, `redirect`, `personal_access_client`, `password_client`, `revoked`, `created_at`, `updated_at`) VALUES
(1, NULL, 'Laravel Personal Access Client', 'U3BJ2PRVo0RRtK9BUnkfUrNbiLXAflS5fEKv34BQ', NULL, 'http://localhost', 1, 0, 0, '2025-01-24 07:06:48', '2025-01-24 07:06:48'),
(2, NULL, 'Laravel Password Grant Client', 'axDVWxEtLmakfNLdNQRD3ammuvQvbkFFni88AupM', 'users', 'http://localhost', 0, 1, 0, '2025-01-24 07:06:48', '2025-01-24 07:06:48');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oauth_personal_access_clients`
--

CREATE TABLE `oauth_personal_access_clients` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `client_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `oauth_personal_access_clients`
--

INSERT INTO `oauth_personal_access_clients` (`id`, `client_id`, `created_at`, `updated_at`) VALUES
(1, 1, '2025-01-24 07:06:48', '2025-01-24 07:06:48');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oauth_refresh_tokens`
--

CREATE TABLE `oauth_refresh_tokens` (
  `id` varchar(100) NOT NULL,
  `access_token_id` varchar(100) NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `oauth_refresh_tokens`
--

INSERT INTO `oauth_refresh_tokens` (`id`, `access_token_id`, `revoked`, `expires_at`) VALUES
('0042377cc420c08cb1553e32c85552684ecd21e5bd736fd01d8654ec4c31c6f58ec8415ed12c4449', '12be649ed3fc1d647bf3f1dbe6faffdc376d9610bc0fa158f0f2e2453bc116d0a037cdbe67275389', 0, '2026-01-24 06:18:58'),
('078a7780cc2cfb040520fa0d11f7a325f1c9b8ee145b4f45ae8ee8cf7e8789a8a8a0c3662fd57917', '5cb3beb0d0d326bee5e526783dbc0a1aa1e2553b373f9509ee3e5ece7114e7db234adc528fc8cc9f', 0, '2026-01-24 06:39:43'),
('0b4b3b65aa92768599f0d621d695273450a4835a1a76b535d8a64427345f54552d48961b0cbf188c', 'a960983e69c878f6269f8f75458510fccd406340e68445e93c2a1c12cc6061d2c23388f41bc24f60', 0, '2026-01-24 09:00:46'),
('0b6aa7cc5e9103ea5337613cb51d908e7da4a397d8e715721157f26b03e98b9a0371d965879bcdbf', '68ed3076982fe771cc3df5a43a4dcf3c5106e7c7c262ec1f0221a34016fc5719ce09a8484a88db69', 0, '2026-01-24 01:26:40'),
('100d2b0342084fdb68359350e7b757bc7bc43f3d98869bc702d17359a8a2f2433b05ab36b0b333f6', '7015f639693a4fbdd746e1243ecdcdfec76cf614b4545624e6ebd633765ae877f29f4b3a19acf2ba', 0, '2026-01-24 06:34:59'),
('115a36eda0abb086f41292d060991579be05afd87f9168539547f6f270b31313fa9c236035bb62bb', 'ee7366e52703f91704707bc0c807b41663eb3762de83dee7816e3b44b231aafbdf5921341a1997d6', 0, '2026-01-24 01:28:00'),
('13b9efc634ff56cf29ed7ac0455dcf2d44bb39a07666b72f45fa0e360bf0839a8744537766b1162a', '5fc37e810d33f3ab4e0dd42869f6286bd2daff329b63ab0e75a4c419d8b624ed0d6741044d67581b', 0, '2026-01-24 11:19:44'),
('1869928f367a6be61facc6328452de5c808974d486b24233d46f2e336f91eda3d5b85bf5da630b4e', '833e501865be7d37e7ee82816551a6ef00d64ce73edcf3d0e06f013663ed06835500d4977856d6b5', 0, '2026-01-24 11:24:33'),
('1c08468394ac7fc42397bc6f91a413f82323a79a87c9535ea95e158b5c8eaaff6cb87a33326bd4be', 'a5193eeb8d2a9d3cb0fc4059245afa80ea5f58ba05a04b0f2357230e328a6cc42623d41a3d7fef7f', 0, '2026-01-24 06:39:42'),
('1f4c64dda991f18a8f98d0b0740a415930fc56934daa5ea1c7a2569b68e01ac4697fd357ac9ef7df', '5ed02cd1c2613e5b81f740843595d889d5b8927bf333de49412c110ceee54a19a5aca2a39fd6ab61', 0, '2026-01-24 01:26:22'),
('21cc47d549ef20492514055ff29c63a824ff332b44ca56a9c29f7e16704eededd447b8b22270b637', 'e15d5deb15b085dd43501c92bbf25463cc746622e59b099d0d54c7e8f7b4b23fc9fffbf1f7b30b8f', 0, '2026-01-24 06:31:47'),
('253ef58b9caa676d4158cb03cb178493287f1c94bbd7df5d2718d13f9e829f9ca6d97bf64a9d8678', '88c9b2fb15fc551f6aee08d600a4d3325b18f9807e16134a1d7c87c060cd66e39b6e43feca63fcc5', 0, '2026-01-24 06:30:07'),
('2be1631390e037da8b7eb4d638bb6a6bf8dd91e115c3b9f8caed618e338bce6602c5f570ea28c303', '05c8c0ef84d6a9f5e5845b2b2123ef226f0ac38a5c65fb3005ce59965a3c4bd14ac024dd4013b798', 0, '2026-01-24 06:28:37'),
('3834b0629272225cd4a98808f4703878513a6eb6e19f20b978e92abbc7048b11928bb3acf6bbfd34', '4d2929fbf0322427f211b6836e0a2e2dcd694c990e9907a1050b9429b9481dccaf8c41d1337ede8b', 0, '2026-01-24 06:35:29'),
('3a2f26c4bd66972b29e313b3c8df6dc923a8868ff1eaac195e282c7b143d99c62a3cfc5f718d37cf', '36ff5e878c924a63ddce6386c91c9425a1285b8ee0ec6c26ef175a1a08f29705bf649a81d04dc781', 0, '2026-01-24 06:25:06'),
('3cb292a3bcc7bb723e32a8131c4aacd24ca0000e2ed15f02a3842f0529a6520a2bc3ab82b7a6cc05', 'bf95a17cf523dbe0581152e9316ca0505e29d85b4102b3f992e70e5aaa853fca1a90dc0321ae068c', 0, '2026-01-24 06:29:17'),
('436aa62d3316c7eeff22ed8fc3087862839ee17d2b23f4d06eac3ec3df7f7222801768c26e6dcc63', 'd2bdd7da5f1c5ef6e48133f71f29c9d1ee2d4996194fef80ca1212de4fb128884ad215d4e75dd506', 0, '2026-01-24 06:40:04'),
('4a178e2079d6d48c4c927e0064e4857e8ce06a368c593d880379f19bb6927eaa858015bb84875f33', '448dd7b79e73b13856cee6486dc09c022e96ae6ee72e5399bdf203d1891eb2d8a01285d9804a3638', 0, '2026-01-24 06:30:37'),
('4aafa0e9a8dffb4c46d09b3600159e3f27b38a936d21e00250ac8a8d5f4aafbd3afc976018bf2d9c', 'b73867ef5163c76672ea030d0e90a2ad8a0c787992159d7e941f737f5e8dbbe87f2146c48c1f7710', 0, '2026-01-24 06:25:28'),
('4c1a65f0938a0ef73cbbef5cebbc11aa218b39b6a5d6589039abc7d3ce5223c7fe95ba58b9929209', '3fa919dd305a339f0dfe7cb548a74e95daad1780bbf31a6eb0f67fe61823088aa9b20a38507548e4', 0, '2026-01-24 06:22:42'),
('50398b971211c30a6a4701a78d2e26672623d79ffc2189ee0991cb090384a5da401f8cc8fe0989ba', '149db9ba8732aa14fb8747530756f998fee0960daf60d4029363c5d6f02227121a3005c59a40931e', 0, '2026-01-24 10:03:18'),
('55f0a498ae6832d44a2f521861ffa74992728d31b9320dd72f21a8fa217fac94b176398394232414', 'b227765476619a39832681a7ea332e75bfcda5077834336dae445e8c88e871a5329739d01c1bf988', 0, '2026-01-24 06:41:36'),
('583685264916fd3e9680a29af0541c8c9b3b9976e846fb1accf3b1629a5f2b538020313c48820722', '139e46130ff46081d9ba3a91a5810ea1290163ba52a20fe42fb0956c1a60da8d6d9a7c31f7b989e0', 0, '2026-01-24 06:39:27'),
('5d4a095b2a985d1e6e9ecd0039f91c9a97564ad18f4b9e724a0e535d3fd9006ecf668b3c20947fd9', '2f66a85fe853ad63d5520b23cd7c16f691a2da6618c64272769b41d379910fe969680e3d3d23820e', 0, '2026-01-24 06:44:24'),
('6307f4419d3c1d21964fb306a16131500f20470ca0e13697dffd6716a65162e9f0fb5986c2f9183e', '3fc11e4339d580b64dc678f108ef2ce127bb39fbdf10e6eea2e342f302d00daa8460ae0517dd59e4', 0, '2026-01-24 06:19:09'),
('6cb4465c109479fd8eca0b55657ee6a73a0148b649c9d0b2c7bfde0a8fb8a92b19e9bf964a7bb105', 'e427a9cf252a456904f56d28ca39342b2197cf709350c0e343d71e34e6081be217c4023e7f76a101', 0, '2026-01-24 06:23:38'),
('6efe6074019064526adbd0bfbb5fad18544d95b98e1187773af8a38b003a8126217d56dd85bb147c', 'cccdc6d4a04da654b0ab8ba2591f329468826af50db91bf8c012422cd19b013b161344b9f28ebfb7', 0, '2026-01-24 06:29:59'),
('71123606810ff7874b4c574920abce42d4b7d7ee115abe0ef968ec8c82219058052f087731d9d501', '1f3f5e6cbf2cd59f97d44ef9fe78f3ed3ac421f60a8fcf2beab6f2fe4b0a75bf071679625eca3a2a', 0, '2026-01-24 06:17:34'),
('71add1af5647aa70af62a3cf756b657057e133efc1c4481cf7a8e1673f1f81279d9fcc4e8787e516', '9e0eb420698c1e279c94051bbf004f97d4c8bf09e5dd54923621f73ed4f87657d0d38bbb63885ca8', 0, '2026-01-24 05:39:31'),
('7618033dda444319ab4b753f6569356b9b7fa46af6c6ab0ae66022621ffe7fd4532d5a7d8bbd0ccc', 'fb79a51bdc01b77fefa2e170e0a7317058ee701e3b58ca275501d87d6845ad067fcfc40a941290aa', 0, '2026-01-24 10:03:52'),
('7d6a3f15fd7bb8c9f8c24d68cf65a3d66e0d9c53a43471373f5b4e3a08662596ade664d67ab396b5', '5d510d5d19e2998ee0447e300d07b9e2dae63c0527bdb91ab83519e21f3d5c27f4f05c44d48d8dc7', 0, '2026-01-24 06:37:09'),
('7e493036db333bf67c84f43aa984f29a1657c297fc6e2dc64a76d45ebc1e436a327c9523d4c953ad', '5596bfbf8f6c299344ec0e8f7b673e79f380c2700055c12b50fc66144b911398469b987af2f1d40a', 0, '2026-01-24 09:01:39'),
('82c3c54b85e322ff5314bf8c5873ad4f6da68334d0671665aee73f401e3593571730ca2b1db22c92', '481e504829ca2833190243e114b43217d45c8d9193a86347e31fb413a29ca42c766ecde6049a5870', 0, '2026-01-24 11:14:57'),
('8ce4406c709ee3e52056a6e3b6a96d6543c19c04fd574051c49fbb3ce03323cb80455b7bbfa40a1c', 'c3955876fc2342da473c0bd334eb98570329a4ea6a8c916f3a0db13b4306ab161575a37a9de085d1', 0, '2026-01-24 06:41:44'),
('92df1020776c0f301bbd43d3d240bb9db3ddd81833b15b623a370d3f47494c343b1dfb9be5a0c935', 'f1dc3d721ba600432bf06ff469d3f88d052a73e89abd8e22fbf84485b0aaf15978e769600cd407ca', 0, '2026-01-24 01:08:02'),
('9402ff4e9ee9e7a2405129aaac31de2adfddeef279fc3a78c040a4a86dedf309d52f98dae3e61663', 'f7874b112dd109379ca5b48240f5d3268b17cc4cf19fc266de226b71bd51444e4f9b87362655ec22', 0, '2026-01-24 06:39:19'),
('97d1aa3062139ad9233c9b8c56748dc5f316939acf0c31c3e438825b9af03e495428ebad583e12d9', '9dba704025ce71a8917ef2cfb5376956693cc16c39b2ca13ae10fdc90d5c222370904151ae4149fe', 0, '2026-01-24 06:15:18'),
('a010f6c2abc105eddcc4b9fa6536828575c49cd222b31095202ef3169eebb80d2b3fa91c3c6b3eec', '3648fe0f4350196a0ebc75e024c2022a4c48f480949228250ea6c31d6971358aa2f9f6f8c8168525', 0, '2026-01-24 11:16:27'),
('aa7ad5548ba5990cb2bef6502618b2caf53db0c0363ebdb77f78745ff6535b0404e601bbdc0e5b72', '3b1b4c6ec74eaf0d2c9f43b1f53499a641d6bbd762ac848914809c23c98c69dc4309a2b0d23f1681', 0, '2026-01-24 06:40:27'),
('af477e9b55f7551e9fc0895972b44ac95c29117bef59283ccee70663d11c9a29072b2e8c563265bc', '1677effe763d33a5d741a41f2d9d8e33c3e4297500370007a5b56919a08890912e4e83ba3f29807c', 0, '2026-01-24 11:23:32'),
('b30c2afad7bd1490edef5cd4a0bdbe6103a2d9554b84220a3ee951001b7017c331f495601c3e0dfd', 'bd3cd16d3660833ad704bfb923d01538b57e167e8a925ba5f3a0ed04fbe2391b95a19664d5811802', 0, '2026-01-24 06:19:32'),
('c4d8aadcec560f622e74a864e163aaba7398964dd98da51e29cbb00be805a9dab40e7371765f8ac9', '708fb3b7e4c1caeff0555a5f2af84d252144bed2f8d9c43467a09c38ee6da8ca193985b1a4c2168b', 0, '2026-01-24 06:25:22'),
('ce9f4a91b6e9eb1a910f8dc683a8600d25435b90bfe7efa6fae268dbd0a1329f869f7ee6cafb3843', '2fc890d04dd11cda8c0b48e23f944020e5a504489a5b27ca9c60c74c9bed3d4f6c5a55089c8d7069', 0, '2026-01-24 06:42:57'),
('d0e73c3483cf8446f45d40bed01ac26757b724b9f61dee8a06efd0747fe717fad3e3d4092fe75614', 'c8cac6cd7c442a3969f0f41184a4c819082800945cd0b02eb7f9e843083a4845573c7ed1aae69c95', 0, '2026-01-24 01:18:30'),
('d24b40061dd0b632249b3cf8f7205461f99384d1ebccb8294d3f0c04ca053f915bb50a664982ce9d', '357e450ce922aa8e396df0d03761beecc23ad69a2c5a84d22b0ce324c01d0ee79ffb35af3712d4cd', 0, '2026-01-24 01:24:04'),
('dfd2f73e2f5ffcdcb44801c25e6ced2303e8d5d8fd8ab3a4113563ae99e4a7953b2b9bca3f9465fc', '7f2e28e8e2ef81a9a75748a99d89de28323ff7a9a510b2c5f7c05a98c5201d1dbe7515e11ee7ba84', 0, '2026-01-24 08:44:15'),
('f16998074c6aca023920b511fb2c10028df58a97983addea3728e166996e46d0b52b0e0aaf7fd010', 'b50c369061f3b25841c8d2d326ebf733cd8041e8b94539e64d48f29550621a3cca194f3224b86c7c', 0, '2026-01-24 01:36:18'),
('f29854d7c92210738333a17651730b98ed59a3acf4afb055fd53a2063146070c0eef0417cdee3008', '8b58655abaf0912501b7d420ab966560ca847dab1162c3b778934d95d493c5032acf1d3a684791c7', 0, '2026-01-24 07:47:43'),
('fb442b80507c8a28cea812813a29ecd0955dda927203b89fe77776d29f41c9b81dc58cfd25c65466', '6679d4d44772eec2b84e1cb1992bdd02eff0584d229a45a3d9d5d4924b4e69b1ecf2fc17fabd3b26', 0, '2026-01-24 06:42:28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `person`
--

CREATE TABLE `person` (
  `id` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `paterno` varchar(255) NOT NULL,
  `materno` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `person`
--

INSERT INTO `person` (`id`, `nombre`, `paterno`, `materno`) VALUES
(6, 'Alfredo', 'Saánchez', 'Cruz'),
(4, 'Ana', 'Martínez', 'Hernández'),
(3, 'Carlos', 'Morales', 'Díaz'),
(1, 'Juan', 'Pérez', 'López'),
(5, 'Luis', 'Rodríguez', 'Cruz'),
(2, 'María', 'González', 'Ramírez');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `phone`
--

CREATE TABLE `phone` (
  `id` int(10) UNSIGNED NOT NULL,
  `phone` varchar(10) NOT NULL,
  `person_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `phone`
--

INSERT INTO `phone` (`id`, `phone`, `person_id`) VALUES
(6, '5537226462', 3),
(7, '5541265874', 6),
(4, '5551122334', 4),
(1, '5551234567', 1),
(3, '5556789123', 3),
(2, '5559876543', 2),
(5, '5559988776', 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `temporal_person`
--

CREATE TABLE `temporal_person` (
  `nombre` varchar(255) DEFAULT NULL,
  `paterno` varchar(255) DEFAULT NULL,
  `materno` varchar(255) DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL,
  `calle` varchar(255) DEFAULT NULL,
  `numero_exterior` varchar(10) DEFAULT NULL,
  `numero_interior` varchar(10) DEFAULT NULL,
  `colonia` varchar(255) DEFAULT NULL,
  `cp` varchar(10) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `user_type` smallint(6) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `user_type`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Alberto', 'Alberto@example.com', '0000-00-00 00:00:00', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, NULL, NULL, NULL),
(2, 'El grillo sanchez', 'grillo@mikistlilabs.com', NULL, '$2y$10$rACFt.heL/Q0TqCWEeUnauIzMeZmL0vwMV.aaW0XTfC7BkWz3a55e', 2, NULL, '2025-01-24 07:32:12', '2025-01-24 07:32:12');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `address`
--
ALTER TABLE `address`
  ADD PRIMARY KEY (`id`),
  ADD KEY `address_person_id_foreign` (`person_id`),
  ADD KEY `idx_address_person` (`calle`,`numero_exterior`,`numero_interior`,`colonia`,`cp`,`person_id`);

--
-- Indices de la tabla `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indices de la tabla `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indices de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indices de la tabla `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `oauth_access_tokens`
--
ALTER TABLE `oauth_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_access_tokens_user_id_index` (`user_id`);

--
-- Indices de la tabla `oauth_auth_codes`
--
ALTER TABLE `oauth_auth_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_auth_codes_user_id_index` (`user_id`);

--
-- Indices de la tabla `oauth_clients`
--
ALTER TABLE `oauth_clients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_clients_user_id_index` (`user_id`);

--
-- Indices de la tabla `oauth_personal_access_clients`
--
ALTER TABLE `oauth_personal_access_clients`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `oauth_refresh_tokens`
--
ALTER TABLE `oauth_refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_refresh_tokens_access_token_id_index` (`access_token_id`);

--
-- Indices de la tabla `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`email`);

--
-- Indices de la tabla `person`
--
ALTER TABLE `person`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_person_name` (`nombre`,`paterno`,`materno`);

--
-- Indices de la tabla `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indices de la tabla `phone`
--
ALTER TABLE `phone`
  ADD PRIMARY KEY (`id`),
  ADD KEY `phone_person_id_foreign` (`person_id`),
  ADD KEY `idx_phone_person` (`phone`,`person_id`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `address`
--
ALTER TABLE `address`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `oauth_clients`
--
ALTER TABLE `oauth_clients`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `oauth_personal_access_clients`
--
ALTER TABLE `oauth_personal_access_clients`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `person`
--
ALTER TABLE `person`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `phone`
--
ALTER TABLE `phone`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `address`
--
ALTER TABLE `address`
  ADD CONSTRAINT `address_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `phone`
--
ALTER TABLE `phone`
  ADD CONSTRAINT `phone_person_id_foreign` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
