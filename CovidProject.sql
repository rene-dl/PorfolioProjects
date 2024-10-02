
/* 
Coronavirus (COVID-19) Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
SELECT *
FROM CovidProject..deaths

SELECT *
FROM CovidProject..vaccinations

-- Select the data we are going to start usisng 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..deaths
ORDER BY location, date

-- Cleaning

ALTER TABLE CovidProject..deaths
ALTER COLUMN total_deaths float

UPDATE CovidProject..deaths
SET total_deaths = NULL
WHERE total_deaths=0


ALTER TABLE CovidProject..deaths
ALTER COLUMN total_cases float

UPDATE CovidProject..deaths
SET total_cases = NULL
WHERE total_cases = 0

-- Total Cases vs Total Deaths
-- Shows the probabilty fo dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..deaths
WHERE location like '%Mexico%'
ORDER BY location, date

-- Total Cases vs Population
-- Shows the percentage of people infected in your country

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM CovidProject..deaths
WHERE location like '%Mexico%'
ORDER BY location, date

-- Countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighetsInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM CovidProject..deaths
WHERE continent != ' '
GROUP BY location, population
ORDER BY InfectedPercentage DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidProject..deaths
WHERE continent != ' '
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with Highest Death Count per Population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidProject..deaths
WHERE continent != ' '
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT 
	SUM(CAST(new_cases AS BIGINT)) AS global_cases,
	SUM(CAST(new_deaths AS BIGINT)) AS global_deaths,
	SUM(CAST(new_deaths AS FLOAT)) /SUM(CAST(new_cases AS FLOAT))*100 AS global_death_percentage 
FROM CovidProject..deaths
WHERE location != ' ' 
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows the percentage of population that has recieved at least one Covid vaccine

SELECT dt.continent, dt.location, dt.date, dt.population, vt.new_vaccinations,
SUM(CONVERT (BIGINT, vt.new_vaccinations)) OVER(PARTITION BY dt.location ORDER BY dt.location, dt.date) AS RollingPeopleVaccinated
FROM CovidProject..vaccinations vt
JOIN CovidProject..deaths dt
	ON dt.location = vt.location
	AND dt.date = vt.date
WHERE dt.continent != ' ' 
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dt.continent, dt.location, dt.date, dt.population, vt.new_vaccinations,
SUM(CONVERT (BIGINT, vt.new_vaccinations)) OVER(PARTITION BY dt.location ORDER BY dt.location, dt.date) AS RollingPeopleVaccinated
FROM CovidProject..vaccinations vt
JOIN CovidProject..deaths dt
	ON dt.location = vt.location
	AND dt.date = vt.date
WHERE dt.continent != ' ' 
)
SELECT *, (RollingPeopleVaccinated/CAST(Population AS FLOAT))*100 AS PercentagePopulationVaccinated
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS GlobalPercentageVaccianted
CREATE TABLE GlobalPercentageVaccianted
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_Vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)

INSERT INTO GlobalPercentageVaccianted
SELECT dt.continent, dt.location, dt.date, dt.population, vt.new_vaccinations,
SUM(CONVERT (BIGINT, vt.new_vaccinations)) OVER(PARTITION BY dt.location ORDER BY dt.location, dt.date) AS RollingPeopleVaccinated
FROM CovidProject..vaccinations vt
JOIN CovidProject..deaths dt
	ON dt.location = vt.location
	AND dt.date = vt.date
WHERE dt.continent != ' ' 

SELECT *, (RollingPeopleVaccinated/CAST(Population AS FLOAT))*100 AS PercentagePopulationVaccinated
FROM GlobalPercentageVaccianted
ORDER BY location, date

-- Creating a view to store data for later visualizations

CREATE VIEW ViewGlobalPercentageVaccianted AS
SELECT dt.continent, dt.location, dt.date, dt.population, vt.new_vaccinations,
SUM(CONVERT (BIGINT, vt.new_vaccinations)) OVER(PARTITION BY dt.location ORDER BY dt.location, dt.date) AS RollingPeopleVaccinated
FROM CovidProject..vaccinations vt
JOIN CovidProject..deaths dt
	ON dt.location = vt.location
	AND dt.date = vt.date
WHERE dt.continent != ' ' 
