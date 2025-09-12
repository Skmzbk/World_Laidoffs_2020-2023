-- Data Exploration Analysis

SELECT *
FROM layoffs_staging;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging;

-- Defunct companies
SELECT *
FROM layoffs_staging
WHERE percentage_laid_off=1
ORDER BY total_laid_off DESC;

-- Companies/Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY industry
ORDER BY 2 DESC;

-- Total Layoffs per country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY country
ORDER BY 2 DESC;

-- Period of Time
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY stage
ORDER BY 2 DESC;

-- Visualization the laid offs through the years
WITH Month_RT AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS TLO
FROM layoffs_staging
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, TLO, SUM(TLO) OVER(ORDER BY `MONTH`) AS Rolling_Total
FROM Month_RT;

SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Which company had the biggest Layouts by year
WITH Company_Year (company,years,TLO) AS
(
SELECT company,YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging
GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY TLO DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;
