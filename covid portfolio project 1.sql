SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

Select continent, Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total cases vs Total Deaths in Nigeria
-- Shows the likelihood of death if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Nigeria%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
-- shows what percentage of the population got covid

Select continent,Location, date, population,total_cases,  (total_cases/Population )* 100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%Nigeria%'
and continent is not null
order by 1,2

--Looking at countries with Highest Infection rates compared to population

Select Location,continent, population,MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/Population ))* 100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by Location, Population, continent
order by PercentageOfPopulationInfected desc

-- Showing countries with the Highest Mortality per Population

Select Continent, Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location, continent
order by TotalDeathCount desc


-- breaking things down by continents

--showing continents with highest death count per population
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select   SUM(new_cases) as total_cases,SUM (cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2




-- Looking at Total Population vs Vaccination

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using CTE

with PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population) * 100 RollingPeopleVaccinatedPercentage
from PopvsVac


--USING TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population) * 100 RollingPeopleVaccinatedPercentage
from #PercentPopulationVaccinated


--Creating View to store data for later Visualisations

CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
