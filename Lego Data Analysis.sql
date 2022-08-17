--1
-- What is the total number of parts per theme 
--Create view

/*create view dbo.analytics_main as 

select s.set_num, s.name as set_name, s.year, cast(s.num_parts as numeric) num_parts, t.name as theme_name, t.parent_id, p.name as parent_theme_name
from dbo.sets s
left join dbo.themes t 
	on s.theme_id = t.id
left join dbo.themes p
	on t.parent_id = p.id
*/


select theme_name, sum(num_parts) as total_num_parts 
from dbo.analytics_main
--where parent_theme_name is not null
group by theme_name
order by 2 desc;

--2
--What is the total number of parts per year?

select year, sum(num_parts) as total_num_parts 
from dbo.analytics_main
where parent_theme_name is not null
group by year
order by 2 desc;





--3
--How many sets were created in each century in the dataset

/* ALTER view [dbo].[analytics_main] as 

select s.set_num, s.name as set_name, s.year, cast(s.num_parts as numeric) num_parts, t.name as theme_name, t.parent_id, p.name as parent_theme_name,
case 
	when s.year between  1901 and 2000 then '20th_century'
	when s.year between  2001 and 2100 then '21st_century'
end 
as Century
from dbo.sets s
left join dbo.themes t 
	on s.theme_id = t.id
left join dbo.themes p
	on t.parent_id = p.id
GO
*/

select * from dbo.analytics_main;

select Century, count(set_num) as total_set_num
from dbo.analytics_main
where parent_theme_name is not null
group by Century;



--3
--What percentage of sets ever released in the 21st century were trains themed 
--CREATE A cte

with cte as 
(
	select Century, theme_name, count(set_num) as total_set_num
	from analytics_main
	where Century = '21st_century'
	group by Century, theme_name

)

select sum(total_set_num), sum(Percentage)
from(
	select Century, theme_name, total_set_num , sum(total_set_num) over() as total, cast(1.00 * total_set_num/sum(total_set_num) over() as decimal(5,4))*100 Percentage
	from cte
	--order by 3 desc;
) m
where theme_name like '%train%'
	


---5----
----What was the popular theme by year in terms of sets released in the 21st century 


select year, theme_name, total_set_num
from (
	select year, theme_name, count(set_num) total_set_num, ROW_NUMBER() over (partition by year order by count(set_num) desc) rn
	from analytics_main
	where Century = '21st_century' AND parent_theme_name IS NOT NULL
	group by year, theme_name
) m
where rn = 1
order by year desc



---6---
---what is the most produced color of lego ever in terms of quantity of parts 


select color_name , sum(quantity) as quantity_of_parts
from 
(
	select 
		inv.color_id, inv.inventory_id, inv.part_num, cast(inv.quantity as numeric) quantity, c.name as color_name, c.rgb as part_name, p.part_material, pc.name as category_name
	from inventory_parts inv 
	inner join colors c
		on inv.color_id = c.id
	inner join parts p 
		on inv.part_num = p.part_num
	inner join part_categories pc 
		on part_cat_id = pc.id
) 

main
group by color_name
order by 2 desc