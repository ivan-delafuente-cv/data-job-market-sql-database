.import --csv DataScientist.csv DataScientist


-- CLEANING DATA
-- Remove unnecessary or blank columns and name the columns correctly
ALTER TABLE DataScientist RENAME COLUMN "index" TO "id";
ALTER TABLE DataScientist DROP COLUMN "?";

-- Put everything in minuscule and remove unnecessary spaces
UPDATE DataScientist SET
    id = LOWER(TRIM(id)),
    "Job Title" = LOWER(TRIM("Job Title")),
    "Salary Estimate" = LOWER(TRIM("Salary Estimate")),
    "Job Description" = LOWER(TRIM("Job Description")),
    Rating = LOWER(TRIM(Rating)),
    "Company Name" = LOWER(TRIM("Company Name")),
    Location = LOWER(TRIM(Location)),
    Headquarters = LOWER(TRIM(Headquarters)),
    Size = LOWER(TRIM(Size)),
    Founded = LOWER(TRIM(Founded)),
    "Type of ownership" = LOWER(TRIM("Type of ownership")),
    Industry = LOWER(TRIM(Industry)),
    Sector = LOWER(TRIM(Sector)),
    Revenue = LOWER(TRIM(Revenue)),
    Competitors = LOWER(TRIM(Competitors)),
    "Easy Apply" = LOWER(TRIM("Easy Apply"));

-- Remove line hops in the "Job Description" column
UPDATE DataScientist
SET "Job Description" = REPLACE(REPLACE("Job Description", CHAR(10), ' '), CHAR(13), ' ');

-- Convert to NULL the unavailable data

UPDATE DataScientist
SET competitors = NULL
WHERE competitors = -1 OR competitors = -1.0;

UPDATE DataScientist
SET "Easy Apply" = 'false'
WHERE "Easy Apply" = -1 OR "Easy Apply" = -1.0;

UPDATE DataScientist
SET Rating = NULL
WHERE Rating = -1 OR Rating = -1.0;

UPDATE DataScientist
SET Industry = NULL
WHERE Industry = -1 OR Industry = -1.0;

UPDATE DataScientist
SET Sector = NULL
WHERE Sector = -1 OR Sector = -1.0;

UPDATE DataScientist
SET Founded = NULL
WHERE Founded = -1 OR Founded = -1.0;

UPDATE DataScientist
SET Revenue = NULL 
WHERE Revenue = 'unknown / non-applicable'; 


-- Clear the "Company Name" column with numbers
UPDATE DataScientist
SET "Company Name" = substr("Company Name", 1, instr("Company Name", char(10)) - 1)
WHERE "Company Name" LIKE '%'|| char(10) || '%'
;


-- Move all the data to a table already structured with well-defined and modeled variables.

CREATE TABLE DataScientist_Clean(
    id INTEGER,
    "Job Title" TEXT NOT NULL,
    "Salary Estimate" TEXT NOT NULL,
    "Job Description" TEXT NOT NULL,
    Rating REAL CHECK(Rating >= 0 AND Rating <= 5),
    "Company Name" TEXT NOT NULL,
    Location TEXT NOT NULL,
    "Headquarters" TEXT,
    Size TEXT NOT NULL,
    Founded INTEGER,
    "Type of ownership" TEXT NOT NULL,
    Industry TEXT,
    Sector TEXT,
    Revenue TEXT,
    Competitors TEXT,
    "Easy Apply" TEXT NOT NULL,

    PRIMARY KEY(id)
);

INSERT INTO DataScientist_Clean (
    id, "Job Title", "Salary Estimate", "Job Description",
    Rating, "Company Name", Location,"Headquarters", Size, Founded,
    "Type of ownership", Industry, Sector, Revenue,
    Competitors, "Easy Apply"
)
SELECT
    CAST(id AS INTEGER),
    "Job Title",
    "Salary Estimate",
    "Job Description",
    CAST(Rating AS REAL),
    "Company Name",
    Location,
    "Headquarters",
    Size,
    CAST(Founded AS INTEGER),
    "Type of ownership",
    Industry,
    Sector,
    Revenue,
    Competitors,
    "Easy Apply"
FROM DataScientist;



-- DATA MODELLING

-- Convert the "Salary Estimate" column into two headers: "Salary Min" and "Salary Max"

ALTER TABLE DataScientist_Clean 
ADD COLUMN "Salary Min ($ gross annual)" TEXT;

ALTER TABLE DataScientist_Clean 
ADD COLUMN "Salary Max ($ gross annual)" TEXT;


UPDATE DataScientist_Clean
SET "Salary Min ($ gross annual)" =
    CAST(
        REPLACE(
            REPLACE(
                SUBSTR("Salary Estimate", 1, INSTR("Salary Estimate", '-') - 1),
                '$', ''
            ),
            'k', ''
        ) AS INTEGER
    ) * 1000;

UPDATE DataScientist_Clean
SET "Salary Max ($ gross annual)" =
    CAST(
        REPLACE(
            REPLACE(
                SUBSTR("Salary Estimate", INSTR("Salary Estimate", '-') + 1),
                '$', ''
            ),
            'k', ''
        ) AS INTEGER
    ) * 1000;


-- CREATE NEW TABLES

CREATE TABLE Companies(
    id INTEGER,
    Rating REAL CHECK(Rating >= 0 AND Rating <= 5),
    "Company Name" TEXT NOT NULL,
    Headquarters_location_id INTEGER,
    Size TEXT NOT NULL,
    Founded INTEGER,
    "Type of ownership" TEXT NOT NULL,
    Industry_id INTEGER,
    Revenue TEXT,
    UNIQUE ("Company Name", Headquarters_location_id),

    PRIMARY KEY (id),
    FOREIGN KEY (Headquarters_location_id) REFERENCES Locations(id),
    FOREIGN KEY (Industry_id) REFERENCES Industries(id)
);

CREATE TABLE Industries(
    id INTEGER,
    name TEXT NOT NULL UNIQUE,
    sector_id INTEGER NOT NULL,

    PRIMARY KEY (id),
    FOREIGN  KEY (sector_id) REFERENCES Sectors(id)
);

CREATE TABLE Jobs(
    id INTEGER,
    name TEXT NOT NULL UNIQUE,

    PRIMARY KEY (id)
);

CREATE TABLE Job_Offers(
    id INTEGER,
    job_id INTEGER,
    description TEXT NOT NULL,
    company_id INTEGER,
    location_id INTEGER,
    easy_apply TEXT NOT NULL,
    "Salary Max ($ gross annual)" TEXT NOT NULL,
    "Salary Min ($ gross annual)" TEXT NOT NULL,


    PRIMARY KEY (id),
    FOREIGN KEY (job_id) REFERENCES Jobs(id),
    FOREIGN KEY (company_id) REFERENCES Companies(id),
    FOREIGN KEY (location_id) REFERENCES Locations(id)
);

CREATE TABLE Skills_Job(
    skill_id INTEGER,
    job_id INTEGER,

    PRIMARY KEY (skill_id, job_id),
    FOREIGN KEY (skill_id) REFERENCES Skills(id),
    FOREIGN KEY (job_id) REFERENCES Jobs(id)
);

CREATE TABLE Skills(
    id INTEGER,
    name TEXT NOT NULL UNIQUE,

    PRIMARY KEY (id)
);

CREATE TABLE Locations(
    id INTEGER,
    city TEXT NOT NULL,
    region TEXT NOT NULL,

    PRIMARY KEY (id)
);

CREATE TABLE Sectors(
    id INTEGER,
    name TEXT NOT NULL UNIQUE,

    PRIMARY KEY (id)
);


CREATE TABLE Competitors(
    company1_id INTEGER,
    company2_id INTEGER,

    PRIMARY KEY (company1_id, company2_id),
    FOREIGN KEY (company1_id) REFERENCES Companies(id),
    FOREIGN KEY (company2_id) REFERENCES Companies(id)
);




-- DELETE OLD DATA
DROP TABLE DataScientist;
ALTER TABLE DataScientist_Clean DROP COLUMN "Salary Estimate";



-- INSERT THE DATA IN THE NEW TABLES

-- Skills Table
INSERT INTO skills (name) VALUES
('Python'),
('R'),
('SQL'),
('NoSQL'),
('PostgreSQL'),
('MySQL'),
('MongoDB'),
('SQLite'),
('Data Cleaning'),
('Data Wrangling'),
('Data Visualization'),
('Exploratory Data Analysis'),
('Statistics'),
('Probability'),
('Linear Algebra'),
('Calculus'),
('Machine Learning'),
('Deep Learning'),
('Supervised Learning'),
('Unsupervised Learning'),
('Reinforcement Learning'),
('Feature Engineering'),
('Model Evaluation'),
('Model Deployment'),
('A/B Testing'),
('Hypothesis Testing'),
('Time Series Analysis'),
('Forecasting'),
('Big Data'),
('Spark'),
('Hadoop'),
('ETL Pipelines'),
('Data Warehousing'),
('Snowflake'),
('Redshift'),
('BigQuery'),
('Azure Data Factory'),
('AWS Glue'),
('Power BI'),
('Tableau'),
('Looker'),
('Excel'),
('Google Sheets'),
('Dashboards'),
('KPI Definition'),
('Business Intelligence'),
('Data Modeling'),
('Dimensional Modeling'),
('Star Schema'),
('Data Governance'),
('Data Quality'),
('Data Architecture'),
('APIs'),
('REST'),
('Git'),
('Docker'),
('Kubernetes'),
('MLOps'),
('CI/CD'),
('TensorFlow'),
('PyTorch'),
('Scikit-learn'),
('Pandas'),
('NumPy'),
('Matplotlib'),
('Seaborn'),
('Plotly'),
('NLP'),
('Computer Vision'),
('Data Pipelines'),
('Batch Processing'),
('Stream Processing'),
('Kafka'),
('Airflow'),
('dbt'),
('Data Lakes'),
('Delta Lake'),
('Lakehouse Architecture'),
('Parquet'),
('ORC'),
('Data Encryption'),
('Data Masking'),
('Metadata Management'),
('Data Catalogs'),
('Data Stewardship'),
('Cloud Computing'),
('AWS S3'),
('AWS Lambda'),
('AWS Redshift Spectrum'),
('Azure Synapse'),
('Azure Databricks'),
('Google Cloud Storage'),
('Vertex AI'),
('AutoML'),
('Model Drift Detection'),
('Bias Detection'),
('Explainable AI'),
('SHAP'),
('LIME'),
('Bayesian Statistics'),
('Monte Carlo Simulation'),
('Optimization Algorithms'),
('Gradient Descent'),
('Clustering'),
('Classification'),
('Regression'),
('Neural Networks'),
('GANs'),
('Transformers'),
('LLMs'),
('Prompt Engineering'),
('Vector Databases'),
('FAISS'),
('Pinecone'),
('ChromaDB'),
('Graph Databases'),
('Neo4j'),
('Graph Algorithms'),
('Network Analysis'),
('Geospatial Analysis'),
('GIS Tools'),
('QGIS'),
('GeoPandas'),
('Regex'),
('Web Scraping'),
('BeautifulSoup'),
('Selenium'),
('API Integration') ,
('OAuth'),
('Data Ethics'),
('Privacy Compliance'),
('GDPR'),
('Data Storytelling'),
('Business Requirements Analysis'),
('Stakeholder Communication'),
('Agile Methodologies'),
('Scrum'),
('JIRA'),
('Confluence'),
('Hive'),
('Amplitude'),
('Unix'),
('Linux'),
('SAS'),
('Empirical Research'),
('Statistical Modeling'),
('Data Mining'),
('Large-Scale Data Processing'),
('Business Intelligence Analysis'),
('Product Analytics'),
('Dashboard Design'),
('A/B Experiment Tracking'),
('User Behavior Analysis'),
('Healthcare Data Analysis'),
('Medical Claims Data'),
('Clinical Data'),
('Demographic Data Analysis'),
('Root Cause Analysis'),
('Data Profiling'),
('Data Lineage'),
('Data Quality Assurance'),
('Data Standards'),
('Data Governance Policies'),
('Data QA Processes'),
('ETL Validation'),
('Data Documentation'),
('Cross-Functional Collaboration'),
('Predictive Analytics'),
('Keras'),
('Scrapy'),
('Marketing Analytics'),
('Econometrics'),
('Actuarial Modeling'),
('Insurance Analytics'),
('Model Validation'),
('Model Monitoring'),
('Parameter Tuning'),
('Optimization Criteria'),
('Feature Selection'),
('SAS Enterprise Guide'),
('SAS Enterprise Miner'),
('Monte Carlo Methods'),
('Scientific Computing'),
('MATLAB'),
('C++'),
('OCaml'),
('Functional Programming'),
('Algorithmic Trading'),
('Portfolio Construction'),
('Trading Strategy Development'),
('Financial Modeling'),
('Quantitative Research'),
('Entity Resolution'),
('De-duplication Algorithms'),
('Optical Mark Recognition'),
('Computer Vision Modeling'),
('Confidence Estimation'),
('Model Calibration'),
('Concept Drift Detection');


UPDATE Skills SET name = LOWER(name);

-- Jobs Table
INSERT INTO Jobs (name)
SELECT DISTINCT "Job Title" FROM DataScientist_Clean;

-- Skills_Job Table

INSERT OR IGNORE INTO Skills_Job (job_id, skill_id)
SELECT Jobs.id, Skills.id
FROM Jobs 
JOIN DataScientist_Clean 
    ON Jobs.name = DataScientist_Clean."Job Title"
JOIN Skills
    ON (
        -- skill surrounded by spaces
        (' ' || DataScientist_Clean."Job Description" || ' ')
            LIKE '% ' || Skills.name || ' %'
        
        OR
        
        -- skill followed by coma
        (' ' || DataScientist_Clean."Job Description" || ' ')
            LIKE '% ' || Skills.name || ',%'
        
        OR
        
        -- skill followed by a dot
        (' ' || DataScientist_Clean."Job Description" || ' ')
            LIKE '% ' || Skills.name || '.%'
    );



-- Locations Table
INSERT INTO Locations (city, region)
SELECT DISTINCT
    TRIM(substr(Location, 1, instr(Location, ',') - 1)) AS city,
    TRIM(substr(Location, instr(Location, ',') + 1)) AS region
FROM DataScientist_Clean;

-- Sectors Table
INSERT INTO Sectors (name)
SELECT DISTINCT(Sector) FROM DataScientist_Clean
WHERE Sector IS NOT NULL;


-- Industries Table
INSERT INTO Industries (name, sector_id)
SELECT DISTINCT DataScientist_Clean.Industry, Sectors.id
FROM DataScientist_Clean JOIN Sectors
ON DataScientist_Clean.Sector = Sectors.name
;

-- Companies Table
INSERT INTO Companies(Rating, "Company name", Headquarters_location_id, Size, Founded, "Type of ownership", Industry_id, Revenue)
SELECT DISTINCT DataScientist_Clean.Rating, DataScientist_Clean."Company name", Locations.id, DataScientist_Clean.Size, DataScientist_Clean.Founded, DataScientist_Clean."Type of ownership", Industries.id, DataScientist_Clean.Revenue
FROM Locations JOIN DataScientist_Clean
    ON DataScientist_Clean.Headquarters = (Locations.city || ', ' || Locations.region )
JOIN Industries 
    ON DataScientist_Clean.Industry = Industries.name
;


-- Job_Offers Table 
INSERT INTO Job_Offers (job_id, description, company_id, location_id, easy_apply, "Salary Max ($ gross annual)", "Salary Min ($ gross annual)")
SELECT Jobs.id, DataScientist_Clean."Job Description", Companies.id, Locations.id, DataScientist_Clean."Easy Apply", DataScientist_Clean."Salary Max ($ gross annual)" ,DataScientist_Clean."Salary Min ($ gross annual)"
FROM Jobs JOIN DataScientist_Clean 
    ON Jobs.name = DataScientist_Clean."Job Title"
JOIN Companies
    ON DataScientist_Clean."Company Name" = Companies."Company Name"
JOIN Locations 
    ON DataScientist_Clean.Location = (Locations.city || ', ' || Locations.region)
;


-- Competitors  Table 
-- The disadvantage of this table is that not all competitors have published offers and therefore not all competitors are registered as companies in the dataset
CREATE TABLE Competitors_temp(
    Company_id INTEGER,
    name TEXT NOT NULL,
    Competitors TEXT,

    PRIMARY KEY (Company_id)
);
INSERT OR IGNORE INTO Competitors_temp(Company_id, name, Competitors)
SELECT Companies.id, Companies."Company Name", DataScientist_Clean.Competitors
FROM Companies JOIN DataScientist_Clean
    ON Companies."Company Name" = DataScientist_Clean."Company Name"
;


INSERT OR IGNORE INTO Competitors(company1_id, company2_id)
SELECT c1.Company_id, c2.Company_id
FROM Competitors_temp c1
JOIN Competitors_temp c2 
    ON ( 
        ',' || REPLACE(REPLACE(c2.Competitors, ', ', ','), ' ,', ',') || ','
        LIKE '%,' || c1.name || ',%'
        )
;


-- VIEWS

CREATE VIEW Company_Revenues AS
SELECT * FROM (
    SELECT "Company Name", Size, Revenue
    FROM Companies
    WHERE Size = '10000+ employees'  AND (Revenue = '$25 to $50 million (usd)' OR Revenue = '$5 to $10 billion (usd)')
    ORDER BY
        CASE Revenue
            WHEN '$10+ billion (usd)' THEN 1
            WHEN '$5 to $10 billion (usd)' THEN 2
            WHEN '$2 to $5 billion (usd)' THEN 3
            WHEN '$1 to $2 billion (usd)' THEN 4
            WHEN '$500 million to $1 billion (usd)' THEN 5
            WHEN '$100 to $500 million (usd)' THEN 6
            WHEN '$50 to $100 million (usd)' THEN 7
            WHEN '$25 to $50 million (usd)' THEN 8
            WHEN '$10 to $25 million (usd)' THEN 9
            WHEN '$5 to $10 million (usd)' THEN 10
            WHEN '$1 to $5 million (usd)' THEN 11
            WHEN 'less than $1 million (usd)' THEN 12
            ELSE 99
        END
    LIMIT 5
)
UNION ALL
SELECT * FROM(
    SELECT "Company Name", Size, Revenue
    FROM Companies
    WHERE Size = '5001 to 10000 employees'
    ORDER BY
        CASE Revenue
            WHEN '$10+ billion (usd)' THEN 1
            WHEN '$5 to $10 billion (usd)' THEN 2
            WHEN '$2 to $5 billion (usd)' THEN 3
            WHEN '$1 to $2 billion (usd)' THEN 4
            WHEN '$500 million to $1 billion (usd)' THEN 5
            WHEN '$100 to $500 million (usd)' THEN 6
            WHEN '$50 to $100 million (usd)' THEN 7
            WHEN '$25 to $50 million (usd)' THEN 8
            WHEN '$10 to $25 million (usd)' THEN 9
            WHEN '$5 to $10 million (usd)' THEN 10
            WHEN '$1 to $5 million (usd)' THEN 11
            WHEN 'less than $1 million (usd)' THEN 12
            ELSE 99
        END
    LIMIT 5
)
UNION ALL
SELECT * FROM(
    SELECT "Company Name", Size, Revenue
    FROM Companies
    WHERE Size = '1001 to 5000 employees'
    ORDER BY
        CASE Revenue
            WHEN '$10+ billion (usd)' THEN 1
            WHEN '$5 to $10 billion (usd)' THEN 2
            WHEN '$2 to $5 billion (usd)' THEN 3
            WHEN '$1 to $2 billion (usd)' THEN 4
            WHEN '$500 million to $1 billion (usd)' THEN 5
            WHEN '$100 to $500 million (usd)' THEN 6
            WHEN '$50 to $100 million (usd)' THEN 7
            WHEN '$25 to $50 million (usd)' THEN 8
            WHEN '$10 to $25 million (usd)' THEN 9
            WHEN '$5 to $10 million (usd)' THEN 10
            WHEN '$1 to $5 million (usd)' THEN 11
            WHEN 'less than $1 million (usd)' THEN 12
            ELSE 99
        END
    LIMIT 5
)
UNION ALL
SELECT * FROM(
    SELECT "Company Name", Size, Revenue
    FROM Companies
    WHERE Size = '501 to 1000 employees'
    ORDER BY
        CASE Revenue
            WHEN '$10+ billion (usd)' THEN 1
            WHEN '$5 to $10 billion (usd)' THEN 2
            WHEN '$2 to $5 billion (usd)' THEN 3
            WHEN '$1 to $2 billion (usd)' THEN 4
            WHEN '$500 million to $1 billion (usd)' THEN 5
            WHEN '$100 to $500 million (usd)' THEN 6
            WHEN '$50 to $100 million (usd)' THEN 7
            WHEN '$25 to $50 million (usd)' THEN 8
            WHEN '$10 to $25 million (usd)' THEN 9
            WHEN '$5 to $10 million (usd)' THEN 10
            WHEN '$1 to $5 million (usd)' THEN 11
            WHEN 'less than $1 million (usd)' THEN 12
            ELSE 99
        END
    LIMIT 5
)
UNION ALL
SELECT * FROM(
    SELECT "Company Name", Size, Revenue
    FROM Companies
    WHERE Size = '201 to 500 employees'
    ORDER BY
        CASE Revenue
            WHEN '$10+ billion (usd)' THEN 1
            WHEN '$5 to $10 billion (usd)' THEN 2
            WHEN '$2 to $5 billion (usd)' THEN 3
            WHEN '$1 to $2 billion (usd)' THEN 4
            WHEN '$500 million to $1 billion (usd)' THEN 5
            WHEN '$100 to $500 million (usd)' THEN 6
            WHEN '$50 to $100 million (usd)' THEN 7
            WHEN '$25 to $50 million (usd)' THEN 8
            WHEN '$10 to $25 million (usd)' THEN 9
            WHEN '$5 to $10 million (usd)' THEN 10
            WHEN '$1 to $5 million (usd)' THEN 11
            WHEN 'less than $1 million (usd)' THEN 12
            ELSE 99
        END
    LIMIT 5
)
UNION ALL
SELECT * FROM(
    SELECT "Company Name", Size, Revenue
    FROM Companies
    WHERE Size = '51 to 200 employees'
    ORDER BY
        CASE Revenue
            WHEN '$10+ billion (usd)' THEN 1
            WHEN '$5 to $10 billion (usd)' THEN 2
            WHEN '$2 to $5 billion (usd)' THEN 3
            WHEN '$1 to $2 billion (usd)' THEN 4
            WHEN '$500 million to $1 billion (usd)' THEN 5
            WHEN '$100 to $500 million (usd)' THEN 6
            WHEN '$50 to $100 million (usd)' THEN 7
            WHEN '$25 to $50 million (usd)' THEN 8
            WHEN '$10 to $25 million (usd)' THEN 9
            WHEN '$5 to $10 million (usd)' THEN 10
            WHEN '$1 to $5 million (usd)' THEN 11
            WHEN 'less than $1 million (usd)' THEN 12
            ELSE 99
        END
    LIMIT 5
)
UNION ALL
SELECT * FROM(
    SELECT "Company Name", Size, Revenue
    FROM Companies
    WHERE Size = '1 to 50 employees'
    ORDER BY
        CASE Revenue
            WHEN '$10+ billion (usd)' THEN 1
            WHEN '$5 to $10 billion (usd)' THEN 2
            WHEN '$2 to $5 billion (usd)' THEN 3
            WHEN '$1 to $2 billion (usd)' THEN 4
            WHEN '$500 million to $1 billion (usd)' THEN 5
            WHEN '$100 to $500 million (usd)' THEN 6
            WHEN '$50 to $100 million (usd)' THEN 7
            WHEN '$25 to $50 million (usd)' THEN 8
            WHEN '$10 to $25 million (usd)' THEN 9
            WHEN '$5 to $10 million (usd)' THEN 10
            WHEN '$1 to $5 million (usd)' THEN 11
            WHEN 'less than $1 million (usd)' THEN 12
            ELSE 99
        END
    LIMIT 5
)
;



CREATE VIEW Skills_Sector AS
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 1
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 2
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 3
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 4
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 5
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 6
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 7
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 8
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 9
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 10
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 11
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 12
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 13
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 14
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 15
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 16
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 17
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 18
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 19
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 20
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 21
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 22
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 23
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 24
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT Sectors.name AS "Sector", Skills.name AS "Skill", ROUND(AVG(Job_Offers."Salary Min ($ gross annual)"),2) AS "Average Salary Min ($ gross annual)", ROUND(AVG(Job_Offers."Salary Max ($ gross annual)"),2) AS "Average Salary Max ($ gross annual)"
    FROM Skills JOIN Skills_Job
        ON Skills.id = Skills_Job.skill_id
    JOIN Job_Offers 
        ON Skills_Job.job_id = Job_Offers.job_id
    JOIN Companies 
        ON Companies.id = Job_Offers.company_id
    JOIN Industries
        ON Industries.id = Companies.Industry_id
    JOIN Sectors
        ON Sectors.id = Industries.sector_id
    WHERE Industries.sector_id = 25
    GROUP BY Skills.id
    ORDER BY "Average Salary Max ($ gross annual)" DESC, "Average Salary Min ($ gross annual)" DESC
    LIMIT 1
);

-- INDEXES

CREATE INDEX index_Jobs_name ON Jobs(name);

CREATE INDEX index_DataScientist_Clean_Job_Title ON DataScientist_Clean("Job Title");

CREATE INDEX index_Skills_name ON Skills(name);

CREATE INDEX index_Skills_Job_skill_id ON Skills_Job(skill_id);

CREATE INDEX index_Job_Offers_job_id ON Job_Offers(job_id);

CREATE INDEX index_Job_Offers_company_id ON Job_Offers(company_id);





-- TRIGGERS
-- For automatically updating the database

CREATE TRIGGER trigger_updating_Skills_Job 
AFTER INSERT ON Jobs
BEGIN
    INSERT OR IGNORE INTO Skills_Job (job_id, skill_id) 
    SELECT NEW.id, Skills.id
    FROM Skills JOIN DataScientist_Clean
        ON (
        -- skill surrounded by spaces
        (' ' || DataScientist_Clean."Job Description" || ' ')
            LIKE '% ' || Skills.name || ' %'
        
        OR
        
        -- skill followed by coma
        (' ' || DataScientist_Clean."Job Description" || ' ')
            LIKE '% ' || Skills.name || ',%'
        
        OR
        
        -- skill followed by a dot
        (' ' || DataScientist_Clean."Job Description" || ' ')
            LIKE '% ' || Skills.name || '.%'
    );

END;

CREATE TRIGGER trigger_updating_database
AFTER INSERT ON DataScientist_Clean
BEGIN
    -- Updating Jobs
    INSERT OR IGNORE INTO Jobs(name)
    VALUES (NEW."Job Title");
    -- Updating Locations
    INSERT OR IGNORE INTO Locations(city, region)
    VALUES (
        TRIM(substr(NEW.Location, 1, instr(NEW.Location, ',') - 1)),
        TRIM(substr(NEW.Location, instr(NEW.Location, ',') + 1))
    );
    -- Updating Sectors
    INSERT OR IGNORE INTO Sectors(name)
    VALUES (NEW.Sector);
    -- Updating Industries
    INSERT OR IGNORE INTO Industries(name, sector_id)
    VALUES (
        NEW.Industry,
        (SELECT id FROM Sectors WHERE name = NEW.Sector) 
    );
    -- Updating Companies
    INSERT OR IGNORE INTO Companies(Rating, "Company name", Headquarters_location_id, Size, Founded, "Type of ownership", Industry_id, Revenue)
    VALUES (NEW.Rating,
            NEW."Company name",
            (SELECT id FROM Locations WHERE ((city || ', ' || region) = NEW.Headquarters OR region = NEW.Headquarters)), 
            NEW.Size,
            NEW.Founded, 
            NEW."Type of ownership", 
            (SELECT id FROM Industries WHERE name = NEW.Industry),
            NEW.Revenue);
    -- Updating Job_Offers
    INSERT OR IGNORE INTO Job_Offers(job_id, description, company_id, location_id, easy_apply, "Salary Max ($ gross annual)", "Salary Min ($ gross annual)")
    VALUES (
        (SELECT id FROM Jobs WHERE name = NEW."Job Title"),
        NEW."Job Description",
        (SELECT id FROM Companies WHERE "Company Name" = NEW."Company Name"), 
        (SELECT id FROM Locations WHERE (city || ', ' || region) = NEW.Location OR region = NEW.Location), 
        NEW."Easy Apply", 
        NEW."Salary Max ($ gross annual)", 
        NEW."Salary Min ($ gross annual)"
    );

END;


CREATE TRIGGER trigger_updating_Competitors
AFTER INSERT ON Companies
BEGIN
    INSERT OR IGNORE INTO Competitors_temp(Company_id, name, Competitors)
    VALUES(
        NEW.id, 
        NEW."Company Name", 
        (SELECT Competitors FROM DataScientist_Clean WHERE "Company Name" = NEW."Company Name")
    )
    ;

    INSERT OR IGNORE INTO Competitors(company1_id, company2_id)
    SELECT c1.Company_id, c2.Company_id
    FROM Competitors_temp c1
    JOIN Competitors_temp c2 
        ON ( 
            ',' || REPLACE(REPLACE(c2.Competitors, ', ', ','), ' ,', ',') || ','
            LIKE '%,' || c1.name || ',%'
            )
    WHERE c1.Company_id = NEW.id OR c2.Company_id = NEW.id
    ;
END;







