# data-job-market-sql-database
This project builds a complete SQL database designed to analyze the job market for data‑related roles using real job postings scraped from Glassdoor. The repository includes the original dataset, the full relational schema, analytical SQL queries, the ER diagram, and a final report with charts and insights.

1. Project Overview:

The goal of this project is to model, clean, and analyze a dataset of real job offers for positions such as Data Scientist, Data Analyst, Data Engineer, and Machine Learning Engineer. The database structure makes it possible to explore which skills are most in demand, how salaries vary across roles, which sectors publish the most offers, and how companies compare in terms of ratings and compensation. The analysis is entirely SQL‑based, from data modeling to insight extraction.

2. Repository Contents:

- DataScientist.csv
Original dataset containing real Glassdoor job postings. This file serves as the raw source used to build and normalize the database.

- schema.sql
SQL script that creates the full relational database, including tables, primary and foreign keys, indexes, and triggers that automatically update the schema when new job offers are inserted.

- queries.sql
Collection of analytical SQL queries used to answer key questions about the job market, such as skill demand, salary patterns, job frequency, sector distribution, and company comparisons.

- ER_Diagram.pdf
Entity–Relationship Diagram showing the structure of the database and the relationships between skills, jobs, companies, industries, sectors, locations, and job offers.

- Report_Data‑Driven_Insights_on_the_Data_Job_Market.docx
A complete summary of the analysis, including charts, insights, and data‑driven recommendations for job seekers and companies.

3. Database Structure:

The database models the main components of the data job market:
Skills, Jobs, Companies, Industries, Sectors, Locations, Job_Offers, Skills_Job, and Competitors.
The schema is normalized and optimized with indexes to improve query performance.

4. Analysis and Insights:

Using SQL queries, the project explores:
- The most requested skills in data‑related job postings
- The highest‑paid skills and the most “optimal” ones (high demand + strong salaries)
- The most common job titles
- Sector and industry distribution of job offers
- Company ratings and salary patterns
- Skill requirements by sector
The final report includes visual charts that summarize these findings and highlights several practical actions that job seekers and companies can take based on the results.

5. Purpose of the Project:

This project demonstrates:
- Relational database design and normalization
- SQL proficiency (DDL, DML, joins, aggregation, indexing, triggers)
- Data cleaning and preparation
- Analytical thinking applied to real‑world data
- Clear communication of insights through reports and visuals
  
It provides a structured, data‑driven view of the current job market for data professionals.
