#################Difficulty uploading datasets
- Executing (Error)
Messages
•	Error 0xc02020a1: Data Flow Task 1: Data conversion failed. The data conversion for column "end_station_name" returned status value 4 and status text "Text was truncated or one or more characters had no match in the target code page.".
 (SQL Server Import and Export Wizard)
 
•	Error 0xc020902a: Data Flow Task 1: The "Source - 202102-divvy-tripdata_csv.Outputs[Flat File Source Output].Columns[end_station_name]" failed because truncation occurred, and the truncation row disposition on "Source - 202102-divvy-tripdata_csv.Outputs[Flat File Source Output].Columns[end_station_name]" specifies failure on truncation. A truncation error occurred on the specified object of the specified component.
 (SQL Server Import and Export Wizard)
 
•	Error 0xc0202092: Data Flow Task 1: An error occurred while processing file "C:\Users\Christian\Documents\ExtractedDivy\202102-divvy-tripdata.csv" on data row 273.
 (SQL Server Import and Export Wizard)
 
Error 0xc0047038: Data Flow Task 1: SSIS Error Code DTS_E_PRIMEOUTPUTFAILED.  The PrimeOutput method on Source - 202102-divvy-tripdata_csv returned error code 0xC0202092.  The component returned a failure code when the pipeline engine called PrimeOutput(). The meaning of the failure code is defined by the component, but the error is fatal and the pipeline stopped executing.  There may be error messages posted before this with more information about the failure.
 (SQL Server Import and Export Wizard)

#################Issue was resolved by transferring data sets from excel to access then to sql server.
#################Difficulty executing a ‘union all’ of all data sets. Several data sets needed to have a column data type adjusted to nvarchar(255) for union to be successful.

Alter table Divvy.dbo.202012(202102, 202101, 202111)
Alter column start_station_id nvarchar(255)



SELECT *
Into [Divvy].[dbo].[UnionDivvy]
FROM [Divvy].[dbo].[202004-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202005-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202006-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202007-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202008-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202009-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202010-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202011-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202012-divvy-tripdata]
UNION ALL
SELECT *
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
FROM [Divvy].[dbo].[202201-divvy-tripdata]
UNION ALL
SELECT *
FROM [Divvy].[dbo].[202202-divvy-tripdata]

###Extracting day, month and month_num, hour, year, length of ride from started_at column
###Selecting all data from dataset where selected columns are not null

SELECT *,
Datename(weekday FROM started_at) as Dayofweek,
Datepart(month FROM started_at) as Month_Num,
Datename(month From started_at) as Month,
Datepart(hour FROM started_at) as HourofDay,
Datepart(year FROM started_at) as Year,
DateDiff(minute, started_at, ended_at) as ride_length_min
Into Divvy.dbo.UnionDivvy_1
FROM Divvy.dbo.UnionDivvy

WHERE
ride_id IS NOT NULL
AND rideable_type IS NOT NULL
AND started_at IS NOT NULL
AND ended_at IS NOT NULL
AND start_station_name IS NOT NULL
AND end_station_name IS NOT NULL
AND start_lat IS NOT NULL
AND start_lng IS NOT NULL
AND end_lat IS NOT NULL
AND end_lng IS NOT NULL
AND member_casual IS NOT NULL
AND (start_station_name) NOT LIKE '%TEST%'
AND (end_station_name) NOT LIKE '%TEST%'

###Selecting all data where ride length is longer than one minute and less than 24 hours.
###Any ride longer than 24 hours the bike is considered stolen and any ride less than one minute is considered a false start.

SELECT *
Into Divvy.dbo.CleanDivvy
FROM Divvy.dbo.UnionDivvy_1
WHERE ride_length_min between 1 AND 1440



##Pricing Rules according to Divvy 5/10/22
#####Member rides under 45min on classic and docked bikes are free with membership
###Member rides over 45 min on classic and docked bikes are .16 a minute after the first 45 minutes
###Assuming all customers know that it is cost efficient to use the Daily Pass for rides that are 3 hours or longer. I instituted the parameters that all rides that are 3 hours exactly are the daily price pass of $15. Any ride longer than 3 hours is the Daily Pass price of $15 + .16 cents a minute after the 3 hour mark.
###Members are charged .16 cents a minute for electric bikes
###Casual users are charged $3.30 for rides under 30 minutes
###Casual users with rides longer than 30 min are charged the $1 unlock fee and .16 cents per minute for classic and docked bikes and .39 cents a minute for electric bikes

Select *,
Case 
when member_casual = 'member' and ride_length_min < 45 then 0
when member_casual = 'member' and ride_length_min > 45 then (ride_length_min - 45) * .16
when member_casual = 'member' and rideable_type = 'docked_bike' and ride_length_min = 180  then 15
when member_casual = 'member' and rideable_type = 'classic_bike' and ride_length_min = 180 then 15
when member_casual = 'member' and rideable_type = 'docked_bike' and ride_length_min > 180  then (ride_length_min - 180) * .16 + 15
when member_casual = 'member' and rideable_type = 'classic_bike' and ride_length_min > 180 then (ride_length_min - 180) * .16 + 15
when member_casual = 'member' and rideable_type = 'electric_bike' then ride_length_min * .16
when member_casual = 'casual' and ride_length_min < 30 then 3.30
when member_casual = 'casual' and rideable_type = 'electric_bike' then (ride_length_min * .39) + 1
when member_casual = 'casual' and rideable_type = 'docked_bike' then ride_length_min * .16 + 1
when member_casual = 'casual' and rideable_type = 'classic_bike' then ride_length_min * .16 + 1
when member_casual = 'casual' and rideable_type = 'docked_bike' and ride_length_min = 180  then 15
when member_casual = 'casual' and rideable_type = 'classic_bike' and ride_length_min = 180 then 15
when member_casual = 'casual' and rideable_type = 'docked_bike' and ride_length_min > 180  then (ride_length_min - 180) * .16 + 15
when member_casual = 'casual' and rideable_type = 'classic_bike' and ride_length_min > 180 then (ride_length_min - 180) * .16 + 15 end as RIDE_Cost
Into Divvy.dbo.CleanDivvy3
From Divvy.dbo.CleanDivvy2

###Getting rid of duplicate rides

SELECT Distinct [ride_id]
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
      ,[Dayofweek]
      ,[Month_Num]
      ,[Month]
      ,[HourofDay]
      ,[Year]
      ,[ride_length_min]
      ,[CostR]
INTO [Divvy].[dbo].[CleanDivvy4]
FROM [Divvy].[dbo].[CleanDivvy3]

###Creating a table with total number of member and causal rides

Select member_casual, year,
count(1) as rides
Into Divvy.dbo.YearlyRides
From Divvy.dbo.CleanDivvy4
group by member_casual, year
order by year

###Creating a table with total number of member and casual rides per bike type 

SELECT 
rideable_type, member_casual, year,
count(1) as rides
Into Divvy.dbo.YearlyBikeRides
FROM 
Divvy.dbo.CleanDivvy4
group by rideable_type, member_casual, year

###Creating a table with total number of member and casual rides per month

SELECT 
month, member_casual, year, Month_Num,
count(1) as users
Into Divvy.dbo.MonthlyRides
from 
Divvy.dbo.CleanDivvy4
group by month, member_casual, year, Month_Num
order by year, month

###Creating a table with the monthly profits made from rides

Select member_casual, year, month, Month_Num, SUM(CostR) as Monthly_Profit
Into Divvy.dbo.Profit
From Divvy.dbo.CleanDivvy4
Group by member_casual, year, month, Month_Num

###Creating a table with the member casual rides per day as well as the profit made during that time of day

Select member_casual, HourofDay, Year, Sum(CostR) as Profit,
count(1) as Rides
Into [Divvy].[dbo].HourlyRides
FROM [Divvy].[dbo].[CleanDivvy4]
Group by member_casual, HourofDay, Year

###Creating a table with the member and casual rides per day of week

Select member_casual,Dayofweek, year,
count(1) as rides
Into [Divvy].[dbo].[DailyRides]
From [Divvy].[dbo].[CleanDivvy4]
Group By member_casual, Dayofweek, year

Select *,
Case
When Dayofweek = 'Sunday' Then 1
When Dayofweek = 'Monday' Then 2
When Dayofweek = 'Tuesday' Then 3
When Dayofweek = 'Wednesday' Then 4
When Dayofweek = 'Thursday' Then 5
When Dayofweek = 'Friday' Then 6
When Dayofweek = 'Saturday' Then 7
End as Dayofweek_numb
Into Divvy.dbo.DailyRides_1
From Divvy.dbo.DailyRides




###Membership Prices according to Divvy 5/10/22. Membership = $9
###These queries are being performed with the assumption that a percentage of member rides are repeat customers.
###I chose the three percentages 30, 45, & 60.
###I then subtracted the percentage from total rides and multiplied by 9 to get an estimate of the profit made from new memberships.

Select *,
Case
when member_casual = 'member' then (rides * .30) end as '30pctRepeatUsers'
Into Divvy.dbo.RepeatUsers
From Divvy.dbo.YearlyRides

Alter table Divvy.dbo.RepeatUsers
Alter Column [30pctRepeatUsers] int

SELECT *, rides - [30PctRepeatUsers] as Rides_3
Into Divvy.dbo.RepeatUsers_1
FROM [Divvy].[dbo].[RepeatUsers]

Select *,
Case
when member_casual = 'member' then (rides * .45) end as '45pctRepeatUsers'
Into Divvy.dbo.RepeatUsers_2
From Divvy.dbo.RepeatUsers_1

Alter table Divvy.dbo.RepeatUsers_2
Alter Column [45pctRepeatUsers] int

SELECT *, rides - [45PctRepeatUsers] as Rides_45
Into Divvy.dbo.RepeatUsers_3
FROM [Divvy].[dbo].[RepeatUsers_2]

Select *,
Case
when member_casual = 'member' then (rides * .60) end as '60pctRepeatUsers'
Into Divvy.dbo. RepeatUsers_4
From Divvy.dbo.RepeatUsers_3

Alter table Divvy.dbo.RepeatUsers_4
Alter Column [60pctRepeatUsers] int

SELECT *, rides - [60PctRepeatUsers] as Rides_60
Into Divvy.dbo.RepeatUsers_5
FROM [Divvy].[dbo].[RepeatUsers_4]

SELECT *
Into Divvy.dbo.RepeatUsers_6
FROM [Divvy].[dbo].[RepeatUsers_5]
Where member_casual = 'member'

SELECT *,
Rides_3 * 9 as Profit_30
Into Divvy.dbo.RepeatUsers_7
FROM [Divvy].[dbo].[RepeatUsers_6]

SELECT *,
Rides_45 * 9 as Profit_45
Into Divvy.dbo.RepeatUsers_8
FROM [Divvy].[dbo].[RepeatUsers_7]

SELECT *,
Rides_60 * 9 as Profit_60
Into Divvy.dbo.RepeatUsers_9
FROM [Divvy].[dbo].[RepeatUsers_8]


###Creating a table with the member and casual rides per bike station
SELECT 
[start_station_name]
,[end_station_name]
,[start_lat]
,[start_lng]
,[end_lat]
,[end_lng]
,[member_casual]
,[Year],
Count(1) as Rides
Into Divvy.dbo.PopularStat
FROM [Divvy].[dbo].[CleanDivvy4]
Where start_station_name is not null
Group by[start_station_name]
,[end_station_name]
,[start_lat]
,[start_lng]
,[end_lat]
,[end_lng]
,[member_casual]
,[Year]


###Union Quarterly data sets
Select *
Into Divvy.dbo.Divvy2YRQuarterly
From Divvy.dbo.Divvy_Trips_2018_Q1
Union All
Select *
From Divvy.dbo.Divvy_Trips_2018_Q2
Union All
Select *
From Divvy.dbo.Divvy_Trips_2018_Q3
Union All
Select *
From Divvy.dbo.Divvy_Trips_2018_Q4
Select *
From Divvy.dbo.Divvy_Trips_2019_Q1
Union All
Select *
From Divvy.dbo.Divvy_Trips_2019_Q2
Union All
Select *
From Divvy.dbo.Divvy_Trips_2019_Q3
Union All
Select *
From Divvy.dbo.Divvy_Trips_2019_Q4

###Cleaning data to salvage the gender information contained in the dataset
Select *,
Case
when birthyear like 'Mal%' then 'Male'
when birthyear like 'Fem%' then 'Female'
when gender = 'Male' then 'Male'
when gender = 'Female' then 'Female' end as Sex
Into Divvy.dbo.QuarterlyUnion
From Divvy.dbo.Divvy2YRQuarterly

###Cleaning data to salvage the birth year information in the dataset
SELECT *,
Case
When BirthYear Like 'Male%' then Substring(BirthYear, 6, 4)
When BirthYear like 'Female%' then Substring(BirthYear, 8, 4) end as Birth
Into [Divvy].[dbo].[QuarterlyUnion_1]
FROM [Divvy].[dbo].[QuarterlyUnion]

Delete 
FROM Divvy.dbo.QuarterlyUnion_1
Where BirthYear = ','
and BirthYear is null

Delete 
FROM Divvy.dbo.QuarterlyUnion_1
Where Sex is null

Update [Divvy].[dbo].[QuarterlyUnion_1]
SET Birth = BirthYear
Where 
Birth is null


###Extracting year from StartTime to later utilize in identifying riders age.
Select *,
Datepart(year From StartTime) as Year
Into [Divvy].[dbo].[QuarterlyUnion]
FROM [Divvy].[dbo].[QuarterlyUnion_2]

SELECT *, Year - Birth as Age
Into [Divvy].[dbo].[QuarterlyUnion_1]
FROM [Divvy].[dbo].[QuarterlyUnion]

###Creating a table that counts the number of times an individual bike has been riden
SELECT BikeID,
Count(1) as Rides
Into Divvy.dbo.BikeID_Rides
FROM [Divvy].[dbo].[QuarterlyUnion_1]
Group by BikeID

###Creating a table that counts the number of rides per age and deleting any rides where the rider is over 100 years old
SELECT Age,
Count(1) as Rides
Into Divvy.dbo.Age_Rides
FROM [Divvy].[dbo].[QuarterlyUnion_1]
Group by Age

SELECT *
Into Divvy.dbo.AgeRides
FROM [Divvy].[dbo].[Age_Rides]
Where Age < 101

###Creating a table that counts the number of rides per rider gender
SELECT Sex,
Count(1) as Rides
Into Divvy.dbo.Sex_Rides
FROM [Divvy].[dbo].[QuarterlyUnion_1]
Group by Sex
