/*
COVID 19 Data Exploration

Skills used: Joins, CTE's, Windows Function, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from PortfolioProject..CovidDeaths
order by 3,4;


--Selecting the starting data

select location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at the Total Cases vs. Total Deaths
-- Shows the Likelihood of dying of COVD in US

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location = 'united states'
order by 1,2

--Looking at the total cases vs the population
--Show what percentage of the population got COVID

select location, date, total_cases, population, (total_cases/population)*100 as Percent_Contration_in_US
from PortfolioProject..CovidDeaths
where location = 'united states'
order by 1,2;

--Shows the odds of contracting COVID in the US
select MAX(total_cases) as Current_Total_Cases, MAX(population) Current_Total_Population, (MAX(total_cases)/MAX(population))*100 as Percent_Contration_in_US
from PortfolioProject..CovidDeaths
where location = 'united states'
order by 1,2;

--Shows the worldwide contraction rate/ The odds of contraction COVID in each continent
select location, MAX(total_cases) as Total_Cases, population, (MAX(total_cases)/population)*100 as Percent_Contration
from PortfolioProject..CovidDeaths
group by location,population
order by 4 desc

--Looking at Countries with Highest Infection Rate compared to Population
select location, MAX(total_cases) as Total_Cases, population, (MAX(total_cases)/population)*100 as Percent_Contration
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by 4 desc;

--Shows the deaths for each continent 
select continent, 
MAX(population) as population,
MAX(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 3 desc

--Shows the deaths for each country
select location, MAX(population) as Pop, sum(cast(new_Deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 3 desc;

--Looking at total vaccination vs total population
select a.continent, a.location, a.date, a.population, b.new_vaccinations
, sum(cast(b.new_vaccinations as int)) over (partition by a.location order by a.location,a.date) as RollingTotalVaccinations
from PortfolioProject..CovidDeaths as a
join PortfolioProject..CovidVaccinations as b
on a.location = b. location
and a.date = b.date 
where a.continent is not null
order by 2,3;



--Using CTE to perform calculations on partition by in previous query


with PopulationVsVaccination (location, population, date, new_vaccinations, FullyVaccinatedPeople, RollingPeopleVaccinated)
as 
(
select a.location, a.population, a.date, b.new_vaccinations, MAX(cast(b.People_Fully_Vaccinated as bigint)) over (partition by a.location order by a.location, a.date) as FullyVaccinatedPeople,
MAX(cast(b.people_vaccinated as bigint)) OVER (Partition by a.location order by a.location, a.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths a
join PortfolioProject..CovidVaccinations b
on a.location = b.location
and a.date = b.date
where a.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100 as PercentOfPopWithAtLeastOneShot
from PopulationVsVaccination
order by 1,3;

--Creating View for visualization 

Create View PercentPopulationVaccinated as
select a.location, a.population, a.date, 
a.continent,
b.new_vaccinations, MAX(cast(b.People_Fully_Vaccinated as bigint)) over (partition by a.location order by a.location, a.date) as FullyVaccinatedPeople,
MAX(cast(b.people_vaccinated as bigint)) OVER (Partition by a.location order by a.location, a.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths a
join PortfolioProject..CovidVaccinations b
on a.location = b.location
and a.date = b.date
where a.continent is not null
--order by 1,3



