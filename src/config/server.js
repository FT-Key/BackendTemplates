import express from 'express';

export class Server {
  constructor({ routes = [] } = {}) {
    this.app = express();
    this.routes = routes;
  }

  setupMiddlewares() {
    this.app.use(express.json());
    // Aquí podés agregar middlewares como CORS, logging, auth, etc.
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
      console.log(`Servidor iniciado en http://localhost:${port}`);
    });
  }

  getApp() {
    return this.app; // Para test o uso externo
  }
}
