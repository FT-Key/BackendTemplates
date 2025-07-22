#!/bin/bash

set -e

echo "📁 Generando estructura base del proyecto..."

# Verifica si Node.js está instalado
if ! command -v node &>/dev/null; then
  echo "❌ Node.js no está instalado. Por favor instálalo primero."
  exit 1
fi

# Inicializar npm si no existe
if [ ! -f package.json ]; then
  echo "📦 Inicializando proyecto Node..."
  npm init -y
fi

# Instalar Express si no está
if [ ! -d "node_modules/express" ]; then
  echo "📦 Instalando Express..."
  npm install express
fi

# Archivos raíz
touch .gitignore .prettierrc entity-scheme.json estructura.txt README.md
echo "{}" >package-lock.json

# Directorios principales
mkdir -p \
  generator \
  generator/entity-schemas \
  src/config \
  src/domain/user \
  src/infrastructure/user \
  src/infrastructure/database \
  src/interfaces/http/user \
  src/interfaces/http/health \
  src/interfaces/http/auth \
  src/interfaces/http/public \
  src/interfaces/http/middlewares \
  src/application/user/use-cases \
  src/application/user/services \
  src/utils \
  tests/application/user \
  tests/interfaces/http/middlewares

# Generator placeholder
for i in {00..12}; do
  touch "generator/${i}-generate-placeholder.sh"
done

# Archivo de esquema de ejemplo
cat <<'EOF' >generator/entity-schemas/user.json
{
  "name": "user",
  "fields": [
    { "name": "email", "required": true },
    { "name": "password", "required": true },
    { "name": "role", "default": "client" },
    { "name": "name", "required": true }
  ],
  "methods": [
    {
      "name": "isAdmin",
      "params": [],
      "body": "return this.role === 'admin';"
    }
  ]
}
EOF

# server.js (clase Server)
cat <<'EOF' >src/config/server.js
import express from 'express';

export class Server {
  constructor({ routes = [], middlewares = [] } = {}) {
    this.app = express();
    this.routes = routes;
    this.middlewares = middlewares;
  }

  setupMiddlewares() {
    this.app.use(express.json());
    this.middlewares.forEach((mw) => this.app.use(mw));
  }

  setupRoutes() {
    this.routes.forEach(({ path, handler }) => {
      this.app.use(path, handler);
    });
  }

  start(port = 3000) {
    this.setupMiddlewares();
    this.setupRoutes();

    this.app.listen(port, () => {
      console.log(`🚀 Servidor iniciado en http://localhost:${port}`);
    });
  }

  getApp() {
    return this.app;
  }
}
EOF

# health.routes.js
cat <<'EOF' >src/interfaces/http/health/health.routes.js
import express from 'express';

const router = express.Router();

router.get('/', (req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

export default router;
EOF

# public.routes.js
cat <<'EOF' >src/interfaces/http/public/public.routes.js
import express from 'express';

const router = express.Router();

router.get('/info', (req, res) => {
  res.json({ app: 'Backend Template', version: '1.0.0', description: 'Información pública' });
});

export default router;
EOF

# wrap-router-with-flexible-middlewares.js
cat <<'EOF' >src/utils/wrap-router-with-flexible-middlewares.js
import express from 'express';
import { match } from 'path-to-regexp';

export function wrapRouterWithFlexibleMiddlewares(router, options = {}) {
  const {
    globalMiddlewares = [],
    excludePathsByMiddleware = {},
    routeMiddlewares = {},
  } = options;

  const wrapped = express.Router();

  globalMiddlewares.forEach((mw) => {
    const mwName = mw.name || 'anonymous';

    wrapped.use((req, res, next) => {
      const excludes = excludePathsByMiddleware[mwName] || [];
      if (excludes.some(path => match(path, { decode: decodeURIComponent })(req.path))) {
        return next();
      }
      return mw(req, res, next);
    });
  });

  wrapped.use((req, res, next) => {
    for (const pattern in routeMiddlewares) {
      const isMatch = match(pattern, { decode: decodeURIComponent })(req.path);
      if (isMatch) {
        const mws = routeMiddlewares[pattern];
        if (!mws.length) return next();

        let i = 0;
        function run(i) {
          if (i >= mws.length) return next();
          mws[i](req, res, () => run(i + 1));
        }
        return run(0);
      }
    }
    return next();
  });

  wrapped.use(router);

  return wrapped;
}
EOF

# index.js con placeholders
cat <<'EOF' >src/index.js
import { Server } from './config/server.js';
import healthRoutes from './interfaces/http/health/health.routes.js';
import publicRoutes from './interfaces/http/public/public.routes.js';
import { wrapRouterWithFlexibleMiddlewares } from './utils/wrap-router-with-flexible-middlewares.js';

// IMPORTAR MIDDLEWARES Y RUTAS AQUÍ
// import userRoutes from './interfaces/http/user/user.routes.js';
// import { authMiddleware } from './interfaces/http/middlewares/auth.middleware.js';
// import { checkRole } from './interfaces/http/middlewares/check-role.middleware.js';

// Middlewares globales
const globalMiddlewares = []; // Ej: [cors(), helmet(), morgan('dev'), authMiddleware]

// Exclusiones por middleware
const excludePathsByMiddleware = {
  // authMiddleware: ['/public', '/health']
};

// Middlewares por ruta
const routeMiddlewares = {
  // '/': [checkRole('admin')],
};

// Envuelve rutas con middlewares (si aplica)
// const userRouter = wrapRouterWithFlexibleMiddlewares(userRoutes, {
//   globalMiddlewares,
//   excludePathsByMiddleware,
//   routeMiddlewares,
// });

const server = new Server({
  middlewares: [], // Ya aplicados en routers si es necesario
  routes: [
    // { path: '/users', handler: userRouter },
    { path: '/health', handler: healthRoutes },
    { path: '/public', handler: publicRoutes },
  ],
});

server.start(process.env.PORT || 3000);
EOF

echo "✅ Proyecto generado con éxito. Puedes comenzar a desarrollar tu API."
