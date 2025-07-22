#!/bin/bash

if [ "$CREATE_MIDDLEWARES" != "true" ]; then
  echo "⏩ Skipping base middlewares..."
  exit 0
fi

mkdir -p src/interfaces/http/middlewares

cat <<'EOF' >src/interfaces/http/middlewares/auth.middleware.js
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
EOF

cat <<'EOF' >src/interfaces/http/middlewares/check-role.middleware.js
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
EOF

cat <<'EOF' >src/interfaces/http/middlewares/error-handler.middleware.js
export default function errorHandler(err, req, res, next) {
  console.error('❌ Error capturado:', err.stack || err.message);
  res.status(err.status || 500).json({
    error: {
      message: err.message || 'Error interno del servidor',
    },
  });
}
EOF

cat <<'EOF' >src/interfaces/http/middlewares/rate-limiter.middleware.js
import rateLimit from 'express-rate-limit';

export const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Demasiadas solicitudes desde esta IP, intentá más tarde',
  standardHeaders: true,
  legacyHeaders: false,
});
EOF

cat <<'EOF' >src/interfaces/http/middlewares/request-logger.middleware.js
export function requestLogger(req, res, next) {
  console.log(`📥 ${req.method} ${req.originalUrl}`);
  next();
}
EOF

cat <<'EOF' >src/interfaces/http/middlewares/sanitize.middleware.js
import xss from 'xss-clean';
import mongoSanitize from 'express-mongo-sanitize';

export const sanitizeMiddleware = [
  mongoSanitize(),
  xss(),
];
EOF

echo "✅ Middlewares base generados"
