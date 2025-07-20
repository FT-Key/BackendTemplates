// auth.middleware.js
export function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No autorizado: token requerido' });
  }

  const token = authHeader.split(' ')[1];

  try {
    // TODO: Verificá el token (con JWT u otro mecanismo)
    // const payload = jwt.verify(token, process.env.JWT_SECRET);
    // req.user = payload;

    next();
  } catch (error) {
    return res.status(401).json({ message: 'Token inválido o expirado' });
  }
}