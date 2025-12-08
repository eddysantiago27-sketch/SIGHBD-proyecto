const { sql, poolPromise } = require('../config/db');

// Ajusta estas rutas locales
const PATH_FULL = "D:\\U\\300 par\\IS-382 Gestión de entornos de bases de datos\\BACKUPS\\SIGHBD_FULL.bak";
const PATH_DIFF = "D:\\U\\300 par\\IS-382 Gestión de entornos de bases de datos\\BACKUPS\\SIGHBD_DIFF.bak";
const PATH_LOG  = "D:\\U\\300 par\\IS-382 Gestión de entornos de bases de datos\\BACKUPS\\SIGHBD_LOG.trn";
const fullBackup = async (req, res) => {
    try {
    const pool = await poolPromise;
    await pool.request().query(`
      BACKUP DATABASE SIGHBD 
      TO DISK = '${PATH_FULL}' 
      WITH INIT, FORMAT
    `);
    res.json({ message: "Full Backup creado" });
  } catch (e) {
    res.status(500).json({ message: "Error Full Backup", error: e.message });
  }
};

const differentialBackup = async (req, res) => {
  try {
    const pool = await poolPromise;
    await pool.request().query(`
      BACKUP DATABASE SIGHBD 
      TO DISK = '${PATH_DIFF}' 
      WITH DIFFERENTIAL, INIT
    `);
    res.json({ message: "Differential Backup creado" });
  } catch (e) {
    res.status(500).json({ message: "Error Differential Backup", error: e.message });
  }
};

const logBackup = async (req, res) => {
  try {
    const pool = await poolPromise;
    await pool.request().query(`
      BACKUP LOG SIGHBD 
      TO DISK = '${PATH_LOG}' 
      WITH INIT
    `);
    res.json({ message: "Log Backup creado" });
  } catch (e) {
    res.status(500).json({ message: "Error Log Backup", error: e.message });
  }
};

module.exports = { fullBackup, differentialBackup, logBackup };
