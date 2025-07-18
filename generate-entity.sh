#!/bin/bash

# Comprobamos si se pasó un nombre
if [ -z "$1" ]; then
  echo "⚠️  Debes indicar el nombre de la entidad. Ej: ./generate-entity.sh product"
  exit 1
fi

ENTITY_NAME=$1
ENTITY_LOWER=$(echo "$ENTITY_NAME" | tr '[:upper:]' '[:lower:]')

echo "🚀 Generando estructura para entidad: $ENTITY_NAME"

# Domain
mkdir -p src/domain/$ENTITY_LOWER
touch src/domain/$ENTITY_LOWER/$ENTITY_LOWER.js

# Application
mkdir -p src/application/$ENTITY_LOWER/services
mkdir -p src/application/$ENTITY_LOWER/use-cases
touch src/application/$ENTITY_LOWER/use-cases/create-$ENTITY_LOWER.js
touch src/application/$ENTITY_LOWER/use-cases/get-$ENTITY_LOWER.js
touch src/application/$ENTITY_LOWER/use-cases/update-$ENTITY_LOWER.js
touch src/application/$ENTITY_LOWER/use-cases/delete-$ENTITY_LOWER.js
touch src/application/$ENTITY_LOWER/services/utils.js

# Infrastructure
mkdir -p src/infrastructure/$ENTITY_LOWER
touch src/infrastructure/$ENTITY_LOWER/in-memory-$ENTITY_LOWER-repository.js

# Interfaces
mkdir -p src/interfaces/http/$ENTITY_LOWER
touch src/interfaces/http/$ENTITY_LOWER/$ENTITY_LOWER.controller.js
touch src/interfaces/http/$ENTITY_LOWER/$ENTITY_LOWER.routes.js

# Tests
mkdir -p tests/application/$ENTITY_LOWER
touch tests/application/$ENTITY_LOWER/create-$ENTITY_LOWER.test.js
touch tests/application/$ENTITY_LOWER/get-$ENTITY_LOWER.test.js
touch tests/application/$ENTITY_LOWER/update-$ENTITY_LOWER.test.js
touch tests/application/$ENTITY_LOWER/delete-$ENTITY_LOWER.test.js
touch tests/application/$ENTITY_LOWER/deactivate-$ENTITY_LOWER.test.js

echo "✅ Estructura para '$ENTITY_NAME' generada correctamente."
