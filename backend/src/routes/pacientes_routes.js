const express = require('express');
const router = express.Router();

const { registrarPaciente } = require('../controllers/pacientes_controller');
const { verificarToken } = require('../middlewares/auth_middleware');
const { verificarPermiso } = require('../middlewares/permisos_middleware');

router.post(
  '/registrar',
  verificarToken,
  verificarNivel(4),
  registrarPaciente
);

module.exports = router;