select location, continent
from portfolio_project..covid_deaths
order by 1,2

UPDATE covid_deaths SET continent= NULL WHERE continent = '';

--select *
--from portfolio_project..covid_vaxxx
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..covid_deaths
where continent is not null
order by 1,2

alter table covid_deaths alter column Total_cases float;
alter table covid_deaths alter column new_deaths float;
-- looking at total cases vs total deaths


select location, date, Total_cases, Total_deaths, (Total_deaths / nullif(Total_cases, 0))*100 as death_percentage
from portfolio_project..covid_deaths
where location like 'United states'
and continent is not null
order by 1,2



select location, date, Total_cases, population, (Total_cases / nullif(population, 0))*100 as death_percentage
from portfolio_project..covid_deaths
where location like 'United states'
and continent is not null
order by 1,2



-- looking countries with highest infection rate compared to population

select location, population, max(Total_cases) as highest_infection_count,max((total_cases/ nullif(population, 0)))*100 as percentage_population_infected
from portfolio_project..covid_deaths
--where location like 'india'
where continent is not null
group by location, population
order by percentage_population_infected desc


-- showing countries with the highest death count as per population

select location, max(Total_deaths) as total_death_count
from portfolio_project..covid_deaths
where continent is not null
group by location
order by total_death_count desc

-- introspecting via continent: highest death count

select continent, max(Total_deaths) as total_death_count
from portfolio_project..covid_deaths
where continent is not null
group by  continent
order by total_death_count desc



--global numbers

select date, Sum (new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as death_percentage
from portfolio_project..covid_deaths
where continent is not null
group by date
order by 1,2


select * 
from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaxxx  vac
    on dea.location = vac.location
	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rolling_vaccinated

from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaxxx  vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3





-- cte
with popvsVac(continent, location, date, population,new_vaccinated, rolling_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rolling_vaccinated

from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaxxx  vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (rolling_vaccinated/population)*100
from popvsVac



--temp table
drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
rollingpeoplevaccinated int
)
insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rolling_vaccinated

from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaxxx  vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100
from #percentagepopulationvaccinated



create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rolling_vaccinated

from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaxxx  vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
from percentpopulationvaccinated












