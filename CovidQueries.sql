--Enviornment used was SSMS(Sql Server Management Studio)

SELECT *
FROM Covid_Proj_Files..CovidDeaths
ORDER BY 3, 4

SELECT * 
FROM Covid_Proj_Files..CovidVaccinations
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Proj_Files..CovidDeaths
ORDER BY 1,2

--Looking at Total_Cases vs Total_Deaths by date
--Shows likelihood of dying if Covid is contracted by Country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid_Proj_Files..CovidDeaths
ORDER BY 1,2

--Looking at Total_Cases vs Population and calculating Death% against Country population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM Covid_Proj_Files..CovidDeaths
ORDER BY 1,2

--Looking at total infection count by Country and calculating % of population infected

Select Location, population, MAX(total_cases) as InfectionCount, Max((total_cases/population)) * 100 as PopulationInfectionPercentage
FROM Covid_Proj_Files..CovidDeaths
Group by Location, population
Order by PopulationInfectionPercentage DESC

--Looking at Death Count and calculating % of dead population by Country

Select Location, MAX(cast(total_deaths as int)) as DeathCount, Max((total_deaths/population)) * 100 as PopulationDeathCountPercentage
FROM Covid_Proj_Files..CovidDeaths
Where continent is not null
Group by Location, population
Order by DeathCount DESC

--Looking at population and death count by Continent

Select Continent, sum(population) as ContinentPopulation, MAX(cast(total_deaths as int)) as DeathCount
FROM Covid_Proj_Files..CovidDeaths
Where continent is not null
Group by continent
Order by DeathCount DESC

--Global Number of cases and deaths and calculating the % of infected that died by date

SELECT date, SUM(new_cases) as total_cases, Sum(cast(new_Deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
FROM Covid_Proj_Files..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

--Global number of cases and deaths and calculating the % of infected that died

SELECT SUM(new_cases) as total_cases, SUM(cast(new_Deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
FROM Covid_Proj_Files..CovidDeaths
WHERE continent is not null
--GROUP BY date
order by 1,2

--Looking at total cases and deaths and calculating % of infected that died by continent

SELECT continent, SUM(new_cases) as total_cases, Sum(cast(new_Deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
FROM Covid_Proj_Files..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by 1,2

--Rolling_#of_Cases Orderd by Date and Continent

SELECT continent, date, Sum(count(total_cases)) over (partition by continent order by continent, date) as NumberOfCases
From Covid_Proj_Files..CovidDeaths
where continent is not null
Group by continent, date, total_cases


--Join Vaccination Table and Death Table

Select * 
From
Covid_Proj_Files..CovidDeaths dea
JOIN Covid_Proj_Files..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccCount)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(new_vaccinations as int)) OVER (Partition by dea.location, dea.date) as RollingVaccCount
--(RollingVaccCount/population)*100
FROM Covid_Proj_Files..CovidDeaths dea
Join Covid_Proj_Files..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)

Select *
From PopvsVac

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Proj_Files..CovidDeaths dea
Join Covid_Proj_Files.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as Percent_of_Pop_Vaxxed
From #PercentPopulationVaccinated


-- Create View for visualizations
---Using Tableau for visualizations(tables will be copied into Excel)

Create View ContinentTotals as
SELECT continent, SUM(new_cases) as total_cases, Sum(cast(new_Deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
FROM Covid_Proj_Files..CovidDeaths
WHERE continent is not null
GROUP BY continent
--order by 1,2

Create View InfectionRateByCountry as
Select Location, population, MAX(total_cases) as InfectionCount, Max((total_cases/population)) * 100 as PopulationInfectionPercentage
FROM Covid_Proj_Files..CovidDeaths
Group by Location, population
--Order by PopulationInfectionPercentage DESC

Create View ContinentDeath# as
Select sum(population) as ContinentPopulation, continent, MAX(cast(total_deaths as int)) as DeathCount
FROM Covid_Proj_Files..CovidDeaths
Where continent is not null
Group by continent
--Order by DeathCount DESC

Create View PopulationInfectionPercentage as
Select Location, population, MAX(total_cases) as InfectionCount, Max((total_cases/population)) * 100 as PopulationInfectionPercentage
FROM Covid_Proj_Files..CovidDeaths
Group by Location, population
--Order by PopulationInfectionPercentage DESC

Create View Total_Cases_Deaths as
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid_Proj_Files..CovidDeaths
--ORDER BY 1,2

Create View Country_InfectionRate as
Select Location, population, MAX(total_cases) as InfectionCount, Max((total_cases/population)) * 100 as PopulationInfectionPercentage
FROM Covid_Proj_Files..CovidDeaths
Group by Location, population
--Order by PopulationInfectionPercentage DESC



