-- Get source data from Redwood.dbo.Property
-- Used with Data Flow Task "Fill DimProperty"
SELECT 
	p.PropertyID,
	s.SaleStatus,
	p.City,
	p.ZipCode,
	p.[Address],
	p.LotSize,
	p.SqFt,
	p.Bedrooms,
	p.Bathrooms,
	p.Stories,
	p.YearBuilt,
	l.EndListDate
FROM Redwood.dbo.Property AS p
INNER JOIN Redwood.dbo.Listing AS l
	ON p.PropertyID = l.PropertyID
LEFT OUTER JOIN Redwood.dbo.SaleStatus AS s
	ON l.SaleStatusID = s.SaleStatusID
GO
/************************************************/
-- Get source data from Redwood.dbo.Agent
-- Used with Data Flow Task "Fill DimAgent"
SELECT
	a.AgentID,
	a.Title,
	a.HireDate,
	a.Gender,
	a.BirthDate
FROM Redwood.dbo.Agent AS a
GO
/******************************************************/
-- Load data for DimDate
-- Used with Data Flow Task "Fill DimDate"
-- Load a Date Dimension (DimDate) adapted by Amy Phillips
USE RedwoodDW1

-- Specify start date and end date here
-- Value of start date must be less than your end date 

DECLARE @StartDate DATETIME = '01/01/2016' -- Starting value of date range
DECLARE @EndDate DATETIME = '7/19/2017' -- End Value of date range

-- Temporary variables to hold the values during processing of each date of year
DECLARE
	@DayOfWeekInMonth INT,
	@DayOfWeekInYear INT,
	@DayOfQuarter INT,
	@WeekOfMonth INT,
	@CurrentYear INT,
	@CurrentMonth INT,
	@CurrentQuarter INT

-- Table data type to store the day of week count for the month and year
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

-- Extract and assign various parts of values from current date to variable

DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)

-- Proceed only if start date(current date ) is less than end date you specified above

WHILE @CurrentDate < @EndDate
BEGIN
 
-- Begin day of week logic

	/*Check for change in month of the current date if month changed then change variable value*/
	IF @CurrentMonth <> DATEPART(MM, @CurrentDate) 
	BEGIN
		UPDATE @DayOfWeek
		SET MonthCount = 0
		SET @CurrentMonth = DATEPART(MM, @CurrentDate)
	END

	/* Check for change in quarter of the current date if quarter changed then change variable value*/

	IF @CurrentQuarter <> DATEPART(QQ, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET QuarterCount = 0
		SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)
	END
       
	/* Check for Change in Year of the Current date if Year changed then change variable value*/
	
	IF @CurrentYear <> DATEPART(YY, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET YearCount = 0
		SET @CurrentYear = DATEPART(YY, @CurrentDate)
	END
	
-- Set values in table data type created above from variables 

	UPDATE @DayOfWeek
	SET 
		MonthCount = MonthCount + 1,
		QuarterCount = QuarterCount + 1,
		YearCount = YearCount + 1
	WHERE DOW = DATEPART(DW, @CurrentDate)

	SELECT
		@DayOfWeekInMonth = MonthCount,
		@DayOfQuarter = QuarterCount,
		@DayOfWeekInYear = YearCount
	FROM @DayOfWeek
	WHERE DOW = DATEPART(DW, @CurrentDate)
	
-- End day of week logic

	/* Populate your dimension table with values*/
	
	INSERT INTO dbo.DimDate
	SELECT
		
		CONVERT (char(8),@CurrentDate,112) AS Date_SK,
		@CurrentDate AS Date,
		CONVERT (char(10),@CurrentDate,101) AS FullDate,
		DATEPART(MM, @CurrentDate) AS Month,
		DATENAME(MM, @CurrentDate) AS MonthName,
		'Q' + CONVERT(VARCHAR, DATEPART(QQ, @CurrentDate)) AS Quarter,
		DATEPART(YEAR, @CurrentDate) AS Year,
		LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR, 
		DATEPART(YY, @CurrentDate)) AS MonthYear,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) + 
		CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMYYYY,
		 CASE
			WHEN DATEPART(MM, @CurrentDate) IN (12,1,2) THEN 'Winter'
			WHEN DATEPART(MM, @CurrentDate) IN (3,4,5) THEN 'Spring'
			WHEN DATEPART(MM, @CurrentDate) IN (6,7,8) THEN 'Summer'
			WHEN DATEPART(MM, @CurrentDate) IN (9,10,11) THEN 'Fall'
			END AS Season

	SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END
;
/*************************************************************************/
-- Get source data from Redwood.dbo.CustAgentList and others
-- Used with Data Flow Task "Fill FactDaysOnMarket"
SELECT
	DimProperty.Property_SK,
	DimAgent.Agent_SK,
	ContactDate = DimDate.Date_SK,
	BeginListDate = DimDate.Date_SK,
	Redwood.dbo.Listing.AskingPrice,
	Redwood.dbo.CustAgentList.BidPrice
FROM Redwood.dbo.CustAgentList
INNER JOIN Redwood.dbo.Listing
	ON Redwood.dbo.CustAgentList.ListingID = Redwood.dbo.Listing.ListingID
INNER JOIN Redwood.dbo.Property
	ON Redwood.dbo.Listing.PropertyID = Redwood.dbo.Property.PropertyID
INNER JOIN DimProperty
	ON DimProperty.PropertyID_AK = Redwood.dbo.Property.PropertyID
INNER JOIN DimAgent
	ON DimAgent.AgentID_AK = Redwood.dbo.CustAgentList.AgentID
INNER JOIN DimDate
	ON DimDate.Date = Redwood.dbo.CustAgentList.ContactDate