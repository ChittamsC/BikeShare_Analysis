
SELECT [O].[Row ID]
	,[O].[Order ID]
	,[O].[Order Date]
	,[O].[Ship Date]
	,[O].[Ship Mode]
	,[O].[Customer ID]
	,[O].[Customer Name]
	,[O].[Segment]
	,[O].[City]
	,[O].[State]
	,[O].[Country]
	,[O].[Postal Code]
	,[O].[Market]
	,[O].[Region]
	,[P].[Person]
	,[O].[Product ID]
	,[O].[Category]
	,[O].[Sub-Category]
	,[O].[Product Name]
	,ROUND([O].[Sales], 2) AS Sales
	,[O].[Quantity]
	,[O].[Discount]
	,ROUND([O].[Profit], 2) AS Profit
	,ROUND([O].[Shipping Cost], 2) AS Shipping_Cost
	,[O].[Order Priority]
INTO Superstore.dbo.Orders_1
FROM Superstore.dbo.Orders$ AS O
FULL JOIN Superstore.dbo.People$ AS P ON O.Region = P.Region

SELECT *
INTO Superstore.dbo.Orders_2
FROM Superstore.dbo.Orders_1 AS O1
LEFT JOIN Superstore.dbo.Returns$ AS R ON O1.[Order ID] = R.Orders_Id


WITH O3
AS (
	SELECT *
		,(Sales * Discount) AS Discount_Amount
		,Datename(weekday FROM [Order Date]) AS Dayofweek
		,Datepart(month FROM [Order Date]) AS Month_Num
		,Datename(month FROM [Order Date]) AS Month
		,Datepart(year FROM [Order Date]) AS Year
		,DateDiff(day, [Order Date], [Ship Date]) AS Time_to_Ship
	FROM Superstore.dbo.Orders_2
	)
SELECT *
	,(Sales - Discount_Amount) AS Actual_Sale
INTO Superstore.dbo.Orders_3
FROM O3

UPDATE Superstore.dbo.Orders_3
SET Profit = 0
WHERE Returned = 'Yes'

SELECT [Row ID]
FROM [Superstore].[dbo].[Orders_3]
GROUP BY [Row ID]
HAVING COUNT([Row ID]) > 1

SELECT *
FROM [Superstore].[dbo].[Orders_3]
WHERE [Row ID] = 8102
	OR [Row ID] = 36486
	OR [Row ID] = 8100
	OR [Row ID] = 36487
	OR [Row ID] = 8101

WITH cte
AS (
	SELECT [Row ID]
		,[Order ID]
		,[Order Date]
		,[Ship Date]
		,[Ship Mode]
		,[Customer ID]
		,[Customer Name]
		,[Segment]
		,[City]
		,[State]
		,[Country]
		,[Postal Code]
		,[Market]
		,[Region]
		,[Person]
		,[Product ID]
		,[Category]
		,[Sub-Category]
		,[Product Name]
		,[Sales]
		,[Quantity]
		,[Discount]
		,[Profit]
		,[Shipping_Cost]
		,[Order Priority]
		,[Returned]
		,[Orders_Id]
		,[Markets]
		,[Discount_Amount]
		,[Dayofweek]
		,[Month_Num]
		,[Month]
		,[Year]
		,[Time_to_Ship]
		,[Actual_Sale]
		,ROW_NUMBER() OVER (
			PARTITION BY [Row ID] ORDER BY [Row ID]
			) row_num
	FROM [Superstore].[dbo].[Orders_3]
	)
DELETE
FROM cte
WHERE row_num > 1

###Table Showing Sales Performance and Discounts Given By Year, Month, Day
SELECT Person
	,Isnull(Person, 'Company Direct') AS PersonII
	,Category
	,Sum(Profit) AS TotalProfit
	,SUM(Discount_Amount) AS TotalDiscount
	,Dayofweek
	,Month_Num
	,Month
	,Year
	,Count(*) AS NumOfSales
	,CASE 
		WHEN Dayofweek = 'Sunday'
			THEN 1
		WHEN Dayofweek = 'Monday'
			THEN 2
		WHEN Dayofweek = 'Tuesday'
			THEN 3
		WHEN Dayofweek = 'Wednesday'
			THEN 4
		WHEN Dayofweek = 'Thursday'
			THEN 5
		WHEN Dayofweek = 'Friday'
			THEN 6
		WHEN Dayofweek = 'Saturday'
			THEN 7
		END AS Dayofweek_numb
INTO Superstore.dbo.SalesmanPerformance
FROM [Superstore].[dbo].[Orders_3]
GROUP BY Person
	,Category
	,Dayofweek
	,Month_Num
	,Month
	,Year

###Table Showing Performance By Market and Region
SELECT Market
	,Region
	,ROUND(Sum(Shipping_Cost), 2) AS SpentShipping
	,Sum(Quantity) AS UnitsShipped
	,ROUND(Sum(Profit), 2) AS TotalProfit
	,year
	,month
	,month_num
INTO Superstore.dbo.Yearly_Ship_Prof_Mark_Regi
FROM [Superstore].[dbo].Orders_3
GROUP BY Market
	,region
	,year
	,month
	,month_num
ORDER BY TotalProfit DESC

###Table Showing Highest Grossing Products By Category, Sub-Category, and year
SELECT Category
	,[Sub-Category]
	,[Product Name]
	,Sum(Profit) AS TotalProfit
	,year
	,SUM(Shipping_Cost) AS CostOfShipping
	,Sum(Quantity) AS Units_Sold
INTO Superstore.dbo.YearlyGrossingSubCatTable
FROM [Superstore].[dbo].[Orders_3]
GROUP BY Category
	,[Sub-Category]
	,[Product Name]
	,year
ORDER BY TotalProfit DESC

###Table Showing Profit by Customer and Discounts Customer Received
SELECT [Customer Name]
	,Market
	,Category
	,COUNT(*) AS NumOfOrders
	,SUM(Profit) AS TotalProfit
	,SUM(Discount_Amount) AS TotalDiscount
	,year
	,CASE 
		WHEN Discount_Amount > 0
			THEN 1
		ELSE 0
		END AS discountTally
INTO Superstore.dbo.DiscountsByCustomerYearMarket
FROM [Superstore].[dbo].[Orders_3]
GROUP BY [Customer Name]
	,Market
	,Category
	,year
	,Discount_Amount

###Table Showing Market Sales By Day of Week and Month
SELECT Market
	,Category
	,[Sub-Category]
	,[Product Name]
	,Sum(Profit) AS Profit
	,Sum(Shipping_Cost) AS SpentShipping
	,Sum(Quantity) AS UnitsSold
	,Dayofweek
	,month
	,month_num
	,year
	,CASE 
		WHEN Dayofweek = 'Sunday'
			THEN 1
		WHEN Dayofweek = 'Monday'
			THEN 2
		WHEN Dayofweek = 'Tuesday'
			THEN 3
		WHEN Dayofweek = 'Wednesday'
			THEN 4
		WHEN Dayofweek = 'Thursday'
			THEN 5
		WHEN Dayofweek = 'Friday'
			THEN 6
		WHEN Dayofweek = 'Saturday'
			THEN 7
		END AS Dayofweek_numb
INTO Superstore.dbo.MarketSalesTimeline
FROM [Superstore].[dbo].[Orders_3]
GROUP BY Market
	,Category
	,[Sub-Category]
	,[Product Name]
	,Dayofweek
	,month
	,Month_Num
	,year
ORDER BY Market
	,UnitsSold DESC

###Order Priority Table
SELECT Market
	,Category
	,[Sub-Category]
	,[Order Priority]
	,month
	,month_num
	,Dayofweek
	,year
	,AVG(Time_to_Ship) AvgShipTime
	,Count(*) AS Orders
	,Returned
	,CASE 
		WHEN Dayofweek = 'Sunday'
			THEN 1
		WHEN Dayofweek = 'Monday'
			THEN 2
		WHEN Dayofweek = 'Tuesday'
			THEN 3
		WHEN Dayofweek = 'Wednesday'
			THEN 4
		WHEN Dayofweek = 'Thursday'
			THEN 5
		WHEN Dayofweek = 'Friday'
			THEN 6
		WHEN Dayofweek = 'Saturday'
			THEN 7
		END AS Dayofweek_numb,
INTO Superstore.dbo.OrderPriorityMarketTimline
FROM Superstore.dbo.Orders_3
GROUP BY Market
	,Category
	,[Sub-Category]
	,[Order Priority]
	,month
	,month_num
	,Dayofweek
	,year
	,Returned

###Orders Returned Table
SELECT Market
	,Category
	,[Sub-Category]
	,month
	,month_num
	,Dayofweek
	,year
	,Returned
	,CASE 
		WHEN Dayofweek = 'Sunday'
			THEN 1
		WHEN Dayofweek = 'Monday'
			THEN 2
		WHEN Dayofweek = 'Tuesday'
			THEN 3
		WHEN Dayofweek = 'Wednesday'
			THEN 4
		WHEN Dayofweek = 'Thursday'
			THEN 5
		WHEN Dayofweek = 'Friday'
			THEN 6
		WHEN Dayofweek = 'Saturday'
			THEN 7
		END AS Dayofweek_numb
INTO Superstore.dbo.OrdersReturned
FROM Superstore.dbo.Orders_3
WHERE Returned = 'Yes'


###Table Showing Customer Sale Metrics and Country Sale Metrics
SELECT [Customer Name]
	,Market
	,Country
	,Category
	,COUNT(*) AS NumOfOrders
	,SUM(Quantity) AS UnitsShipped
	,Shipping_Cost
	,Profit
	,Discount_Amount
	,year
	,CASE 
		WHEN Discount_Amount > 0
			THEN 1
		ELSE 0
		END AS discountTally
INTO Superstore.dbo.CountryCustomerTable
FROM [Superstore].[dbo].[Orders_3]
GROUP BY [Customer Name]
	,Market
	,Country
	,Category
	,year
	,Discount_Amount
	,Quantity
	,Shipping_Cost
	,Profit
	,Discount

