.mode column
.headers on

-- QUERIES

-- What are the 10 most asked skills?
SELECT Skills.name AS "Skill", COUNT(Skills_Job.skill_id) AS "Frequency"
FROM Skills JOIN Skills_Job ON Skills.id = Skills_Job.skill_id
GROUP BY skill_id
ORDER BY "Frequency" DESC
LIMIT 10;

-- What are the 10 best paid skills on average?
SELECT Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
FROM Skills JOIN Skills_Job
    ON Skills.id = Skills_Job.skill_id
JOIN Job_Offers 
    ON Skills_Job.job_id = Job_Offers.job_id
GROUP BY Skills.id
ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
LIMIT 10;



-- What are the 10 most offered jobs positions?
SELECT Jobs.name AS "Job", COUNT(Job_Offers.job_id) AS "Number of Offers"
FROM Jobs JOIN Job_Offers ON Jobs.id = Job_Offers.job_id
GROUP BY Jobs.id
ORDER BY "Number of Offers" DESC
LIMIT 10;

-- What are the 10 best paid job positions on average
SELECT Jobs.name AS "Job", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
FROM Jobs JOIN Job_Offers 
    ON Jobs.id = Job_Offers.job_id
GROUP BY Jobs.id 
ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
LIMIT 10;

-- What are the most optimal skills?
SELECT 
    Skills.name,
    (ROUND(AVG((Job_Offers."Salary Max ($ gross annual)" + Job_Offers."Salary Min ($ gross annual)")/2),2)*COUNT(Skills.id)) AS "Optimality Index"
FROM Skills JOIN Skills_Job
    ON Skills.id = Skills_Job.skill_id
JOIN Job_Offers 
    ON Skills_Job.job_id = Job_Offers.job_id
GROUP BY Skills.id
ORDER BY "Optimality Index" DESC
LIMIT 10;

-- What are the 10 Companies with more offers plubiced?
SELECT Companies."Company Name", COUNT(Job_Offers.id) AS "Number of Offers"
FROM Companies JOIN Job_Offers
    ON Companies.id = Job_Offers.company_id
GROUP BY Companies.id
ORDER BY "Number of Offers" DESC
LIMIT 10;


-- What are the top 50 best rated Companies?
SELECT "Company Name", Rating AS "Rate"
FROM Companies
ORDER BY "Rate" DESC
LIMIT 50;


-- Which companies offer the best average pay?
SELECT Companies."Company Name", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)"
FROM Companies JOIN Job_Offers
    ON Companies.id = Job_Offers.company_id
GROUP BY Companies.id
ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
LIMIT 20;


-- What are the oldest companies?
SELECT "Company Name", Founded
FROM Companies
WHERE Founded NOT NULL
ORDER BY Founded ASC
LIMIT 10
;

-- What are the newest companies?
SELECT "Company Name", Founded
FROM Companies
WHERE Founded NOT NULL
ORDER BY Founded DESC
LIMIT 10
;

-- Which locations have the highest number of company headquarters?
SELECT Locations.city, Locations.region, COUNT(Companies.id) AS "Number of company headquarters"
FROM Locations JOIN Companies
    ON Locations.id = Companies.Headquarters_location_id
GROUP BY Locations.id
ORDER BY "Number of company headquarters" DESC
LIMIT 10;

-- In which locations are there more job openings?
SELECT Locations.city, Locations.region, COUNT(Job_Offers.id) AS "Number of Offers"
FROM Locations JOIN Job_Offers
    ON Locations.id = Job_Offers.location_id
GROUP BY Locations.id
ORDER BY "Number of Offers" DESC
LIMIT 10;


-- What are the Industries with more offers?
SELECT Industries.name AS "Industry", COUNT(Job_Offers.id) AS "Number of Offers"
FROM Industries JOIN Companies
    ON Industries.id = Companies.Industry_id
JOIN Job_Offers
    ON Companies.id = Job_Offers.company_id
GROUP BY Industries.id
ORDER BY "Number of Offers" DESC
LIMIT 10;


-- What are the Sectors with more offers?
SELECT Sectors.name AS "Sector", COUNT(Job_Offers.id) AS "Number of Offers"
FROM Sectors JOIN Industries
    ON Sectors.id = Industries.sector_id
JOIN Companies
    ON Industries.id = Companies.Industry_id
JOIN Job_Offers
    ON Companies.id = Job_Offers.company_id
GROUP BY Sectors.id
ORDER BY "Number of Offers" DESC
LIMIT 10;

-- What are the companies with more revenue? (depending on their size)
SELECT * FROM Company_Revenues;


-- What is the best paid skill on average by sector
SELECT * FROM Skills_Sector;


-- What companies paid above the average?
SELECT Companies."Company Name", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)"
FROM Companies JOIN Job_Offers
    ON Companies.id = Job_Offers.company_id
GROUP BY Companies.id
HAVING AVG(Job_Offers."Salary Max ($ gross annual)") > ( SELECT AVG("Salary Max ($ gross annual)") FROM Job_Offers )
ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
;


-- COMMON STATEMENTS

-- Updating Rating of Companies
UPDATE Companies SET Rating = 3
WHERE id = 3;

-- Delete Job Offers
DELETE FROM Job_Offers
WHERE id = 3;