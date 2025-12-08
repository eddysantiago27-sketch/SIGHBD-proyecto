const { sql, poolPromise } = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const login = async (req, res) => {
  try {
    const { usuario, password } = req.body;
    const pool = await poolPromise;

    const result = await pool.request()
      .input('usuario', sql.VarChar, usuario)
      .query("SELECT * FROM Usuarios WHERE Usuario = @usuario");

    if (result.recordset.length === 0) {
      return res.status(401).json({ message: 'Usuario no encontrado' });
    }

    const user = result.recordset[0];
    const valid = bcrypt.compareSync(password, user.PasswordHash);

    if (!valid) {
      return res.status(401).json({ message: 'Contraseña incorrecta' });
    }

    const token = jwt.sign(
      { id: user.IdUsuario, rol: user.IdRol },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    res.json({ token, rol: user.IdRol });

  } catch (error) {
    res.status(500).json({ message: 'Error en login', error });
  }
};

module.exports = { login };
