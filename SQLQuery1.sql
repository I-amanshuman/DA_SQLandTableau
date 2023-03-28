select * from dbo.CovidDeaths$
order by 3,4

--select * from ..CovidVaccinations$
--order by 3,4
-- Select the data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from [Capstone_Covid _data]..CovidDeaths$
order by 1,2

-- Looking at the total_cases vs total_deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Capstone_Covid _data]..CovidDeaths$
where location like '%States'
order by 1,2

-- Looking at the total_cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as Cases_vs_Population
from [Capstone_Covid _data]..CovidDeaths$
where location like '%India'
order by 1,2

--What countries have the highest infection rate compared to population
select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as Percent_of_population_infected
from [Capstone_Covid _data]..CovidDeaths$
group by location, population
order by 4 desc

-- Showing the countries with the higest death count per population
select location, max(cast (total_deaths as int)) as TotalDeathCount
-- nvarchar was causing some error, so we casted the data into integer usinf cast function
from [Capstone_Covid _data]..CovidDeaths$
where continent is not null
-- Continent has some null values which was showing errors in the count
group by location
order by 2 desc

--LETS BREAK THINGS DOWN BY CONTINENT
select location, max(cast (total_deaths as int)) as TotalDeathCount
-- nvarchar was causing some error, so we casted the data into integer usinf cast function
from [Capstone_Covid _data]..CovidDeaths$
where continent is null
-- Continent has some null values which was showing errors in the count
group by location
order by 2 desc

-- Showing the continent with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from ..CovidDeaths$
where continent is not null
group by continent
order by 2 desc


-- Global numbers (Percentage)
select date, sum(total_cases) as total_cases, sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from ..CovidDeaths$
where continent is not null
group by date
order by Death_Percentage desc



-- Let's select the covid vaccinations

-- Looking at total population vs vaccination
select  dea.date, max(dea.population) as population,  sum(cast(vac.new_vaccinations as int)) as total_vaccinations
from ..CovidDeaths$ dea
join ..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date =vac.date
where dea.continent is not null
group by dea.date
order by 3 desc

-- Lets look at country level total new cases, population and vaccinations
select dea.continent, dea.location, dea.date, dea.population, cast (vac.new_vaccinations as int) as new_vaccinations
from ..CovidDeaths$ as dea
join ..CovidVaccinations$ as vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
order by 5 desc

-- Lets look at country level total new cases, population and vaccinations with sum and partition on date and location
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from ..CovidDeaths$ as dea
join ..CovidVaccinations$ as vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
order by 2,3 



--Lets find out how many people in the country are vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated

from ..CovidDeaths$ as dea
join ..CovidVaccinations$ as vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
order by 2,3 



-- USE CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from ..CovidDeaths$ as dea
join ..CovidVaccinations$ as vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
-- and dea.location like '%Albania'
--order by 2,3 
)
select *, (rollingpeoplevaccinated/population)*100
from PopvsVac

-- Temp table
drop table if exists #Percent_population_vaccinated
create table #Percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #Percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from ..CovidDeaths$ as dea
join ..CovidVaccinations$ as vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
-- and dea.location like '%Albania'
--order by 2,3 

select *, (rollingpeoplevaccinated/population)*100
from #Percent_population_vaccinated

-- Creating view to store data for later visualizations
Create view Percent_population_vaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from ..CovidDeaths$ as dea
join ..CovidVaccinations$ as vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
-- and dea.location like '%Albania'
--order by 2,3 

select *
from Percent_population_vaccinated