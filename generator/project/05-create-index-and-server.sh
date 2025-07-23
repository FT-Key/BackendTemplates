#!/bin/bash
# generator/project/04-create-index-and-server.sh
# shellcheck disable=SC1091

source ../generator/common/confirm-action.sh

write_file_with_confirm() {
  local filepath=$1
  local content=$2

  if [[ -f "$filepath" ]]; then
    if [[ "$AUTO_YES" == true ]]; then
      echo "⚠️  El archivo $filepath ya existe. Sobrescribiendo por opción -y."
      echo "$content" >"$filepath"
    else
      if confirm_action "⚠️  El archivo $filepath ya existe. ¿Desea sobrescribirlo? (y/n): "; then
        echo "$content" >"$filepath"
      else
        echo "❌ No se sobrescribió $filepath"
      fi
    fi
  else
    echo "$content" >"$filepath"
  fi
}

# Ahora guardás cada archivo con esta función para que pregunte o sobrescriba según corresponda

write_file_with_confirm "src/config/server.js" "$(
  cat <<'EOF'
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
)"

write_file_with_confirm "src/interfaces/http/health/health.routes.js" "$(
  cat <<'EOF'
import express from 'express';

const router = express.Router();

router.get('/', (req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

export default router;
EOF
)"

write_file_with_confirm "src/interfaces/http/public/public.routes.js" "$(
  cat <<'EOF'
import express from 'express';

const router = express.Router();

router.get('/info', (req, res) => {
  res.json({ app: 'Backend Template', version: '1.0.0', description: 'Información pública' });
});

export default router;
EOF
)"

write_file_with_confirm "src/utils/wrap-router-with-flexible-middlewares.js" "$(
  cat <<'EOF'
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
)"

write_file_with_confirm "src/index.js" "$(
  cat <<'EOF'
import { Server } from './config/server.js';

import healthRoutes from './interfaces/http/health/health.routes.js';
import publicRoutes from './interfaces/http/public/public.routes.js';

// import entityRoutes from './interfaces/http/entity/entity.routes.js';

import { wrapRouterWithFlexibleMiddlewares } from './utils/wrap-router-with-flexible-middlewares.js';
import { createQueryMiddlewares } from './interfaces/http/middlewares/query.middlewares.js';
// import { entityQueryConfig } from './interfaces/http/entity/query-entity-config.js';

const excludePathsByMiddleware = {
  // Por ahora sin exclusiones específicas
};

const routeMiddlewares = {};

// Middlewares globales comunes (como helmet, cors, etc) pueden ir acá
const globalMiddlewares = [];

// Ejemplo de cómo inyectar middlewares de búsqueda en /entity
// const entityRouterWithMiddlewares = wrapRouterWithFlexibleMiddlewares(entityRoutes, {
//   globalMiddlewares: createQueryMiddlewares(entityQueryConfig),
//   excludePathsByMiddleware,
//   routeMiddlewares,
// });

const healthRouter = wrapRouterWithFlexibleMiddlewares(healthRoutes, {
  globalMiddlewares,
  excludePathsByMiddleware,
  routeMiddlewares,
});

const publicRouter = wrapRouterWithFlexibleMiddlewares(publicRoutes, {
  globalMiddlewares,
  excludePathsByMiddleware,
  routeMiddlewares,
});

const server = new Server({
  middlewares: [],
  routes: [
    { path: '/health', handler: healthRouter },
    { path: '/public', handler: publicRouter },
    // { path: '/entity', handler: entityRouterWithMiddlewares },
  ],
});

server.start(process.env.PORT || 3000);
EOF
)"

echo "✅ index.js y configuración de servidor generados."
