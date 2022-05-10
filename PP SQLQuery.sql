--Portfolio Project Sample Querries
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total Cases Vs Total Deaths

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentageDeaths
From PortfolioProject..CovidDeaths
Where location like '%kenya%'
--The above querry selects locations with 'kenya' in them. This helps in narrowing down to specific area of interest.
Order by 1,2

--Total Cases Vs Population
Select Location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%kenya%'
Order by 1,2

--Countries With the Highest Infections Compared to Population
Select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location,population
Order by PercentPopulationInfected desc

--Countries with The Highest Death Count Per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
Order by TotalDeathCount desc

--ANALYSIS BASED ON CONTINENTS

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Continents with Highest Death Count Per Population-- same as above querry
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Querry2
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
Order by 1,2

--Looking at Total Population Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--USING CTE
With PopvsVac(Continent, Location, Date, population, new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Using a Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating View to Store Data for Later Visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated