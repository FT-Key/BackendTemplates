// src/interfaces/http/middlewares/filters.middleware.js

export function filtersMiddleware(filterableFields = []) {
  return (req, res, next) => {
    const filters = {};
    for (const field of filterableFields) {
      if (req.query[field] !== undefined) {
        filters[field] = req.query[field];
      }
    }
    req.filters = filters;
    next();
  };
}
