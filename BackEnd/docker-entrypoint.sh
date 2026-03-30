#!/bin/sh
set -eu

echo "Waiting for database..."
until python -c "from sqlalchemy import create_engine, text; from app.core.config import settings; engine = create_engine(settings.DATABASE_URL); conn = engine.connect(); conn.execute(text('SELECT 1')); conn.close()" >/dev/null 2>&1
do
  sleep 2
done

echo "Running database migrations..."
alembic upgrade head

echo "Bootstrapping admin user..."
python scripts/bootstrap_admin.py

echo "Starting API..."
exec "$@"
