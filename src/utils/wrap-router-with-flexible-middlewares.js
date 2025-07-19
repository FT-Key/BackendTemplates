import express from 'express';
import { match } from 'path-to-regexp';

/**
 * Wrapper para aplicar middlewares globales con exclusiones y middlewares específicos por ruta.
 * 
 * @param {import('express').Router} router - router original
 * @param {Object} options
 * @param {Array<function>} options.globalMiddlewares - middlewares globales
 * @param {Object<string, Array<string>>} options.excludePathsByMiddleware - paths excluidos por middleware nombre
 * @param {Object<string, Array<function>>} options.routeMiddlewares - middlewares específicos por ruta
 */


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
      // Excluir si alguna ruta coincide con la ruta actual
      if (excludes.some(path => match(path, { decode: decodeURIComponent })(req.path))) {
        return next();
      }
      return mw(req, res, next);
    });
  });

  wrapped.use((req, res, next) => {
    // Buscar middlewares para la ruta actual según patrones
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