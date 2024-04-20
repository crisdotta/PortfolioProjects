select location,continent,date,total_cases,new_cases,total_deaths,population
from projectportfolio.coviddeaths
where continent = ''
order by 1,2;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Total cases and total deaths
-- Shows likelihood of dying from covid 
select location,continent,date,total_cases,total_deaths, concat(round((total_deaths/total_cases)*100,2),'%') as death_percentage
from projectportfolio.coviddeaths
-- where location = 'Cyprus'
order by 1,2;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Looking at the total cases vs the population
-- Shows percentage of population that got Covid
select location,continent,date,population,total_cases, concat(round((total_cases/population)*100,2),'%') as sick_percentage
from projectportfolio.coviddeaths
where location = 'Argentina'
order by 1,2;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Looking at countries with highest infection rates compared to population
select location,continent, population, MAX(cast(total_cases as unsigned)) as highest_infection_count, round(max((total_cases/population))*100,2) as sick_percentage 
from projectportfolio.coviddeaths
group by location, population
order by sick_percentage DESC;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with the highest death counts per population
select location,continent, MAX(cast(total_deaths as unsigned)) as total_death_count
from projectportfolio.coviddeaths
where continent != ''
group by location
order by total_death_count DESC;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Querying by continent
-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Showing the continents with the highest death count
/* --CORRECT WAY--*/
select location, max(cast(total_deaths as unsigned)) as total_death_count
from projectportfolio.coviddeaths
where continent = ''
group by location
order by total_death_count DESC;
/*select continent, max(cast(total_deaths as unsigned)) as total_death_count
from projectportfolio.coviddeaths
where continent != ''
group by continent
order by total_death_count DESC;*/
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global numbers
select date,total_cases,total_deaths, concat(round((total_deaths/total_cases)*100,2),'%') as death_percentage
from projectportfolio.coviddeaths
where continent != ''
group by date
order by 1,2;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOIN THE TWO TABLES
-- CTE
with PopVsVac (Continent, Location, Date, Population, new_vaccinations, total_vaccinations_per_country)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as unsigned)) Over (partition by dea.location order by dea.location, dea.date) as total_vaccinations_per_country 
FROM projectportfolio.coviddeaths dea
join projectportfolio.covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.location != ''
-- order by 2,3
)
Select *, round((total_vaccinations_per_country/Population)*100,2) as percentage_of_people_vaccinated
FROM PopVsVac;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREATING VIEWS FOR LATER VISUALIZATIONS
-- PERCENTAGE OF PEOPLE VACCINATED
create view percentage_of_people_vaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as unsigned)) Over (partition by dea.location order by dea.location, dea.date) as total_vaccinations_per_country 
FROM projectportfolio.coviddeaths dea
join projpercentage_of_people_vaccinatedectportfolio.covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.location != '';
-- order by 2,3
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- percentage of population that got Covid
create view percentage_of_population_that_got_Covid as
select location,continent, population, MAX(cast(total_cases as unsigned)) as highest_infection_count, round(max((total_cases/population))*100,2) as sick_percentage 
from projectportfolio.coviddeaths
group by location, population
order by sick_percentage DESC;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- highest death counts per population
create view highest_death_counts_per_population as
select location,continent, MAX(cast(total_deaths as unsigned)) as total_death_count
from projectportfolio.coviddeaths
where continent != ''
group by location
order by total_death_count DESC;


