#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

psql -U postgres -h $(terraform output -raw mydatabase | cut -d':' -f1) mydatabase -f sqls/seed.sql
