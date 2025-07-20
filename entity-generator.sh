#!/bin/bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034
# shellcheck disable=SC1091
set -e

# Cargar partes
source ./generator/00-helpers.sh
source ./generator/01-parse-args.sh "$@"
source ./generator/02-load-schema.sh

echo "🛠 Generando entidad '$entity'..."

# Unir campos base + custom
base_fields='[
  { "name": "id", "required": true },
  { "name": "active", "default": true },
  { "name": "createdAt", "default": "new Date()" },
  { "name": "updatedAt", "default": "new Date()" },
  { "name": "deletedAt", "default": null },
  { "name": "ownedBy", "default": null }
]'

tmp_base=$(mktemp)
tmp_custom=$(mktemp)

echo "$base_fields" >"$tmp_base"
echo "$custom_fields" >"$tmp_custom"
fields=$(jq -s '.[0] + .[1]' "$tmp_base" "$tmp_custom")

rm "$tmp_base" "$tmp_custom"

# Crear carpetas base
mkdir -p "src/domain/$entity"
mkdir -p "src/application/$entity/use-cases"
mkdir -p "src/infrastructure/$entity"
mkdir -p "src/interfaces/http/$entity"
mkdir -p "tests/application/$entity"

# Ejecutar partes de generación
source ./generator/03-generate-domain.sh
source ./generator/04-generate-validation.sh
source ./generator/05-generate-factory.sh
source ./generator/06-generate-constants.sh
source ./generator/07-generate-repository.sh
source ./generator/08-generate-usecases.sh
source ./generator/09-generate-services.sh
source ./generator/10-generate-controller.sh
source ./generator/11-generate-routes.sh
source ./generator/12-generate-tests.sh

echo "✔️  Estructura generada para '$entity'"
