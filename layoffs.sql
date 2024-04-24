SELECT * 
FROM projectportfolio.layoffs;

-- 1. Remove Duplicates
-- 2. Standarize the data
-- 3. Look at null or blank values
-- 4. Remove cols or row unnecesary

-- removing duplicates
SELECt *, row_number() over(partition by layoffs.﻿company,industry,total_laid_off,percentage_laid_off,`date`) as row_num
from layoffs;
-- dividing the data to see how many duplicates are there, with a cte and row_number the duplicated data will be labeled as row_num = 2
with duplicate_cte as (
SELECT *, 
row_number() over
(partition by layoffs.﻿company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs
)
select * 
from duplicate_cte
where row_num > 1;

-- Deleting duplicates by creating a table with those duplicates values and the row num to filter by it and delete them
-- Copy of the layoffs table with row_num column
CREATE TABLE `layoffs_staging2` (
  `﻿company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- inserting the data with row_num column, the data with column row_num with a value of 2 are the duplicates to delete 
INSERT INTO layoffs_staging2
SELECT *, 
row_number() over
(partition by layoffs_staging.﻿company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;
-- selecting and deleting all duplicates
select *
FROM projectportfolio.layoffs_staging2;

-- standarizing data
select distinct industry
from layoffs_staging2
order by industry;
-- updating the values (CryptoCurrency, Cripto Currency) to match Crypto therefore they can all be in the same Crypto categorie	 
update layoffs_staging2
set layoffs_staging2.industry = 'Crypto'
where layoffs_staging2.industry like 'Crypto%';
-- found a '.' in the values 'United States.' and changing them to match the right value 'United States'
select distinct country, trim(TRAILING '.' FROM country)
from layoffs_staging2
order by 1;
-- deleting a '.' found only in the values 'United States.' to match the right value 'United States'
update layoffs_staging2
set country = trim(TRAILING '.' FROM country)
where country like 'United States%';

-- format date using the str_to_date function
select layoffs_staging2.date
from layoffs_staging2
order by 1;
-- updating the date values from text to 
update layoffs_staging2
set layoffs_staging2.date = str_to_date(layoffs_staging2.date, '%m/%d/%Y');
-- changing the date column from text to date 'MONTH-DAY-YEAR'
alter table layoffs_staging2
modify column `date` date;
-- checking for blanks and nulls
-- selecting blank values in industry
select *
from layoffs_staging2
where industry = '';
-- checking if blanks industries are populatable (Airbnb, Carvana, Juul, Bally% no other records than blank)
select *
from layoffs_staging2
where layoffs_staging2.﻿company = 'Airbnb';
select *
from layoffs_staging2
where layoffs_staging2.﻿company like 'Bally%';
select *
from layoffs_staging2
where layoffs_staging2.﻿company = 'Carvana';
select *
from layoffs_staging2
where layoffs_staging2.﻿company = 'Juul';
-- updating blank industry from airbnb
update layoffs_staging2
set layoffs_staging2.industry = 'Travel'
where layoffs_staging2.﻿company = 'Airbnb' and layoffs_staging2.industry = '';
-- updating blank industry from Carvana 
update layoffs_staging2
set layoffs_staging2.industry = 'Transportation'
where layoffs_staging2.﻿company = 'Carvana' and layoffs_staging2.industry = '';
-- updating blank industry from Juul 
update layoffs_staging2
set layoffs_staging2.industry = 'Consumer'
where layoffs_staging2.﻿company = 'Juul' and layoffs_staging2.industry = '';
-- deleting total laid off and percentage laid off
select *
from layoffs_staging2;

delete 
from layoffs_staging2
where total_laid_off = '' 
AND percentage_laid_off = '';
-- deleting unncesary cols
alter table layoffs_staging2
drop column row_num;



