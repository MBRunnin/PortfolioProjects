SELECT
  TOP 10 *
FROM
  portfolioproject..coviddeaths
ORDER BY
  3,4

--SELECT
--  TOP 10 *
--FROM
--  portfolioproject..covidvacc
--ORDER BY
--  3,4

--Select data that we are going to be using

SELECT
  location, date, total_cases, new_cases, total_deaths, population
FROM
  portfolioproject..coviddeaths
ORDER BY
  1,2

--Looking at Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract COVID in each country
SELECT
  location,
  date,
  total_cases,
  total_deaths,
  total_deaths / total_cases * 100 AS deathPerCasePerc
FROM
  portfolioproject..coviddeaths
WHERE continent IS NOT NULL
ORDER BY
  1,2

--Looking at Total Cases vs. Total Deaths in United States
SELECT
  location,
  date,
  total_cases,
  total_deaths,
  total_deaths / total_cases * 100 AS deathPerCasePerc
FROM
  portfolioproject..coviddeaths
WHERE
  location LIKE '%states%' AND continent IS NOT NULL
ORDER BY
  1,2

--Looking at Total Cases vs. Population in United States
--Shows percentage of population that has been diagnosed with COVID
SELECT
  location,
  date,
  total_cases,
  population,
  total_cases / population * 100 AS casePercentage
FROM
  portfolioproject..coviddeaths
WHERE
  location LIKE '%states%'AND continent IS NOT NULL
ORDER BY
  1,2

--Looking at Total Cases vs. Population in Various Countries
--Shows percentage of population that has been diagnosed with COVID
SELECT
  location,
  date,
  total_cases,
  population,
  total_cases / population * 100 AS casePercentage
FROM
  portfolioproject..coviddeaths
WHERE continent IS NOT NULL
ORDER BY
  1,2

--Looking at the Countries with Highest Infection Rate compared to Population
SELECT
  location,
  population,
  MAX(total_cases) AS HighestInfectionCount,
  MAX((total_cases / population * 100)) AS PercPopulationDiagnosed
FROM
  portfolioproject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY
  location,
  population
ORDER BY
  4 DESC

--Looking at the Countries with Highest Death Count
SELECT
  location,
  MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM
  portfolioproject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY
  location
ORDER BY
  2 DESC

--Looking at the Countries with Highest Death Rate compared to Population
SELECT
  location,
  population,
  MAX(total_deaths) AS HighestDeathCount,
  MAX((total_deaths / population * 100)) AS PercPopulationDiagnosed
FROM
  portfolioproject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY
  location,
  population
ORDER BY
  4 DESC


  --Let's break things down by continent
  --Showing the continents with highest death count per population
SELECT
  continent,
  MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM
  portfolioproject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY
  continent
ORDER BY
  2 DESC


--Global Numbers

SELECT
  date,
  SUM(new_cases) AS TotalNewCases,
  SUM(CAST(new_deaths AS int)) AS TotalNewDeaths,
  SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM
  portfolioproject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY 
  date
ORDER BY
  1,2
  
--Date removed
SELECT
  --date,
  SUM(new_cases) AS TotalNewCases,
  SUM(CAST(new_deaths AS int)) AS TotalNewDeaths,
  SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM
  portfolioproject..coviddeaths
WHERE continent IS NOT NULL
--GROUP BY 
  --date
ORDER BY
  1,2


--Looking at total population versus vaccination

SELECT
  deaths.continent,
  deaths.location,
  deaths.date,
  deaths.population,
  vacc.new_vaccinations,
  SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS RollingVaccCount
FROM
  portfolioproject..coviddeaths deaths JOIN portfolioproject..covidvacc vacc
  ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
ORDER BY
  1,2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccCount)
AS 
(SELECT
  deaths.continent,
  deaths.location,
  deaths.date,
  deaths.population,
  vacc.new_vaccinations,
  SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS RollingVaccCount
FROM
  portfolioproject..coviddeaths deaths JOIN portfolioproject..covidvacc vacc
  ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
--ORDER BY
--  2,3
)

SELECT
  *,
  RollingVaccCount / Population * 100 AS PercentVaccinated
FROM PopvsVac


--AS TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
  deaths.continent,
  deaths.location,
  deaths.date,
  deaths.population,
  vacc.new_vaccinations,
  SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS RollingVaccCount
FROM
  portfolioproject..coviddeaths deaths JOIN portfolioproject..covidvacc vacc
  ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
--ORDER BY
--  2,3

SELECT
  *,
  RollingVaccCount / Population * 100
FROM #PercentPopulationVaccinated




--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
  deaths.continent,
  deaths.location,
  deaths.date,
  deaths.population,
  vacc.new_vaccinations,
  SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS RollingVaccCount
FROM
  portfolioproject..coviddeaths deaths JOIN portfolioproject..covidvacc vacc
  ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
--ORDER BY
--  2,3