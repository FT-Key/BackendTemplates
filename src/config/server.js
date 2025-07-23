import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

// Definir __dirname en ESModules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class Server {
  constructor({ routes = [], middlewares = [] } = {}) {
    this.app = express();
    this.routes = routes;
    this.middlewares = middlewares;
  }

  setupMiddlewares() {
    this.app.use(express.json());

    // Servir archivos estáticos desde la carpeta 'src/public'
    this.app.use(express.static(path.resolve(__dirname, '../public')));

    this.middlewares.forEach((mw) => this.app.use(mw));
  }

  setupRoutes() {
    this.routes.forEach(({ path: routePath, handler }) => {
      this.app.use(routePath, handler);
    });

    // Ruta raíz para servir index.html explícitamente
    this.app.get('/', (req, res) => {
      res.sendFile(path.resolve(__dirname, '../public/index.html'));
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
