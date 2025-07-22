// src/interfaces/http/middlewares/search.middleware.js

export function searchMiddleware(searchableFields = []) {
  return (req, res, next) => {
    const q = req.query.q;
    if (q && searchableFields.length > 0) {
      req.search = { query: q, fields: searchableFields };
    }
    next();
  };
}
