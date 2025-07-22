// src/interfaces/http/middlewares/sort.middleware.js

export function sortMiddleware(sortableFields = []) {
  return (req, res, next) => {
    const { sortBy, order } = req.query;

    if (sortBy && sortableFields.includes(sortBy)) {
      req.sort = {
        sortBy,
        order: order?.toLowerCase() === 'asc' ? 'asc' : 'desc',
      };
    }

    next();
  };
}
