#!/bin/bash

export STORAGE_DIR="${STORAGE_DIR:-/app/server/storage}"
export SERVER_PORT="${SERVER_PORT:-3000}"

# Symlink .env to persistent storage so config survives container restarts
if [ ! -f "$STORAGE_DIR/.env" ]; then
  touch "$STORAGE_DIR/.env"
fi
ln -sf "$STORAGE_DIR/.env" /app/server/.env

# Map Polydock/Lagoon variables to AnythingLLM/LiteLLM expected names
export LITE_LLM_BASE_PATH="${LLM_URL:-$LITE_LLM_BASE_PATH}"
export LITE_LLM_API_KEY="${LLM_AI_KEY:-$LITE_LLM_API_KEY}"

cd /app/server || { echo "ERROR: Cannot cd to /app/server"; exit 1; }

{
  CHECKPOINT_DISABLE=1 npx prisma migrate deploy --schema=./prisma/schema.prisma 2>&1 || echo "Prisma migrate: no pending migrations"
  node /app/server/index.js
} &

node /app/collector/index.js &

wait -n
exit $?
