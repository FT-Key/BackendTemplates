#!/bin/bash
# generator/project/01-init-npm-and-install-deps.sh

# Inicializar proyecto si no existe package.json
if [ ! -f package.json ]; then
  echo "📦 Inicializando proyecto Node..."
  npm init -y
fi

echo "📦 Verificando e instalando dependencias necesarias..."

# Lista de dependencias
declare -a dependencies=("express" "path-to-regexp" "cors" "helmet" "morgan" "dotenv")
for dep in "${dependencies[@]}"; do
  if ! grep -q "\"$dep\"" package.json; then
    echo "📦 Instalando $dep..."
    npm install "$dep"
  fi
done

# Dependencias de desarrollo
if ! grep -q "\"nodemon\"" package.json; then
  echo "🛠️ Instalando nodemon (dev)..."
  npm install --save-dev nodemon
fi

# Crear archivos .env y .env.production si no existen
for env_file in ".env" ".env.production"; do
  if [ ! -f "$env_file" ]; then
    echo "🔧 Creando archivo $env_file"
    echo "# Variables de entorno" >"$env_file"
  fi
done

# Verificar y agregar scripts a package.json
echo "🛠️ Verificando scripts en package.json..."

# Usamos jq para editar de forma segura
if ! command -v jq &>/dev/null; then
  echo "❌ Error: 'jq' no está instalado. Instalalo con: sudo apt install jq o brew install jq"
  exit 1
fi

tmp_file="package.tmp.json"

start_exists=$(jq '.scripts.start' package.json)
dev_exists=$(jq '.scripts.dev' package.json)

jq 'if .scripts == null then .scripts = {} else . end' package.json >"$tmp_file" && mv "$tmp_file" package.json

if [ "$start_exists" = "null" ]; then
  jq '.scripts.start = "node src/index.js"' package.json >"$tmp_file" && mv "$tmp_file" package.json
  echo "✅ Script start agregado"
fi

if [ "$dev_exists" = "null" ]; then
  jq '.scripts.dev = "nodemon src/index.js"' package.json >"$tmp_file" && mv "$tmp_file" package.json
  echo "✅ Script dev agregado"
fi

echo "✅ Configuración de proyecto completada."
