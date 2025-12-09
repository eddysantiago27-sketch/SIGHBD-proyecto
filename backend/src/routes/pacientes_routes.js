const express = require('express');
const router = express.Router();

const { registrarPaciente } = require('../controllers/pacientes_controller');
const { verificarToken } = require('../middlewares/auth_middleware');
const { VerificarNivel } = require('../middlewares/nivel_middleware');

router.post(
  '/registrar',
  verificarToken,
  VerificarNivel(4),
  registrarPaciente
);

module.exports = router;