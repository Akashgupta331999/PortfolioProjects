USE [PortfolioProject]
GO

SELECT*
  FROM [dbo].[CovidDeath]

GO
-- looking at total case vs total death 
-- show death percentage if you have covid in that country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
  FROM [dbo].[CovidDeath]
  where location = 'india' AND continent is not null
  order by 1,2 

  -- looking total case vs total population 
  -- show percentage of people got covid
  SELECT location,date,population,total_cases,(total_cases/population)*100 AS casePercentage
  FROM [dbo].[CovidDeath]
  where location = 'india'AND continent is not null
  order by 1,2 
  -- looking of country with high infection rate
    SELECT location,population,max(total_cases) as Highinfectioncount,max((total_cases/population)*100) AS casePercentage
  FROM [dbo].[CovidDeath]
  WHERE continent is not null
  Group BY location, population
  order by casePercentage DESC ;

  -- looking for high amount of death with covid

  SELECT location,max(CAST(total_deaths as INT))  AS TOTALDEATHCOUNT
  FROM [dbo].[CovidDeath] 
  WHERE continent is not null
 group by location
  order by  TOTALDEATHCOUNT DESC;


  -- SHOWING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION

      SELECT continent,max(CAST(total_deaths as INT))  AS TOTALDEATHCOUNT
  FROM [dbo].[CovidDeath] 
  WHERE continent is not null
 group by continent
  order by TOTALDEATHCOUNT DESC;

  -- GLOBAL NUMBER

  SELECT date,sum(new_cases)as total_case,sum(cast(new_deaths as int)) as total_death,
  sum (cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
  FROM [dbo].[CovidDeath]
  where  continent is not null
  GROUP BY date
  order by 1,2 

  -- total death

  SELECT sum(new_cases) as total_case,sum(cast(new_deaths as int)) as total_death,
  sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
  FROM [dbo].[CovidDeath]
  where  continent is not null
  order by 1,2 ;
  --looking at total population vs vaccination
  SELECT dea.continent , dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location , dea.date) as RolingPeopleVaccinated
  FROM dbo.CovidDeath dea
  join dbo.CovidVaccination vac
  ON dea.location = vac.location
  AND dea.date=vac.date
  where dea.continent is not null 
  order by 2,3

  -- use cte

  With PopvsVac(continent,location,date,population,new_vaccinations,RolingPeopleVaccinated)
  as
  (
  SELECT dea.continent , dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location , dea.date) as RolingPeopleVaccinated
  FROM dbo.CovidDeath dea
  join dbo.CovidVaccination vac
  ON dea.location = vac.location
  AND dea.date=vac.date
  where dea.continent is not null 
)
  Select *,(RolingPeopleVaccinated/population)*100
  from PopvsVac

  -- temp table
  Drop table if exists #PercentPopulationVaccinated
  create table #PercentPopulationVaccinated
  (
  continent nvarchar(225),
  location nvarchar(225),
  date datetime,
  population numeric,
  new_vaccination numeric,
  RolingPeopleVaccinated numeric

  )

  Insert into #PercentPopulationVaccinated
   SELECT dea.continent , dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location , dea.date) as RolingPeopleVaccinated
  FROM dbo.CovidDeath dea
  join dbo.CovidVaccination vac
  ON dea.location = vac.location
  AND dea.date=vac.date
  where dea.continent is not null 

   Select *,(RolingPeopleVaccinated/population)*100
  from #PercentPopulationVaccinated

  -- create view for data for later visualization
  
  create view PercentPopulationVaccinated AS

  Select dea.continent , dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location , dea.date) as RolingPeopleVaccinated
  FROM dbo.CovidDeath dea
  join dbo.CovidVaccination vac
  ON dea.location = vac.location
  AND dea.date=vac.date
  where dea.continent is not null