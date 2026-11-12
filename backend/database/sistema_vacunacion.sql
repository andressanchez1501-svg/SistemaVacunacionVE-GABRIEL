SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- --------------------------------------------------------
-- 1. ESTRUCTURA GEOGRÁFICA Y CENTROS
-- --------------------------------------------------------

CREATE TABLE `estado` (
  `id_estado` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`id_estado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `municipio` (
  `id_municipio` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `id_estado` int(11) NOT NULL,
  PRIMARY KEY (`id_municipio`),
  KEY `id_estado` (`id_estado`),
  CONSTRAINT `fk_municipio_estado` FOREIGN KEY (`id_estado`) REFERENCES `estado` (`id_estado`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `parroquia` (
  `id_parroquia` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `id_municipio` int(11) NOT NULL,
  PRIMARY KEY (`id_parroquia`),
  KEY `id_municipio` (`id_municipio`),
  CONSTRAINT `fk_parroquia_municipio` FOREIGN KEY (`id_municipio`) REFERENCES `municipio` (`id_municipio`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `subregion` (
  `id_subregion` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_subregion` varchar(100) NOT NULL,
  `id_municipio` int(11) NOT NULL,
  PRIMARY KEY (`id_subregion`),
  KEY `id_municipio` (`id_municipio`),
  CONSTRAINT `fk_subregion_municipio` FOREIGN KEY (`id_municipio`) REFERENCES `municipio` (`id_municipio`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `centros` (
  `id_centros` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL,
  `direccion` text NOT NULL,
  `telf` varchar(30) DEFAULT NULL,
  `id_parroquia` int(11) NOT NULL,
  PRIMARY KEY (`id_centros`),
  KEY `id_parroquia` (`id_parroquia`),
  CONSTRAINT `fk_centros_parroquia` FOREIGN KEY (`id_parroquia`) REFERENCES `parroquia` (`id_parroquia`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- 2. SEGURIDAD, USUARIOS Y AUDITORÍA
-- --------------------------------------------------------

CREATE TABLE `roles` (
  `id_rol` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_rol` varchar(50) NOT NULL,
  PRIMARY KEY (`id_rol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_usuario` varchar(50) NOT NULL,
  `clave` varchar(255) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `id_centros` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `nombre_usuario` (`nombre_usuario`),
  KEY `id_rol` (`id_rol`),
  KEY `id_centros` (`id_centros`),
  CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_usuario_centro` FOREIGN KEY (`id_centros`) REFERENCES `centros` (`id_centros`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `logs` (
  `id_log` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `accion` enum('INSERT','UPDATE','DELETE','APROBAR') NOT NULL,
  `tabla_afectada` varchar(100) NOT NULL,
  `descripcion_detalle` text DEFAULT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_log`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `fk_logs_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- 3. CATÁLOGO DE VACUNAS, FABRICANTES, ESQUEMAS E INVENTARIO
-- --------------------------------------------------------

CREATE TABLE `fabricante` (
  `id_fabricante` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_laboratorio` varchar(150) NOT NULL,
  `pais_origen` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_fabricante`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `vacunas` (
  `id_vacuna` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `id_fabricante` int(11) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  PRIMARY KEY (`id_vacuna`),
  KEY `id_fabricante` (`id_fabricante`),
  CONSTRAINT `fk_vacunas_fabricante` FOREIGN KEY (`id_fabricante`) REFERENCES `fabricante` (`id_fabricante`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `esquema_vacunacion` (
  `id_esquema` int(11) NOT NULL AUTO_INCREMENT,
  `id_vacuna` int(11) NOT NULL,
  `nro_dosis` int(11) NOT NULL,
  `dias_intervalo` int(11) NOT NULL DEFAULT 0,
  `edad_minima_meses` int(11) DEFAULT 0,
  PRIMARY KEY (`id_esquema`),
  KEY `id_vacuna` (`id_vacuna`),
  CONSTRAINT `fk_esquema_vacuna` FOREIGN KEY (`id_vacuna`) REFERENCES `vacunas` (`id_vacuna`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `lote_vacuna` (
  `id_lote` int(11) NOT NULL AUTO_INCREMENT,
  `id_vacuna` int(11) NOT NULL,
  `numero_lote` varchar(100) NOT NULL,
  `fecha_vencimiento` date NOT NULL,
  `cantidad_recibida` int(11) NOT NULL CHECK (`cantidad_recibida` >= 0),
  `cantidad_disponible` int(11) NOT NULL CHECK (`cantidad_disponible` >= 0),
  `id_centros` int(11) NOT NULL,
  PRIMARY KEY (`id_lote`),
  KEY `id_vacuna` (`id_vacuna`),
  KEY `id_centros` (`id_centros`),
  CONSTRAINT `fk_lote_vacuna` FOREIGN KEY (`id_vacuna`) REFERENCES `vacunas` (`id_vacuna`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_lote_centro` FOREIGN KEY (`id_centros`) REFERENCES `centros` (`id_centros`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- 4. PACIENTES, APLICACIÓN DE DOSIS Y CERTIFICADOS
-- --------------------------------------------------------

CREATE TABLE `personas` (
  `id_personas` int(11) NOT NULL AUTO_INCREMENT,
  `cedula` varchar(20) NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `telefono` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id_personas`),
  UNIQUE KEY `cedula` (`cedula`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `registrodosis` (
  `id_registro` int(11) NOT NULL AUTO_INCREMENT,
  `id_personas` int(11) NOT NULL,
  `id_vacuna` int(11) NOT NULL,
  `id_lote` int(11) NOT NULL,
  `id_centros` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `fecha_aplicacion` timestamp NULL DEFAULT current_timestamp(),
  `nro_dosis` int(11) NOT NULL,
  PRIMARY KEY (`id_registro`),
  KEY `id_personas` (`id_personas`),
  KEY `id_vacuna` (`id_vacuna`),
  KEY `id_centros` (`id_centros`),
  KEY `id_usuario` (`id_usuario`),
  KEY `id_lote` (`id_lote`),
  CONSTRAINT `fk_registrodosis_persona` FOREIGN KEY (`id_personas`) REFERENCES `personas` (`id_personas`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_registrodosis_vacuna` FOREIGN KEY (`id_vacuna`) REFERENCES `vacunas` (`id_vacuna`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_registrodosis_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote_vacuna` (`id_lote`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_registrodosis_centro` FOREIGN KEY (`id_centros`) REFERENCES `centros` (`id_centros`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_registrodosis_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `examenes` (
  `id_examenes` int(11) NOT NULL AUTO_INCREMENT,
  `id_personas` int(11) NOT NULL,
  `nombre_archivo` varchar(255) NOT NULL,
  `ruta_archivo` varchar(255) NOT NULL,
  `fecha_carga` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_examenes`),
  KEY `id_personas` (`id_personas`),
  CONSTRAINT `fk_examenes_persona` FOREIGN KEY (`id_personas`) REFERENCES `personas` (`id_personas`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `certsalud` (
  `id_cert` int(11) NOT NULL AUTO_INCREMENT,
  `id_personas` int(11) NOT NULL,
  `id_examenes` int(11) DEFAULT NULL,
  `id_registro` int(11) DEFAULT NULL,
  `codigo_verificacion` varchar(64) DEFAULT NULL,
  `estatus` varchar(50) DEFAULT 'Pendiente',
  `observaciones` text DEFAULT NULL,
  PRIMARY KEY (`id_cert`),
  UNIQUE KEY `codigo_verificacion` (`codigo_verificacion`),
  KEY `id_personas` (`id_personas`),
  KEY `id_examenes` (`id_examenes`),
  KEY `id_registro` (`id_registro`),
  CONSTRAINT `fk_certsalud_persona` FOREIGN KEY (`id_personas`) REFERENCES `personas` (`id_personas`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_certsalud_examenes` FOREIGN KEY (`id_examenes`) REFERENCES `examenes` (`id_examenes`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_certsalud_registro` FOREIGN KEY (`id_registro`) REFERENCES `registrodosis` (`id_registro`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
