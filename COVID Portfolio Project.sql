-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL --Excludes groupings of entire continents
ORDER BY 1,2 ;



-- Looking at Total Cases vs. Total Deaths
-- Shows the likelihood of death if you contract covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
Where location like '%South Africa'AND continent IS NOT NULL
ORDER BY 1,2 ;



--Looking at Total Cases vs. Population
--Shows what percentage of the population contracted covid

SELECT location, date, total_cases, Population, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject1.dbo.CovidDeaths
--Where location like '%South Africa'
WHERE continent IS NOT NULL
ORDER BY 1,2 ;



--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, MAX(total_cases) as HighestInfectionCount, Population, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject1.dbo.CovidDeaths
--Where location like '%South Africa'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;



--Showing Countries with Highest Deate Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
--Where location like '%South Africa'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC;



---BREAKING THINGS DOWN BY CONTINENT


--Showing Continent with Highest Death Count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
--Where location like '%South Africa'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- GLOBAL NUMBERS
--Shows global death rate overall

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 
as GlobalDeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
Where  continent IS NOT NULL
ORDER BY 1,2 ;



--Looking at Total Population vs Vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY  2, 3



--Using CTE

WITH Popvsvac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM Popvsvac



--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




--Creating View to store data for visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated;