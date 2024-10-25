#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

export LANG=C
PGPASSWORD=password psql -U rdsadmin -h localhost -p 5432 postgres -q -f dump/globals-only.sql 2> /dev/null
PGPASSWORD=password pg_restore -U rdsadmin -h localhost -p 5432 -d postgres -c --if-exists -F c dump/mydatabase.dump
