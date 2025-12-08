const { sql, poolPromise } = require('../config/db');

const registrarPaciente = async (req, res) => {
  try {
    const {
      nombres,
      apellidos,
      dni,
      fecha_nacimiento,
      sexo
    } = req.body;

    const pool = await poolPromise;

    await pool.request()
      .input('Nombres', sql.VarChar, nombres)
      .input('Apellidos', sql.VarChar, apellidos)
      .input('DNI', sql.VarChar, dni)
      .input('FechaNacimiento', sql.Date, fecha_nacimiento)
      .input('Sexo', sql.Char, sexo)
      .execute('SP_RegistrarPaciente');

    res.json({ message: 'Paciente registrado correctamente' });

  } catch (error) {
    res.status(500).json({ message: 'Error al registrar paciente', error });
  }
};

module.exports = { registrarPaciente };
