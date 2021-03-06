--Cretaed by Stef Tudor, Michael Atkins, Miguel Gerov
--Build RedwoodDW1
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
--
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
	YearBuilt NUMERIC(4,0) NOT NULL,
	EndListDate DATETIME NOT NULL,
	PropertyStartDate DATETIME,
	PropertyEndDate DATETIME
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
		Date_SK INT PRIMARY KEY, 
		Date DATETIME,
		FullDate CHAR(10),-- Date in MM-dd-yyyy format
		DayOfMonth INT, -- Field will hold day number of Month
		DayName VARCHAR(9), -- Contains name of the day, Sunday, Monday 
		DayOfWeek INT,-- First Day Sunday=1 and Saturday=7
		DayOfWeekInMonth INT, -- 1st Monday or 2nd Monday in Month
		DayOfWeekInYear INT,
		DayOfQuarter INT,
		DayOfYear INT,
		WeekOfMonth INT,-- Week Number of Month 
		WeekOfQuarter INT, -- Week Number of the Quarter
		WeekOfYear INT,-- Week Number of the Year
		Month INT, -- Number of the Month 1 to 12{}
		MonthName VARCHAR(9),-- January, February etc
		MonthOfQuarter INT,-- Month Number belongs to Quarter
		Quarter CHAR(2),
		QuarterName VARCHAR(9),-- First,Second..
		Year INT,-- Year value of Date stored in Row
		YearName CHAR(7), -- CY 2015,CY 2016
		MonthYear CHAR(10), -- Jan-2016,Feb-2016
		MMYYYY INT,
		FirstDayOfMonth DATE,
		LastDayOfMonth DATE,
		FirstDayOfQuarter DATE,
		LastDayOfQuarter DATE,
		FirstDayOfYear DATE,
		LastDayOfYear DATE,
		IsHoliday BIT,-- Flag 1=National Holiday, 0-No National Holiday
		IsWeekday BIT,-- 0=Week End ,1=Week Day
		Holiday VARCHAR(50),--Name of Holiday in US
		Season VARCHAR(10)--Name of Season
	);

CREATE TABLE FactDaysOnMarket (
	FactID INT IDENTITY (1,1) CONSTRAINT pk_FactID PRIMARY KEY,
	Property_SK INT CONSTRAINT fk_Property_DimProperty FOREIGN KEY REFERENCES DimProperty(Property_SK),
	Agent_SK INT CONSTRAINT fk_Agent_DimAgent FOREIGN KEY REFERENCES DimAgent(Agent_SK),
	ContactDate INT CONSTRAINT fk_ContactDate_DimDate FOREIGN KEY REFERENCES DimDate(Date_SK),
	BeginListDate INT CONSTRAINT fk_ListDate_DimDate FOREIGN KEY REFERENCES DimDate(Date_SK),
	AskingPrice MONEY NOT NULL,
	BidPrice MONEY
);