// rate-limiter.middleware.js
import rateLimit from 'express-rate-limit';

export const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // límite por IP
  message: 'Demasiadas solicitudes desde esta IP, intentá más tarde',
  standardHeaders: true,
  legacyHeaders: false,
});