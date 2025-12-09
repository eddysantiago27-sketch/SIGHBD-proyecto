const { sql, poolPromise } = require('../config/db');
const jwt = require('jsonwebtoken');

const login = async (req, res) => {
  try {
    const { usuario, password } = req.body;

    if (!usuario || !password) {
      return res.status(400).json({ message: 'Faltan datos' });
    }

    const pool = await poolPromise;

    if (!pool) {
      return res.status(500).json({ message: 'No hay conexión con la base de datos' });
    }

    const query = `
      SELECT
      u.IdUsuario,
      u.NombreUsuario,
      u.IdRol,
      r.NombreRol,
      r.Nivel,
      u.CuentaBloqueada
      FROM USUARIOS u
      INNER JOIN Roles r ON u.IdRol = r.IdRol
      WHERE u.NombreUsuario = @usuario
      AND u.PasswordHash = HASHBYTES('SHA2_512', CONVERT(VARBINARY(100), @password) +u.PasswordSalt)
    `;

    const result = await pool.request()
      .input('usuario', sql.VarChar(50), usuario)
      .input('password', sql.VarChar(100), password)
      .query(query);

    if (result.recordset.length === 0) {
      return res.status(401).json({ message: 'Usuario o contraseña incorrectos' });
    }

    const user = result.recordset[0];

    if (user.CuentaBloqueada) {
      return res.status(403).json({ message: 'Cuenta bloqueada' });
    }

    const token = jwt.sign(
      {
        id: user.IdUsuario,
        rol: user.IdRol,
        nombreRol: user.NombreRol,
        nivel: user.Nivel
      },
      process.env.JWT_SECRET,
      { expiresIn: '3h' }
    );

    return res.json({
      message: 'Login exitoso',
      token,
      usuario: user.NombreUsuario,
      rol: user.IdRol,
      nivel: user.Nivel
    });

  } catch (error) {
    console.error("ERROR REAL:", error);
    res.status(500).json({
      message: 'Error en login',
      detalle: error.message
    });
  }
};

module.exports = { login };