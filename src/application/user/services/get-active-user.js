export async function getActiveUsers(repository) {
  const all = await repository.findAll();
  return all.filter(item => item.active);
}
