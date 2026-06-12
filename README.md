# California Licensed Healthcare Facility Analysis

## Project Overview

This project analyzes licensed healthcare facilities across California using a dataset sourced from **Data.gov**, an official U.S. government open data platform. Since the dataset comes from a government source, it provides real public healthcare facility information rather than a random sample dataset.

The main goal of this project is to understand how healthcare facilities are distributed across counties, how licensed bed capacity varies, and how emergency service availability differs by location.

## Why I Chose This Project

Healthcare access is an important real-world topic. By analyzing facility locations, bed capacity, facility types, and emergency service coverage, this project helps identify patterns in healthcare infrastructure across California.

This project also allowed me to practice a complete data analytics workflow, starting from data cleaning and ending with an interactive Power BI dashboard.

## Dataset Source

* Source: **Data.gov**
* Dataset: California Licensed Healthcare Facility Listing
* Data Type: Government open data
* Domain: Healthcare facilities, licensing, bed capacity, emergency service information

## Tools Used

* **Python / Pandas** – Data cleaning and preprocessing
* **PostgreSQL** – Storing the cleaned dataset
* **SQL** – Data analysis and view creation
* **Power BI** – Dashboard development and visualization

## Project Process

### 1. Data Collection

The dataset was collected from Data.gov, which provides official government open datasets. The data contains information about licensed healthcare facilities in California, including facility name, county, license type, facility status, bed count, and emergency service details.

### 2. Data Cleaning Using Python

I used Python and Pandas to clean the dataset before analysis. This included checking missing values, removing unnecessary columns, formatting column names, handling null values, and preparing the data for database import.

### 3. Data Storage in PostgreSQL

After cleaning the data, I imported it into PostgreSQL. This helped me organize the data properly and perform structured SQL analysis.

### 4. SQL Analysis

I used SQL to answer key business and healthcare access questions such as:

* Which counties have the highest number of facilities?
* Which counties have the highest licensed bed capacity?
* What facility types are most common?
* How many facilities provide emergency services?
* Which counties may have lower emergency service coverage?

### 5. SQL View Creation

I created SQL views to prepare summarized data for Power BI. These views helped simplify dashboard building and improved the structure of the analysis.

### 6. Power BI Dashboard Development

I built an interactive Power BI dashboard with multiple pages to present the findings clearly.

## Dashboard Pages

### Page 1: Statewide Overview

This page shows overall healthcare facility statistics, including total facilities, total beds, facility types, license categories, and facility status.

### Page 2: County Access & Capacity

This page focuses on county-level analysis. It shows which counties have the most facilities, highest bed capacity, top facilities by beds, and facility locations on a map.


## Key Findings

* The dataset contains **7,225 licensed healthcare facilities** across **57 counties** in California.
* **Los Angeles County** has the highest number of licensed healthcare facilities.
* **Mono County** has the lowest number of licensed healthcare facilities.
* The most common license category is **Home Health Agency**.
* Out of 7,225 facilities, **7,183 are open** and **42 are closed**.
* **Los Angeles County** has the highest licensed bed capacity, with **66,796 beds**.
* The facility with the highest bed count is **Department of State Hospital - Coalinga**.


## Outcome

This project demonstrates an end-to-end data analytics workflow using a real government healthcare dataset. It shows how raw public data can be cleaned, stored, analyzed, and transformed into meaningful dashboard insights using Python, SQL, PostgreSQL, and Power BI.
