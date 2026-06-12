SELECT current_database();
DROP TABLE IF EXISTS healthcare_data;

CREATE TABLE healthcare_data (
    oshpd_id TEXT,
    facility_name TEXT,
    license_number TEXT,
    facility_level TEXT,
    dba_address TEXT,
    dba_city TEXT,
    dba_zip_code TEXT,
    county_code TEXT,
    county_name TEXT,
    er_service_level TEXT,
    total_beds NUMERIC,
    facility_status TEXT,
    facility_start_date DATE,
    license_type TEXT,
    license_category TEXT,
    latitude NUMERIC(10,6),
    longitude NUMERIC(10,6),
    facility_start_year INTEGER,
    has_er_service TEXT,
    is_open TEXT,
    oshpd_facility_type_code TEXT,
    oshpd_county_code_from_id TEXT,
    oshpd_random_id TEXT,
    county_code_clean TEXT,
    county_code_match TEXT
);
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'healthcare_data'
ORDER BY ordinal_position;

-------DATA ANALYSIS------
select count(*) as total_rows from healthcare_data
select * from healthcare_data limit 40
-----how many total healthcare facilities are in the dataset?--
select  distinct count(facility_name) as total_hospitals from healthcare_data 
--how many counties are covered in the dataset?
select  count(distinct county_name)as total_counties 
from healthcare_data
--which top 5 counties have the highest number of facilities?
select  county_name ,count(facility_name) as total_count 
from healthcare_data 
group by distinct county_name 
order by total_count desc
limit 5
---which top 5 counties have the lowest number of facilities?
select county_name ,count(facility_name) as total_facilities
from healthcare_data 
group by distinct county_name 
order by total_facilities asc
limit 5
-----what are the most common licence categories 
update healthcare_data
set license_category = 'not specified'
where license_category is null;
select license_category,count(*) as total_facilities
from healthcare_data
group by license_category
order by total_facilities desc;
-----verifyting er_service coloumn--
update healthcare_data 
set er_service_level = 'not specified'
where er_service_level is null;
select distinct er_service_level from healthcare_data
-----what are the main healthcare facility types
update healthcare_data 
set license_type= 'not specified'
where license_type is null;
select distinct license_type from healthcare_data 
----
select * from healthcare_Data limit 2
select is_open ,count(*) as total_count 
from healthcare_data 
group by distinct is_open 
order by total_count desc
---- facility status distribution 
select distinct facility_status,count(*) as total_facilities
from healthcare_data 
group by facility_status
---
select distinct license_type,count(*) as suspended_count from healthcare_data
where is_open='No'
group by license_type
order by suspended_count desc
-----BED CAPACITY ANALYSIS -----
select distinct county_name ,sum(total_beds) as Bed_Capacity 
from healthcare_data
group by county_name 
order by Bed_Capacity desc
-----which facility types contribute most beds 
select * from healthcare_data
select license_type,count(*) as facilities_with_beds,sum(total_beds) as total_beds,
round(avg(total_beds), 2) as average_beds, max(total_beds) as maximum_beds
from healthcare_data
where total_beds is not null
group by license_type
order by total_beds desc;
----top 10 largest facilities by bed count 
select facility_name, sum(total_beds) as bed_count 
from healthcare_data 
where total_beds is not null
group by facility_name  
order by bed_count desc
limit 10 
----
select county_name ,count(distinct facility_name) as total_facilities,
sum(total_beds)as bed_count ,
ROUND(SUM(COALESCE(total_beds, 0)) * 1.0 / COUNT(*), 2) AS beds_per_facility
from healthcare_data
group by county_name 
having count(*)>=20
order by beds_per_facility asc
----- which licence categories have highest average bed count 

select license_category,
round(avg(total_beds),2) as total_beds
from healthcare_data 
where total_beds is not null
group by license_category

------Emergency service analysis--
select * from healthcare_data
select has_er_service ,count(*) as ER_Srevice_Count
from healthcare_data
where has_er_service ='Yes'
group by has_er_service

select er_service_level,count(*)as total_facilities
from healthcare_data
group by er_service_level 

---no er services 
SELECT county_name
FROM healthcare_data
GROUP BY county_name
HAVING SUM(CASE WHEN has_er_service = 'Yes' THEN 1 ELSE 0 END) = 0
ORDER BY county_name;
----Which counties have many facilities but low ER coverage?
select county_name ,
count(*) as total_facilities,
sum(case when has_er_service ='yes' then 1 else 0 end ) as er_facilities,
round(sum(case when has_er_Service ='yes' then 1 else 0 end)*100.0/count(*),2)as er_percentage
from healthcare_data 
group by county_name 
having count(*) >=50
order by er_percentage asc;
----Hospital, clinic, and long-term care analysis
---which counties have most hospitals
select county_name,count(facility_name) as total_facilities
from healthcare_data 
group by county_name 
----
select county_name, count(*) as total_clinics
from healthcare_data 
where license_type ='Clinic'
group by county_name 
order by total_clinics desc

select * from healthcare_data

--which counties contribute the highest share of total facilities statewide?
---ranking and percentage analysis
with facility_count as(
select county_name,count(*)as total_facilities
from healthcare_data
group by county_name 
order by total_facilities desc
)
select county_name,total_facilities,
dense_rank() over(order by total_facilities desc) as county_rank
from facility_count
order by county_rank
-- What are the top 10 counties by facility count
with county_count as(
select county_name,count(*)as total_counts
from healthcare_data
group by county_name 
)
select county_name , total_counts,
dense_rank() over(order by total_counts desc) as county_rank
from county_count
group by county_name,total_counts
order by county_rank
--------------------------views----------------------------------
----------kpi summary-------------
create or replace view statewide_kpi_summary as
select
    count(*) as total_facilities,
    count(distinct county_name) as total_counties,
    count(distinct license_type) as total_license_types,
    count(distinct license_category) as total_license_categories,
    sum(case when lower(trim(is_open)) = 'yes' then 1 else 0 end) as open_facilities,
    sum(case when lower(trim(is_open)) <> 'yes' then 1 else 0 end) as non_open_facilities,
    sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) as er_service_facilities,
    sum(case when lower(trim(has_er_service)) <> 'yes' then 1 else 0 end) as non_er_facilities,
    sum(total_beds) as total_beds,
    count(total_beds) as facilities_with_beds,
    count(*) - count(total_beds) as facilities_missing_beds,
    round(avg(total_beds), 2) as average_beds_for_bed_facilities,
    round(
        sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) * 100.0 / count(*),
        2
    ) as er_coverage_percentage,
    round(
        sum(case when lower(trim(is_open)) = 'yes' then 1 else 0 end) * 100.0 / count(*),
        2
    ) as open_facility_percentage
from healthcare_data;
select * from statewide_kpi_summary
----------------facilities by license type
create or replace view facilities_by_license_type as
select
    license_type,
    count(*) as total_facilities,
    sum(case when lower(trim(is_open)) = 'yes' then 1 else 0 end) as open_facilities,
    sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) as er_service_facilities,
    sum(total_beds) as total_beds,
    count(total_beds) as facilities_with_beds,
    round(avg(total_beds), 2) as average_beds,
    round(count(*) * 100.0 / sum(count(*)) over (), 2) as facility_share_percentage,
    dense_rank() over (order by count(*) desc) as facility_count_rank
from healthcare_data
group by license_type
order by total_facilities desc;
select * from vw_facilities_by_license_type;
-------facilities by license category
create or replace view facilities_by_license_category as
select
    license_category,
    license_type,
    count(*) as total_facilities,
    sum(case when lower(trim(is_open)) = 'yes' then 1 else 0 end) as open_facilities,
    sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) as er_service_facilities,
    sum(total_beds) as total_beds,
    count(total_beds) as facilities_with_beds,
    round(count(*) * 100.0 / sum(count(*)) over (), 2) as facility_share_percentage,
    dense_rank() over (order by count(*) desc) as category_rank
from healthcare_data
group by license_category, license_type
order by total_facilities desc;
create or replace view vw_facilities_by_license_category as
select
    license_category,
    license_type,
    count(*) as total_facilities,
    sum(case when lower(trim(is_open)) = 'yes' then 1 else 0 end) as open_facilities,
    sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) as er_service_facilities,
    sum(total_beds) as total_beds,
    count(total_beds) as facilities_with_beds,
    round(count(*) * 100.0 / sum(count(*)) over (), 2) as facility_share_percentage,
    dense_rank() over (order by count(*) desc) as category_rank
from healthcare_data
group by license_category, license_type
order by total_facilities desc;
select * from vw_facilities_by_license_category limit 20;
------------------facilities by county
create or replace view facilities_by_county as
select
    county_name,
    count(*) as total_facilities,
    sum(case when lower(trim(is_open)) = 'yes' then 1 else 0 end) as open_facilities,
    sum(case when lower(trim(is_open)) <> 'yes' then 1 else 0 end) as non_open_facilities,
    sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) as er_service_facilities,
    sum(total_beds) as total_beds,
    count(total_beds) as facilities_with_beds,
    round(avg(total_beds), 2) as average_beds,
    round(
        sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) * 100.0 / count(*),
        2
    ) as er_coverage_percentage,
    round(
        sum(total_beds) * 1.0 / nullif(count(total_beds), 0),
        2
    ) as beds_per_bed_facility,
    dense_rank() over (order by count(*) desc) as county_facility_rank,
    dense_rank() over (order by sum(total_beds) desc nulls last) as county_bed_rank
from healthcare_data
group by county_name
order by total_facilities desc;
select * from facilities_by_county
----top facilities bed count
create or replace view top_facilities_by_beds as
select
    facility_name,
    county_name,
    dba_city,
    license_type,
    license_category,
    facility_status,
    er_service_level,
    total_beds,
    dense_rank() over (order by total_beds desc) as bed_rank
from healthcare_data
where total_beds is not null
order by total_beds desc;
-------er service by county
create or replace view er_service_by_county as
select
    county_name,
    count(*) as total_facilities,
    sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) as er_service_facilities,
    sum(case when lower(trim(has_er_service)) <> 'yes' then 1 else 0 end) as non_er_facilities,
    round(
        sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) * 100.0 / count(*),
        2
    ) as er_coverage_percentage,
    dense_rank() over (
        order by 
        round(
            sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) * 100.0 / count(*),
            2
        ) asc
    ) as low_er_coverage_rank
from healthcare_data
group by county_name
order by er_coverage_percentage asc;
-----er service level summary
create or replace view er_service_level_summary as
select
    er_service_level,
    count(*) as total_facilities,
    sum(total_beds) as total_beds,
    round(count(*) * 100.0 / sum(count(*)) over (), 2) as percentage_of_facilities
from healthcare_data
group by er_service_level
order by total_facilities desc;
select * from vw_er_service_level_summary;
---facility status summary
create or replace view facility_status_summary as
select
    facility_status,
    count(*) as total_facilities,
    round(count(*) * 100.0 / sum(count(*)) over (), 2) as status_percentage
from healthcare_data
group by facility_status
order by total_facilities desc;
select * from facility_status_summary;
------facility start year trend
create or replace view facility_start_year_trend as
select
    facility_start_year,
    count(*) as facilities_started,
    sum(count(*)) over (order by facility_start_year) as cumulative_facilities_started
from healthcare_data
where facility_start_year is not null
group by facility_start_year
order by facility_start_year;
select * from facility_start_year_trend;
----county access gap analysis
create or replace view county_access_gap_analysis as
with county_summary as (
select county_name,count(*) as total_facilities,sum(total_beds) as total_beds,
count(total_beds) as facilities_with_beds,
sum(case when lower(trim(has_er_service)) = 'yes' then 1 else 0 end) as er_service_facilities
from healthcare_data
group by county_name
),
county_metrics as (
 select county_name,total_facilities,total_beds,facilities_with_beds,
er_service_facilities,round(total_beds * 1.0 / nullif(facilities_with_beds, 0), 2) as beds_per_bed_facility,
round(er_service_facilities * 100.0 / total_facilities, 2) as er_coverage_percentage
 from county_summary
)
select
county_name,total_facilities,total_beds,facilities_with_beds,er_service_facilities,beds_per_bed_facility, er_coverage_percentage,
dense_rank() over (order by total_facilities desc) as facility_count_rank,
dense_rank() over (order by total_beds desc nulls last) as bed_capacity_rank,
dense_rank() over (order by er_coverage_percentage asc) as low_er_coverage_rank,
case
when total_facilities >= 20
and er_coverage_percentage < 5
and coalesce(beds_per_bed_facility, 0) < 50
then 'high access gap risk'
when er_coverage_percentage < 10
or coalesce(beds_per_bed_facility, 0) < 75
then 'moderate access gap risk'
else 'lower access gap risk'
end as access_gap_category
from county_metrics
order by access_gap_category, er_coverage_percentage asc;
select * from county_access_gap_analysis;