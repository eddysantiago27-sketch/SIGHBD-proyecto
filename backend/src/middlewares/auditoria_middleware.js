const { sql, poolPromise } = require('../config/db');

const setUsuarioContexto = async (req, res, next) => {
  try {
    const pool = await poolPromise;
    await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query("EXEC sp_set_session_context 'UsuarioID', @userId");

    next();
  } catch (error) {
    console.error("Error en auditoría:", error);
    next();
  }
};

module.exports = { setUsuarioContexto };
