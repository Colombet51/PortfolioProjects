
select *
from PortfolioProject.dbo.coviddeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject.dbo.covidvaccinations
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.coviddeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (convert(float, total_deaths) / nullif(convert(float, total_cases),0))*100 as DeathPercentage
from PortfolioProject.dbo.coviddeaths
where location like '%state%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shjow what percentage of population get Covid

select location, date, population, total_cases, (convert(float, total_cases) / nullif(convert(float, population),0))*100 as DeathPercentage
from PortfolioProject.dbo.coviddeaths
--where location like '%state%'
order by 1,2

-- Looking at Countries with Highest Infection Rage compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max(convert(float, total_cases) / nullif(convert(float, population),0))*100 
as PercentPopulationInfected
from PortfolioProject.dbo.coviddeaths
--where location like '%state%'
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.coviddeaths
--where location like '%state%'
where continent is not null
group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.coviddeaths
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.coviddeaths
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as  total_deaths, SUM(convert(float, new_deaths)) /
nullif(convert(float, New_Cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER 
(partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.coviddeaths dea
join PortfolioProject.dbo.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Use CTE

with popvsVac (Continent, Location, Date, Population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER 
(partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.coviddeaths dea
join PortfolioProject.dbo.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsVac

-- TEMP Table

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date rows unbounded preceding) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to srotre data for later virsulizations

create view PercenPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date rows unbounded preceding) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * 
from PercenPopulationVaccinated