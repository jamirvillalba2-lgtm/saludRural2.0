# Salud Rural

## Conexión con el backend

La app consume una API REST con base predeterminada
`http://10.0.2.2:3000/api` para un emulador Android. Para un dispositivo físico
o para iOS, configura la IP/host que pueda alcanzar el dispositivo:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000/api
```

La URL debe terminar en `/api`. En producción utiliza HTTPS y elimina las
excepciones de tráfico HTTP de `AndroidManifest.xml` y `ios/Runner/Info.plist`.

El cliente Flutter realiza estas operaciones:

- `POST /pacientes/registro` envía los datos de identidad y contacto, contraseña,
  autorización, estructura OCR (`ocr.frente` y `ocr.reverso`) e imágenes del
  documento en Base64 (`imagenesDocumento.frente/reverso`).
- `POST /pacientes/login` envía `documento` y `password`.
- `GET /doctores?especialidad=...` lista los médicos; el parámetro es opcional.
- `POST /doctores/registro` envía `nombre`, `especialidad` y `numeroRethus`.
- `GET /citas?documentoPaciente=...` lista las citas del paciente.
- `POST /citas` crea una cita. `PUT /citas/:id` actualiza/reagenda y
  `DELETE /citas/:id` la cancela.

El backend debe aceptar JSON UTF-8 y responder con JSON; para las imágenes en
Base64, configura el límite del parser JSON de Express de acuerdo con el tamaño
máximo de los documentos. Al responder `409 Conflict` al agendar o reagendar,
se muestra un mensaje indicando que el horario ya no está disponible.

La aplicación no guarda credenciales, citas ni datos para uso sin conexión.
Los listados se vuelven a consultar al actualizar las pantallas.
