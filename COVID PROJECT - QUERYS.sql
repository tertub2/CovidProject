-- TESTING
-- Testing the Datasets
SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY location, date DESC;

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY location, date DESC;



-- DATA EXPLORATION
-- 1° - Selecting Data which is going to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- DYING ANALYSYS 
-- likelihood of dying from covid in Brazil (My country) 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercetageofDeaths
FROM PortfolioProject..CovidDeaths
WHERE location ='Brazil'
ORDER BY 1,2;

-- Likelihood of deaths in countries with the pattern of having vowels (i.e. a, e, i, o, and u) as the first and last characters
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) AS PercetageofDeaths
FROM PortfolioProject..CovidDeaths
WHERE LEFT(location,1) in ('A','E','I','O','U') AND RIGHT(location,1) IN ('A','E','I','O','U')
ORDER BY 1,2;



-- INFECTION ANALYSYS
-- Percentage of population who got Covid (WORLD)
SELECT location, date, population, total_cases,(total_cases/population)*100 AS ContaminationPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location ='Brazil'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS MaxTotalCases, MAX((total_cases/population)*100) AS HighestInfectionRatePerCountries
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY HighestInfectionRatePerCountries DESC;

-- Looking at continents with highest Deaths Percentage compared to total cases and population
SELECT Continent, SUM(CONVERT(INT, total_deaths)) AS SumofDeaths, AVG((total_deaths/total_cases)*100) AS DethsPercentageAvgPerCases, 
AVG((total_deaths/population)*100) AS DethsPercentageAvgPerPopulation
FROM PortfolioProject..CovidDeaths
WHERE NOT Continent = 'NULL'
GROUP BY Continent
ORDER BY SumofDeaths DESC;

-- Insight: Death percentage for continent
SELECT continent, (total_deaths/total_cases)*100 AS PercetageofDeaths
FROM PortfolioProject..CovidDeaths;

-- Insight: Cumulative Deaths throughout the days
SELECT Location, Population, SUM(CONVERT(INT, total_deaths)) OVER(ORDER BY Location) AS CumulativeDeaths
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Looking at the Total Population x Vaccinnations (JOIN)
SELECT D.Continent, D.Location, D.Population, D.Date, V.total_vaccinations
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
	ON D.LOCATION=V.LOCATION AND D.DATE=V.DATE
WHERE D.continent IS NOT NULL
ORDER BY  1,2,3,4;


-- Looking at the Total Population x Vaccinnations (JOIN)
SELECT D.Continent, D.Location, D.Date, D.Population, V.new_vaccinations, 
SUM(CONVERT(INT, V.new_vaccinations)) OVER(PARTITION BY D.Location ORDER BY D.Location,D.Date) AS soma 
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
	ON D.LOCATION=V.LOCATION AND D.DATE=V.DATE
WHERE D.continent IS NOT NULL
ORDER BY  2,3;


-- Using CTE to perform Calculation on Partition By in previous query
WITH PeopleVac (Continent,Location,Date,Population,New_Vaccinantions, RollingPeopleVaccinated)
AS 
(SELECT D.Continent, D.Location, D.Date, D.Population, V.new_vaccinations, 
SUM(CONVERT(INT, V.new_vaccinations)) OVER(PARTITION BY D.Location ORDER BY D.Location,D.Date) AS soma 
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
	ON D.LOCATION=V.LOCATION AND D.DATE=V.DATE
WHERE D.continent IS NOT NULL)
--ORDER BY  2,3;
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageofRollingPeopleVaccinated
FROM PeopleVac;

SELECT C.total_deaths, V.total_vaccinations SUM(CONVERT(INT, C.total_deaths)) AS SumofDeaths, AVG((V.total_vaccinations/population)*100) AS VaccinationPercentagePerPopulation, 
AVG((total_deaths/population)*100) AS DethsPercentageAvgPerPopulation
FROM PortfolioProject..CovidDeaths
WHERE NOT Continent = 'NULL'
GROUP BY Continent
ORDER BY SumofDeaths DESC