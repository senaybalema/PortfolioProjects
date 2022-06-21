-- select * from CovidVaccinations where continent is not null order by 3,4
;

-- select * from CovidDeaths order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths order by 1,2;

-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of contracting covid in your country

select location,date,total_cases,total_deaths , (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths 
where location like '%state%' -- and continent is not null
order by 1,2;

-- Looking at total cases vs population
--Shows what percentage of population got covid

select location,date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths 
--where location like '%state%'
--where continent is not null
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths 
group by location,population
order by PercentPopulationInfected desc;


-- Showing Countries with Highest Death Count per Population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where continent is not null 
group by location
order by TotalDeathCount desc;






-- Death Count by Income
select location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where location like '%income'
group by location
order by TotalDeathCount desc;


-- Showing Continents with the Highest Death Count Per Population

--	LET'S BREAK THINGS DOWN BY CONTINENT

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where continent is not null 
group by continent
order by TotalDeathCount desc;




-- Global Numbers 

select date,sum( new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage   --(total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths 
--where location like '%state%' 
where continent is not null 
group by date
order by 1,2;



select sum( new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage   --(total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths 
--where location like '%state%' 
where continent is not null 
order by 1,2;



-- Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated, -- sum(convert(int,vac.new_vaccinations) works aswell 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


--USE CTE 

With PopvsVac (Continent,Location,Date,Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)8100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac;





-- TEMP Table 
Drop table if exists #PercentPopulationVaccinated 
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

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)8100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3




select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated;





-- Creating View to Store Data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)8100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


select * from PercentPopulationVaccinated;