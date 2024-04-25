-- Data Exploratory Analisis (EDA)
SELECT * 
FROM layoffs_staging2;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- range of date 
select min(layoffs_staging2.date), max(layoffs_staging2.date)
from layoffs_staging2;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- total laid off per year
select year(layoffs_staging2.date), SUM(total_laid_off)
from layoffs_staging2
where year(layoffs_staging2.date) != 0
group by 1; 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- total laid off in each company per year
select layoffs_staging2.﻿company, year(layoffs_staging2.date), SUM(total_laid_off)
from layoffs_staging2
where year(layoffs_staging2.date) != 0
group by 1,2
order by 1; 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- max of laid off and percentage laid off
SELECT MAX(layoffs_staging2.total_laid_off), MAX(layoffs_staging2.percentage_laid_off)
FROM layoffs_staging2;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- max laid off and percentage laid off per year
select MAX(layoffs_staging2.total_laid_off), MAX(layoffs_staging2.percentage_laid_off), year(layoffs_staging2.date)
FROM layoffs_staging2
where year(layoffs_staging2.date) != 0
group by year(layoffs_staging2.date)
order by 1;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- sum of all layoffs per industry
select layoffs_staging2.industry, sum(layoffs_staging2.total_laid_off)
from layoffs_staging2
group by industry
order by 2 DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- percentage of total layoffs per industry
SET @sumOfLayoffs = (select sum(layoffs_staging2.total_laid_off) from layoffs_staging2);
select layoffs_staging2.industry, round((sum(layoffs_staging2.total_laid_off)/@sumOfLayoffs)*100,2)
from layoffs_staging2
where industry is not null
group by industry
order by 2 DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- sum of all layoffs per country
select layoffs_staging2.country, sum(layoffs_staging2.total_laid_off)
from layoffs_staging2
group by country
order by 2 DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- percentage of total layoffs per country
SET @sumOfLayoffs = (select sum(layoffs_staging2.total_laid_off) from layoffs_staging2);
select layoffs_staging2.country, round((sum(layoffs_staging2.total_laid_off)/@sumOfLayoffs)*100,2)
from layoffs_staging2
where country is not null
group by country
order by 2 DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  total layoffs per compány
select layoffs_staging2.﻿company, sum(layoffs_staging2.total_laid_off)
from layoffs_staging2
group by layoffs_staging2.﻿company
order by 2 DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- percentage of total layoffs per company
SET @sumOfLayoffsCompany = (select sum(layoffs_staging2.total_laid_off) from layoffs_staging2);
select layoffs_staging2.﻿company, round((sum(layoffs_staging2.total_laid_off)/@sumOfLayoffsCompany)*100,2)
from layoffs_staging2
where layoffs_staging2.﻿company is not null
group by layoffs_staging2.﻿company
order by 2 DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- view of a top 5 ranking with the most laidoff people per company and year
with Company_year (company, years, total_laid_off) AS
(
SELECT layoffs_staging2.﻿company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY layoffs_staging2.﻿company, YEAR(`date`)
), Company_Year_Rank as 
(
SELECT *,
DENSE_RANK() OVER  (partition by years order by total_laid_off DESC) as Ranking
FROM Company_year
where years is not null
)
SELECT * 
FROM Company_Year_Rank
where Ranking <= 5;