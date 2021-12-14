select * from
PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4


--select * from PortfolioProject.dbo.CovidVaccination
--order by 3,4

--select data that we are going to be using

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--looking at total cases vs total deaths

select Location,date,total_cases,total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states'
order by 1,2

--lokking at total cases vs population
-- shows what percentage of population got covid.


select Location,date,population,total_cases,total_deaths,
(total_cases/population)*100 as PopulationPercentage
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--looking at country with highest infection rate compared to Population

select Location,population,MAX(total_cases) as HighestInfectionInCOunt,
Max((total_cases/population))*100 as PopulationPercentageInfected
from PortfolioProject.dbo.CovidDeaths
group by location,population
order by PopulationPercentageInfected desc

--showing countries with highes desth count per Population

select location,MAX(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is null
group by location
order by totalDeathCount desc

--showing continente with the highest death count per population

select continent,MAX(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by totalDeathCount desc

--GLOBAL NUMBERS

	select sum(total_cases)as SumOfTotalCase,--date
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
	from PortfolioProject.dbo.CovidDeaths
	where continent is not null
	--group by date
	order by 1,2	

--looking at total population vs vaccination

select dae.continent,dae.location,dae.date,
dae.population,vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint ))
	over (Partition by dae.Location ,
			 dae.date) as RollingPeopleVaccinated
			-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dae
join PortfolioProject..CovidVaccination vac
	on dae.location = vac.location
	and dae.date = vac.date
where dae.continent is not null
order by 2,3

--use CTE
with PopvsVac(Continent,Location,Date,Population,New_vaccinations,RollingpeopleVaccinated)
as
(
select dae.continent,dae.location,dae.date,
dae.population,vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint ))
	over (Partition by dae.Location ,
			 dae.date) as RollingPeopleVaccinated
			-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dae
join PortfolioProject..CovidVaccination vac
	on dae.location = vac.location
	and dae.date = vac.date
where dae.continent is not null
--order by 2,3
)

select*,(RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp table percentage of population vaccinated
 if object_id('tempdb.dbo.#percentPeopleVaccinated') is not null 
 Drop table #percentPeopleVaccinated

	create table #percentPeopleVaccinated
	(	Continent nvarchar(255),
		Location nvarchar(255),
		Date datetime,
		Population numeric,
		New_vaccination numeric,
		RollingPeopleVaccinated numeric
	)

	Insert into #percentPeopleVaccinated
	select dae.continent,dae.location,dae.date,
	dae.population,vac.new_vaccinations,
	sum(cast( vac.new_vaccinations as bigint ))
		over (Partition by dae.Location ,
				 dae.date) as RollingPeopleVaccinated
				-- (RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths dae
	join PortfolioProject..CovidVaccination vac
		on dae.location = vac.location
		and dae.date = vac.date
	--where dae.continent is not null


	select*,(RollingPeopleVaccinated/population)*100
	from #percentPeopleVaccinated


-- creating view to store data for later visualiztion 

create view percentPeopleVaccinated as 
select dae.continent,dae.location,dae.date,
	dae.population,vac.new_vaccinations,
	sum(cast( vac.new_vaccinations as bigint ))
		over (Partition by dae.Location ,
				 dae.date) as RollingPeopleVaccinated
				-- (RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths dae
	join PortfolioProject..CovidVaccination vac
		on dae.location = vac.location
		and dae.date = vac.date
	where dae.continent is not null
	--order by 2,3

select * from percentPeopleVaccinated