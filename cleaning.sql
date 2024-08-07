
 -- WE CLEAN THE DATA FIRST --
 
 -- We also create a duplicate of the real database in order to keep the raw data apart
 
-- 1. REMOVING DUPLICATES --


-- We look into the data

SELECT *
FROM income;

SELECT * 
FROM stat;

SELECT id, COUNT(id)
FROM income
GROUP BY id
HAVING COUNT(id) >1;

-- We found some duplicates in Income table
DELETE FROM income
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id,
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		FROM income
		) duplicates
	WHERE row_num >1)
;

-- no duplicates in stat table

SELECT id, COUNT(id)
FROM stat
GROUP BY id
HAVING COUNT(id) > 1;

SELECT state_name, COUNT(state_name)
FROM income
GROUP BY state_name;


-- 2. Standardization 

-- We found some wrong spellings
UPDATE income
SET state_name = 'Georgia'
WHERE state_name = 'georia';

UPDATE income
SET state_name = 'Alabama'
WHERE state_name = 'alabama';

-- We check state_ab
SELECT DISTINCT state_ab
FROM income
ORDER BY 1;

-- We found a missing place . We can populate it

SELECT *
FROM income
WHERE county = 'Autaga County'
ORDER BY 1;

UPDATE income
SET PLACE = 'Autaugaville'
WHERE county = 'Autauga County'
AND city = 'Vinemont';

-- We also found some error in type
SELECT type, COUNT(type)
FROM income
GROUP BY type;

UPDATE income
SET type = 'Borough'
WHERE type = 'Boroughs';

-- Some minor issues

UPDATE income
SET county = UPPER(County);

UPDATE income
SET city = UPPER(City);

UPDATE income
SET state_name = UPPER(state_name);

UPDATE income
SET place = UPPER(Place);

UPDATE income
SET type = 'CDP'
WHERE type = 'CPD';



-- We look at waterland

SELECT aland, awater
FROM income
WHERE awater = 0 OR awater = '' OR awater IS NULL;

-- no nulls/blanks in either land or water



-- EXPLORING DATA --

SELECT *
FROM income;

SELECT *
FROM stat;

SELECT state_name, SUM(aland), SUM(awater)
FROM income
GROUP BY state_name
ORDER BY 2 DESC-- also ORDER BY 3
LIMIT 10;

SELECT *
FROM income 
JOIN stat
	USING(id);

-- We found some missing statistics (with 0 value)

SELECT *
FROM income 
JOIN stat
	USING(id)
WHERE mean != 0;

SELECT u.state_name, u.county, type, `primary`, mean, median
FROM income u
JOIN stat s
	USING(id)
WHERE mean != 0;

SELECT u.state_name, ROUND(AVG(mean),1), ROUND(AVG(median),1)
FROM income u
JOIN stat s
	USING(id)
WHERE mean != 0
GROUP BY u.state_name
ORDER BY 2 -- DESC
LIMIT 10;

SELECT type, COUNT(type), ROUND(AVG(mean),1), ROUND(AVG(median),1)
FROM income u
JOIN stat s
	USING(id)
WHERE mean != 0
GROUP BY type
HAVING COUNT(type) > 100 -- some outliers dont seem usefull
ORDER BY 3 DESC -- also checked BY 4 and ASC
LIMIT 10;

SELECT *
FROM income
WHERE type = 'Community';

SELECT u.state_name, city, ROUND(AVG(mean),1), ROUND(AVG(median),1)
FROM income u
JOIN stat s
	USING(id)
GROUP BY u.state_name, city
ORDER BY ROUND(AVG(mean),1) DESC;



