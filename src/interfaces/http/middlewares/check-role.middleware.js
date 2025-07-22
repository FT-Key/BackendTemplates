export function checkRole(requiredRole) {
  return (req, res, next) => {
    const user = req.user;
    if (!user) return res.status(401).json({ message: 'No autorizado' });
    if (user.role !== requiredRole) {
      return res.status(403).json({ message: 'Acceso denegado' });
    }
    next();
  };
}

export function checkRoleOrOwner(requiredRole) {
  return (req, res, next) => {
    const user = req.user;
    if (!user) return res.status(401).json({ message: 'No autorizado' });
    if (user.role === requiredRole) return next();
    if (req.params.id && req.params.id === user.id) return next();
    return res.status(403).json({ message: 'Acceso denegado' });
  };
}
