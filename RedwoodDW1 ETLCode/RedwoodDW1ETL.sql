-- Get source data from Redwood.dbo.Property
-- Used with Data Flow Task "Fill DimProperty"
SELECT 
	dbo.Property.PropertyID,
	dbo.SaleStatus.SaleStatus,
	dbo.Property.City,
	dbo.Property.ZipCode,
	dbo.Property.[Address],
	dbo.Property.LotSize,
	dbo.Property.SqFt,
	dbo.Property.Bedrooms,
	dbo.Property.Bathrooms,
	dbo.Property.Stories,
	dbo.Property.YearBuilt
FROM Redwood.dbo.Property
INNER JOIN Redwood.dbo.Listing
	ON Redwood.dbo.Property.PropertyID = Redwood.dbo.Listing.PropertyID
LEFT OUTER JOIN Redwood.dbo.SaleStatus
	ON Redwood.dbo.Listing.SaleStatusID = Redwood.dbo.SaleStatus.SaleStatusID
GO

-- Get source data from Redwood.dbo.Agent
-- Used with Data Flow Task "Fill DimAgent"
SELECT
	dbo.Agent.AgentID,
	dbo.Agent.Title,
	dbo.Agent.HireDate,
	dbo.Agent.Gender,
	dbo.Agent.BirthDate
FROM Redwood.dbo.Agent
GO
-- Load data for DimDate
-- Used with Data Flow Task "Fill DimDate"



-- Get source data from Redwood.dbo.CustAgentList and others
-- Used with Data Flow Task "Fill FactDaysOnMarket"
SELECT
	dbo.Property.PropertyID,
	dbo.CustAgentList.AgentID,
	dbo.CustAgentList.ContactDate,
	dbo.Listing.BeginListDate,
	dbo.Listing.AskingPrice,
	dbo.CustAgentList.BidPrice
FROM Redwood.dbo.CustAgentList
INNER JOIN Redwood.dbo.Listing
	ON dbo.CustAgentList.ListingID = dbo.Listing.ListingID
INNER JOIN Redwood.dbo.Property
	ON dbo.Listing.PropertyID = dbo.Property.PropertyID
GO