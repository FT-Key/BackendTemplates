#!/bin/bash

# Por defecto no auto-yes
export AUTO_YES=false

# Recorrer argumentos recibidos (guardados en INIT_ARGS)
for arg in "${INIT_ARGS[@]}"; do
  if [[ "$arg" == "-y" || "$arg" == "--yes" ]]; then
    export AUTO_YES=true
  fi
done
