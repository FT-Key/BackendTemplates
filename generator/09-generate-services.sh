#!/bin/bash
# shellcheck disable=SC2154
# 3.5. SERVICES
services_path="src/application/$entity/services"
if confirm_action "¿Crear carpeta de servicios ($services_path)?"; then
  mkdir -p "$services_path"
  echo "// Servicios para la entidad $EntityPascal" >"$services_path/README.md"
fi
service_file="src/application/$entity/services/get-active-${entity}.js"
if confirm_action "¿Agregar servicio getActive? ($service_file)"; then
  cat <<EOF >"$service_file"
export async function getActive${EntityPascal}s(repository) {
  const all = await repository.findAll();
  return all.filter(item => item.active);
}
EOF
fi
