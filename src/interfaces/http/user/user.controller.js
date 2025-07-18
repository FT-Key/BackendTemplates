export const createUser = (req, res) => {
  const { name, email } = req.body;
  // Acá iría el caso de uso real, por ahora algo simulado:
  const user = {
    id: Date.now(),
    name,
    email,
  };
  res.status(201).json(user);
};
