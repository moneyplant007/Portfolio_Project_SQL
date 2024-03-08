--Analyzing Covid-19 Data:

select * from covidd;

--Querying data--

select country, dated, total_cases, new_cases, total_deaths, population
from covidd
order by 1,2;

--Looking at Total cases vs Total Deaths

select country, dated, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as Death_percentage
from covidd
where country like '%India%'
order by 1,2

--Looking at Total_cases vs population, cases to population ratio

select country, dated, total_cases, population, ROUND((total_cases/population)*100,2) as cases_to_population
from covidd
where country like '%India%'
order by 1,2

--Looking at countries with highest infection rate compared to population

select country, population, max(total_cases) as Highest_Count, ROUND(MAX((total_cases/population)*100),2) as Highest_infection_rate
from covidd
group by country, population
order by ROUND(MAX((total_cases/population)*100),2)desc

-- Showing the countries with highest deaths per population

select country, MAX(Total_deaths) as Highest_deaths_in_a_day
from covidd
where Total_deaths is not null and country != continent and country != 'European Union'
group by country
order by max(total_deaths) desc

--showing continents with highest deaths per population

select continent, MAX(Total_deaths) as Highest_deaths_in_a_day
from covidd
group by continent
order by max(total_deaths) desc

--GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from covidd
where country != continent and country != 'European Union'


--GLOBAL NUMBERS EVERY DAY

select dated, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
ROUND(sum(new_deaths)/sum(new_cases)*100,2) as death_percentage
from covidd
where country != continent and country != 'European Union'
group by dated
order by dated

-- Analyzing Covid-19 Vaccination Data

select * from covidv

--Looking at Total Population vs Vaccinations

select covidd.continent, covidd.country, covidd.dated, covidd.population, covidv.new_vaccinations
from covidd inner join covidv on covidd.dated = covidv.dated and covidd.country = covidv.country
where covidd.continent != covidd.country and covidd.country != 'European_union'
order by 2,3

-- Vaccinations Every Day

select covidd.continent, covidd.country, covidd.dated, covidd.population, covidv.new_vaccinations,
sum(new_vaccinations) over (partition by covidd.country order by covidd.country, covidd.dated) as every_day_vaccinations
from covidd inner join covidv on covidd.dated = covidv.dated and covidd.country = covidv.country
where covidd.continent != covidd.country and covidd.country != 'European_union'
order by 2,3

-- Vaccinations to population ratio

with popvsv as
(
select covidd.continent, covidd.country, covidd.dated, covidd.population, covidv.new_vaccinations,
sum(new_vaccinations) over (partition by covidd.country order by covidd.country, covidd.dated) as every_day_vaccinations
from covidd inner join covidv on covidd.dated = covidv.dated and covidd.country = covidv.country
where covidd.continent != covidd.country and covidd.country != 'European_union'
order by 2,3
)
select continent, country, dated, population, every_day_vaccinations,
ROUND(every_day_vaccinations/population * 100,2) as percentage_vaccinated
from popvsv

-- Using an temp table

create table vaccines_data(
continent varchar (120),
country varchar (120),
dated date,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
Insert into  vaccines_data
(
select covidd.continent, covidd.country, covidd.dated, covidd.population, covidv.new_vaccinations,
sum(new_vaccinations) over (partition by covidd.country order by covidd.country, covidd.dated) as every_day_vaccinations
from covidd inner join covidv on covidd.dated = covidv.dated and covidd.country = covidv.country
where covidd.continent != covidd.country and covidd.country != 'European_union'
order by 2,3
)

select * from vaccines_data

--Creating a view for visualizations

create view percent_people_vaccinated as 
select *, 
(rolling_people_vaccinated/population)*100 as percentage_vaccinated 
from vaccines_data
























