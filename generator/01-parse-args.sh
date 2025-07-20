#!/bin/bash
AUTO_CONFIRM=false
USE_JSON=false

for arg in "$@"; do
  case $arg in
  -y) AUTO_CONFIRM=true ;;
  --json) USE_JSON=true ;;
  esac
done