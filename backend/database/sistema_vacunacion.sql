CREATE TABLE estado (
  id_estado INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL
);

CREATE TABLE municipio (
  id_municipio INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  id_estado INT NOT NULL,
  CONSTRAINT fk_mun_est FOREIGN KEY (id_estado) REFERENCES estado(id_estado)
);

CREATE TABLE parroquia (
  id_parroquia INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  id_municipio INT NOT NULL,
  CONSTRAINT fk_par_mun FOREIGN KEY (id_municipio) REFERENCES municipio(id_municipio)
);

CREATE TABLE subregion (
  id_subregion INT AUTO_INCREMENT PRIMARY KEY,
  nombre_subregion VARCHAR(100) NOT NULL,
  id_municipio INT NOT NULL,
  CONSTRAINT fk_sub_mun FOREIGN KEY (id_municipio) REFERENCES municipio(id_municipio)
);

CREATE TABLE centros (
  id_centros INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  direccion TEXT NOT NULL,
  telf VARCHAR(30),
  id_parroquia INT NOT NULL,
  CONSTRAINT fk_cen_par FOREIGN KEY (id_parroquia) REFERENCES parroquia(id_parroquia)
);

CREATE TABLE roles (
  id_rol INT AUTO_INCREMENT PRIMARY KEY,
  nombre_rol VARCHAR(50) NOT NULL
);

CREATE TABLE usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre_usuario VARCHAR(50) NOT NULL,
  clave VARCHAR(255) NOT NULL,
  id_rol INT NOT NULL,
  id_centros INT,
  CONSTRAINT fk_usu_rol FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
  CONSTRAINT fk_usu_cen FOREIGN KEY (id_centros) REFERENCES centros(id_centros)
);

CREATE TABLE logs (
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  accion VARCHAR(50) NOT NULL,
  tabla_afectada VARCHAR(100) NOT NULL,
  descripcion_detalle TEXT,
  fecha_hora TIMESTAMP,
  CONSTRAINT fk_log_usu FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE fabricante (
  id_fabricante INT AUTO_INCREMENT PRIMARY KEY,
  nombre_laboratorio VARCHAR(150) NOT NULL,
  pais_origen VARCHAR(100)
);

CREATE TABLE vacunas (
  id_vacuna INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  id_fabricante INT,
  descripcion TEXT,
  CONSTRAINT fk_vac_fab FOREIGN KEY (id_fabricante) REFERENCES fabricante(id_fabricante)
);

CREATE TABLE esquema_vacunacion (
  id_esquema INT AUTO_INCREMENT PRIMARY KEY,
  id_vacuna INT NOT NULL,
  nro_dosis INT NOT NULL,
  dias_intervalo INT DEFAULT 0,
  edad_minima_meses INT DEFAULT 0,
  CONSTRAINT fk_esq_vac FOREIGN KEY (id_vacuna) REFERENCES vacunas(id_vacuna)
);

CREATE TABLE lote_vacuna (
  id_lote INT AUTO_INCREMENT PRIMARY KEY,
  id_vacuna INT NOT NULL,
  numero_lote VARCHAR(100) NOT NULL,
  fecha_vencimiento DATE NOT NULL,
  cantidad_recibida INT NOT NULL,
  cantidad_disponible INT NOT NULL,
  id_centros INT NOT NULL,
  CONSTRAINT fk_lot_vac FOREIGN KEY (id_vacuna) REFERENCES vacunas(id_vacuna),
  CONSTRAINT fk_lot_cen FOREIGN KEY (id_centros) REFERENCES centros(id_centros)
);

CREATE TABLE personas (
  id_personas INT AUTO_INCREMENT PRIMARY KEY,
  cedula VARCHAR(20) NOT NULL,
  nombres VARCHAR(100) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  correo VARCHAR(100),
  telefono VARCHAR(30)
);

CREATE TABLE registrodosis (
  id_registro INT AUTO_INCREMENT PRIMARY KEY,
  id_personas INT NOT NULL,
  id_vacuna INT NOT NULL,
  id_lote INT NOT NULL,
  id_centros INT NOT NULL,
  id_usuario INT NOT NULL,
  fecha_aplicacion TIMESTAMP,
  nro_dosis INT NOT NULL,
  CONSTRAINT fk_reg_per FOREIGN KEY (id_personas) REFERENCES personas(id_personas),
  CONSTRAINT fk_reg_vac FOREIGN KEY (id_vacuna) REFERENCES vacunas(id_vacuna),
  CONSTRAINT fk_reg_lot FOREIGN KEY (id_lote) REFERENCES lote_vacuna(id_lote),
  CONSTRAINT fk_reg_cen FOREIGN KEY (id_centros) REFERENCES centros(id_centros),
  CONSTRAINT fk_reg_usu FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE examenes (
  id_examenes INT AUTO_INCREMENT PRIMARY KEY,
  id_personas INT NOT NULL,
  nombre_archivo VARCHAR(255) NOT NULL,
  ruta_archivo VARCHAR(255) NOT NULL,
  fecha_carga TIMESTAMP,
  CONSTRAINT fk_exa_per FOREIGN KEY (id_personas) REFERENCES personas(id_personas)
);

CREATE TABLE certsalud (
  id_cert INT AUTO_INCREMENT PRIMARY KEY,
  id_personas INT NOT NULL,
  id_examenes INT,
  id_registro INT,
  codigo_verificacion VARCHAR(64),
  estatus VARCHAR(50),
  observaciones TEXT,
  CONSTRAINT fk_cer_per FOREIGN KEY (id_personas) REFERENCES personas(id_personas),
  CONSTRAINT fk_cer_exa FOREIGN KEY (id_examenes) REFERENCES examenes(id_examenes),
  CONSTRAINT fk_cer_reg FOREIGN KEY (id_registro) REFERENCES registrodosis(id_registro)
);
