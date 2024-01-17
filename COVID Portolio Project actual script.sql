SELECT *
FROM CovidDeaths
ORDER BY 3, 4;

SELECT *
FROM CovidVaccinations
ORDER BY 3, 4;

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases vs. Total Deaths for the United States 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Looking at Total Cases vs Population (USA)
-- Shows what percentage of population has contracted Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentofPopulationInfected
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Looking at Countries with Highest Infection Rate copared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentofPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentofPopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent <> 'NULL'
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Showing continents with Highest Death Count per Population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent <> 'NULL'
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent <> 'NULL'
ORDER BY 1,2;

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent <> 'NULL'
GROUP BY date
ORDER BY 1,2;


-- Check CovidVaccinations Table
SELECT *
FROM CovidVaccinations;

-- Join CovidVaccinations table and CovidDeaths table together

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date;

-- Looking at Total Population vs Vaccinations
-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> 'NULL'
-- ORDER BY 2,3 AND dea.continent
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVAC;

-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATE,
	population DECIMAL,
	new_vaccinations DECIMAL,
	RollingPeopleVaccinated DECIMAL
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> 'NULL';
-- ORDER BY 2,3 AND dea.continent

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> 'NULL'
ORDER BY 2,3;





