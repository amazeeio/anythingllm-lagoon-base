#!/bin/bash

export STORAGE_DIR="${STORAGE_DIR:-/app/server/storage}"
export SERVER_PORT="${SERVER_PORT:-3000}"

cd /app/server || { echo "ERROR: Cannot cd to /app/server"; exit 1; }

{
  CHECKPOINT_DISABLE=1 npx prisma migrate deploy --schema=./prisma/schema.prisma 2>&1 || echo "Prisma migrate: no pending migrations"
  node /app/server/index.js
} &

node /app/collector/index.js &

wait -n
exit $?
