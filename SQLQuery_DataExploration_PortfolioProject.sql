select * from CovidDeaths
order by 3,4

--select * from CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population from dbo.CovidDeaths order by 1,2

--country wise total case sand total deaths

SELECT total_cases, total_deaths, population, location, (total_deaths/  population) * 100 AS Population_Percentage_infected
FROM CovidDeaths

--countries with highest infection rate compared to population
SELECT location, population, max(total_cases) as highest_infection_count, max((total_cases/  population)* 100) AS PopulationPercentageInfected
FROM CovidDeaths 
group by population, location
ORDER BY PopulationPercentageInfected DESC

--countries with highest death count per population
SELECT location, max(cast(total_deaths as int)) as HigheshtDeathCount
from dbo.CovidDeaths where continent is not null --to avoid continents and just consider countries
group by location
order by HigheshtDeathCount desc

--let's break things by continent
SELECT location, max(cast(total_deaths as int)) as HigheshtDeathCount
from dbo.CovidDeaths where continent is null --to avoid countries and just consider continents
group by location
order by HigheshtDeathCount desc

SELECT continent, max(cast(total_deaths as int)) as HigheshtDeathCount
from dbo.CovidDeaths where continent is not null --to avoid countries and just consider continents
group by continent
order by HigheshtDeathCount desc

--continents with highest death count per population

SELECT continent, max(cast(total_deaths as int)) as HigheshtDeathCount
from dbo.CovidDeaths where continent is not null --to avoid countries and just consider continents
group by continent
order by HigheshtDeathCount desc

--global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
from dbo.CovidDeaths where continent is not null
group by date
order by 1,2 desc

--looking at Total Population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
from dbo.CovidDeaths as dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE
with popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
	Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
	from dbo.CovidDeaths as dea
	join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)


select *, (RollingPeopleVaccinated/population) * 100
from popvsvac

--use Temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
	from dbo.CovidDeaths as dea
	join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
select * from #PercentPopulationVaccinated

--creating view to store data for later visualisations
create view ercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
	from dbo.CovidDeaths as dea
	join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3