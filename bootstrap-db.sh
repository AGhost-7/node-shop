createdb node_shop
psql node_shop -f sql/tables.sql
psql node_shop -f sql/views.sql
psql node_shop -f sql/data.sql
