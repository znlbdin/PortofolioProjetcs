/* DATA EXPLORATION */
-- COVID DEATH DATA
-- Selecting Data
SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	PortofolioProject.dbo.CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY
	location, date

-- Looking at Total Cases vs Total Deaths : It shows the likelihood of dying if you contract covid in your country
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths / total_cases) * 100 DeatchPercentage
FROM
	PortofolioProject.dbo.CovidDeaths
WHERE
	location = 'Indonesia' AND continent IS NOT NULL
ORDER BY
	location, date

-- Looking at Total Cases vs Population : It shows the percentage of population got covid
SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases / population) * 100 PercentPopulationInfected
FROM
	PortofolioProject.dbo.CovidDeaths
WHERE
	location = 'Indonesia' AND continent IS NOT NULL
ORDER BY
	location, date

-- Looking at Countries with Highest Infection Rate compared with the Population
SELECT
	location,
	population,
	MAX(total_cases) total_cases,
	MAX((total_cases / population) * 100) PercentPopulationInfected
FROM
	PortofolioProject.dbo.CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location, population
ORDER BY
	PercentPopulationInfected DESC

-- Showing Continent with Highest Death Count per Population
SELECT
	continent,
	MAX(CAST(total_deaths AS INT)) TotalDeatchCount
FROM
	PortofolioProject.dbo.CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	TotalDeatchCount DESC

-- Global Numbers of DeathPercentage
SELECT
	SUM(new_cases) Total_Cases,
	SUM(CAST(new_deaths AS INT)) Total_Deaths,
	(SUM(CAST(new_deaths AS INT)) / SUM(new_cases))*100 DeathPercentage
FROM
	PortofolioProject.dbo.CovidDeaths
WHERE
	continent IS NOT NULL

-- COVID VACCINATIONS DATA

-- Looking at Total Population vs Vaccinations
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
SELECT
	DEA.continent,
	DEA.location,
	CAST(DEA.date AS DATE),
	DEA.population,
	VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS INT)) OVER(PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) RollingPeopleVaccinated
FROM
	PortofolioProject..CovidDeaths DEA
JOIN
	PortofolioProject..CovidVaccinations VAC
ON
	DEA.location = VAC.location AND DEA.date = VAC.date
WHERE
	DEA.continent IS NOT NULL AND DEA.location = 'Indonesia'
)

SELECT
	*,
	(RollingPeopleVaccinated / Population) * 100 PercentageVaccinated
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #Temp_Population
CREATE TABLE #Temp_Population (
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_Vaccinations numeric,
RollingPepoleVaccinated numeric)

INSERT INTO #Temp_Population
SELECT
	DEA.continent,
	DEA.location,
	CAST(DEA.date AS DATE),
	DEA.population,
	VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS INT)) OVER(PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) RollingPeopleVaccinated
FROM
	PortofolioProject..CovidDeaths DEA
JOIN
	PortofolioProject..CovidVaccinations VAC
ON
	DEA.location = VAC.location AND DEA.date = VAC.date
WHERE
	DEA.continent IS NOT NULL AND DEA.location = 'Indonesia'

SELECT 
	*,
	(RollingPepoleVaccinated / Population) * 100 PercentageVac
FROM 
	#Temp_Population
ORDER BY
	Date

-- CREATING VIEWS
CREATE VIEW PercentPopulationVaccinated AS
SELECT
	DEA.continent,
	DEA.location,
	CAST(DEA.date AS DATE) Date,
	DEA.population,
	VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS INT)) OVER(PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) RollingPeopleVaccinated
FROM
	PortofolioProject..CovidDeaths DEA
JOIN
	PortofolioProject..CovidVaccinations VAC
ON
	DEA.location = VAC.location AND DEA.date = VAC.date
WHERE
	DEA.continent IS NOT NULL