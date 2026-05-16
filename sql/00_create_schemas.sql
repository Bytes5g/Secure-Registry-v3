IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'core') EXEC('CREATE SCHEMA core');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'security') EXEC('CREATE SCHEMA security');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'governance') EXEC('CREATE SCHEMA governance');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'enforcement') EXEC('CREATE SCHEMA enforcement');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'justice') EXEC('CREATE SCHEMA justice');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'corrections') EXEC('CREATE SCHEMA corrections');
GO
