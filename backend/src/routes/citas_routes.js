const express = require('express');
const router = express.Router();
const { programarCita } = require('../controllers/citas_controller');
const { verificarToken } = require('../middlewares/auth_middleware');

router.post('/programar', verificarToken, programarCita);

module.exports = router;
