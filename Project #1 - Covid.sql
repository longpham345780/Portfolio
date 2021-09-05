SELECT *
FROM Portfolio#1..CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM Portfolio#1..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio#1..CovidDeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths in the country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio#1..CovidDeaths
WHERE location like '%viet%'
ORDER BY 1,2


-- Total Cases vs The Population in the country
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM Portfolio#1..CovidDeaths
WHERE location like '%viet%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS InfectionRate
FROM Portfolio#1..CovidDeaths
WHERE continent IS NOT NULL -- so it cancels out the unnecessary Continent data in countries' data
GROUP BY location, population
ORDER BY InfectionRate DESC


-- Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio#1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENTS

-- Show continents with Highest Death Count
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio#1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS
SELECT date,
		SUM(new_cases) as TotalCases, 
		SUM(CAST(new_deaths as int)) as TotalDeaths, 
		SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM Portfolio#1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as TotalCases, 
		SUM(CAST(new_deaths as int)) as TotalDeaths, 
		SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM Portfolio#1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Rolling Count of Vaccinations
-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM Portfolio#1..CovidDeaths dea
JOIN Portfolio#1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingVaccinationRate
FROM PopvsVac



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM Portfolio#1..CovidDeaths dea
JOIN Portfolio#1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingVaccinationRate
FROM #PercentPopulationVaccinated




-- CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM Portfolio#1..CovidDeaths dea
JOIN Portfolio#1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

