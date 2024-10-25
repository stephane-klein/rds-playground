#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

PGPASSWORD=password psql -U rdsadmin -h localhost -p 5432 postgres
