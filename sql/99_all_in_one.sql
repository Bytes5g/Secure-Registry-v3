/*
Run all schema/setup scripts in dependency order.
Usage (sqlcmd): execute from the /sql directory so relative :r includes resolve correctly.
*/
:r 00_create_schemas.sql
:r 01_core_schema.sql
:r 02_security_schema.sql
:r 03_enforcement_schema.sql
:r 04_justice_schema.sql
:r 05_corrections_schema.sql
:r 06_seed_reference_data.sql
