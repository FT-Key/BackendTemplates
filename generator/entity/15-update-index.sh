#!/bin/bash

INDEX_FILE="src/index.js"

if [ ! -f "$INDEX_FILE" ]; then
  echo "⚠️  No se encontró index.js en src/"
  exit 0
fi

# 1. Nombres útiles
entity_lower=$(echo "$entity" | tr '[:upper:]' '[:lower:]')
entity_pascal=$(echo "$entity" | sed -E 's/(^|-)([a-z])/\U\2/g')

# 2. Import de entity.routes.js
route_import="import ${entity_lower}Routes from './interfaces/http/${entity_lower}/${entity_lower}.routes.js';"
if ! grep -q "${entity_lower}Routes" "$INDEX_FILE"; then
  sed -i "/^import .*routes\.js';/a $route_import" "$INDEX_FILE"
fi

# 3. Import de query config
config_import="import { ${entity_lower}QueryConfig } from './interfaces/http/${entity_lower}/query-${entity_lower}-config.js';"
if ! grep -q "${entity_lower}QueryConfig" "$INDEX_FILE"; then
  sed -i "/^import { .*query\.middlewares\.js';/a $config_import" "$INDEX_FILE"
fi

# 4. Definición de router con middlewares
router_declaration="const ${entity_lower}RouterWithMiddlewares = wrapRouterWithFlexibleMiddlewares(${entity_lower}Routes, {
  globalMiddlewares: createQueryMiddlewares(${entity_lower}QueryConfig),
  excludePathsByMiddleware,
  routeMiddlewares,
});"

if ! grep -q "const ${entity_lower}RouterWithMiddlewares" "$INDEX_FILE"; then
  tmp=$(mktemp)
  awk -v insert="$router_declaration" '
    BEGIN { added = 0 }
    {
      if (!added && $0 ~ /^const publicRouter = /) {
        print insert "\n"
        added = 1
      }
      print
    }
  ' "$INDEX_FILE" >"$tmp" && mv "$tmp" "$INDEX_FILE"
fi

# 5. Insertar la ruta en el array `routes: [ ... ]`
route_entry="{ path: '/${entity_lower}', handler: ${entity_lower}RouterWithMiddlewares },"
if ! grep -q "$route_entry" "$INDEX_FILE"; then
  sed -i "/routes: \[/a \ \ \ \ $route_entry" "$INDEX_FILE"
fi

echo "✅ index.js actualizado con rutas y middlewares para '$entity'"
