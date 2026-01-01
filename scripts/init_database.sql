USE master;
GO

--drop and recreate database if already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Datawarehouse')
BEGIN
	ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Datawarehouse;
END

CREATE DATABASE Datawarehouse;
GO

USE Datawarehouse;
GO

--create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO 
CREATE SCHEMA gold;
GO 