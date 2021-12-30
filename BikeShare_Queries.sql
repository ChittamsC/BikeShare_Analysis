###Enviornment used was Big Query

### Following is a Union of Separate csv files to create Big table

CREATE TABLE civic-vigil-319501.Cyclistic.CyclisticUnion AS
SELECT *
FROM `civic-vigil-319501.Cyclistic.202007`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202008`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202009`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202010`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202011`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202012`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202101`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202102`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202103`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202104`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202105`
UNION ALL
SELECT *
FROM `civic-vigil-319501.Cyclistic.202106`


###Following query cleans the newly created table and creates a final table to be used for analysis
###Removes rows with NULL values as well as documented rides that were tests done by the company and extracts the dayofweek, month, and hourofday from started_at column.
###Also gives the difference in both started_at and ended_at timestamps and saves results to gain a ride_length_secs(ride length in seconds) column.

CREATE TABLE civic-vigil-319501.Cyclistic.CleanCyclisticUnion_1 AS

SELECT *,
EXTRACT(dayofweek FROM started_at) as Dayofweek,
EXTRACT(month FROM started_at) as Month,
EXTRACT(hour FROM started_at) as HourofDay,
TIMESTAMP_DIFF(ended_at, started_at, second) as ride_length_secs
FROM `civic-vigil-319501.Cyclistic.CyclisticUnion`
WHERE
ride_id IN (SELECT ride_id FROM `civic-vigil-319501.Cyclistic.CyclisticUnion`)
AND
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


###Querying all results with a ride length between 1 minute and 1 day since rides under a minute considered either lost or stolen.

SELECT *,
FROM `civic-vigil-319501.Cyclistic.CleanCyclisticUnion_1`
WHERE ride_length_secs between 60 AND 86400


###Query lets us know how many Cyclistic users are either a member or a casual user

SELECT 
member_casual, 
count(1) as users
FROM `civic-vigil-319501.Cyclistic.CleanCyclisticUnion_1`
group by member_casual



###Query lets us know what bikes are most popular amongst what kind of users

SELECT 
rideable_type, member_casual, 
count(1) as rides
FROM `civic-vigil-319501.Cyclistic.CleanCyclisticUnion_1`
group by rideable_type, member_casual



###Query lets us know number of rides per member and casual user per month allowing us to know the more popular months of usage

SELECT 
month, member_casual,
count(1) as rides
from `civic-vigil-319501.Cyclistic.CleanCyclisticUnion_1`
group by month, member_casual
order by Month



###Query the station name and the amount of rides per members and casual users to figure out the most popular stations

SELECT 
start_station_name, member_casual,
count(1) as rides
from `civic-vigil-319501.Cyclistic.CleanCyclisticUnion_1`
group by start_station_name, member_casual
order by member_casual, rides desc



###Query lets us know how many rides per member and casual user are initiated every hour of the day. This allows us to determine the most popular usage hours for both members and casual users.

SELECT 
HourofDay, member_casual,
count(1) as rides
from `civic-vigil-319501.Cyclistic.CleanCyclisticUnion_1`
group by HourofDay, member_casual
order by HourofDay


###Query lets us know number of rides per member and casual user according to the day of the week. This allows us to determine most popular days for both members and casual users.

SELECT 
Dayofweek, member_casual,
count(1) as rides
from `civic-vigil-319501.Cyclistic.CleanCyclisticUnion_1`
group by Dayofweek, member_casual
order by Dayofweek


###Following two queries give us a table that tells us the avg ride length in minutes for both members and casual riders, as well as both users together.

SELECT
AVG(ride_length_secs)/60 as Avg_ride_length_Min, member_casual,
FROM 
`civic-vigil-319501.Cyclistic.CleanCyclisticUnion_4`
group by member_casual


SELECT
AVG(ride_length_secs)/60 as All_avg_ride_length_Min
FROM 
`civic-vigil-319501.Cyclistic.CleanCyclisticUnion_4`
