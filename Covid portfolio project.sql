select *
from PortfolioProject..CovidDeaths$
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1, 2

-- looking at total cases vs total deaths
-- showes likelyhod dying iy you contract covid in yout county
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like '%czech%'
order by 1, 2 

-- looking at total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationWithCovid
from PortfolioProject..CovidDeaths$
--Where location like '%czech%'
order by 1, 2 

-- looking at countries with highest infection rate

select location, population, MAX (total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentageOfPopulationInfected 
from PortfolioProject..CovidDeaths$
--Where location like '%czech%'
group by population, location
order by PercentageOfPopulationInfected desc

--showing countries highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
--Where location like '%czech%'
where continent is not null
group by location
order by TotalDeathsCount desc

--let's break things down by continetnt

select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
--Where location like '%czech%'
where continent is not null
group by continent
order by TotalDeathsCount desc

-- global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 1, 2 

select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 

--looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 order by 2,3

 -- Use CTE 

 with PopVsVac (Continent, Location, date, population, New_vaccinations, RollingPeopleVaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
 --order by 2,3
 Select*, (RollingPeopleVaccinated/population)*100
 from PopVsVac


 --TEMP table
 drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar (255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric)

 insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null



 --creating view to store data for later viz
 create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 



select*
from PercentPopulationVaccinated