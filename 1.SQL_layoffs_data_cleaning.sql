-- DATA CLEANING

SELECT *
FROM alex_bootcamp.layoffs;


-- 1. Remove duplicates
-- 2. Standarize the data
-- 3. Null values or blank values
-- 4. remove unecessary columns and rows 

-- DROP TABLE IF EXISTS layoffs_staging;
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

-- make sure you only run this code once
INSERT alex_bootcamp.layoffs_staging
SELECT *
FROM layoffs;


-- We delete duplicates
-- we put the following code in CTE
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`) AS row_num
FROM layoffs_staging;

-- CTE-- 
WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

-- WE CHECK they are duplicates
SELECT *
FROM layoffs_staging
WHERE company ='Casper';


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` bigint DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage
,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

--  We visualize the duplicated to delete
SELECT *
FROM alex_bootcamp.layoffs_staging2
WHERE row_num > 1;

--  we delete the duplicates
DELETE 
FROM alex_bootcamp.layoffs_staging2
WHERE row_num > 1;

-- STEP 2: STANDARIZING DATA

SELECT industry,LENGTH(company), TRIM(company),LENGTH(TRIM(company))
FROM alex_bootcamp.layoffs_staging2;

-- WE UPDATE THE TABLE
UPDATE alex_bootcamp.layoffs_staging2
SET company=TRIM(company);

--  we do the same thing for industry
SELECT industry,LENGTH(industry), TRIM(industry),LENGTH(TRIM(industry))
FROM alex_bootcamp.layoffs_staging2
ORDER BY 1;

--  we identify industry crypto 
SELECT *
FROM alex_bootcamp.layoffs_staging2
WHERE industry LIKE 'Crypto%'
ORDER BY 3;

-- we change the name of the industry

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- we check they are clean
SELECT DISTINCT industry
FROM alex_bootcamp.layoffs_staging2
ORDER BY 1;

--  we check country
SELECT DISTINCT country
FROM alex_bootcamp.layoffs_staging2
ORDER BY 1;

--  we found errors in USA
SELECT *
FROM alex_bootcamp.layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY country;

-- we see if we can fix it by using trim and trailing 
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM alex_bootcamp.layoffs_staging2
ORDER BY 1;

-- We update the TABLE

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


--  WE WORK ON DATE COLUMN
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM alex_bootcamp.layoffs_staging2;

-- WE UPDATE THE DATE COLUMN
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM alex_bootcamp.layoffs_staging2;

--  WE CHANGE THE DATE COLUMN TYPE

ALTER TABLE alex_bootcamp.layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. NULLS AND BLANKS

SELECT * 
FROM alex_bootcamp.layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT *
FROM alex_bootcamp.layoffs_staging2
WHERE company = 'Airbnb';

-- we will JOIN the table with itself
SELECT *
FROM alex_bootcamp.layoffs_staging2 t1
JOIN alex_bootcamp.layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

SELECT t1.industry,t2.industry
FROM alex_bootcamp.layoffs_staging2 t1
JOIN alex_bootcamp.layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

--  before Updating  we set the white spaces to NULL
-- this might save us time in case it doesnt update the values that have spaces instead of NULLS

UPDATE layoffs_staging2 
SET industry=NULL
WHERE industry = '';

-- WE UPDATE THE TABLE 

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
ON t1.company = t2.company
SET t1.industry= t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


-- we check the columns total laid off and % laid off
SELECT * 
FROM alex_bootcamp.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- we decide to delete these rows-- 
DELETE
FROM alex_bootcamp.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

 -- we delete row num column-- 
 ALTER TABLE alex_bootcamp.layoffs_staging2
 DROP COLUMN row_num;
 









