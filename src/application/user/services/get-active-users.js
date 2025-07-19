// src/application/user/services/get-active-users.js
export async function getActiveUsers(repository) {
  const all = await repository.findAll();
  return all.filter(u => u.active);
}
