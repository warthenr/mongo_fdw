\set MONGO_HOST			`echo \'"$MONGO_HOST"\'`
\set MONGO_PORT			`echo \'"$MONGO_PORT"\'`
\set MONGO_USER_NAME	`echo \'"$MONGO_USER_NAME"\'`
\set MONGO_PASS			`echo \'"$MONGO_PWD"\'`

-- Before running this file user must create database mongo_fdw_regress on
-- MongoDB with all permission for MONGO_USER_NAME user with MONGO_PASS
-- password and ran mongodb_init.sh file to load collections.

\c contrib_regression
CREATE EXTENSION IF NOT EXISTS mongo_fdw;
CREATE SERVER mongo_server FOREIGN DATA WRAPPER mongo_fdw
  OPTIONS (address :MONGO_HOST, port :MONGO_PORT);
CREATE USER MAPPING FOR public SERVER mongo_server;

-- Create foreign tables mapping Decimal128 field to various PostgreSQL types.

-- Decimal128 as NUMERIC (preserves full precision)
CREATE FOREIGN TABLE f_test_decimal128_numeric (_id NAME, c1 INTEGER, c2 VARCHAR(20), c3 NUMERIC)
  SERVER mongo_server OPTIONS (database 'mongo_fdw_regress', collection 'test_decimal128');

-- Decimal128 as NUMERIC with typmod
CREATE FOREIGN TABLE f_test_decimal128_numeric_mod (_id NAME, c1 INTEGER, c2 VARCHAR(20), c3 NUMERIC(12, 5))
  SERVER mongo_server OPTIONS (database 'mongo_fdw_regress', collection 'test_decimal128');

-- Decimal128 as TEXT
CREATE FOREIGN TABLE f_test_decimal128_text (_id NAME, c1 INTEGER, c2 VARCHAR(20), c3 TEXT)
  SERVER mongo_server OPTIONS (database 'mongo_fdw_regress', collection 'test_decimal128');

-- Decimal128 as VARCHAR
CREATE FOREIGN TABLE f_test_decimal128_varchar (_id NAME, c1 INTEGER, c2 VARCHAR(20), c3 VARCHAR(50))
  SERVER mongo_server OPTIONS (database 'mongo_fdw_regress', collection 'test_decimal128');

-- Decimal128 as INTEGER (truncating conversion)
CREATE FOREIGN TABLE f_test_decimal128_int (_id NAME, c1 INTEGER, c2 VARCHAR(20), c3 INTEGER)
  SERVER mongo_server OPTIONS (database 'mongo_fdw_regress', collection 'test_decimal128');

-- Decimal128 as BIGINT
CREATE FOREIGN TABLE f_test_decimal128_bigint (_id NAME, c1 INTEGER, c2 VARCHAR(20), c3 BIGINT)
  SERVER mongo_server OPTIONS (database 'mongo_fdw_regress', collection 'test_decimal128');

-- Decimal128 as FLOAT8
CREATE FOREIGN TABLE f_test_decimal128_float8 (_id NAME, c1 INTEGER, c2 VARCHAR(20), c3 FLOAT8)
  SERVER mongo_server OPTIONS (database 'mongo_fdw_regress', collection 'test_decimal128');

-- Test reading Decimal128 as NUMERIC (full precision)
SELECT c1, c2, c3 FROM f_test_decimal128_numeric ORDER BY c1;

-- Test reading Decimal128 as NUMERIC with typmod
SELECT c1, c2, c3 FROM f_test_decimal128_numeric_mod WHERE c1 IN (1, 3, 4, 5) ORDER BY c1;

-- Test reading Decimal128 as TEXT
SELECT c1, c2, c3 FROM f_test_decimal128_text ORDER BY c1;

-- Test reading Decimal128 as VARCHAR
SELECT c1, c2, c3 FROM f_test_decimal128_varchar ORDER BY c1;

-- Test reading Decimal128 as INTEGER (only rows with integer-compatible values)
SELECT c1, c2, c3 FROM f_test_decimal128_int WHERE c1 IN (4, 5) ORDER BY c1;

-- Test reading Decimal128 as BIGINT
SELECT c1, c2, c3 FROM f_test_decimal128_bigint WHERE c1 IN (4, 5) ORDER BY c1;

-- Test reading Decimal128 as FLOAT8
SELECT c1, c2, c3 FROM f_test_decimal128_float8 WHERE c1 IN (1, 3, 4, 5) ORDER BY c1;

-- Test WHERE clause with Decimal128 NUMERIC column
SELECT c1, c2, c3 FROM f_test_decimal128_numeric WHERE c3 > 0 ORDER BY c1;
SELECT c1, c2, c3 FROM f_test_decimal128_numeric WHERE c3 = 0 ORDER BY c1;

-- Cleanup
DROP FOREIGN TABLE f_test_decimal128_numeric;
DROP FOREIGN TABLE f_test_decimal128_numeric_mod;
DROP FOREIGN TABLE f_test_decimal128_text;
DROP FOREIGN TABLE f_test_decimal128_varchar;
DROP FOREIGN TABLE f_test_decimal128_int;
DROP FOREIGN TABLE f_test_decimal128_bigint;
DROP FOREIGN TABLE f_test_decimal128_float8;
DROP USER MAPPING FOR public SERVER mongo_server;
DROP SERVER mongo_server;
DROP EXTENSION mongo_fdw;
