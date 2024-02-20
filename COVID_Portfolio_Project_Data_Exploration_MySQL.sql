/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From Covid_deaths
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Covid_deaths
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid_deaths
Where location like '%states%'
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of the population is infected with COVID

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Covid_deaths
--Where location like '%states%'
order by 1,2;


-- Countries with the Highest Infection Rate compared to the Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as float)) as TotalDeathCount
From Covid_deaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From Covid_deaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From Covid_deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2;



-- Total Population vs Vaccinations
-- Shows the Percentage of the Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_deaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in the previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_deaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float,
RollingPeopleVaccinated numeric
);

SELECT 
    dea.Location, 
    dea.Population, 
    dea.date, 
    MAX(dea.total_cases) AS HighestInfectionCount, 
    MAX((dea.total_cases / dea.Population)) * 100 AS PercentPopulationInfected
FROM 
    Covid_deaths dea
JOIN 
    covidvaccinations vac ON dea.Location = vac.Location AND dea.date = vac.date
WHERE 
    dea.Location LIKE '%state%'
GROUP BY 
    dea.Location, dea.Population, dea.date
ORDER BY 
   PercentPopulationInfected DESC;

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_deaths
Where Location IN ('United States', 'United Kingdom', 'Canada', 'China', 'India', 'Brazil')
Group by Location, Population, date
order by PercentPopulationInfected DESC;


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_deaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_deaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;


