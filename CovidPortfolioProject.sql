--Wiew the CovidDeaths table // CovidDeaths tablosunu goruntuleme
--Which continent is not null // Kita kolonu dolu olanlari goruntule

Select *
From PortfolioProject..CovidDeaths
Where continent is not NULL
Order By 3,4


--Wiew the CovidVaccinations table // CovidVaccinations tablosunu goruntuleme

Select *
From PortfolioProject..CovidVaccinations
Where continent is not NULL
Order By 3,4

--Select Data that we are going to be using // Kullanacagimiz datayi seciyoruz

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not NULL
Order By 1,2

--Looking at Total Cases vs Total Deaths // Toplam vaka ve olum oranini karsilastiriyoruz
--Shows likelihood of dying if you contact covid in your country // Turkiye'de covid ile temasa gecersen olme ihtimalinin kac oldugunu gosteriyor

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Turkey%'
and continent is not NULL
Order By 1,2

--Looking at the total Cases vs Population // Toplam vaka ve nufusun karsilastirilmasi
--Shows what percentage of population got covid // Toplumun yuzde kacinin Covide yakalandigini gosteriyor

Select Location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Turkey%'
and continent is not NULL
Order By 1,2

--Looking at countries with highest infection rate compared to population // Nufus sayisina kiyasla vaka sayisi ve  en yuksek olan ulkelerin karsilastirilmasi
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group By Location, population
Order By PercentPopulationInfected DESC

--Showing countries with highest death count per population // Her ulkenin en yuksek olum oranini goruntuleme

Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group By Location
Order By TotalDeathCount DESC

--Showing continents with highest death per population  // Kitalarin en yuksek olum oranlarini gosterme

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not  NULL
Group By continent
Order By TotalDeathCount DESC

--Global Numbers // Dunya genelindeki sayilar

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, NULLIF(SUM(new_deaths), 0)/NULLIF(SUM(new_cases), 0)*100 as DeathPersentage
From PortfolioProject..CovidDeaths
--Where location like '%Turkey%'
Where continent is not NULL
--Group By date
Order By 1,2

-- Looking at total population vs vaccinations // Toplam nufus ve asilama orani karsilastirilmasi

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))  OVER(PARTITION BY dth.location Order By dth.location, dth.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	And dth.date = vac.date
Where dth.continent is not null
Order By 2,3

--USING CTE // CTE KULLANIMI

With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))  OVER(PARTITION BY dth.location Order By dth.location, dth.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	And dth.date = vac.date
Where dth.continent is not null
--Order By 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE // Gecici Tablo

DROP Table IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))  OVER(PARTITION BY dth.location Order By dth.location, dth.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	And dth.date = vac.date
Where dth.continent is not null
--Order By 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations // View olusturma

Create View PercentPopulationVaccinated as 
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))  OVER(PARTITION BY dth.location Order By dth.location, dth.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	And dth.date = vac.date
Where dth.continent is not null
--Order By 2,3 

Select *
From PercentPopulationVaccinated