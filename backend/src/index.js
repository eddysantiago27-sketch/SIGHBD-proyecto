const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth_routes');
const pacientesRoutes = require('./routes/pacientes_routes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/pacientes', pacientesRoutes);

const citasRoutes = require('./routes/citas_routes');
const consultasRoutes = require('./routes/consultas_routes');

app.use('/api/citas', citasRoutes);
app.use('/api/consultas', consultasRoutes);

const auditoriaRoutes = require('./routes/auditoria_routes');
app.use('/api/auditoria', auditoriaRoutes);

const backupsRoutes = require('./routes/backups_routes');
app.use('/api/backups', backupsRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
