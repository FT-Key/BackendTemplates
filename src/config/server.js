import express from 'express';

export class Server {
  constructor({ routes = [], middlewares = [] } = {}) {
    this.app = express();
    this.routes = routes;
    this.middlewares = middlewares;
  }

  setupMiddlewares() {
    this.app.use(express.json()); // Middleware base
    this.middlewares.forEach((mw) => {
      this.app.use(mw); // Aplica uno por uno
    });
  }

  setupRoutes() {
    this.routes.forEach((route) => {
      this.app.use(route.path, route.handler);
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