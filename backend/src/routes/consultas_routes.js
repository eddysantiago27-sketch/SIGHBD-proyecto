const express = require('express');
const router = express.Router();
const { registrarConsulta } = require('../controllers/consultas_controller');
const { verificarToken } = require('../middlewares/auth_middleware');

router.post('/registrar', verificarToken, registrarConsulta);

module.exports = router;
