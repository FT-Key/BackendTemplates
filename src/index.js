import { Server } from './config/server.js';

import userRoutes from './interfaces/http/user/user.routes.js';
import healthRoutes from './interfaces/http/health/health.routes.js';
import publicRoutes from './interfaces/http/public/public.routes.js';

import { authMiddleware } from './interfaces/http/middlewares/auth.middleware.js';
import { checkRole } from './interfaces/http/middlewares/check-role.middleware.js';

import { wrapRouterWithFlexibleMiddlewares } from './utils/wrap-router-with-flexible-middlewares.js';

import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

// Middlewares globales que se aplican a todo el router user
const globalMiddlewares = [cors(), helmet(), morgan('dev'), authMiddleware];

// Rutas excluidas para middlewares (ejemplo: authMiddleware se excluye en estas rutas)
const excludePathsByMiddleware = {
  authMiddleware: ['/public', '/health'],
};

// Middlewares específicos por ruta (dentro de /users)
const userRouteMiddlewares = {
  '/': [checkRole('admin')],
  '/:id': [checkRoleOrOwner('admin')],
  '/:id/deactivate': [checkRole('admin')],
};

// Router users con middlewares aplicados con flexibilidad
const userRouter = wrapRouterWithFlexibleMiddlewares(userRoutes, {
  globalMiddlewares,
  excludePathsByMiddleware,
  routeMiddlewares: userRouteMiddlewares,
});

// Servidor principal que puede montar varios routers
const server1 = new Server({
  middlewares: [], // Ya aplicados en wrappers si corresponde
  routes: [
    { path: '/users', handler: userRouter },
    { path: '/health', handler: healthRoutes },
    { path: '/public', handler: publicRoutes },
  ],
});

server1.start(process.env.PORT || 3000);