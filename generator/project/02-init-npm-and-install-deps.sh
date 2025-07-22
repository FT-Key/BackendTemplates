#!/bin/bash
# generator/project/01-init-npm-and-install-deps.sh

if [ ! -f package.json ]; then
  echo "📦 Inicializando proyecto Node..."
  npm init -y
fi

if ! grep -q '"express"' package.json; then
  echo "📦 Instalando express..."
  npm install express
fi

if ! grep -q '"path-to-regexp"' package.json; then
  echo "📦 Instalando path-to-regexp..."
  npm install path-to-regexp
fi

echo "✅ Dependencias instaladas."
