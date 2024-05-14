
select * 
from ultracleanedupdata_output

--How many states were in the race
select count (distinct state )
from ultracleanedupdata_output



--What was the average time of men vs women 

select gender,avg (Total_Minutes) as avg_time
from ultracleanedupdata_output
group by gender


--what are the young and oldest ages in the race by gender
select gender,min(age) as youngest, max(age) as oldest
from ultracleanedupdata_output
group by gender


--What was the average time for each age group
with age_buckets as 
(select Total_Minutes,
case 
	when age<30 then 'age_20-29'
	when age<40 then 'age_30-39'
	when age<50 then 'age_40-49'
	when age<60 then 'age_50-59'
	else 'age_60+'
end as age_group
from ultracleanedupdata_output
)
select age_group, avg(Total_Minutes)
from age_buckets
group by age_group

--Who were the top 3 male and females 
with gender_rank as 
(
select  rank() over (partition by gender order by Total_Minutes asc) as gen_rank,
fullname, gender , Total_Minutes
from ultracleanedupdata_output
)
select * 
from gender_rank
where gen_rank <4
order by Total_Minutes asc



