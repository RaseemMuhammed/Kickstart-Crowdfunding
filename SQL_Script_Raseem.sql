# Q1 Extract Dates into standard format
SELECT 
    from_unixtime(created_at) AS created_date,
    from_unixtime(deadline) AS deadline_date,
    from_unixtime(launched_at) AS launched_date,
    from_unixtime(successful_at) AS successful_date,
    from_unixtime(state_changed_at) AS state_changed_date,
    from_unixtime(updated_at) AS updated_date
FROM projects;

#Q2 Extract Year,Month,Monthname,Quater,Week,Dayname,Weekday,Fm,Year_Month
ALTER TABLE projects ADD COLUMN created_date DATE;
UPDATE projects SET created_date = from_unixtime(created_at);
SELECT 
    created_date,
    YEAR(created_date) AS Year_value,
    MONTH(created_date) AS month_value,
    MONTHNAME(created_date) AS month_name,
    CONCAT('Q', QUARTER(created_date)) AS quarter_name,
    CONCAT(YEAR(created_date), '-', MONTH(created_date)) AS year_mon,
    WEEK(created_date) AS week_day_no,
    DAYNAME(created_date) AS week_day_name
FROM projects;

SELECT 
    created_date,
    DATE_FORMAT(created_date, '%M') AS month_name,
    CONCAT('FM', (MONTH(created_date) - 3 + 12) % 12 + 1) AS financial_month
FROM projects;
alter table projects add column year_value int,
add column month_value int,
add column month_name varchar(50),
add column quarter_name varchar(50),
add column financial_month varchar(50);
alter table projects
add column week_day_no int;
alter table projects
add column week_day_name varchar(50);
alter table projects
add column year_mon varchar(50);
update projects set year_value=year(created_date);
update projects set month_value=month(created_date);
update projects set month_name=monthname(created_date);
update projects set quarter_name=concat("Q",quarter(created_date));
update projects set year_mon=concat(year(created_date),"-",month(created_date));
UPDATE projects
SET financial_month = 
    CONCAT('FM', (MONTH(created_date) - 3 + 12) % 12 + 1)
WHERE financial_month IS NULL;
update projects set week_day_no=week(created_date);
update projects set week_day_name=dayname(created_date);

SELECT 
    financial_month,
    CASE 
        WHEN financial_month BETWEEN "FM1" AND "FM3" THEN 'Q1'
        WHEN financial_month BETWEEN "FM4" AND "FM6" THEN 'Q2'
        WHEN financial_month BETWEEN "FM7" AND "FM9" THEN 'Q3'
        WHEN financial_month BETWEEN "FM10" AND "FM12" THEN 'Q4'
    END AS financial_quarter
FROM projects;
alter table projects
add column financial_quarter varchar(50);
UPDATE projects
SET financial_quarter = 
    CASE 
        WHEN financial_month IN ('FM1', 'FM2', 'FM3') THEN 'FQ-1'
        WHEN financial_month IN ('FM4', 'FM5', 'FM6') THEN 'FQ-2'
        WHEN financial_month IN ('FM7', 'FM8', 'FM9') THEN 'FQ-3'
        WHEN financial_month IN ('FM10', 'FM11', 'FM12') THEN 'FQ-4'
    END;
    #Q3 main table calender
create view calender as select year_value,month_value,month_name,week_day_no,week_day_name,financial_month,financial_quarter,quarter_name from projects;
select * from calender;

		#Q4 Convert the Goal amount into USD using the Static USD Rate.
Select goal,
	static_usd_rate,
    round(goal * static_usd_rate,2) as Goal_In_USD
from projects;

	#Q5 overview KPIS: A) Total Number of Projects 
select count(ProjectID) as "Total Number of Projects" from projects;
			# Q5 B) Total Number of Projects based on outcome
select state, count(projectID) as "Total Number of Projects"
from projects
group by state;

		#Q5 C) Total number of projects based on location
select country, count(ProjectID) as "Total Number of Projects"
from projects
group by country;

		#Q5 D) Total number of projects based on Category
select category_id,count(ProjectID)  as "Total Number of Projects"
from projects
group by category_id;
		#Q5 E) Total number of project created by year, Quarter, Month
select year(FROM_UNIXTIME(created_at)) AS Year ,
concat("Q",quarter(FROM_UNIXTIME(created_at))) AS Quarter,
Month(FROM_UNIXTIME(created_at)) AS Month,
count(projectID) as "Total Number of Projects" from projects
group by Year,Quarter,Month
order by Year desc;

	#Q6. Successful Project based on: A) Amount Raised
select concat(Round(sum(CASE 
WHEN state = 'successful' THEN pledged
ELSE 0
END)  / 1000000000 ,2),"B") as AmountRaised 
from projects;

		#Q6 B)Number of Backers
select count(backers_count) "Number of Backers" from projects 
where state = "successful";

		#Q6 C) Avg no. of Days taken
select avg(datediff(FROM_UNIXTIME(successful_at),FROM_UNIXTIME(created_at))) "Avg. days Taken"
from projects
where state = "successful";

		#Q7. Top Successful Projects : A) Based on Number of Backers
select name, backers_count from projects
order by 2 desc
limit 10;

		# Q7 B) based on Amount Raised
select name, 
case 
when state = "successful" then pledged
else 0
end as AmountRaised
from projects
order by 2 desc
limit 10;

		#Q8. A)Percentage of Successful Projects overall
select concat((sum(case when state = "successful" 
then 1 else 0 end)/ count(*)) * 100,"%") as percentage_successful
from projects;

		#Q8 B) Percentage of successful projects by category 
select category_id ,concat((sum(case when state = "successful" 
then 1 else 0 end)/ count(*)) * 100,"%") as percentage_successful 
from projects
group by category_id;

		#Q8 C)percentage of succesfulproject by year, Quarter, month
select year(FROM_UNIXTIME(created_at)) AS Year ,
concat("Q",quarter(FROM_UNIXTIME(created_at))) AS Quarter,
Month(FROM_UNIXTIME(created_at)) AS Month,
concat((sum(case when state = "successful" 
then 1 else 0 end)/ count(*)) * 100,"%") as percentage_successful
from projects
group by Year,Quarter,Month;

		#Q8 D) percentage of successful projects by goal range
select 
case 
when goal < 2501 then "0-2500"
when goal < 5001 then "0-5000"
when goal < 10001 then "0-10000"
when goal < 20001 then "0-20000"
when goal < 50001 then "0-50000"
when goal < 100001 then "0-100000"
when goal < 200001 then "0-200000"
when goal > 200000 then "200001+"  
end as GoalRange,
concat((sum(case when state = "successful" 
then 1 else 0 end)/ count(*)) * 100,"%") as percentage_successful
from projects
group by goalrange;