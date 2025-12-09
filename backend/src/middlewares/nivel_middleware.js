const VerificarNivel = (nivelMaximoPermitido) => {
    return (req, res, next) => {
        const user = req.user;

        if (!user.nivel) {
            return res.status(403).json({ message: 'Nivel de usuario no disponible' });
        }

        if (user.nivel > nivelMaximoPermitido) {
            return res.status(403).json({ message: 'Acceso denegado: nivel insuficiente' });
        }

        next();
    };
};
module.exports = {VerificarNivel};