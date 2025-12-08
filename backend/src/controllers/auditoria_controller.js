const { sql, poolPromise } = require('../config/db');

const verLogs = async (req, res) => {
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .query("SELECT * FROM AuditLog ORDER BY Fecha DESC");

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener logs' });
  }
};

module.exports = { verLogs };
