const verificarRol = (rolesPermitidos) => {
  return (req, res, next) => {
    const { rol } = req.user;

    if (!rolesPermitidos.includes(rol)) {
      return res.status(403).json({ message: 'No tienes permiso' });
    }
    next();
  };
};

module.exports = { verificarRol };
const verificarRoles = (rolesPermitidos) => {
  return (req, res, next) => {
    const { rol } = req.user;

    if (!rolesPermitidos.includes(rol)) {
      return res.status(403).json({ message: 'No tienes permiso' });
    }
    next();
  };
};

module.exports = { verificarRol };
