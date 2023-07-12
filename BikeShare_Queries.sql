ALTER TABLE [Divvy].[dbo].['202101-divvy-tripdata$']
ALTER COLUMN start_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202102-divvy-tripdata$']
ALTER COLUMN start_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202103-divvy-tripdata$']
ALTER COLUMN start_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202104-divvy-tripdata$']
ALTER COLUMN end_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202107-divvy-tripdata$']
ALTER COLUMN end_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].[202111-divy-tripdata]
ALTER COLUMN start_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202204-divvy-tripdata$']
ALTER COLUMN start_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202207-divvy-tripdata$']
ALTER COLUMN start_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202209-divvy-publictripdata$']
ALTER COLUMN end_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202210-divvy-tripdata$']
ALTER COLUMN start_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202211-divvy-tripdata$']
ALTER COLUMN start_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202211-divvy-tripdata$']
ALTER COLUMN end_station_id NVARCHAR(255)

ALTER TABLE [Divvy].[dbo].['202212-divvy-tripdata$']
ALTER COLUMN end_station_id NVARCHAR(255)

SELECT *
INTO [Divvy].[dbo].[UnionDivvy]
FROM [Divvy].[dbo].[202101-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202102-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202103-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202104-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202105-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202106-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202107-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202108-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202109-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202110-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202111-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202112-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202201-divvy-tripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202202-divvy-tripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202203-divvy-tripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202204-divvy-tripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202205-divvy-tripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202206-divvy-tripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202207-divvy-tripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202208-divvy-tripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202209-divvy-publictripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202210-divvy-tripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202210-divvy-tripdata$']
UNION ALL
SELECT *
FROM [Divvy].[dbo].['202211-divvy-tripdata$']

###Getting rid of duplicate rides and extracting date names, parts, and length of ride from started_at column

SELECT DISTINCT [ride_id]
	,[rideable_type]
	,[started_at]
	,[ended_at]
	,[start_station_name]
	,[start_station_id]
	,[end_station_name]
	,[end_station_id]
	,[start_lat]
	,[start_lng]
	,[end_lat]
	,[end_lng]
	,[member_casual]
	,Datename(weekday FROM started_at) AS Dayofweek
	,Datepart(weekday FROM started_at) AS DayofweekNum
	,Datepart(month FROM started_at) AS Month_Num
	,Datename(month FROM started_at) AS Month
	,Datepart(hour FROM started_at) AS HourofDay
	,Datepart(year FROM started_at) AS Year
	,DateDiff(minute, started_at, ended_at) AS ride_length_min
INTO Divvy.dbo.UnionDivvy2
FROM Divvy.dbo.UnionDivvy

###Selecting all data where ride length is longer than one minute and less than 24 hours.
###Any ride longer than 24 hours the bike is to be considered stolen, and any ride less than one minute is considered a false start.

SELECT *
INTO Divvy.dbo.CleanDivvy
FROM Divvy.dbo.UnionDivvy2
WHERE ride_length_min between 1 AND 1440

###Cleaning Station Names

UPDATE Divvy.[dbo].[CleanDivvy]
SET start_station_name = LEFT(start_station_name, Len(start_station_name) - 1)
WHERE start_station_name LIKE '%*'

UPDATE Divvy.[dbo].[CleanDivvy]
SET end_station_name = LEFT(end_station_name, Len(end_station_name) - 1)
WHERE end_station_name LIKE '%*'

UPDATE Divvy.[dbo].[CleanDivvy]
SET start_station_name = LEFT(start_station_name, Len(start_station_name) - 3)
WHERE start_station_name LIKE '%(*)'

UPDATE Divvy.[dbo].[CleanDivvy]
SET end_station_name = LEFT(end_station_name, Len(end_station_name) - 3)
WHERE end_station_name LIKE '%(*)'

UPDATE Divvy.[dbo].[CleanDivvy]
SET start_station_name = LEFT(start_station_name, Len(start_station_name) - 11)
WHERE start_station_name LIKE '% - Charging'

UPDATE Divvy.[dbo].[CleanDivvy]
SET end_station_name = LEFT(end_station_name, Len(end_station_name) - 11)
WHERE end_station_name LIKE '% - Charging'

DELETE
FROM Divvy.dbo.CleanDivvy
WHERE start_station_name = 'DIVVY CASSETTE REPAIR MOBILE STATION'
	OR end_station_name = 'DIVVY CASSETTE REPAIR MOBILE STATION'
	OR start_station_name = 'Base - 2132 W Hubbard'
	OR end_station_name = 'Base - 2132 W Hubbard'
	OR start_station_name = 'Base - 2132 W Hubbard Warehouse'
	OR end_station_name = 'Base - 2132 W Hubbard Warehouse'
	OR start_station_name = 'Pawel Bialowas - Test- PBSC charging station'
	OR end_station_name = 'Pawel Bialowas - Test- PBSC charging station'
	OR start_station_name = '351'
	OR end_station_name = '351'

UPDATE Divvy.dbo.CleanDivvy
SET rideable_type = 'classic_bike'
WHERE rideable_type = 'docked_bike'

DELETE
FROM Divvy.dbo.CleanDivvy
WHERE rideable_type = 'classic_bike'
	AND start_station_name IS NULL
	OR end_station_name IS NULL

UPDATE Divvy.dbo.CleanDivvy
SET start_station_name = 'E-Bike Lock'
WHERE start_station_name IS NULL
	AND rideable_type = 'electric_bike'

UPDATE Divvy.dbo.CleanDivvy
SET end_station_name = 'E-Bike Lock'
WHERE end_station_name = ' '
	AND rideable_type = 'electric_bike'

UPDATE Divvy.dbo.CleanDivvy
SET end_station_name = 'E-Bike Lock'
WHERE end_station_name IS NULL
	AND rideable_type = 'electric_bike'

###Creating a table with total number of member and causal rides

SELECT member_casual
	,year
	,count(*) AS rides
FROM Divvy.dbo.CleanDivvy
GROUP BY member_casual
	,year
ORDER BY year

###Creating a table with total number of member and casual rides per bike type 

SELECT rideable_type
	,member_casual
	,year
	,count(*) AS rides
FROM Divvy.dbo.CleanDivvy
GROUP BY rideable_type
	,member_casual
	,year

###Creating a table with total number of member and casual rides per month

SELECT month
	,member_casual
	,year
	,Month_Num
	,count(1) AS users
FROM Divvy.dbo.CleanDivvy
GROUP BY month
	,member_casual
	,year
	,Month_Num
ORDER BY year
	,month

###Creating a table with the member and casual rides per day of week

SELECT member_casual
	,Dayofweek
	,year
	,count(*) AS rides
FROM [Divvy].[dbo].[CleanDivvy]
GROUP BY member_casual
	,Dayofweek
	,year

#Creating a table with # of rides by start station 

SELECT DISTINCT start_station_name
	,member_casual
	,count(*) AS Rides
INTO Divvy.dbo.RidesbyStartStation
FROM Divvy.dbo.CleanDivvy
GROUP BY start_station_name
	,member_casual
ORDER BY Rides DESC

### # of rides by end station

SELECT DISTINCT end_station_name
	,member_casual
	,count(*) AS Rides
INTO Divvy.dbo.RidesbyDestinationStation
FROM Divvy.dbo.CleanDivvy3
GROUP BY end_station_name
	,member_casual
ORDER BY Rides DESC

###Member Top 5 Start Stations
SELECT start_station_name
	,member_casual
	,Count(ride_id) AS Rides
	,CASE 
		WHEN start_station_name = 'Kingsbury St & Kinzie St'
			THEN 41.88924
		WHEN start_station_name = 'Clark St & Elm St'
			THEN 41.90308
		WHEN start_station_name = 'Wells St & Concord Ln'
			THEN 41.91225
		WHEN start_station_name = 'Wells St & Elm St'
			THEN 41.90325
		WHEN start_station_name = 'Dearborn St & Erie St'
			THEN 41.89402
		END AS latitude
	,CASE 
		WHEN start_station_name = 'Kingsbury St & Kinzie St'
			THEN - 87.63851
		WHEN start_station_name = 'Clark St & Elm St'
			THEN - 87.63129
		WHEN start_station_name = 'Wells St & Concord Ln'
			THEN - 87.63468
		WHEN start_station_name = 'Wells St & Elm St'
			THEN - 87.63433
		WHEN start_station_name = 'Dearborn St & Erie St'
			THEN - 87.62932
		END AS longitude
	,CASE 
		WHEN start_station_name IS NOT NULL
			THEN 'Chicago'
		END AS City
INTO Divvy2.dbo.Top5MemberStartStations
FROM Divvy2.dbo.CleanDivvy
WHERE start_station_name = 'Kingsbury St & Kinzie St'
	OR start_station_name = 'Clark St & Elm St'
	OR start_station_name = 'Wells St & Concord Ln'
	OR start_station_name = 'Wells St & Elm St'
	OR start_station_name = 'Dearborn St & Erie St'
GROUP BY start_station_name
	,member_casual

###Member Top 5 End Stations
Select start_station_name,member_casual, Count(ride_id) as Rides,
Case 
When start_station_name = 'Kingsbury St & Kinzie St' then 41.88924
When start_station_name = 'Clark St & Elm St' then 41.90308
When start_station_name = 'Wells St & Concord Ln' then 41.91225
When start_station_name = 'Wells St & Elm St' then 41.90325
When start_station_name = 'Clinton St & Madison St' then 41.88186
end as latitude,
Case 
When start_station_name = 'Kingsbury St & Kinzie St' then -87.63851
When start_station_name = 'Clark St & Elm St' then -87.63129
When start_station_name = 'Wells St & Concord Ln' then -87.63468
When start_station_name = 'Wells St & Elm St' then -87.63433
When start_station_name = 'Clinton St & Madison St' then -87.64112
end as longitude,
Case
When start_station_name is not null then 'Chicago'
end as City
Into Divvy2.dbo.Top5MemberEndStations
FROM Divvy2.dbo.CleanDivvy
WHERE start_station_name = 'Kingsbury St & Kinzie St'
OR start_station_name = 'Clark St & Elm St'
OR start_station_name = 'Wells St & Concord Ln'
OR start_station_name = 'Wells St & Elm St'
OR start_station_name = 'Clinton St & Madison St'
GROUP BY start_station_name, member_casual

###Casual Top 5 Start Stations
Select start_station_name,member_casual, Count(ride_id) as Rides,
Case 
When start_station_name = 'Streeter Dr & Grand Ave' then 41.89230
When start_station_name = 'Millennium Park' then 41.88268
When start_station_name = 'Michigan Ave & Oak St' then 41.90117
When start_station_name = 'DuSable Lake Shore Dr & Monroe St' then 41.88140
When start_station_name = 'Shedd Aquarium' then 41.86780
end as latitude,
Case 
When start_station_name = 'Streeter Dr & Grand Ave' then -87.61202
When start_station_name = 'Millennium Park' then -87.62256
When start_station_name = 'Michigan Ave & Oak St' then -87.62379
When start_station_name = 'DuSable Lake Shore Dr & Monroe St' then -87.61686
When start_station_name = 'Shedd Aquarium' then -87.61401
end as longitude,
Case
When start_station_name is not null then 'Chicago'
end as City
Into Divvy2.dbo.Top5CasualStartStations
FROM Divvy2.dbo.CleanDivvy
WHERE start_station_name = 'Streeter Dr & Grand Ave'
OR start_station_name = 'Millennium Park'
OR start_station_name = 'Michigan Ave & Oak St'
OR start_station_name = 'DuSable Lake Shore Dr & Monroe St'
OR start_station_name = 'Shedd Aquarium'
GROUP BY start_station_name, member_casual

###Top 5 Casual End Stations
Select start_station_name,member_casual, Count(ride_id) as Rides,
Case 
When start_station_name = 'Streeter Dr & Grand Ave' then 41.89230
When start_station_name = 'Millennium Park' then 41.88268
When start_station_name = 'Michigan Ave & Oak St' then 41.90117
When start_station_name = 'DuSable Lake Shore Dr & Monroe St' then 41.88140
When start_station_name = 'DuSable Lake Shore Dr & North Blvd' then 41.88102
end as latitude,
Case 
When start_station_name = 'Streeter Dr & Grand Ave' then -87.61202
When start_station_name = 'Millennium Park' then -87.62256
When start_station_name = 'Michigan Ave & Oak St' then -87.62379
When start_station_name = 'DuSable Lake Shore Dr & Monroe St' then -87.61686
When start_station_name = 'DuSable Lake Shore Dr & North Blvd' then -87.61674
end as longitude,
Case
When start_station_name is not null then 'Chicago'
end as City
Into Divvy2.dbo.Top5CasualEndStations
FROM Divvy2.dbo.CleanDivvy
WHERE start_station_name = 'Streeter Dr & Grand Ave'
OR start_station_name = 'Millennium Park'
OR start_station_name = 'Michigan Ave & Oak St'
OR start_station_name = 'DuSable Lake Shore Dr & Monroe St'
OR start_station_name = 'DuSable Lake Shore Dr & North Blvd'
GROUP BY start_station_name, member_casual




###Creating a table with the most popular routes of casual riders from the most popular departing stations

SELECT start_station_name
	,end_station_name
	,year
	,member_casual
	,count(*) AS rides
INTO Divvy2.dbo.PopularRoutes
FROM Divvy2.dbo.CleanDivvy2
WHERE start_station_name = 'Streeter Dr & Grand Ave'
	OR start_station_name = 'Millennium Park'
	OR start_station_name = 'Michigan Ave & Oak St'
	OR start_station_name = 'Theater on the Lake'
	OR start_station_name = 'Lake Shore Dr & Monroe St'
	OR start_station_name = 'Clark St & Elm St'
	OR start_station_name = 'Wells St & Concord Ln'
	OR start_station_name = 'Kingsbury St & Kinzie St'
	OR start_station_name = 'Wells St & Elm St'
	OR start_station_name = 'St. Clair St & Erie St'
GROUP BY start_station_name
	,end_station_name
	,member_casual
	,year

#AVG ride length for member_casual & bike type
SELECT rideable_type
      ,member_casual
      ,Year
      ,AVG(ride_length_min) as avg_ride_time
  INTO Divvy.dbo.AvgRideLengths
  FROM Divvy.dbo.CleanDivvy2
  GROUP BY rideable_type
      ,member_casual
      ,Year


###Selecting all data where ride length is 24 hours or greater—Ride is considered a stolen bike

SELECT *
INTO Divvy2.dbo.Rides_Over_24hrs
FROM Divvy2.dbo.CleanDivvy
WHERE ride_length_min > 1440

SELECT DISTINCT start_station_name
	,count(*) AS Bikes_stolen
INTO Divvy2.dbo.Num_bikes_stolen_from_station
FROM Divvy2.dbo.Rides_Over_24hrs
GROUP BY start_station_name
ORDER BY Bikes_stolen DESC

SELECT DISTINCT [Dayofweek]
	,Count(*) AS StolenBikes
	,
INTO Divvy2.dbo.Daily_StolenBikes
FROM [Divvy2].[dbo].[Rides_Over_24hrs]
GROUP BY Dayofweek
ORDER BY StolenBikes DESC

SELECT rideable_type
	,count(*) AS bikes_stolen
INTO Divvy2.dbo.Num_of_type_StolenBikes
FROM Divvy2.dbo.Rides_Over_24hrs
GROUP BY rideable_type

SELECT DISTINCT HourofDay
	,Count(*) AS StolenBikes
INTO Divvy2.dbo.StolenBikes_HourOfDay
FROM Divvy2.dbo.Rides_Over_24hrs
GROUP BY HourofDay
ORDER BY HourofDay ASC

SELECT DISTINCT Month
	,Month_Num
	,Year
	,Count(*) AS StolenBikes
INTO Divvy2.dbo.Month_Year_StolenBikes
FROM Divvy2.dbo.Rides_Over_24hrs
GROUP BY Month
	,month_num
	,Year
ORDER BY Month_Num ASC




###Alter columns to enable a union of all datasets

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2018_Q1$]
ALTER COLUMN trip_id VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2018_Q1$]
ALTER COLUMN start_time VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2018_Q1$]
ALTER COLUMN end_time VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2018_Q1$]
ALTER COLUMN bikeid VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2018_Q1$]
ALTER COLUMN tripduration VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2018_Q1$]
ALTER COLUMN from_station_id VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2018_Q1$]
ALTER COLUMN to_station_id VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2018_Q1$]
ALTER COLUMN birthyear VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2019_Q2]
ALTER COLUMN trip_id VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2019_Q2]
ALTER COLUMN start_time VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2019_Q2]
ALTER COLUMN end_time VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2019_Q2]
ALTER COLUMN bikeid VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2019_Q2]
ALTER COLUMN tripduration VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2019_Q2]
ALTER COLUMN from_station_id VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2019_Q2]
ALTER COLUMN to_station_id VARCHAR(50)

ALTER TABLE [QDivvy].[dbo].[Divvy_Trips_2019_Q2]
ALTER COLUMN birthyear VARCHAR(50)


###Union Quarterly data sets

SELECT *
INTO QDivvy.dbo.Q_Union
FROM [QDivvy].[dbo].[Divvy_Trips_2018_Q1$]
UNION ALL
SELECT *
FROM [QDivvy].[dbo].[Divvy_Trips_2018_Q2]
UNION ALL
SELECT *
FROM [QDivvy].[dbo].[Divvy_Trips_2018_Q3]
UNION ALL
SELECT *
FROM [QDivvy].[dbo].[Divvy_Trips_2018_Q4]
UNION ALL
SELECT *
FROM [QDivvy].[dbo].[Divvy_Trips_2019_Q1]
UNION ALL
SELECT *
FROM [QDivvy].[dbo].[Divvy_Trips_2019_Q2]
UNION ALL
SELECT *
FROM [QDivvy].[dbo].[Divvy_Trips_2019_Q3]
UNION ALL
SELECT *
FROM [QDivvy].[dbo].[Divvy_Trips_2019_Q4]

###Changing data type of two columns to prepare for dat
ALTER TABLE Qdivvy.dbo.Q_Union
ALTER COLUMN start_time DATETIME

ALTER TABLE QDivvy.dbo.Q_Union
ALTER COLUMN end_time DATETIME

###Cleaning data to extract date parts, ride length in minutes, and to salvage the gender , birth year, and user type information in the dataset.

SELECT *
	,Datename(weekday FROM start_time) AS Dayofweek
	,Datepart(weekday FROM start_time) AS DayofweekNum
	,Datepart(month FROM start_time) AS Month_Num
	,Datename(month FROM start_time) AS Month
	,Datepart(hour FROM start_time) AS HourofDay
	,Datepart(year FROM start_time) AS Year
	,DateDiff(minute, start_time, end_time) AS ride_length_min
	,CASE 
		WHEN birthyear LIKE 'Male,%'
			THEN Substring(birthyear, 6, 4)
		WHEN birthyear LIKE 'Male, %'
			THEN Substring(birthyear, 7, 4)
		WHEN birthyear LIKE 'Subscriber,Male,%'
			THEN Substring(birthyear, 17, 4)
		WHEN birthyear LIKE 'Customer,Male,%'
			THEN Substring(birthyear, 15, 4)
		WHEN birthyear LIKE 'Subscriber,Male, %'
			THEN Substring(birthyear, 18, 4)
		WHEN birthyear LIKE 'Customer,Male, %'
			THEN Substring(birthyear, 16, 4)
		WHEN birthyear LIKE 'Customer,,%'
			THEN Substring(birthyear, 11, 4)
		WHEN birthyear LIKE 'Customer,Female,%'
			THEN Substring(birthyear, 17, 4)
		WHEN birthyear LIKE 'Subscriber,Female,%'
			THEN Substring(birthyear, 19, 4)
		WHEN birthyear LIKE 'Customer,, %'
			THEN Substring(birthyear, 12, 4)
		WHEN birthyear LIKE 'Customer,Female, %'
			THEN Substring(birthyear, 18, 4)
		WHEN birthyear LIKE 'Subscriber,Female, %'
			THEN Substring(birthyear, 20, 4)
		WHEN birthyear LIKE 'Female, %'
			THEN Substring(birthyear, 9, 4)
		WHEN birthyear LIKE 'Female,%'
			THEN Substring(birthyear, 8, 4)
		WHEN birthyear LIKE ',%'
			THEN Substring(birthyear, 2, 4)
		WHEN birthyear LIKE '1%'
			THEN Substring(birthyear, 1, 4)
		WHEN birthyear LIKE '2%'
			THEN Substring(birthyear, 1, 4)
		END AS Birth
	,CASE 
		WHEN birthyear LIKE 'Mal%'
			THEN 'Male'
		WHEN birthyear LIKE 'Fem%'
			THEN 'Female'
		WHEN gender = 'Male'
			THEN 'Male'
		WHEN gender = 'Female'
			THEN 'Female'
		END AS Sex
	,CASE 
		WHEN gender = 'Customer'
			THEN 'Casual'
		WHEN gender = 'Subscriber'
			THEN 'Member'
		WHEN usertype = 'Customer'
			THEN 'Casual'
		WHEN usertype = 'Subscriber'
			THEN 'Member'
		END AS Member_Casual
INTO QDivvy.dbo.Q2
FROM QDivvy.dbo.Q_Union



DELETE
FROM [QDivvy].[dbo].[Q2]
WHERE Sex IS NULL
	OR Birth IS NULL
	OR Birth = ' '

ALTER TABLE [QDivvy].[dbo].[Q2] ADD Age INT

UPDATE [QDivvy].[dbo].[Q2]
SET Age = Year – Birth

SELECT AVG(Age)
	,sex
	,Member_Casual
FROM [QDivvy].[dbo].[Q2]
GROUP BY sex
	,Member_Casual

SELECT DISTINCT Age
	,sex
	,member_casual
	,count(*) AS customers
FROM [QDivvy].[dbo].[Q2]
GROUP BY age
	,sex
	,member_casual
ORDER BY count(*) DESC
	,Sex

SELECT DISTINCT Age
	,sex
	,member_casual
	,count(*) AS customers
FROM [QDivvy].[dbo].[Q2]
WHERE sex = 'Male'
	AND Member_Casual = 'casual'
GROUP BY age
	,sex
	,member_casual
ORDER BY count(*) DESC
	,Sex

SELECT DISTINCT Age
	,sex
	,member_casual
	,count(*) AS customers
FROM [QDivvy].[dbo].[Q2]
WHERE sex = 'Female'
	AND Member_Casual = 'casual'
GROUP BY age
	,sex
	,member_casual
ORDER BY count(*) DESC
	,Sex

###Creating a table that counts the number of rides per age and deleting any rides where the rider is over 100 years old

SELECT Age
	,Count(1) AS Rides
INTO Divvy.dbo.Age_Rides
FROM [Divvy].[dbo].[QuarterlyUnion_1]
GROUP BY Age

SELECT *
INTO Divvy.dbo.AgeRides
FROM [Divvy].[dbo].[Age_Rides]
WHERE Age < 101

###Creating a table that counts the number of rides per rider gender

SELECT Sex
	,Count(1) AS Rides
INTO Divvy.dbo.Sex_Rides
FROM [Divvy].[dbo].[QuarterlyUnion_1]
GROUP BY Sex
