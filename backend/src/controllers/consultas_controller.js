const { sql, poolPromise } = require('../config/db');

const registrarConsulta = async (req, res) => {
  try {
    const { idCita, diagnostico, tratamiento } = req.body;
    const pool = await poolPromise;

    await pool.request()
      .input('IdCita', sql.Int, idCita)
      .input('Diagnostico', sql.VarChar, diagnostico)
      .input('Tratamiento', sql.VarChar, tratamiento)
      .execute('SP_RegistrarConsulta');

    res.json({ message: 'Consulta registrada' });
  } catch (error) {
    res.status(500).json({ message: 'Error al registrar consulta', error });
  }
};

module.exports = { registrarConsulta };
