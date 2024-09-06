-- Selecting the data used for this EDA
SELECT location, dates, total_cases, new_cases, total_deaths, population
FROM deaths
WHERE NOT continent = ''
ORDER BY 1,2


-- Total cases vs Total deaths
-- Shows the liklihood of dying if covid is contracted 
SELECT location, dates, total_cases, total_deaths, (total_deaths/total_cases)*100 death_percentage
FROM deaths
-- where location = 'United States'
ORDER BY 1,2


-- Total cases vs Population
-- Shows what percentage of the population contracted covid
SELECT location, dates, total_cases, population, (total_cases/population)*100 contraction_rate
FROM deaths
-- where location = 'United States'
ORDER BY 1,2


-- Highest contraction rate compared to population
SELECT location, population, MAX(total_cases) highest_infection_count, MAX(total_cases/population)*100 contraction_rate
FROM deaths
-- WHERE location = 'United States'
GROUP BY location, population
ORDER BY 4 DESC


-- Countries with highest death count per population
SELECT location, MAX(total_deaths) total_death_count
FROM deaths
WHERE NOT continent = ''
GROUP BY location
ORDER BY 2 DESC

-- BREAKDOWN BY CONTINENTS

-- Total cases vs Total deaths
-- Shows the liklihood of dying if covid is contracted 
SELECT location, MAX(total_cases) total_cases, MAX(total_deaths) total_deaths, MAX((total_deaths/total_cases)*100) death_percentage
FROM deaths
WHERE continent = ''
GROUP BY location
ORDER BY 4 DESC

-- Total cases vs Population
-- Continents with contraction rates
SELECT location, MAX(total_cases) total_cases, MAX(population) population, MAX((total_cases/population)*100) contraction_rate
FROM deaths
WHERE continent = ''
GROUP BY location
ORDER BY 4 DESC

-- Continents with highest death count per population
SELECT location, MAX(total_deaths) total_death_count
FROM deaths
WHERE continent = ''
GROUP BY location
ORDER BY 2 DESC


-- GLOBAL DATA

-- Global cases vs death by date
SELECT dates, SUM(new_cases) total_cases, SUM(new_deaths) total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 death_percentage
FROM deaths
WHERE NOT continent = ''
GROUP BY dates
ORDER BY dates

-- Total global cases vs deaths
SELECT SUM(new_cases) total_cases, SUM(new_deaths) total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 death_percentage
FROM deaths
WHERE NOT continent = ''


-- JOIN BOTH TABLES
SELECT *
FROM deaths d
JOIN vaccinations v
	ON d.location = v.location
	AND d.dates = v.dates
	

-- Looking at total_population vs vaccinations
SELECT d.continent, d.location, d.dates, d.population, v.new_vaccinations
FROM deaths d
JOIN vaccinations v
	ON d.location = v.location
	AND d.dates = v.dates
WHERE NOT d.continent = ''
ORDER BY 2, 3


-- Looking at total_population vs vaccinations with a rolling count
SELECT d.continent, d.location, d.dates, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.dates) rolling_vaccination_count
FROM deaths d
JOIN vaccinations v
	ON d.location = v.location
	AND d.dates = v.dates
WHERE NOT d.continent = ''
ORDER BY 2, 3

-- Using cte to perform calculation with rolling_vaccination_count
WITH pop_vs_vac(continent, location, dates, population, new_vaccinations, rolling_vaccination_count)
AS 
(
SELECT d.continent, d.location, d.dates, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.dates) rolling_vaccination_count
FROM deaths d
JOIN vaccinations v
	ON d.location = v.location
	AND d.dates = v.dates
WHERE NOT d.continent = ''
)
SELECT *, (rolling_vaccination_count/population)*100 vaccinated_percent
FROM pop_vs_vac


-- Using temp table to perform calculation with rolling_vaccination_count
DROP TEMPORARY TABLE IF EXISTS population_percent_vaccinated;

CREATE TEMPORARY TABLE population_percent_vaccinated
SELECT d.continent, d.location, d.dates, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location,d.dates) rolling_vaccination_count
FROM deaths d
JOIN vaccinations v
	ON d.location = v.location
	AND d.dates = v.dates
WHERE NOT d.continent = '';

SELECT *, (rolling_vaccination_count/population)*100 vaccinated_percent
FROM population_percent_vaccinated;



-- Created view
CREATE VIEW Vaccinated_percent AS

WITH pop_vs_vac(continent, location, dates, population, new_vaccinations, rolling_vaccination_count) AS 
(
    SELECT d.continent, d.location, d.dates, d.population, v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.dates) rolling_vaccination_count
    FROM deaths d
    JOIN vaccinations v
        ON d.location = v.location
        AND d.dates = v.dates
    WHERE NOT d.continent = ''
)
SELECT *, (rolling_vaccination_count/population)*100 vaccinated_percent
FROM pop_vs_vac;


SELECT *
FROM Vaccinated_percent
