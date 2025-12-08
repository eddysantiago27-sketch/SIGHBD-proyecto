const express = require('express');
const router = express.Router();
const { verLogs } = require('../controllers/auditoria_controller');
const { verificarToken } = require('../middlewares/auth_middleware');
const { verificarRol } = require('../middlewares/roles_middleware');

router.get('/', verificarToken, verificarRol([1]), verLogs);

module.exports = router;
