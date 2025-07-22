#!/bin/bash

set -e

echo "📁 Generando estructura base del proyecto..."

# Preguntar si se desea generar archivos de ejemplo para 'user'
read -p "¿Deseas generar archivos de ejemplo para la entidad 'user'? (y/n): " response
response=${response,,} # convertir a minúsculas
if [[ "$response" == "y" || "$response" == "yes" || "$response" == "s" || "$response" == "si" ]]; then
  CREATE_USER=true
else
  CREATE_USER=false
fi

# Verificar si Node.js está instalado
if ! command -v node &>/dev/null; then
  echo "❌ Node.js no está instalado. Por favor instálalo primero."
  exit 1
fi

# Inicializar npm si no existe
if [ ! -f package.json ]; then
  echo "📦 Inicializando proyecto Node..."
  npm init -y
fi

# Instalar express y path-to-regexp si no están en package.json
if ! grep -q '"express"' package.json; then
  echo "📦 Instalando express..."
  npm install express
fi

if ! grep -q '"path-to-regexp"' package.json; then
  echo "📦 Instalando path-to-regexp..."
  npm install path-to-regexp
fi

# Archivos raíz
touch .gitignore .prettierrc estructura.txt README.md
echo "{}" >package-lock.json

# Directorios principales
mkdir -p \
  generator \
  generator/entity-schemas \
  src/config \
  src/domain \
  src/infrastructure \
  src/infrastructure/database \
  src/interfaces/http/health \
  src/interfaces/http/public \
  src/interfaces/http/middlewares \
  src/application \
  src/utils \
  tests/application \
  tests/interfaces/http/middlewares

# Si se desea, generar estructura de ejemplo para 'user'
if [ "$CREATE_USER" = true ]; then
  echo "🧪 Generando archivos de ejemplo para 'user'..."

  mkdir -p \
    src/domain/user \
    src/infrastructure/user \
    src/interfaces/http/user \
    src/application/user/services \
    src/application/user/use-cases \
    tests/application/user

  # Archivos de dominio
  touch src/domain/user/user.js
  touch src/domain/user/constants.js
  touch src/domain/user/user-factory.js
  touch src/domain/user/validate-user.js

  # Infraestructura
  touch src/infrastructure/user/in-memory-user-repository.js

  # Servicios
  touch src/application/user/services/user-hasher.js
  touch src/application/user/services/user-validator.js
  touch src/application/user/services/get-active-users.js
  touch src/application/user/services/generate-user-id.js

  # Casos de uso
  touch src/application/user/use-cases/create-user.js
  touch src/application/user/use-cases/get-user.js
  touch src/application/user/use-cases/update-user.js
  touch src/application/user/use-cases/delete-user.js
  touch src/application/user/use-cases/deactivate-user.js

  # Interfaces HTTP
  touch src/interfaces/http/user/user.controller.js
  touch src/interfaces/http/user/user.routes.js

  # Tests
  touch tests/application/user/create-user.test.js
  touch tests/application/user/get-user.test.js
  touch tests/application/user/update-user.test.js
  touch tests/application/user/delete-user.test.js
  touch tests/application/user/deactivate-user.test.js

  # Esquema de entidad
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
fi

# Archivos base de config y rutas
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

cat <<'EOF' >src/interfaces/http/health/health.routes.js
import express from 'express';

const router = express.Router();

router.get('/', (req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

export default router;
EOF

cat <<'EOF' >src/interfaces/http/public/public.routes.js
import express from 'express';

const router = express.Router();

router.get('/info', (req, res) => {
  res.json({ app: 'Backend Template', version: '1.0.0', description: 'Información pública' });
});

export default router;
EOF

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

cat <<'EOF' >src/index.js
import { Server } from './config/server.js';
import healthRoutes from './interfaces/http/health/health.routes.js';
import publicRoutes from './interfaces/http/public/public.routes.js';
import { wrapRouterWithFlexibleMiddlewares } from './utils/wrap-router-with-flexible-middlewares.js';

// IMPORTAR RUTAS DE TEST Y MIDDLEWARES AQUÍ
// import testRoutes from './interfaces/http/test/test.routes.js';
// import { exampleMiddleware } from './interfaces/http/middlewares/example.middleware.js';

const globalMiddlewares = [];
const excludePathsByMiddleware = {
  // exampleMiddleware: ['/public', '/health']
};

const routeMiddlewares = {
  // '/': [exampleMiddleware],
};

// const testRouter = wrapRouterWithFlexibleMiddlewares(testRoutes, {
//   globalMiddlewares,
//   excludePathsByMiddleware,
//   routeMiddlewares,
// });

const server = new Server({
  middlewares: [],
  routes: [
    // { path: '/test', handler: testRouter },
    { path: '/health', handler: healthRoutes },
    { path: '/public', handler: publicRoutes },
  ],
});

server.start(process.env.PORT || 3000);
EOF

echo "✅ Proyecto generado con éxito. ¡Listo para empezar!"
