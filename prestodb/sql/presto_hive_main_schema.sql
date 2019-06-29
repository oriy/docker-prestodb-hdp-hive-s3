 CREATE SCHEMA IF NOT EXISTS main_schema
  WITH (location = 's3a://bucket_for_schema_1/');


 CREATE TABLE IF NOT EXISTS main_schema.table_1 (
          datetime                TIMESTAMP,
          my_id                   INTEGER,
          date                    VARCHAR
 )
 WITH (
    external_location = 's3a://bucket_for_schema_1/table_1/',
    format = 'ORC',
    partitioned_by = ARRAY['date']
 );
