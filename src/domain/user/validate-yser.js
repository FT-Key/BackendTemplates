// src/domain/user/validate-user.js
export function validateUser(data) {
  if (!data.name) throw new Error('Name is required');
  return true;
}