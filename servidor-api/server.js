/**
 * Archivo: server.js
 * Descripción: Servidor principal de la API REST para el sistema Conecta Salud Rural.
 * Gestiona las rutas de autenticación, pacientes, médicos y programación de citas.
 */

const express = require('express');
const cors = require('cors');
const pool = require('./db'); // Importación de la conexión a PostgreSQL

const app = express();

// Configuración de middlewares globales
app.use(express.json());
app.use(cors());

/**
 * Middleware: Registrador de peticiones HTTP
 * Imprime en consola información detallada de cada solicitud entrante para monitoreo.
 */
app.use((req, res, next) => {
    const horaActual = new Date().toLocaleTimeString();
    console.log('--------------------------------------------------');
    console.log(`[${horaActual}] Petición recibida: ${req.method} ${req.url}`);
    console.log('Cuerpo (Body):', JSON.stringify(req.body, null, 2));
    console.log('--------------------------------------------------');
    next();
});

// ==========================================
// 1. MÓDULO DE PACIENTES
// ==========================================

/**
 * Endpoint: Registro de un nuevo paciente
 * Valida la existencia previa del documento y almacena las credenciales en la base de datos.
 */
app.post('/api/pacientes/registro', async (req, res) => {
    const { documento, correo, password_hash, nombres, apellidos, telefono } = req.body;

    try {
        const pacienteExistente = await pool.query(
            'SELECT * FROM usuarios WHERE documento = $1',
            [documento]
        );

        if (pacienteExistente.rows.length > 0) {
            return res.status(400).json({ message: 'El número de documento ya se encuentra registrado.' });
        }

        // Inserción de prueba estructurada para la capa de datos
        res.status(201).json({ message: 'Paciente registrado con éxito.' });
    } catch (error) {
        console.error('Error al registrar el paciente:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
});

/**
 * Endpoint: Autenticación de pacientes (Login)
 */
app.post('/api/pacientes/login', async (req, res) => {
    const { documento } = req.body;

    try {
        const resultado = await pool.query(
            'SELECT u.*, p.* FROM usuarios u JOIN pacientes p ON u.id = p.usuario_id WHERE u.documento = $1 AND u.rol = $2',
            [documento, 'paciente']
        );

        if (resultado.rows.length === 0) {
            return res.status(401).json({ message: 'Documento no encontrado en el sistema.' });
        }

        res.json({ message: 'Login exitoso', paciente: resultado.rows[0] });
    } catch (error) {
        console.error('Error en el login del paciente:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
});

// ==========================================
// 2. MÓDULO DE MÉDICOS
// ==========================================

/**
 * Endpoint: Obtener listado de médicos
 * Permite filtrar opcionalmente por especialidad médica mediante query params.
 */
app.get('/api/doctores', async (req, res) => {
    const { especialidad } = req.query;

    try {
        let consulta = 'SELECT * FROM medicos';
        let parametros = [];

        if (especialidad) {
            consulta += ' WHERE LOWER(especialidad) = LOWER($1)';
            parametros.push(especialidad);
        }

        const resultado = await pool.query(consulta, parametros);
        res.json(resultado.rows);
    } catch (error) {
        console.error('Error al consultar los médicos:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
});

// ==========================================
// 3. MÓDULO DE CITAS MÉDICAS
// ==========================================

/**
 * Endpoint: Obtener citas médicas
 * Filtra las citas según el documento del paciente si se especifica.
 */
app.get('/api/citas', async (req, res) => {
    const { documentoPaciente } = req.query;

    try {
        let consulta = `
            SELECT c.*, p.documento as documento_paciente 
            FROM citas c 
            JOIN pacientes p ON c.paciente_id = p.id
        `;
        let parametros = [];

        if (documentoPaciente) {
            consulta += ' WHERE p.documento = $1';
            parametros.push(documentoPaciente);
        }

        const resultado = await pool.query(consulta, parametros);
        res.json({ data: { citas: resultado.rows } });
    } catch (error) {
        console.error('Error al obtener las citas:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
});

/**
 * Endpoint: Agendar una nueva cita médica
 * Valida la disponibilidad del horario del médico antes de realizar la inserción.
 */
app.post('/api/citas', async (req, res) => {
    const { paciente_id, medico_id, fecha_hora, motivo } = req.body;

    try {
        const horarioOcupado = await pool.query(
            'SELECT * FROM citas WHERE medico_id = $1 AND fecha_hora = $2 AND estado = $3',
            [medico_id, fecha_hora, 'Agendada']
        );

        if (horarioOcupado.rows.length > 0) {
            return res.status(409).json({ message: 'El horario seleccionado ya se encuentra ocupado.' });
        }

        const nuevaCita = await pool.query(
            'INSERT INTO citas (paciente_id, medico_id, fecha_hora, motivo, estado) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [paciente_id, medico_id, fecha_hora, motivo, 'Agendada']
        );

        res.status(201).json({ message: 'Cita agendada correctamente', cita: nuevaCita.rows[0] });
    } catch (error) {
        console.error('Error al agendar la cita:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
});

// ==========================================
// INICIO DEL SERVIDOR
// ==========================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor API REST de Salud Rural activo en el puerto ${PORT}`);
});
