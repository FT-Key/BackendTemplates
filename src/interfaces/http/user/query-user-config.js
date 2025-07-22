export const userQueryConfig = {
  searchableFields: ['id', 'ownedBy'],  // campos para búsqueda por texto (q)
  sortableFields: ['id', 'createdAt', 'updatedAt'], // campos permitidos para ordenar
  filterableFields: ['id', 'active', 'ownedBy'],  // campos permitidos para filtro exacto
};
