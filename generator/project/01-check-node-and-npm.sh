#!/bin/bash
# generator/project/00-check-node-and-npm.sh

if ! command -v node &>/dev/null; then
  echo "❌ Node.js no está instalado. Por favor instálalo primero."
  exit 1
fi

if ! command -v npm &>/dev/null; then
  echo "❌ npm no está instalado. Por favor instálalo primero."
  exit 1
fi

echo "✅ Node.js y npm detectados."
