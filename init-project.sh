#!/bin/bash

set -e

echo "📁 Generando estructura base del proyecto..."

# Archivos raíz
touch .gitignore .prettierrc entity-scheme.json estructura.txt README.md
echo "{}" >package.json
echo "{}" >package-lock.json

# Directorios principales
mkdir -p \
  generator \
  generator/entity-schemas \
  src/config \
  src/domain/user \
  src/infrastructure/user \
  src/infrastructure/database \
  src/interfaces/http/user \
  src/interfaces/http/health \
  src/interfaces/http/auth \
  src/interfaces/http/public \
  src/interfaces/http/middlewares \
  src/application/user/use-cases \
  src/application/user/services \
  src/utils \
  tests/application/user \
  tests/interfaces/http/middlewares

# Generator scripts
for i in {00..12}; do
  touch "generator/${i}-generate-placeholder.sh"
done

# Archivos base del generador
cat <<'EOF' >generator/entity-schemas/user.json
{
  "name": "user",
  "fields": [
    { "name": "email", "required": true },
    { "name": "password", "required": true },
    { "name": "role", "default": "client" },
    { "name": "name", "required": true }
  ],
  "methods": [
    {
      "name": "isAdmin",
      "params": [],
      "body": "return this.role === 'admin';"
    }
  ]
}
EOF

# Archivos base de configuración
cat <<'EOF' >src/config/server.js
// TODO: Inicializar servidor aquí
EOF

# Archivos base de dominio
touch src/domain/user/user.js
touch src/domain/user/constants.js
touch src/domain/user/user-factory.js
touch src/domain/user/validate-user.js

# Infraestructura
touch src/infrastructure/user/in-memory-user-repository.js

# Servicios (application)
touch src/application/user/services/user-hasher.js
touch src/application/user/services/user-validator.js
touch src/application/user/services/get-active-users.js
touch src/application/user/services/generate-user-id.js

# Casos de uso
touch src/application/user/use-cases/create-user.js
touch src/application/user/use-cases/get-user.js
touch src/application/user/use-cases/update-user.js
touch src/application/user/use-cases/delete-user.js
touch src/application/user/use-cases/deactivate-user.js

# Middlewares
touch src/interfaces/http/middlewares/auth.middleware.js
touch src/interfaces/http/middlewares/check-role.middleware.js
touch src/interfaces/http/middlewares/error-handler.middleware.js
touch src/interfaces/http/middlewares/rate-limiter.middleware.js
touch src/interfaces/http/middlewares/request-logger.middleware.js
touch src/interfaces/http/middlewares/sanitize.middleware.js

# Interfaces HTTP
touch src/interfaces/http/user/user.controller.js
touch src/interfaces/http/user/user.routes.js
touch src/interfaces/http/auth/auth.controller.js
touch src/interfaces/http/auth/auth.routes.js
touch src/interfaces/http/health/health.routes.js
touch src/interfaces/http/public/public.routes.js

# Utilidades
touch src/utils/wrap-router-with-flexible-middlewares.js

# Entrypoint
touch src/index.js

# Tests
touch tests/application/user/create-user.test.js
touch tests/application/user/get-user.test.js
touch tests/application/user/update-user.test.js
touch tests/application/user/delete-user.test.js
touch tests/application/user/deactivate-user.test.js
touch tests/interfaces/http/middlewares/check-role.test.js

echo "✅ Estructura del proyecto generada con éxito."
