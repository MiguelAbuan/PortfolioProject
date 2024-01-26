select *
from PortfolioProject..CovidDeaths
--where continent is not null

--select *
--from PortfolioProject..CovidVaccinations

--Show the likelihood of dying in philippines if someone contract a Covid
select location, date, total_cases, total_deaths, cast(total_deaths as float)/total_cases * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'Philippines'
order by 2

--show the percentage of population got Covid
select location, date, total_cases, population, total_cases/population * 100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like 'Philippines' and total_cases is not null
order by PercentagePopulationInfected desc


--Looking at Countries with Highest infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount,Max(total_cases)/population * 100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentagePopulationInfected desc



--Show the Highest DeathCount per Country
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Show the TotalDeathCount in each continent
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null and location not like '%income%'
group by location
order by TotalDeathCount desc

--Global Numbers
select sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as TotalDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingSumVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--CTEs
with PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingSumVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingSumVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *,RollingSumVaccinated/Population*100 as PercentageVaccination
from PopvsVac


--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingSumVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingSumVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null


select *,RollingSumVaccinated/Population*100 as PercentageVaccination
from #PercentPopulationVaccinated


--Creating View to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingSumVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
from PercentPopulationVaccinated