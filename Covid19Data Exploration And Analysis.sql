
				  --*** Covid19Data Exploration And Analysis ***--

SELECT * 
FROM ProjectPortfolio..CovidVaccinations
SELECT * 
FROM ProjectPortfolio..CovidDeaths


------------------------------------------------DATA SELECTION---------------------------------------------------- 

SELECT location , date , total_cases , new_cases,total_deaths,population 
FROM ProjectPortfolio..CovidDeaths
order by 1,2


-------------------------------------------TOTAL CASES vs TOTAL DEATHS-----------------------------------------------------------------

SELECT location , date , total_cases ,total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%Tunisia%'
order by 1,2


-------------------------------------------TOTAL CASES vs POPULATION--------------------------------------------------

-------------------------------------------SHOING PERCENTAGE OF TUNISIAN POPULATION GOT COVID--------------------------------------------------

SELECT location , date , total_cases ,population , (total_cases/population)*100 as Percentpopulationinfected
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%Tunisia%'
order by 1,2


-------------------------------------------COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION--------------------------------------------------

SELECT location , MAX(total_cases) as highestinfectioncount ,population , max((total_cases/population)*100) as Percentpopulationinfected
FROM ProjectPortfolio..CovidDeaths
group by location , population
order by Percentpopulationinfected desc



-------------------------------------------COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION--------------------------------------------------

SELECT location , MAX(cast(total_deaths  as int ) ) as totaldeathcount 
FROM ProjectPortfolio..CovidDeaths
where continent is not null 
--and location like '%Tunisia%'
group by location 
order by totaldeathcount desc


-------------------------------------------BREAKING THINGS DOWN BY CONTINENT--------------------------------------------------

-----------------------------------CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION --------------------------------------------------

SELECT continent , MAX(cast(total_deaths  as int ) ) as totaldeathcount 
FROM ProjectPortfolio..CovidDeaths
where continent is NOT null 
group by continent 
order by totaldeathcount desc


--------------------------------------------------SOME GOLBAL NUMBERS--------------------------------------------------

SELECT date,SUM(new_cases) as sumnewcases , SUM(cast(new_deaths as int)) as sumnewdeaths , (SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null 
group by date
order by 1,2


--------------------------------------------------SUM ACCROSS THE WORLD--------------------------------------------------

SELECT SUM(population) as sumpopulation,SUM(new_cases) as sumnewcases , SUM(cast(new_deaths as int)) as sumnewdeaths , (SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null 
order by 1,2

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT DEA.continent , DEA.location, DEA.DATE , DEA.population, VAC.new_vaccinations , 
SUM(cast(VAC.new_vaccinations as int )) OVER (PARTITION BY DEA.LOCATION order by DEA.location , DEA.date) as Rollingpeoplevaccinated 
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location =VAC.location
	AND DEA.DATE = VAC.date
WHERE DEA.continent is not null 
order by 2,3


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

with PopvsVac (continent,location ,DATE , population , new_vaccinations, Rollingpeoplevaccinated) as (
SELECT DEA.continent , DEA.location, DEA.DATE , DEA.population, VAC.new_vaccinations , 
SUM(convert(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.LOCATION order by DEA.location , DEA.date) as Rollingpeoplevaccinated 
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location =VAC.location
	AND DEA.DATE = VAC.date
WHERE DEA.continent is not null 
--order by 2,3
)
Select *, (Rollingpeoplevaccinated/population)*100 
From PopvsVac


------------------------------------------------------------TEMPTABLE--------------------------------------------------------
DROP TABLE IF EXISTS #Percentpopulationvaccinated
create table #Percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #Percentpopulationvaccinated

SELECT DEA.continent , DEA.location, DEA.DATE , DEA.population, VAC.new_vaccinations , 
SUM(convert(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.LOCATION order by DEA.location , DEA.date) as Rollingpeoplevaccinated 
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location =VAC.location
	AND DEA.DATE = VAC.date
WHERE DEA.continent is not null 


Select *, (Rollingpeoplevaccinated/population)*100 
FROM #Percentpopulationvaccinated


--------------------------------------------------CREATE VIEW TO STORE DATA VISUALIZATION LATER--------------------------------------------------

create view PERCENTPOPULATIONVACCINATED AS
SELECT DEA.continent , DEA.location, DEA.DATE , DEA.population, VAC.new_vaccinations , 
SUM(convert(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.LOCATION order by DEA.location , DEA.date) as Rollingpeoplevaccinated 
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location =VAC.location
	AND DEA.DATE = VAC.date
WHERE DEA.continent is not null 

SELECT *
FROM PERCENTPOPULATIONVACCINATED
