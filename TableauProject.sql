/*

Queries used for Tableau Covid Project

*/

--1.-

SELECT 
	SUM(CAST(new_cases AS BIGINT)) AS global_cases,
	SUM(CAST(new_deaths AS BIGINT)) AS global_deaths,
	SUM(CAST(new_deaths AS FLOAT)) /SUM(CAST(new_cases AS FLOAT))*100 AS global_death_percentage 
FROM CovidProject..deaths
WHERE location != ' ' 
ORDER BY 1,2

--2.-
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidProject..deaths
WHERE continent != ' '
GROUP BY continent
ORDER BY TotalDeathCount DESC

--3.-
SELECT location, population, MAX(total_cases) AS HighetsInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM CovidProject..deaths
WHERE continent != ' '
GROUP BY location, population
ORDER BY InfectedPercentage DESC

--4.-
SELECT location, population, date, MAX(total_cases) AS HighetsInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM CovidProject..deaths
WHERE continent != ' '
GROUP BY location, population, date
ORDER BY InfectedPercentage DESC, date DESC