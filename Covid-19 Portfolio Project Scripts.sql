/*

Covid-19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 3,4


-- Select Data that we are going to be using


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
ORDER BY 1,2


-- Total cases vs Total deaths
-- Shows likelihood of dying if Covid-19 is contracted


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
Where location like '%Canada%'
and continent is not null
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population has gotten Covid-19


select location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--Where location like '%Canada%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population


select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--Where location like '%Canada%'
Group By location,population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population


select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--Where location like '%Canada%'
where continent is not null
Group By location,population
ORDER BY TotalDeathCount DESC


-- Breaking things down by Continent

-- Showing continents with the highest death count per population


select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--Where location like '%Canada%'
where continent is not null
Group By continent
ORDER BY TotalDeathCount DESC


-- Global Numbers


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum((New_cases))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--Where location like '%Canada%'
where continent is not null
--Group by date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows percentage of Population that has received at least one Covid-19 vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perfrom Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Using Temp Table to perfrom calculation on Partition By in previous query

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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--  Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null