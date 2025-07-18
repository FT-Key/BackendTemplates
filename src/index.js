import { Server } from './config/server.js';
import userRoutes from './interfaces/http/user/user.routes.js';

const server = new Server({
  routes: [
    { path: '/users', handler: userRoutes },
    // Podrías agregar más: { path: '/auth', handler: authRoutes }
  ],
});

server.start(process.env.PORT || 3000);
