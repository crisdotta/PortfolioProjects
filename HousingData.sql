/*
Cleaning Data in SQL Queries
*/
select * 
from projectportfolio.housingdata;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Standarize Date Format
/*Selection of the column once the changes are done to see if they worked*/
select SaleDateConverted, convert(SaleDate, Date)
from projectportfolio.housingdata;
/*We add a column where that we are going to populate with the right date format*/
ALTER TABLE housingdata
add SaleDateConverted DATE;
/*update of the column using the convert function where we select the column Sale Date to change the format to a date format with just the year, day and month*/
Update housingdata
set SaleDateConverted = convert(SaleDate, Date);
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate property adress 
/*Selection of the column once the changes are done to see if they worked*/
select PropertyAddress
from projectportfolio.housingdata;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress)
from projectportfolio.housingdata a
join projectportfolio.housingdata b
on a.ParcelID = b.ParcelID
and a.﻿UniqueID <> b.﻿UniqueID
where a.PropertyAddress is null;

update housingdata a
join projectportfolio.housingdata b
	on a.ParcelID = b.ParcelID
	and a.﻿UniqueID <> b.﻿UniqueID
set a.PropertyAddress = ifnull(a.PropertyAddress,b.PropertyAddress)
where a.PropertyAddress is null;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Separating adress into different columns (Address, City, State)
select PropertyAddress
from projectportfolio.housingdata;

select substring(propertyAddress, 1, locate(",",propertyAddress)-1) as adress,
substring(propertyAddress, locate(",",propertyAddress)+1,length(propertyAddress) ) as location
from projectportfolio.housingdata;

ALTER TABLE housingdata
add address varchar(255);
Update housingdata
set address = substring(propertyAddress, 1, locate(",",propertyAddress)-1);

ALTER TABLE housingdata
add city varchar(255);
Update housingdata
set city = substring(propertyAddress, locate(",",propertyAddress)+1,length(propertyAddress));

select * 
from housingdata;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change SoldAsVacant Y and N to Yes and No
select projectportfolio.housingdata.SoldAsVacant,
CASE when SoldAsVacant = "Y" THEN "Yes"
	when SoldAsVacant = "N" THEN "No"
    ELSE SoldAsVacant
    END
from housingdata;

Update housingdata
set housingdata.SoldAsVacant = CASE when SoldAsVacant = "Y" THEN "Yes"
	when SoldAsVacant = "N" THEN "No"
    ELSE SoldAsVacant
    END;

select SoldAsVacant,count(projectportfolio.housingdata.SoldAsVacant)
from housingdata
group by SoldAsVacant
order by 2;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove duplicates is not recommendable in SQL preferably have it done in Excel
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete unused columns 
ALTER TABLE housingdata
drop column SaleDate;

select * 
from housingdata;

