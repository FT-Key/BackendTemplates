import xss from 'xss-clean';
import mongoSanitize from 'express-mongo-sanitize';

export const sanitizeMiddleware = [
  mongoSanitize(),
  xss(),
];
