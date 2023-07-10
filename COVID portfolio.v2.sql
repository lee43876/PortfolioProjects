
--SELECT *
--FROM FIRST_PORTFOLIO..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM FIRST_PORTFOLIO..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM FIRST_PORTFOLIO..CovidDeaths
where continent is not NULL
order by 1,2


-- Total deaths vs Total cases
-- Shows likelihood of death from Covid infection


SELECT Location, date, 
total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM FIRST_PORTFOLIO..CovidDeaths
where location like '%states%'
order by 1,2


-- Total cases vs Population
-- Infection rates

SELECT Location, date, 
total_cases, population, (total_cases/population)*100 as Infection_rates
FROM FIRST_PORTFOLIO..CovidDeaths
--where location like '%states%'
order by 1,2


--countries with highest infection rates compared to poluation
SELECT Location, population,
MAX(total_cases) as HighestInfectionCount,  
MAX(total_cases/population)*100 as Infection_rates
FROM FIRST_PORTFOLIO..CovidDeaths
--where location like '%states%'
group by population, location
order by Infection_rates desc


--Countries with highest death count per population
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM FIRST_PORTFOLIO..CovidDeaths
--where location like '%states%'
where continent is NULL
group by location
order by TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT date, 
sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
--total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM FIRST_PORTFOLIO..CovidDeaths
where continent is not null
group by date
order by 1,2


-- total population vs vaccinations 

select dea.continent, 
dea.location, 
dea.date, 
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location,dea.date) as RollingPeopleVaccinated
from FIRST_PORTFOLIO..CovidDeaths dea
join FIRST_PORTFOLIO..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE 

with PopvsVac(Continent, Location, Date, Population, new_vaccinations,
RollingPeopleVaccinated)
as 
(
select dea.continent, 
dea.location, 
dea.date, 
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location,dea.date) as RollingPeopleVaccinated
from FIRST_PORTFOLIO..CovidDeaths dea
join FIRST_PORTFOLIO..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population) *100
from PopvsVac


-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)


insert into #PercentPopulationVaccinated
select dea.continent, 
dea.location, 
dea.date, 
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location,dea.date) as RollingPeopleVaccinated
from FIRST_PORTFOLIO..CovidDeaths dea
join FIRST_PORTFOLIO..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view for later visualization

create view PercentPopulationVaccinated as
select dea.continent, 
dea.location, 
dea.date, 
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location,dea.date) as RollingPeopleVaccinated
from FIRST_PORTFOLIO..CovidDeaths dea
join FIRST_PORTFOLIO..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null


select * 
from PercentPopulationVaccinated