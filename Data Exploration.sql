--preview all the data 
	--Deaths table
SELECT *
FROM covid_deaths
LIMIT 100;
	
	--Vaccinations table
SELECT *
FROM covid_vaccinations
LIMIT 100;

--Extract the columns needed for anlysis from the Deaths table
SELECT country, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
order by 1,2;

--Looking at Total cases V Total Deaths
--Shows the likelihood of dying if you contract the Covid-19 virus
Select country, date, total_cases, total_deaths, round(cast(total_deaths/total_cases as numeric)*100,2) as DeathPercentage
from covid_deaths
where country = 'Nigeria' and continent is not null
order by 1,2;

--Total population V total cases
--Shows the percent of the entire population that have the been infected
Select country, date, total_cases, population, (total_cases/population)*100 as Percent_Infected
from covid_deaths
--where country = 'Nigeria'
order by 1,2;

--Country with the highest infection rate 
Select country, population, max(total_cases) AS infections_count, MAX(total_cases/population)*100 as Percent_Infected
from covid_deaths
where continent is not null and total_cases is not null
group by country, population
order by Percent_Infected DESC;

--Countries with highest death count and death rate
Select country, population, max(total_deaths) AS total_death, max(total_deaths/population)*100 as death_rate
from covid_deaths
where continent is not null
group by country,population
order by total_death DESC;



--Number of Deaths by Continents
Select continent, cast(sum(total_deaths) as integer) as total_death
from covid_deaths
where continent is not null
group by continent
order by total_death desc;


--ranking of Continents by  Death count
with cont as (
Select continent, cast(sum(total_deaths) as integer) as total_death
from covid_deaths
where continent is not null
group by continent
order by total_death desc
)

select continent, total_death,rank() over(order by total_death desc)
from cont;



--Global Numbers
--Global daily trend of new cases, new deaths and death percentage
select date,sum(new_cases) as total_cases_for_the_day, sum(new_deaths)as total_deaths_for_the_day,(sum(new_deaths)/nullif(sum(new_cases),0))*100 as DeathPercentage
from covid_deaths
where continent is not null
group by date
order by 1;


--Join both tables to draw insights about vaccination
--Dates when each country to administer vaccinations and their running sum through the years with WINDOWS FUNCTION
select d.continent, d.country, d.date, d.population, v.new_vaccinations,
		sum(v.new_vaccinations) over(partition by d.country order by d.date) as running_sum
from covid_deaths as d
join covid_vaccinations as v
on d.country=v.country and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null
order by 2,3;

--Countries and the percentage of their population that have been vaccinated with CTE
With popvac as(
	select d.continent, d.country, d.date, d.population, v.new_vaccinations,
		sum(v.new_vaccinations) over(partition by d.country order by d.date) as running_sum_vaccination
		from covid_deaths as d
		join covid_vaccinations as v
		on d.country=v.country and d.date=v.date
		where d.continent is not null and v.new_vaccinations is not null
		order by 2,3
)

select country, max(running_sum_vaccination)/max(population)*100 as percentage_vaccinated
from popvac
group by 1
order by 2 desc;


--create a VIEW
create view popvaccinated as
select d.continent, d.country, d.date, d.population, v.new_vaccinations,
		sum(v.new_vaccinations) over(partition by d.country order by d.date) as running_sum_vaccination
		from covid_deaths as d
		join covid_vaccinations as v
		on d.country=v.country and d.date=v.date
		where d.continent is not null and v.new_vaccinations is not null;
		
select *
from popvaccinated;

