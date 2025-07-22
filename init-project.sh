#!/bin/bash

set -e

# Guardar args para pasar a módulos
INIT_ARGS=("$@")

# Ejecutar primer módulo para parsear args
bash ./generator/project/00-parse-args.sh

# Usar variable AUTO_YES para definir flags de creación
if [ "$AUTO_YES" = true ]; then
  CREATE_USER=true
  CREATE_MIDDLEWARES=true
else
  read -r -p "¿Deseas generar archivos de ejemplo para la entidad 'user'? (y/n): " user_response
  user_response=${user_response,,}
  CREATE_USER=false
  [[ "$user_response" =~ ^(y|yes|s|si)$ ]] && CREATE_USER=true

  read -r -p "¿Deseas agregar middlewares base (auth, role, error, etc)? (y/n): " middleware_response
  middleware_response=${middleware_response,,}
  CREATE_MIDDLEWARES=false
  [[ "$middleware_response" =~ ^(y|yes|s|si)$ ]] && CREATE_MIDDLEWARES=true
fi

export CREATE_USER
export CREATE_MIDDLEWARES

# Ejecutar el resto de módulos en orden, ignorando 00-parse-args.sh que ya se ejecutó
for script in ./generator/project/[0-9][0-9]-*.sh; do
  if [[ "$script" != *"00-parse-args.sh" ]]; then
    echo "▶ Ejecutando $script"
    bash "$script"
  fi
done

echo "✅ Proyecto generado con éxito. ¡Listo para comenzar!"
