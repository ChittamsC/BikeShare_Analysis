SELECT [CustomerKey],
      --[GeographyKey]
      [CustomerAlternateKey]
      ,--[Title],
	  [FirstName]
      ,--[MiddleName]
      [LastName]
	  ,FirstName + ' ' + LastName AS [FullName]
      ,--[NameStyle]
      [BirthDate]
      ,[MaritalStatus]
      ,--[Suffix]
      Case gender when 'M' then 'Male' When 'F' then 'Female' end as [Gender]
      ,[EmailAddress]
      ,[YearlyIncome]
      ,--[TotalChildren]
      --[NumberChildrenAtHome]
      [EnglishEducation]
      ,--[SpanishEducation]
      --[FrenchEducation]
      [EnglishOccupation]
      ,--[SpanishOccupation]
      --[FrenchOccupation]
      --[HouseOwnerFlag]
      --[NumberCarsOwned]
      [AddressLine1]
      ,[AddressLine2]
      ,[Phone]
      ,[DateFirstPurchase],
      --,[CommuteDistance]
	    g.city AS [Customer City], -- Joined in Customer City from Geography Table
		g.StateProvinceName AS [State],
		g.EnglishCountryRegionName As [Country]
FROM 
  AdventureWorksDW2019.dbo.DimCustomer as c
  LEFT JOIN AdventureWorksDW2019.dbo.DimGeography AS g ON g.GeographyKey = c.GeographyKey 

ORDER BY 
  CustomerKey ASC -- Ordered List by CustomerKey