const express = require('express');
const cors = require('cors');
const app = express();

app.use(express.json());
app.use(cors());

// ==========================================
// REGISTRADOR DE PETICIONES (MONITOR DE CONEXIÓN)
// ==========================================
app.use((req, res, next) => {
    const horaActual = new Date().toLocaleTimeString();
    console.log(`\n--------------------------------------------------`);
    console.log(`[${horaActual}] 📥 ¡PETICIÓN RECIBIDA DESDE EL MÓVIL!`);
    console.log(`Método: ${req.method} | Ruta: ${req.url}`);
    console.log(`Cuerpo (Body) recibido:`, JSON.stringify(req.body, null, 2));
    console.log(`--------------------------------------------------\n`);
    next();
});

// ==========================================
// BASE DE DATOS EN MEMORIA
// ==========================================
let pacientes = [
    { 
        id: 1, 
        nombre: "Jamir Villalba", 
        documento: "12345", 
        correo: "jamir@saludrural.com", 
        direccion: "Vereda El Carmen" 
    }
];

let doctores = [
    { 
        id: 'doc-1', 
        nombre: "Dra. Rural", 
        especialidad: "Medicina general", 
        sedeAsignada: "Puesto de Salud San Juan", 
        rethus: "ETH-98765" 
    }
];

let citas = [
    { 
        id: 'cita-1', 
        pacienteId: 1, 
        documentoPaciente: "12345",
        doctorId: 'doc-1', 
        especialidad: "Medicina general", 
        sede: "Puesto de Salud San Juan", 
        fecha: "2026-09-28", 
        hora: "09:00", 
        estado: "PROGRAMADA" 
    }
];

// ==========================================
// 1. MÓDULO DE PACIENTES
// ==========================================
app.post('/api/pacientes/registro', (req, res) => {
    const { nombre, documento, correo, direccion } = req.body;
    const existe = pacientes.find(p => p.documento === documento);
    if (existe) {
        return res.status(400).json({ message: "El número de documento ya está registrado." });
    }

    const nuevoPaciente = {
        id: pacientes.length + 1,
        nombre: nombre || "Sin Nombre",
        documento: documento || "",
        correo: correo || "",
        direccion: direccion || ""
    };

    pacientes.push(nuevoPaciente);
    res.status(201).json({ message: "Paciente registrado con éxito", paciente: nuevoPaciente });
});

app.post('/api/pacientes/login', (req, res) => {
    const { documento } = req.body;
    const paciente = pacientes.find(p => p.documento === documento);
    
    if (paciente) {
        res.json({ message: "Login exitoso", paciente });
    } else {
        res.status(401).json({ message: "Documento no encontrado en el sistema." });
    }
});

// ==========================================
// 2. MÓDULO DE MÉDICOS
// ==========================================
app.get('/api/doctores', (req, res) => {
    const { especialidad } = req.query;
    if (especialidad) {
        const filtrados = doctores.filter(d => 
            d.especialidad.toLowerCase() === especialidad.toLowerCase()
        );
        return res.json(filtrados);
    }
    res.json(doctores);
});

app.post('/api/doctores/registro', (req, res) => {
    const { nombre, especialidad, sedeAsignada, rethus } = req.body;
    const nuevoDoctor = {
        id: 'doc-' + (doctores.length + 1),
        nombre: nombre || "Dr. Desconocido",
        especialidad: especialidad || "Medicina general",
        sedeAsignada: sedeAsignada || "Centro de Salud Rural",
        rethus: rethus || "ETH-00000"
    };

    doctores.push(nuevoDoctor);
    res.status(201).json({ message: "Médico registrado con éxito", doctor: nuevoDoctor });
});

// ==========================================
// 3. MÓDULO DE CITAS (ONLINE-FIRST CRUD)
// ==========================================
app.get('/api/citas', (req, res) => {
    const { documentoPaciente } = req.query;
    let resultadoCitas = citas;

    if (documentoPaciente) {
        resultadoCitas = citas.filter(c => c.documentoPaciente === documentoPaciente);
    }

    res.json({
        data: {
            citas: resultadoCitas
        }
    });
});

app.post('/api/citas', (req, res) => {
    const { doctorId, fecha, hora, documentoPaciente } = req.body;

    const horarioOcupado = citas.find(c => c.doctorId === doctorId && c.fecha === fecha && c.hora === hora && c.estado === "PROGRAMADA");
    if (horarioOcupado) {
        return res.status(409).json({ message: 'Horario ocupado' });
    }

    const nuevaCita = {
        id: 'cita-' + (citas.length + 1),
        pacienteId: req.body.pacienteId || 1,
        documentoPaciente: documentoPaciente || "12345",
        doctorId: doctorId || 'doc-1',
        especialidad: req.body.especialidad || "Medicina general",
        sede: req.body.sede || "Centro de Salud Rural",
        fecha: fecha || "2026-10-01",
        hora: hora || "08:00",
        estado: "PROGRAMADA"
    };

    citas.push(nuevaCita);
    res.status(201).json({ message: "Cita agendada correctamente", cita: nuevaCita });
});

app.put('/api/citas/:id', (req, res) => {
    const id = req.params.id;
    const index = citas.findIndex(c => c.id === id);

    if (index === -1) {
        return res.status(404).json({ message: "Cita no encontrada." });
    }

    citas[index] = {
        ...citas[index],
        fecha: req.body.fecha || citas[index].fecha,
        hora: req.body.hora || citas[index].hora,
        estado: req.body.estado || citas[index].estado
    };

    res.json({ message: "Cita actualizada correctamente", cita: citas[index] });
});

app.delete('/api/citas/:id', (req, res) => {
    const id = req.params.id;
    const index = citas.findIndex(c => c.id === id);

    if (index === -1) {
        return res.status(404).json({ message: "Cita no encontrada." });
    }

    citas.splice(index, 1);
    res.status(204).send();
});

// ==========================================
// INICIO DEL SERVIDOR
// ==========================================
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Servidor API REST de Salud Rural activo en http://localhost:${PORT}`);
});