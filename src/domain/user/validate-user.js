export function validateUser(data) {
  if (!data.id) throw new Error('id is required');
  return true;
}
