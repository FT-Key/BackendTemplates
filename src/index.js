import { Server } from './config/server.js';

import healthRoutes from './interfaces/http/health/health.routes.js';
import publicRoutes from './interfaces/http/public/public.routes.js';
import userRoutes from './interfaces/http/user/user.routes.js';

import { wrapRouterWithFlexibleMiddlewares } from './utils/wrap-router-with-flexible-middlewares.js';
import { createQueryMiddlewares } from './interfaces/http/middlewares/query.middlewares.js';
import { userQueryConfig } from './interfaces/http/user/query-user-config.js';

const excludePathsByMiddleware = {
  // Por ahora sin exclusiones específicas
};

const routeMiddlewares = {};

// Middlewares globales comunes (como helmet, cors, etc) pueden ir acá
const globalMiddlewares = [];

// 🧩 Inyectar middlewares de búsqueda en /users
const userRouterWithMiddlewares = wrapRouterWithFlexibleMiddlewares(userRoutes, {
  globalMiddlewares: createQueryMiddlewares(userQueryConfig),
  excludePathsByMiddleware,
  routeMiddlewares,
});

// Otros routers sin búsqueda
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

// Servidor
const server = new Server({
  middlewares: [],
  routes: [
    { path: '/health', handler: healthRouter },
    { path: '/public', handler: publicRouter },
    { path: '/users', handler: userRouterWithMiddlewares },
  ],
});

server.start(process.env.PORT || 3000);
