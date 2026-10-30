const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

// Función para inicializar las tablas basadas en tus requerimientos
const initDatabase = async () => {
    try {
        const query = `
            CREATE TABLE IF NOT EXISTS usuarios (
                id SERIAL PRIMARY KEY,
                documento VARCHAR(20) NOT NULL UNIQUE,
                correo VARCHAR(150) NOT NULL UNIQUE,
                password_hash VARCHAR(255) NOT NULL,
                rol VARCHAR(20) NOT NULL DEFAULT 'paciente',
                activo BOOLEAN NOT NULL DEFAULT TRUE,
                creado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS pacientes (
                id SERIAL PRIMARY KEY,
                usuario_id INT NOT NULL UNIQUE REFERENCES usuarios(id) ON DELETE CASCADE,
                tipo_documento VARCHAR(50) NOT NULL DEFAULT 'Cédula de ciudadanía',
                nombres VARCHAR(100) NOT NULL,
                apellidos VARCHAR(100) NOT NULL,
                fecha_nacimiento DATE,
                lugar_nacimiento VARCHAR(100),
                sexo VARCHAR(20),
                rh VARCHAR(5),
                estatura_cm INT,
                fecha_expedicion DATE,
                lugar_expedicion VARCHAR(100),
                direccion VARCHAR(200),
                vereda_corregimiento VARCHAR(100),
                municipio VARCHAR(100),
                telefono VARCHAR(20) NOT NULL,
                eps VARCHAR(100)
            );

            CREATE TABLE IF NOT EXISTS medicos (
                id SERIAL PRIMARY KEY,
                usuario_id INT NOT NULL UNIQUE REFERENCES usuarios(id) ON DELETE CASCADE,
                nombre_completo VARCHAR(200) NOT NULL,
                numero_rethus VARCHAR(50) NOT NULL UNIQUE,
                especialidad VARCHAR(100) NOT NULL,
                confianza_rethus_porcentaje INT DEFAULT 0,
                estado_validacion VARCHAR(30) DEFAULT 'pendiente'
            );

            CREATE TABLE IF NOT EXISTS citas (
                id SERIAL PRIMARY KEY,
                paciente_id INT NOT NULL REFERENCES pacientes(id),
                medico_id INT REFERENCES medicos(id),
                fecha_hora TIMESTAMP NOT NULL,
                motivo TEXT,
                estado VARCHAR(30) DEFAULT 'Agendada'
            );
        `;
        await pool.query(query);
        console.log("Database tables initialized successfully.");
    } catch (err) {
        console.error("Error initializing database tables:", err);
    }
};

initDatabase();

module.exports = pool;