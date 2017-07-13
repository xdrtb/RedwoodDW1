USE master
GO
-- Check if RedwoodDW1 exists, if it does not create the database RedwoodDW1
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'RedwoodDW1')
CREATE DATABASE RedwoodDW1
GO
USE RedwoodDW1
-- Check if tables exists and delete if they do
-- Check for fact table
IF EXISTS(
	SELECT * FROM sys.tables
	WHERE name = N'FactDaysOnMarket'
)
DROP TABLE FactDaysOnMarket;
-- Check for Dimension Tables
IF EXISTS(
	SELECT * FROM sys.tables
	WHERE name = N'DimDate'
)
DROP TABLE DimDAte;
IF EXISTS(
	SELECT * FROM sys.tables
	WHERE name = N'DimAgent'
)
DROP TABLE DimAgent;
IF EXISTS(
	SELECT * FROM sys.tables
	WHERE name = N'DimProperty'
)
DROP TABLE DimProperty;
-- Create tables
CREATE TABLE DimProperty (
	Property_SK INT IDENTITY (1,1) CONSTRAINT pk_propertySK PRIMARY KEY,
	PropertyID_AK INT NOT NULL,
	SaleStatus NVARCHAR(10) NOT NULL,
	City NVARCHAR(30) NOT NULL,
	ZipCode NVARCHAR(20) NOT NULL,
	Address NVARCHAR(30) NOT NULL,
	LotSize NUMERIC(4,2) NOT NULL,
	SqFt INT NOT NULL,
	Bedrooms INT NOT NULL,
	Bathrooms INT NOT NULL,
	Stories INT NOT NULL,
	YearBuilt NUMERIC(4,0) NOT NULL
);
CREATE TABLE DimAgent (
	Agent_SK INT IDENTITY (1,1) CONSTRAINT pk_agentSK PRIMARY KEY,
	AgentID_AK INT NOT NULL,
	Title NVARCHAR(20) NOT NULL,
	Gender NCHAR(1) NOT NULL,
	DOB DATETIME NOT NULL,
	HireDate DATETIME NOT NULL
);
CREATE TABLE DimDate (
	Date_SK INT IDENTITY(1,1) CONSTRAINT pk_dateSK PRIMARY KEY,
	[Date] DATETIME NOT NULL UNIQUE,
	DateName NVARCHAR(50) NULL,
	Month INT NOT NULL,
	MonthName NVARCHAR(50) NOT NULL,
	Quarter INT NOT NULL,
	QuarterName NVARCHAR(50) NOT NULL,
	Year INT NOT NULL
);
CREATE TABLE FactDaysOnMarket (
	DaysOnMarket_SK INT IDENTITY (1,1) CONSTRAINT pk_DaysOnMarketSK PRIMARY KEY,
	Property_SK INT CONSTRAINT fk_Property_DimProperty FOREIGN KEY REFERENCES DimProperty(Property_SK),
	Agent_SK INT CONSTRAINT fk_Agent_DimAgent FOREIGN KEY REFERENCES DimAgent(Agent_SK),
	ContactDate INT CONSTRAINT fk_ContactDate_DimDate FOREIGN KEY REFERENCES DimDate(Date_SK),
	BeginListDate INT CONSTRAINT fk_ListDate_DimDate FOREIGN KEY REFERENCES DimDate(Date_SK),
	AskingPrice MONEY NOT NULL,
	BidPrice MONEY
);