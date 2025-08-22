/*
==================================================
Create database and schemas
==================================================
Script Purpose :
	This script creates a new database named 'Datawarehouse' after checking if it already exists.
	If database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
	within the database : 'Bronze', 'Silver', 'Gold'

Warning :
	Running this script will drop the entire 'Datawarehouse' database if it exists.
	All data in the database  will be permanently deleted. Proceed with caution
	and ensure you have proper backups before runningthe script.
*/

-- Drop and create 'Datawarehouse' database 

IF EXISTS (SELECT 1 FROM sys.databases WHERE NAME = 'Datawarehouse')
	BEGIN 
		ALTER DATABASE Datewarehouse SET  SINGLE_USER  WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Datawarehouse;
	END; 
GO

--Create Database 'Datawarehouse'

CREATE DATABASE Datawarehouse;
Go

USE Datawarehouse;
GO

-- Create Schemas 

Create schema Bronze;
Go

Create schema Silver;
Go

Create schema Gold;
Go
