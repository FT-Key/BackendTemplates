export default function errorHandler(err, req, res, next) {
  console.error('❌ Error capturado:', err.stack || err.message);
  res.status(err.status || 500).json({
    error: {
      message: err.message || 'Error interno del servidor',
    },
  });
}
