// sanitize.middleware.js
import xss from 'xss-clean';
import mongoSanitize from 'express-mongo-sanitize';

export const sanitizeMiddleware = [
  mongoSanitize(), // Evita inyecciones NoSQL
  xss(),            // Limpia XSS (HTML/script injection)
];