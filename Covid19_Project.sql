/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select *
from PortFolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortFolioProject..CovidVaccinations
--order by 3,4


--select Data That we are going to Use

select location,date,total_cases,new_cases,total_deaths,population
from PortFolioProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at Total Cases vs Total deths
--shows likelihood of dying if you contract covide in your country
 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentagePopulationInfected
from PortFolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--looking at Total cases Vs Population  


select location,date,population,total_cases,(total_cases/population)*100 as DeathPercentage
from PortFolioProject ..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2 

--Looking at countries with highest Infection Rate Compare to Population


select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population)) *100 as 
PercentagePopulationInfected
from PortFolioProject ..CovidDeaths
--where location like '%states%' 
group by location,population

order by PercentagePopulationInfected desc


-- let's Break Things Down BY Conttent

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortFolioProject ..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc



-- showing countries with Highest Date count per Population

select location,max(cast(total_cases as int)) as TotalDeathCount
from PortFolioProject ..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Showing Contintents with the Highst death count perpopulation
 
 
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortFolioProject ..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc
  

--Global Numbers 

select sum(new_cases),sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from PortFolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Looking At Total Population Vs Vaccination 

select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE 

with popvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated )
as
(
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100 
from popvsVac


--Temp Table 


DROP  table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


-- Creating View to Store data for later Visualization

create view PercentPopulationVaccinated as 
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3



select * from PercentPopulationVaccinated
