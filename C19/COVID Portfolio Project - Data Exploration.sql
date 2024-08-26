/*
Covid19 Data Exploration  

Skills used : Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM PortfolioProject..CovidDeaths


select *
from PortfolioProject..CovidVaccinations
order by 3,4;


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2;

--Looking at Total Cases vs Population
--shows what percentage of population got infected with covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2;

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasesPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY CasesPercentage DESC;

--Showing Countries with Highest Death Count Per Population

SELECT location, MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;


--Let's Break Things Down By Continent



--Showing Continents with Highest Death Count Per Population

SELECT continent, MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total Populations vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Use CTE

WITH popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvac;


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;

--Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated