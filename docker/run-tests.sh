#!/usr/bin/env bash
#
# Run mongo_fdw regression tests inside the Docker environment.
#
# Usage:
#   docker compose up -d          # start services
#   docker compose exec postgres /build/mongo_fdw/docker/run-tests.sh
#
set -euo pipefail

export MONGO_HOST="${MONGO_HOST:-mongo}"
export MONGO_PORT="${MONGO_PORT:-27017}"
export MONGO_USER_NAME="${MONGO_USER_NAME:-edb}"
export MONGO_PWD="${MONGO_PWD:-edb}"

cd /build/mongo_fdw

echo "==> Loading test data into MongoDB..."
mongoimport --host="$MONGO_HOST" --port="$MONGO_PORT" \
  -u "$MONGO_USER_NAME" -p "$MONGO_PWD" \
  --db mongo_fdw_regress --collection countries \
  --jsonArray --drop --maintainInsertionOrder --quiet < data/mongo_fixture.json

mongoimport --host="$MONGO_HOST" --port="$MONGO_PORT" \
  -u "$MONGO_USER_NAME" -p "$MONGO_PWD" \
  --db mongo_fdw_regress --collection warehouse \
  --jsonArray --drop --maintainInsertionOrder --quiet < data/mongo_warehouse.json

mongoimport --host="$MONGO_HOST" --port="$MONGO_PORT" \
  -u "$MONGO_USER_NAME" -p "$MONGO_PWD" \
  --db mongo_fdw_regress --collection testlog \
  --jsonArray --drop --maintainInsertionOrder --quiet < data/mongo_testlog.json

mongoimport --host="$MONGO_HOST" --port="$MONGO_PORT" \
  -u "$MONGO_USER_NAME" -p "$MONGO_PWD" \
  --db mongo_fdw_regress --collection testdevice \
  --jsonArray --drop --maintainInsertionOrder --quiet < data/mongo_testdevice.json

mongosh --host="$MONGO_HOST" --port="$MONGO_PORT" \
  -u "$MONGO_USER_NAME" -p "$MONGO_PWD" \
  --authenticationDatabase "mongo_fdw_regress" < data/mongo_test_data.js > /dev/null

mongosh --host="$MONGO_HOST" --port="$MONGO_PORT" \
  -u "$MONGO_USER_NAME" -p "$MONGO_PWD" \
  --authenticationDatabase "mongo_fdw_regress" < data/mongo_test_decimal128.js > /dev/null

echo "==> Test data loaded."

echo "==> Running regression tests..."
export PKG_CONFIG_PATH=/build/mongo_fdw/mongo-c-driver/src/libmongoc/src:/build/mongo_fdw/mongo-c-driver/src/libbson/src
make USE_PGXS=1 installcheck PGUSER=postgres

echo "==> All tests passed!"
