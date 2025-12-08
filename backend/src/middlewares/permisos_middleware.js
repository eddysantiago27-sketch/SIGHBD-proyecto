const { sql, poolPromise } = require('../config/db');

const verificarPermiso = (permiso) => {
  return async (req, res, next) => {
    try {
      const pool = await poolPromise;
      const result = await pool.request()
        .input('IdRol', sql.Int, req.user.rol)
        .query(`
          SELECT 1 FROM Permisos 
          WHERE IdRol = @IdRol AND NombrePermiso = '${permiso}'
        `);

      if (result.recordset.length === 0) {
        return res.status(403).json({ message: 'Permiso denegado' });
      }

      next();
    } catch (error) {
      res.status(500).json({ message: 'Error validando permisos' });
    }
  };
};

module.exports = { verificarPermiso };
