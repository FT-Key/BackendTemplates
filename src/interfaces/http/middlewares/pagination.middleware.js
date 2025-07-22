// src/interfaces/http/middlewares/pagination.middleware.js

export function paginationMiddleware(req, res, next) {
  const page = parseInt(req.query.page) || 1;
  const limit = Math.min(parseInt(req.query.limit) || 10, 100);
  const offset = (page - 1) * limit;

  req.pagination = { page, limit, offset };
  next();
}
