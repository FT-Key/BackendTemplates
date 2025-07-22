#!/bin/bash

# Archivos y contenido Docker básicos
FILES=(
  ".dockerignore"
  "Dockerfile"
  "docker-compose.yml"
)

DOCKERIGNORE_CONTENT="node_modules
npm-debug.log
Dockerfile
docker-compose.yml
.git"

DOCKERFILE_CONTENT="FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD [\"node\", \"src/config/server.js\"]"

DOCKER_COMPOSE_CONTENT="
services:
  backend:
    container_name: hex-backend
    build: .
    ports:
      - \"3000:3000\"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    command: npm start"

# Función para crear archivo con contenido
create_or_overwrite() {
  local file="$1"
  local content="$2"

  if [ -f "$file" ]; then
    read -rp "⚠️ El archivo '$file' ya existe. ¿Deseas sobrescribirlo? (s/n): " confirm
    if [[ "$confirm" =~ ^[Ss]$ ]]; then
      echo "$content" >"$file"
      echo "✅ Archivo '$file' sobrescrito."
    else
      echo "⏩ Archivo '$file' conservado."
    fi
  else
    echo "$content" >"$file"
    echo "✅ Archivo '$file' creado."
  fi
}

# Ejecutar creación/sobrescritura
create_or_overwrite ".dockerignore" "$DOCKERIGNORE_CONTENT"
create_or_overwrite "Dockerfile" "$DOCKERFILE_CONTENT"
create_or_overwrite "docker-compose.yml" "$DOCKER_COMPOSE_CONTENT"

echo "🟢 Configuración Docker completa."
