-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove duplicates (if any)
-- 2. Standarize Data
-- 3. Nulls or blanks
-- 4. Remove innecesary columns/rows

-- Create table to save raw data
CREATE TABLE layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- Duplicate Identification
-- Unique = 1 y Duplicates = 2,3,...
WITH duplicates_cte AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
               stage, country, funds_raised_millions
               ORDER BY company
           ) AS Row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;

-- Create Table without Duplicates
CREATE TABLE layoffs_dedup AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
               ORDER BY company
           ) AS Row_num
    FROM layoffs_staging
) t
WHERE Row_num = 1;

-- Erease Old Table
DROP TABLE layoffs_staging;

-- Rename New
ALTER TABLE layoffs_dedup RENAME TO layoffs_staging;

-- Result
SELECT*
From layoffs_staging;

-- Standarize Data
-- Erease '  '
-- Visualization
SELECT company,TRIM(company)
FROM layoffs_staging
ORDER BY 1;

-- Trimming
UPDATE layoffs_staging
SET company = TRIM(company);

-- Visualization
SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY 1;

-- Same industry misspeling
SELECT *
FROM layoffs_staging
WHERE industry LIKE ('Crypto%');

-- Updateing the Data
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE ('Crypto%');

-- Fine
SELECT DISTINCT location
FROM layoffs_staging
ORDER BY 1;

-- Trimming '.' in USA
SELECT DISTINCT country
FROM layoffs_staging
ORDER BY 1;

-- Visualization
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging
ORDER BY 1;

-- Update Data
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE ('United States%');

-- Previsualization
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging;

-- Change 'Date' from text to 'TIMEDATE'
UPDATE layoffs_staging
SET `date`= STR_TO_DATE(`date`,'%m/%d/%Y');

-- Change Data Type
ALTER TABLE layoffs_staging
MODIFY `date` DATE;

-- Hunting NULL's
SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging
WHERE industry IS NULL
OR industry = ' ';

SELECT *
FROM layoffs_staging
WHERE company = 'Airbnb';

-- Filling missing Data with existing Data
SELECT *
FROM layoffs_staging AS t1
JOIN layoffs_staging AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL;

-- Changing "blanks" for Null's
UPDATE layoffs_staging
SET industry = null
WHERE industry='';

/*This UPDATE fills in the missing values of the "industry" column (NULL or empty).
The match is made by "company" with correct values within the same company
In this way, if a row has an empty "industry" but another row with the same 
company has a valid "industry," that value will be copied*/
UPDATE layoffs_staging AS t1
JOIN layoffs_staging AS t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;
  
-- Deleting unused Cloumns/Rows
SELECT COUNT(*) AS NO_INFO
FROM layoffs_staging
WHERE total_laid_off IS NULL OR percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging
DROP COLUMN Row_num;

SELECT *
FROM layoffs_staging;
