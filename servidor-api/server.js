/**
 * Archivo: server.js
 * Descripción: Servidor principal de la API REST para el sistema Salud Rural.
 * Versión optimizada con mapeo flexible, gestión de roles y agendamiento por cupos publicados.
 */

const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const pool = require('./db');

const app = express();

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));
app.use(cors());

/**
 * Middleware: Registrador de peticiones HTTP
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

app.post('/api/pacientes/registro', async (req, res) => {
    const { 
        documento, correo, password, contrasena, clave,
        nombre, nombres, apellidos, 
        fechaNacimiento, fecha_nacimiento, 
        lugarNacimiento, lugar_nacimiento, 
        sexo, rh, 
        estatura, estatura_cm, 
        fechaExpedicion, fecha_expedicion, 
        lugarExpedicion, lugar_expedicion, 
        direccion, vereda, municipio, telefono, eps 
    } = req.body;

    const passwordFinal = password || contrasena || clave;
    const fNacimientoFinal = fechaNacimiento || fecha_nacimiento;
    const lNacimientoFinal = lugarNacimiento || lugar_nacimiento;
    const estFinal = estatura || estatura_cm;
    const fExpFinal = fechaExpedicion || fecha_expedicion;
    const lExpFinal = lugarExpedicion || lugar_expedicion;

    const nombreCompleto = nombre || (nombres && apellidos ? `${nombres} ${apellidos}` : '');

    if (!documento || !passwordFinal || !telefono || !nombreCompleto) {
        return res.status(400).json({ 
            message: 'Los campos documento, password, teléfono y nombre son obligatorios.' 
        });
    }

    const partes = nombreCompleto.trim().split(' ');
    const nFinal = partes.slice(0, 2).join(' ');
    const aFinal = partes.slice(2).join(' ') || 'Sin apellido';

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        let usuarioExistente;
        if (correo && correo.trim() !== '') {
            usuarioExistente = await client.query(
                'SELECT * FROM usuarios WHERE documento = $1 OR correo = $2',
                [documento, correo]
            );
        } else {
            usuarioExistente = await client.query(
                'SELECT * FROM usuarios WHERE documento = $1',
                [documento]
            );
        }

        if (usuarioExistente.rows.length > 0) {
            await client.query('ROLLBACK');
            return res.status(400).json({ message: 'El número de documento o correo ya se encuentra registrado.' });
        }

        const passwordHash = await bcrypt.hash(passwordFinal, 10);
        const correoBD = (correo && correo.trim() !== '') ? correo : null;
        
        const resultadoUsuario = await client.query(
            'INSERT INTO usuarios (documento, correo, password_hash, rol) VALUES ($1, $2, $3, $4) RETURNING id',
            [documento, correoBD, passwordHash, 'paciente']
        );

        const usuarioId = resultadoUsuario.rows[0].id;

        await client.query(
            `INSERT INTO pacientes (
                usuario_id, nombres, apellidos, fecha_nacimiento, lugar_nacimiento, 
                sexo, rh, estatura_cm, fecha_expedicion, lugar_expedicion, 
                direccion, vereda_corregimiento, municipio, telefono, eps
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)`,
            [
                usuarioId, nFinal, aFinal, fNacimientoFinal || null, lNacimientoFinal || null, 
                sexo || null, rh || null, estFinal || null, fExpFinal || null, lExpFinal || null, 
                direccion || '', vereda || '', municipio || '', telefono, eps || ''
            ]
        );

        await client.query('COMMIT');
        res.status(201).json({ message: 'Paciente registrado con éxito.' });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error al registrar el paciente:', error);
        res.status(500).json({ message: 'Error interno del servidor al procesar el registro.' });
    } finally {
        client.release();
    }
});

app.post('/api/pacientes/login', async (req, res) => {
    const { documento, password, contrasena, clave } = req.body;
    const passwordIngresada = password || contrasena || clave;

    if (!documento) {
        return res.status(400).json({ message: 'El documento es obligatorio para iniciar sesión.' });
    }

    try {
        const resultado = await pool.query(
            'SELECT u.*, p.* FROM usuarios u JOIN pacientes p ON u.id = p.usuario_id WHERE u.documento = $1 AND u.rol = $2',
            [documento, 'paciente']
        );

        if (resultado.rows.length === 0) {
            return res.status(401).json({ message: 'Documento no encontrado en el sistema.' });
        }

        const usuario = resultado.rows[0];

        if (passwordIngresada) {
            const passwordValida = await bcrypt.compare(passwordIngresada, usuario.password_hash);
            if (!passwordValida) {
                return res.status(401).json({ message: 'Credenciales inválidas.' });
            }
        } else {
            return res.status(400).json({ message: 'La contraseña es requerida para autenticar.' });
        }

        res.json({ message: 'Login exitoso', paciente: usuario });
    } catch (error) {
        console.error('Error en el login del paciente:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
});

// ==========================================
// 2. MÓDULO DE MÉDICOS
// ==========================================

app.get('/api/doctores', async (req, res) => {
    const { especialidad } = req.query;

    try {
        let consulta = 'SELECT * FROM medicos WHERE estado_validacion = $1';
        let parametros = ['validado'];

        if (especialidad) {
            consulta += ' AND LOWER(especialidad) = LOWER($2)';
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
// 3. MÓDULO DE CITAS MÉDICAS (Modelo de Cupos Publicados)
// ==========================================

/**
 * Endpoint: Listar citas disponibles (Publicadas por el Admin/Hospital)
 */
app.get('/api/citas/disponibles', async (req, res) => {
    const { especialidad } = req.query;

    try {
        let consulta = `
            SELECT c.id AS cita_id, c.fecha_hora, c.motivo, 
                   m.id AS medico_id, m.nombre_completo AS medico_nombre, m.especialidad 
            FROM citas c 
            JOIN medicos m ON c.medico_id = m.id
            WHERE c.paciente_id IS NULL AND c.estado = 'Disponible'
        `;
        let parametros = [];

        if (especialidad) {
            consulta += ' AND LOWER(m.especialidad) = LOWER($1)';
            parametros.push(especialidad);
        }

        consulta += ' ORDER BY c.fecha_hora ASC';

        const resultado = await pool.query(consulta, parametros);
        res.json({ data: { citasDisponibles: resultado.rows } });
    } catch (error) {
        console.error('Error al consultar citas disponibles:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
});

/**
 * Endpoint: Consultar citas agendadas de un paciente específico
 */
app.get('/api/citas', async (req, res) => {
    const { documentoPaciente } = req.query;

    try {
        let consulta = `
            SELECT c.*, p.documento as documento_paciente, m.nombre_completo as medico_nombre, m.especialidad 
            FROM citas c 
            JOIN pacientes p ON c.paciente_id = p.id
            JOIN medicos m ON c.medico_id = m.id
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
 * Endpoint: Reservar un cupo de cita disponible (El paciente toma el horario publicado)
 */
app.put('/api/citas/reservar/:id', async (req, res) => {
    const { id } = req.params; // ID de la cita disponible
    const { paciente_id } = req.body;

    if (!paciente_id) {
        return res.status(400).json({ message: 'El ID del paciente es obligatorio para reservar la cita.' });
    }

    try {
        // Verificar que la cita siga disponible
        const citaLibre = await pool.query(
            "SELECT * FROM citas WHERE id = $1 AND estado = 'Disponible' AND paciente_id IS NULL",
            [id]
        );

        if (citaLibre.rows.length === 0) {
            return res.status(409).json({ message: 'El horario seleccionado ya no se encuentra disponible o ya fue tomado.' });
        }

        // Asignar el paciente y cambiar estado a Agendada
        const citaReservada = await pool.query(
            "UPDATE citas SET paciente_id = $1, estado = 'Agendada' WHERE id = $2 RETURNING *",
            [paciente_id, id]
        );

        res.json({ message: 'Cita reservada correctamente', cita: citaReservada.rows[0] });
    } catch (error) {
        console.error('Error al reservar la cita:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
});

// ==========================================
// 4. INICIO DEL SERVIDOR
// ==========================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor API REST de Salud Rural activo en el puerto ${PORT}`);
});