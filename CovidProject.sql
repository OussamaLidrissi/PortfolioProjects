--select * from CovidDeaths  order by 3,4


--select * from CovidVaccinations  order by 3,4

-- Select the data that we will be using

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths order by 1,2



-- Looking at total cases vs total deaths

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercenatge
from CovidDeaths 
where location like '%morocc%'
order by 1,2

-- Looking at total cases vs population

select location,date,population, total_cases, (total_cases/population)*100 as CovidPop
from CovidDeaths 
--where location like '%morocc%'
order by 1,2--based on the exploration 3.4% of morrocan got tested positive


--looking at countries whit highest infaction rate compared to population

select location,population, max(total_cases) as highestInfaction, max((total_cases/population))*100 as CovidPopInf
from CovidDeaths 
--where location like '%morocc%'
group by location,population
order by CovidPopInf desc


--showing countires whit highest death count per population

select population,max(CAST(total_deaths as int)) as totalDeaths
from CovidDeaths 
where continent is not null
group by population
order by totalDeaths desc


--Shwoing continant total_Deaths

select location, max(CAST(total_deaths as bigint)) as totalDeaths
from CovidDeaths 
where continent is null
group by location
order by totalDeaths desc


-- Global Numbers
---------------
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercenatge
from CovidDeaths 
--where location like '%morocc%'
where continent is not null
order by 1,2
----------------------overall percentage--------------------------
select sum(total_cases) as total_cases, sum(new_deaths) as total_deaths,sum(new_deaths)/SUM(new_cases)*100 as deathPerce--,total_deaths, (total_deaths/total_cases)*100 as DeathPercenatge
from CovidDeaths 
--where location like '%morocc%'
where continent is not null
--group by date
order by 1,2
--------------------------------------------------

-- looking at total population vs peaple vaccinated
select dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
------------------another way------------------
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_vaccinations
FROM
  CovidDeaths dea
JOIN
  CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  dea.location, dea.date;
  -------now for the percantge of te peaple are vaccinated

  SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_vaccinations
 -- ,(cumulative_vaccinations/population)*100
FROM
  CovidDeaths dea
JOIN
  CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  dea.location, dea.date;

  --Usng CTE " Common Table Expression "

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac---basicaly i need to limit the window frame to include all rows|| error message : ORDER BY list of RANGE window frame has total size of 1020 bytes. Largest size supported is 900 bytes.

--as a solution i need to use 'ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW'
---------aonther version-----------
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
  FROM
    PortfolioProject..CovidDeaths dea
  JOIN
    PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL
)
SELECT
  *,
  (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM
  PopvsVac;
  ---Create View to store data for visualization

  create view 
