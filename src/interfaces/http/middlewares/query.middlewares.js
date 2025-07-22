// src/interfaces/http/middlewares/query.middlewares.js
import { searchMiddleware } from './search.middleware.js';
import { filtersMiddleware } from './filters.middleware.js';
import { sortMiddleware } from './sort.middleware.js';
import { paginationMiddleware } from './pagination.middleware.js';

export function createQueryMiddlewares({
  searchableFields = [],
  filterableFields = [],
  sortableFields = []
}) {
  return [
    searchMiddleware(searchableFields),
    filtersMiddleware(filterableFields),
    sortMiddleware(sortableFields),
    paginationMiddleware,
  ];
}