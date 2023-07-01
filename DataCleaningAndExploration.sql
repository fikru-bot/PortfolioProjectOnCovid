--Data exploration
--Retrieve the total number of deaths by continent
SELECT continent, SUM(total_deaths) AS total_deaths_by_continent
FROM PortfolioProject..CovidDeaths
GROUP BY continent;

--Find the location with the highest number of total deaths
SELECT location, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE total_deaths = (SELECT MAX(total_deaths) FROM PortfolioProject..CovidDeaths);

--Calculate the average number of new deaths per day for each location
SELECT location, AVG(new_deaths) AS avg_new_deaths_per_day
FROM PortfolioProject..CovidDeaths
GROUP BY location
ORDER BY avg_new_deaths_per_day DESC;

--Retrieve the top 5 locations with the highest number of total cases
SELECT TOP 5 continent, total_cases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY total_cases DESC;

--Find the date with the highest number of new deaths globally
SELECT date, new_deaths
FROM PortfolioProject..CovidDeaths
WHERE new_deaths = (SELECT MAX(new_deaths) FROM PortfolioProject..CovidDeaths);

--Calculate the mortality rate (total deaths divided by total cases) for each location
SELECT TOP 5 location, date, total_deaths, total_cases, (total_deaths / total_cases)*100 AS mortality_rate
FROM PortfolioProject..CovidDeaths
ORDER BY mortality_rate DESC;

--Retrieve the location, population, and total deaths where the population is greater than 1 million and the total deaths are more than 1000
SELECT location, population, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE population > 1000000 AND total_deaths > 1000;

--Find the location with the highest mortality rate (total deaths divided by total cases)
SELECT TOP 1 location, (total_deaths / total_cases) AS mortality_rate
FROM PortfolioProject..CovidDeaths
ORDER BY mortality_rate DESC

--Retrieve the dates where the number of new deaths exceeded 1000 cases in a specific location
SELECT date, new_deaths
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
AND new_deaths > 1000;

--Calculate the percentage of total deaths in each location compared to the global total deaths
SELECT location, (total_deaths / (SELECT SUM(total_deaths) FROM PortfolioProject..CovidDeaths)) * 100 AS percentage_total_deaths
FROM PortfolioProject..CovidDeaths;

--Find the locations that have experienced a decrease in total deaths compared to the previous day
SELECT curr.location, curr.date, curr.total_deaths, prev.total_deaths AS previous_day_total_deaths
FROM PortfolioProject..CovidDeaths curr
JOIN PortfolioProject..CovidDeaths prev ON curr.location = prev.location
WHERE curr.total_deaths < prev.total_deaths;

--Calculate the average number of weekly ICU admissions per million people for each continent
SELECT TOP 1 continent, AVG(weekly_icu_admissions_per_million) AS average_weekly_icu_admissions_per_million
FROM PortfolioProject..CovidDeaths
GROUP BY continent;

--Retrieve the dates where the total deaths exceeded a certain threshold for a specific location
SELECT location, date, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States' AND total_deaths > 1000;

--Retrieve the locations with the highest peak in new cases per million people
SELECT location, MAX(new_cases_per_million) AS peak_new_cases_per_million
FROM PortfolioProject..CovidDeaths
GROUP BY location
ORDER BY peak_new_cases_per_million DESC;

--Calculate the average daily change in the reproduction rate over a specific date range for a particular location
SELECT location, date, reproduction_rate,
       (reproduction_rate - LAG(reproduction_rate) OVER (PARTITION BY location ORDER BY date)) AS daily_change
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States' 

--Find the locations where the average daily new deaths per million people has been decreasing over the last 14 days and is below the global average
SELECT location, AVG(new_deaths_per_million) AS average_new_deaths_per_million
FROM PortfolioProject..CovidDeaths
WHERE date >= DATEADD(day, -13, GETDATE())
GROUP BY location
HAVING AVG(new_deaths_per_million) < (SELECT AVG(new_deaths_per_million) FROM PortfolioProject..CovidDeaths);


--Retrieve the dates where the number of new cases per million people exceeded the average number of new cases per million people for the respective continent
SELECT continent, date, new_cases_per_million, average_new_cases_per_million
FROM (
    SELECT continent, date, new_cases_per_million,
           AVG(new_cases_per_million) OVER (PARTITION BY continent) AS average_new_cases_per_million
    FROM PortfolioProject..CovidDeaths
) AS subquery
WHERE new_cases_per_million > average_new_cases_per_million;


--Retrieve the top 5 locations with the highest average daily increase in new cases over the last 30 days
SELECT TOP 5 location, AVG(new_cases) AS average_daily_increase
FROM PortfolioProject..CovidDeaths
WHERE date >= DATEADD(day, -29, GETDATE())
GROUP BY location
ORDER BY average_daily_increase DESC

--Find the locations where the average daily new cases per million people is above the global average and has been increasing for the last 7 days
WITH consecutive_days AS (
    SELECT location, date, new_cases_per_million, ROW_NUMBER() OVER (PARTITION BY location ORDER BY date) AS row_num
    FROM PortfolioProject..CovidDeaths
    WHERE date >= DATEADD(day, -6, GETDATE())
)
SELECT location
FROM consecutive_days
GROUP BY location
HAVING AVG(new_cases_per_million) > (SELECT AVG(new_cases_per_million) FROM PortfolioProject..CovidDeaths)
    AND MAX(row_num) = COUNT(*);

--Retrieve the top 5 locations with the highest rate of change in new deaths per million people over the last 7 days
SELECT TOP 5 location, (new_deaths_per_million - LAG(new_deaths_per_million) OVER (PARTITION BY location ORDER BY date)) AS rate_of_change
FROM PortfolioProject..CovidDeaths
WHERE date >= DATEADD(day, -6, GETDATE())
ORDER BY rate_of_change DESC

--Retrieve the locations with a decreasing trend in new cases for at least 7 consecutive days
WITH consecutive_days AS (
    SELECT location, date, ROW_NUMBER() OVER (PARTITION BY location ORDER BY date) AS row_num
    FROM PortfolioProject..CovidDeaths
    WHERE new_cases > 0
)
SELECT location
FROM consecutive_days
GROUP BY location
HAVING COUNT(*) >= 7 AND MAX(row_num) = COUNT(*);

--Calculate the average number of weekly hospital admissions per million people for each continent
SELECT continent, AVG(weekly_hosp_admissions_per_million) AS average_weekly_hosp_admissions_per_million
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent;

--Retrieve the dates where the reproduction rate has been above 1.2 for a specific location
SELECT location, date, reproduction_rate
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States' AND reproduction_rate > 1.2;

--Calculate the doubling time of total deaths for a specific location, defined as the number of days it takes for the total deaths to double
SELECT location, date, total_deaths,
       LOG(2) / LOG(1 + (total_deaths - LAG(total_deaths) OVER (PARTITION BY location ORDER BY date)) / LAG(total_deaths) OVER (PARTITION BY location ORDER BY date)) AS doubling_time
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States';

--Retrieve the dates where the number of new cases exceeded the average number of new cases per million people for the respective location:
SELECT location, date, new_cases, new_cases_per_million, average_new_cases_per_million
FROM (
    SELECT location, date, new_cases, new_cases_per_million,
           AVG(new_cases_per_million) OVER (PARTITION BY location) AS average_new_cases_per_million
    FROM PortfolioProject..CovidDeaths
) AS subquery
WHERE new_cases_per_million > average_new_cases_per_million;

--Calculate the average percentage change in new cases compared to the previous day for each continent
SELECT continent, location, date, 
       AVG(CASE WHEN lagged_new_cases <> 0 THEN (new_cases - lagged_new_cases) / lagged_new_cases * 100 ELSE NULL END) AS average_percentage_change
FROM (
    SELECT continent, location, date, new_cases, 
           LAG(new_cases) OVER (PARTITION BY continent, location ORDER BY date) AS lagged_new_cases
    FROM PortfolioProject..CovidDeaths
) AS subquery
GROUP BY continent, location, date;

--Find the locations that experienced a surge in new cases, defined as a 50% increase in new cases compared to the previous week
SELECT location, date, new_cases
FROM (
    SELECT location, date, new_cases, 
           LAG(new_cases, 7) OVER (PARTITION BY location ORDER BY date) AS previous_week_cases
    FROM PortfolioProject..CovidDeaths
) AS subquery
WHERE new_cases > 1.5 * previous_week_cases;

--Find the locations where the average daily new cases per million people exceeds the global average
SELECT location, AVG(new_cases_per_million) AS average_new_cases_per_million
FROM PortfolioProject..CovidDeaths
GROUP BY location
HAVING AVG(new_cases_per_million) > (SELECT AVG(new_cases_per_million) FROM PortfolioProject..CovidDeaths);

--Calculate the 7-day rolling average of new cases per million people for a specific location
SELECT location, date, new_cases_per_million,
       AVG(new_cases_per_million) OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_average
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States';

--Retrieve the date with the highest number of new cases for each location
SELECT location, date, new_cases
FROM (
    SELECT location, date, new_cases, 
           ROW_NUMBER() OVER (PARTITION BY location ORDER BY new_cases DESC) AS rn
    FROM PortfolioProject..CovidDeaths
) AS subquery
WHERE rn = 1;

--Find the locations with the highest number of weekly hospital admissions
SELECT location, weekly_hosp_admissions
FROM PortfolioProject..CovidDeaths
ORDER BY weekly_hosp_admissions DESC;

--Retrieve the total number of hospital patients for a specific location and date
SELECT location, date, hosp_patients, new_cases, new_deaths
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States' 

--Calculate the average number of new cases per million people for each continent
SELECT continent, AVG(new_cases_per_million) AS average_new_cases_per_million
FROM PortfolioProject..CovidDeaths
GROUP BY continent;

--Find the locations with the highest population
SELECT TOP 5 location, population
FROM PortfolioProject..CovidDeaths
ORDER BY population DESC;

--Retrieve the total number of ICU patients and hospital patients for a specific date
SELECT date, SUM(icu_patients) AS total_icu_patients, SUM(hosp_patients) AS total_hospital_patients
FROM PortfolioProject..CovidDeaths
WHERE date = '2023-05-10'
GROUP BY date;

--Retrieve the population, total cases, and total deaths for locations where the reproduction rate is greater than 1
SELECT TOP 5 location, population, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE reproduction_rate > 1;

--Get the continent-wise total number of cases and deaths on a specific date
SELECT continent, SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE date = '2023-02-10'
GROUP BY continent;

--working with temp table
DROP Table if exists #PercentOfTotalDeath
Create Table #PercentOfTotalDeath
(
continent nvarchar(50),
location nvarchar(50),
date datetime,
population float,
total_cases float,
total_deaths float,
new_deaths float
)

Insert into #PercentOfTotalDeath
Select continent, location, date, population, total_cases, total_deaths, new_deaths
From PortfolioProject..CovidDeaths 
where continent is not null 
Select SUM(total_deaths/population) as #PercentOfTotalDeath
From #PercentOfTotalDeath


--Data cleaning
--Remove records with missing or null values all the columns
DELETE FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
   OR location IS NULL
   OR date IS NULL
   OR population IS NULL
   OR total_cases IS NULL
   OR new_cases IS NULL
   OR new_cases_smoothed IS NULL
   OR total_deaths IS NULL
   OR new_deaths IS NULL
   OR new_deaths_smoothed IS NULL
   OR total_cases_per_million IS NULL
   OR new_cases_per_million IS NULL
   OR new_cases_smoothed_per_million IS NULL
   OR total_deaths_per_million IS NULL
   OR new_deaths_per_million IS NULL
   OR new_deaths_smoothed_per_million IS NULL
   OR reproduction_rate IS NULL
   OR icu_patients IS NULL
   OR icu_patients_per_million IS NULL
   OR hosp_patients IS NULL
   OR hosp_patients_per_million IS NULL
   OR weekly_icu_admissions IS NULL
   OR weekly_icu_admissions_per_million IS NULL
   OR weekly_hosp_admissions IS NULL
   OR weekly_hosp_admissions_per_million IS NULL;

--Clean the continent names by replacing abbreviations with full names
UPDATE PortfolioProject..CovidDeaths
SET continent = CASE
    WHEN continent = 'AF' THEN 'Africa'
    WHEN continent = 'AS' THEN 'Asia'
    WHEN continent = 'EU' THEN 'Europe'
    WHEN continent = 'NA' THEN 'North America'
    WHEN continent = 'OC' THEN 'Oceania'
    WHEN continent = 'SA' THEN 'South America'
    ELSE continent
    END;

--Remove records with zero or negative values in the hosp_patients column
DELETE FROM PortfolioProject..CovidDeaths
WHERE hosp_patients <= 0;

--Fill missing values in the icu_patients column with zero
UPDATE PortfolioProject..CovidDeaths
SET icu_patients = 0
WHERE icu_patients IS NULL;

--Convert the date column to a date data type
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN date DATE;

--Remove records with zero or negative values in the total_deaths column
DELETE FROM PortfolioProject..CovidDeaths
WHERE total_deaths <= 0;

--Fill missing values in the new_cases column with zero
UPDATE PortfolioProject..CovidDeaths
SET new_cases = 0
WHERE new_cases IS NULL;

--Fill missing values in the reproduction_rate column with the median value for the respective continent
UPDATE PortfolioProject..CovidDeaths
SET reproduction_rate = (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY reproduction_rate) OVER (PARTITION BY continent)
    FROM PortfolioProject..CovidDeaths
    WHERE location = PortfolioProject..CovidDeaths.location
)
WHERE reproduction_rate IS NULL;

--Remove records with inconsistent or suspicious date values
DELETE FROM PortfolioProject..CovidDeaths
WHERE date < '2000-01-01' OR date > '2023-06-30';

--Fill missing values in the reproduction_rate column with the average value for the respective location
UPDATE PortfolioProject..CovidDeaths
SET reproduction_rate = subquery.avg_reproduction_rate
FROM (
    SELECT location, AVG(reproduction_rate) AS avg_reproduction_rate
    FROM PortfolioProject..CovidDeaths
    WHERE reproduction_rate IS NOT NULL
    GROUP BY location
) AS subquery
WHERE PortfolioProject..CovidDeaths.location = subquery.location
AND PortfolioProject..CovidDeaths.reproduction_rate IS NULL;

--Clean the location names by replacing specific characters or substrings
UPDATE PortfolioProject..CovidDeaths
SET location = REPLACE(location, 'United States of America', 'United States')

--Standardize the continent names to a consistent format using a CASE statement
UPDATE PortfolioProject..CovidDeaths
SET continent = CASE
    WHEN continent = 'AF' THEN 'Africa'
    WHEN continent = 'AS' THEN 'Asia'
    WHEN continent = 'EU' THEN 'Europe'
    WHEN continent = 'NA' THEN 'North America'
    WHEN continent = 'OC' THEN 'Oceania'
    WHEN continent = 'SA' THEN 'South America'
    ELSE continent
    END;

--Remove records with inconsistent or incorrect population values based on the population range for each continent
DELETE FROM PortfolioProject..CovidDeaths
WHERE population NOT BETWEEN (
    SELECT MIN(population)
    FROM PortfolioProject..CovidDeaths
    GROUP BY continent
) AND (
    SELECT MAX(population)
    FROM PortfolioProject..CovidDeaths
    GROUP BY continent
);

--Normalize the population column by dividing it by 1 million to represent the population in millions
UPDATE PortfolioProject..CovidDeaths
SET population = population / 1000000;

--Convert the date column to a standardized format (e.g., YYYY-MM-DD)
UPDATE PortfolioProject..CovidDeaths
SET date = CONVERT(VARCHAR, TRY_CONVERT(DATE, date), 23);

--Remove duplicate records from the dataset
DELETE FROM PortfolioProject..CovidDeaths
WHERE EXISTS (
    SELECT 1
    FROM PortfolioProject..CovidDeaths AS cd2
    WHERE cd2.continent = CovidDeaths.continent
        AND cd2.location = CovidDeaths.location
        AND cd2.date = CovidDeaths.date
        AND cd2.population = CovidDeaths.population
        AND cd2.total_cases = CovidDeaths.total_cases
        AND cd2.new_cases = CovidDeaths.new_cases
        AND cd2.total_deaths = CovidDeaths.total_deaths
        AND cd2.new_deaths = CovidDeaths.new_deaths
);
 
   






