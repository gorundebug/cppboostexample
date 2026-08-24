#!/bin/sh
set -eu

: "${POSTGRES_SEEDS:?POSTGRES_SEEDS is required}"
: "${POSTGRES_USER:?POSTGRES_USER is required}"

sql_tool() {
  database="$1"
  shift
  temporal-sql-tool --plugin postgres12 \
    --ep "${POSTGRES_SEEDS}" \
    -u "${POSTGRES_USER}" \
    --pw "${POSTGRES_PWD:-${SQL_PASSWORD:-}}" \
    -p "${DB_PORT:-5432}" \
    --db "${database}" "$@"
}

echo 'Preparing Temporal PostgreSQL schemas'
nc -z -w 10 "${POSTGRES_SEEDS}" "${DB_PORT:-5432}"

sql_tool temporal create || true
sql_tool temporal setup-schema -v 0.0 || true
sql_tool temporal update-schema \
  -d /etc/temporal/schema/postgresql/v12/temporal/versioned

sql_tool temporal_visibility create || true
sql_tool temporal_visibility setup-schema -v 0.0 || true
sql_tool temporal_visibility update-schema \
  -d /etc/temporal/schema/postgresql/v12/visibility/versioned

echo 'Temporal PostgreSQL schemas are ready'