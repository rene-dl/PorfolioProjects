/* 
	Project of Cleaning Data
1. Remove duplicates
2. Standardize the Data
3. Null values or blank values
4. Remove any columns
*/
-- Remove duplicates

SELECT *
FROM layoffs;

CREATE TABLE layoffs_clean
LIKE layoffs;

INSERT layoffs_clean
SELECT *
FROM layoffs;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions)  AS row_num
FROM layoffs_clean
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_clean
WHERE company = 'Oda';


CREATE TABLE `layoffs_clean2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_clean2
WHERE row_num > 1;

INSERT INTO layoffs_clean2
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions)  AS row_num
FROM layoffs_clean;

DELETE
FROM layoffs_clean2
WHERE row_num > 1;

SELECT *
FROM layoffs_clean2;

-- Standardizing data

SELECT company, TRIM(company)
FROM layoffs_clean2;

UPDATE layoffs_clean2
SET company = TRIM(company);

SELECT *
FROM layoffs_clean2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_clean2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_clean2
ORDER BY 1;

UPDATE layoffs_clean2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_clean2;

UPDATE layoffs_clean2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_clean2;

ALTER TABLE layoffs_clean2
MODIFY COLUMN `date` DATE;

-- Null values or blank values

SELECT *
FROM layoffs_clean2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_clean2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_clean2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_clean2
WHERE company = "Airbnb";

SELECT *
FROM layoffs_clean2 t1
JOIN layoffs_clean2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_clean2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_clean2 t1
JOIN layoffs_clean2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Remove columns

SELECT *
FROM layoffs_clean2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_clean2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_clean2;

ALTER TABLE layoffs_clean2
DROP COLUMN row_num;
