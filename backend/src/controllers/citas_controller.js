const { sql, poolPromise } = require('../config/db');

const programarCita = async (req, res) => {
  try {
    const { idPaciente, idMedico, fecha, hora } = req.body;
    const pool = await poolPromise;

    await pool.request()
      .input('IdPaciente', sql.Int, idPaciente)
      .input('IdMedico', sql.Int, idMedico)
      .input('Fecha', sql.Date, fecha)
      .input('Hora', sql.Time, hora)
      .execute('SP_ProgramarCita');

    res.json({ message: 'Cita programada' });
  } catch (error) {
    res.status(500).json({ message: 'Error al programar cita', error });
  }
};

module.exports = { programarCita };
