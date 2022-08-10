--Inspecting data
select * from dbo.sales_data_sample;

--Checking unique values 
select distinct STATUS from dbo.sales_data_sample; -- nice one to plot
select distinct YEAR_ID from dbo.sales_data_sample;
select distinct PRODUCTLINE from dbo.sales_data_sample;-- nice to plot
select distinct COUNTRY from dbo.sales_data_sample;--nice to plot
select distinct DEALSIZE from dbo.sales_data_sample;--nice to plot
select distinct TERRITORY from dbo.sales_data_sample;--nice to plot 

--Analysis 
--Let start by grouping sales by product line 

select PRODUCTLINE, sum(SALES) Revenue 
from dbo.sales_data_sample
group by PRODUCTLINE 
order by 2 desc;


-- Sales by year
select YEAR_ID , sum(SALES) Revenue 
from dbo.sales_data_sample
group by YEAR_ID 
order by 2 desc;

-- How many months are included in sum
select distinct MONTH_ID 
from dbo.sales_data_sample
where YEAR_ID = 2005;

--Sales by size
select DEALSIZE , sum(SALES) Revenue 
from dbo.sales_data_sample
group by DEALSIZE 
order by 2 desc;

--Best month for sales in any given yselect YEAR_ID , sum(SALES) Revenue 
select MONTH_ID , sum(SALES) Revenue, count(ORDERNUMBER) Frequency 
from dbo.sales_data_sample
where YEAR_ID = 2004 -- change year to see for specific year
group by MONTH_ID
order by 2 desc;

--It seems November is the most profitable month,so what items are sold? 
select MONTH_ID , PRODUCTLINE,sum(SALES) Revenue, count(ORDERNUMBER) Frequency 
from dbo.sales_data_sample
where YEAR_ID = 2004 -- change year to see for specific year
group by MONTH_ID, PRODUCTLINE
order by 3 desc;

select MONTH_ID ,PRODUCTLINE,sum(SALES) Revenue, count(ORDERNUMBER) Frequency 
from dbo.sales_data_sample
where YEAR_ID = 2004 and MONTH_ID = 11 -- change year to see for specific year
group by MONTH_ID,PRODUCTLINE
order by 3 desc; 


--Who is our best customer (This could be best answered with RFM) and we will create a CTE  and store our result as a temp table

DROP TABLE IF EXISTS #rfm

;with RFM as 
(	select 
		CUSTOMERNAME, 
		sum(SALES) MonetaryValue,
		avg(SALES) AvgMontetaryValue,
		count(ORDERNUMBER) Frequency,
		max([ORDERDATE]) last_order_date,
		(select max(ORDERDATE) from dbo.sales_data_sample) max_order_date,
		DATEDIFF(DD, max([ORDERDATE]), (select max(ORDERDATE) from dbo.sales_data_sample)) Recency
	from dbo.sales_data_sample
	group by CUSTOMERNAME
),

rfm_calc as 
(
--We group our values into quadrants based on recency, frequency and AvgMontetaryValue
	select r.*,
		NTILE(4) over(order by Recency desc) rfm_recency,
		NTILE(4) over(order by Frequency) rfm_frequency,
		NTILE(4) over(order by MonetaryValue) rfm_monetary
	from RFM r

)

select
	c.*,rfm_recency + rfm_frequency + rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) +cast(rfm_monetary as varchar) as rfm_cell_string
into #rfm
from rfm_calc c

select CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
end rfm_segment
from #rfm;


--What products are most often sold together
--select * from dbo.sales_data_sample where ORDERNUMBER = 10411;


select distinct ORDERNUMBER,STUFF(

	(select ',' + PRODUCTCODE
	from dbo.sales_data_sample p
	where ORDERNUMBER in (

			select ORDERNUMBER 
			from (
				select ORDERNUMBER, count(*) rn
				from sales_data_sample
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3 -- you can chnage this number for how many products were purchased together 
			)
			and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path ('')),1,1,'') ProductCodes


from dbo.sales_data_sample s
order by 2 desc