With hotels as(
SELECT *
from dbo.['2018$']
union
SELECT *
from dbo.['2019$']
union
SELECT *
from dbo.['2020$']
)

Select *
FROM hotels
Join dbo.market_segment$ ON hotels.market_segment = market_segment$.market_segment
Join dbo.meal_cost$ ON meal_cost$.meal = hotels.meal


Select hotel, arrival_date_year, sum((stays_in_weekend_nights + stays_in_week_nights) * adr) as revenue
from hotels
group by hotel, arrival_date_year

select * from dbo.market_segment$