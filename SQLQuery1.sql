
SELECT * 
FROM PortfolioProject..coviddeaths
WHERE continent != ''
ORDER BY 3, 4


-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeaths
WHERE continent != ''
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE location = 'Ecuador' AND (date between '20200318' and '20230815') 
ORDER BY 1, 2


-- Looking at Total Cases vs Population in Ecuador
-- Shows what percentage of population got Covid in Ecuador
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PorcentPopulationInfected
FROM PortfolioProject..coviddeaths
WHERE location = 'Ecuador' and date between '20200318' and '20230815'
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS PorcentPopulationInfected
FROM PortfolioProject..coviddeaths
WHERE continent != ''
GROUP BY location, population
ORDER BY location DESC


-- Showing the countries with the Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent != ''
GROUP BY location
ORDER BY TotalDeathCount DESC


--Let's break things down by contitnent
-- Showing continents with the highest death count per population
SELECT location as continent, MAX(total_deaths) as TotalDeaths
FROM PortfolioProject..coviddeaths
WHERE continent = '' AND location NOT IN ('World', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeaths DESC


-- Global Numbers
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE continent != '' AND date BETWEEN '20200117' AND '20230808'
GROUP BY date
ORDER BY 1, 2

--Total Cases WorldWide
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE continent != '' AND date BETWEEN '20200117' AND '20230808'
--GROUP BY date
ORDER BY 1, 2


--Vaccination
SELECT * 
FROM PortfolioProject..covidvaccines
ORDER BY 3, 4


--Looking at Total Population vs Vaccinations
With PopvsVac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccines vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent!=''
)
SELECT *, (rollingpeoplevaccinated/population) AS Rolling_Population
FROM PopvsVac


--Create View
Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinnated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccines vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent!=''

