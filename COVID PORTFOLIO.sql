SELECT *
FROM Portfolio_Project..covidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM Portfolio_Project..CovidVaccinations
--ORDER BY 3,4

--
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..covidDeaths
ORDER BY 1,2

--LOOKING at TOTAL CASES VS TOTAL DEATHS IN GERMANY
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project..covidDeaths
WHERE location LIKE '%Germany%'
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS POPULATION
SELECT location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage
FROM Portfolio_Project..covidDeaths
WHERE location LIKE '%Germany%'
ORDER BY 1,2


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, max(total_cases) as Highestinfectionrate, max((total_cases/population))*100 as PercentPopulationInfected
FROM Portfolio_Project..covidDeaths
--WHERE location LIKE '%Germany%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing countries highest death count per population
SELECT location, max(cast(total_deaths as Int)) as TotalDeatCount
FROM Portfolio_Project..covidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeatCount DESC

-- BY CONTINENT 
--Showing continents with highest death count per location
SELECT continent, max(cast(total_deaths as Int)) as TotalDeatCount
FROM Portfolio_Project..covidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeatCount DESC


--GLOBAL NUMBERS

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project..covidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--TOTAL POPULATION VS VACCINATIONS

with POPvsVACC (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(int,v.new_vaccinations)) 
over(partition by d.location ORDER BY d.location, d.date) as PeopleVaccinated
FROM Portfolio_Project..covidDeaths D
JOIN Portfolio_Project..CovidVaccinations V
   ON d.location = v.location
   AND d.date = v.date
WHERE d.continent is NOT NULL
--ORDER BY 2,3
)

SELECT *, (PeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
FROM POPvsVACC

--Temp Table

DROP TABLE if EXISTS  #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric)

INSERT INTO #PercentPeopleVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(int,v.new_vaccinations)) 
over(partition by d.location ORDER BY d.location, d.date) as PeopleVaccinated
FROM Portfolio_Project..covidDeaths D
JOIN Portfolio_Project..CovidVaccinations V
   ON d.location = v.location
   AND d.date = v.date

SELECT *, (PeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
FROM #PercentPeopleVaccinated


-- Create view for visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(int,v.new_vaccinations)) 
over(partition by d.location ORDER BY d.location, d.date) as PeopleVaccinated
FROM Portfolio_Project..covidDeaths D
JOIN Portfolio_Project..CovidVaccinations V
   ON d.location = v.location
   AND d.date = v.date
WHERE d.continent is NOT NULL

SELECT *
FROM PercentPopulationVaccinated









