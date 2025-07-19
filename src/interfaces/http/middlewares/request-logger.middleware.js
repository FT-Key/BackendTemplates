// request-logger.middleware.js
export function requestLogger(req, res, next) {
  console.log(`📥 ${req.method} ${req.originalUrl}`);
  next();
}