const express = require('express');
const router = express.Router();
const { fullBackup, differentialBackup, logBackup } = require('../controllers/backups_controller');
const { verificarToken } = require('../middlewares/auth_middleware');
const { verificarRol } = require('../middlewares/roles_middleware');

// Solo Admin
router.post('/full', verificarToken, verificarRol([1]), fullBackup);
router.post('/diff', verificarToken, verificarRol([1]), differentialBackup);
router.post('/log', verificarToken, verificarRol([1]), logBackup);

module.exports = router;
