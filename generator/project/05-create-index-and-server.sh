#!/bin/bash
# generator/project/04-create-index-and-server.sh

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

echo "✅ index.js y configuración de servidor generados."
