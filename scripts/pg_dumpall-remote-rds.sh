#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

mkdir -p dump/

# See this tips: https://www.thatguyfromdelhi.com/2017/03/using-pgdumpall-with-aws-rds-postgres.html
pg_dumpall -U postgres -h $(terraform output -raw mydatabase | cut -d':' -f1) --roles-only --no-role-passwords -f dump/globals-only.sql

# Removes RDS-specific configurations in globals-only.sql
sed -i '/^CREATE ROLE rds/d' dump/globals-only.sql
sed -i '/^ALTER ROLE rds/d' dump/globals-only.sql
sed -i '/^ALTER ROLE rdsadmin/d' dump/globals-only.sql
sed -i '/^GRANT.*rds_/d' dump/globals-only.sql

pg_dump -U postgres -h $(terraform output -raw mydatabase | cut -d':' -f1) -d mydatabase -F c -f dump/mydatabase.dump
