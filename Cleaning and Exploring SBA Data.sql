DROP Table if exists sba_nacis_sector_codes_description;
select *
into sba_nacis_sector_codes_description
FROM
(
	SELECT [NAICS_Industry_Description],
			iif([NAICS_Industry_Description] like '%–%',substring([NAICS_Industry_Description],8,2),'') LookupCodes
			--,case when [NAICS_Industry_Description] like '%–%'then substring([NAICS_Industry_Description],8,2) end LookupCodes_case
			,iif([NAICS_Industry_Description] like '%–%' ,ltrim(substring([NAICS_Industry_Description],CHARINDEX('–', NAICS_Industry_Description)+1,len(NAICS_Industry_Description))),'') Sector
	  FROM [PortfolioDb].[dbo].[sba_industry_standards]
	  where NAICS_Codes= ' '
) main 
where LookupCodes !=''



SELECT [NAICS_Industry_Description]
      ,[LookupCodes_if]
      ,[Sector]
  FROM [PortfolioDb].[dbo].[sba_nacis_sector_codes_description]
  order by LookupCodes;

  insert into sba_nacis_sector_codes_description values 
	('Sector 31 – 33 – Manufacturing',32,'Manufacturing'),
	('Sector 31 – 33 – Manufacturing',33,'Manufacturing'),
	('Sector 44 - 45 – Retail Trade',45,'Retail Trade'),
	('Sector 48 - 49 – Transportation and Warehousing',49,'Transportation and Warehousing');

update dbo.sba_nacis_sector_codes_description
set Sector = 'Manufacturing' 
where LookupCodes = 31;

SELECT *
  FROM [PortfolioDb].[dbo].[sba_nacis_sector_codes_description]
  order by LookupCodes;



--SELECT *
  --FROM [PortfolioDb].[dbo].[sba_public_data]


---What is the summary of all approved PPP loans 

select year(DateApproved) year_approved,
	count(LoanNumber) Number_of_Approved, 
		sum(InitialApprovalAmount) Approved_Amount,
		AVG(InitialApprovalAmount) Average_loan_size
		from sba_public_data
	where 
		year(DateApproved) =2020
	group by year(DateApproved)

union

select year(DateApproved) year_approved,
	count(LoanNumber) Number_of_Approved, 
		sum(InitialApprovalAmount) Approved_Amount,
		AVG(InitialApprovalAmount) Average_loan_size
		from sba_public_data
	where 
		year(DateApproved) =2021
	group by year(DateApproved)

order by year_approved desc;

--11468411

--796817102562.643

--69479.2942599148






---What is the summary of all approved PPP loans 

select count(distinct OriginatingLender) OriginatingLender,
		year(DateApproved) year_approved,
	count(LoanNumber) Number_of_Approved, 
		sum(InitialApprovalAmount) Approved_Amount,
		AVG(InitialApprovalAmount) Average_loan_size
		from sba_public_data
	where 
		year(DateApproved) =2020
		group by year(DateApproved)
	
union

select count(distinct OriginatingLender) OriginatingLender,
		year(DateApproved) year_approved,
	count(LoanNumber) Number_of_Approved, 
		sum(InitialApprovalAmount) Approved_Amount,
		AVG(InitialApprovalAmount) Average_loan_size
		from sba_public_data
	where 
		year(DateApproved) =2021
		group by year(DateApproved)


---Top 15 Originating Lenders by loan cout, total amount and average in 2020 and 2021 

select top 15 OriginatingLender,
	count(LoanNumber) Number_of_Approved, 
	sum(InitialApprovalAmount) Approved_Amount,
	AVG(InitialApprovalAmount) Average_loan_size
from 
	sba_public_data
where 
 year(DateApproved) =2021
 group by 
	OriginatingLender
order by 3 desc;


select top 15 OriginatingLender,
	count(LoanNumber) Number_of_Approved, 
	sum(InitialApprovalAmount) Approved_Amount,
	AVG(InitialApprovalAmount) Average_loan_size
from 
	sba_public_data
where 
 year(DateApproved) =2020
 group by 
	OriginatingLender
order by 3 desc;


--Top 20 Industries that received the PPP loan in 2021 and 2020
--2020
select top 20 d.Sector,
	count(LoanNumber) Number_of_Approved, 
	sum(InitialApprovalAmount) Approved_Amount,
	AVG(InitialApprovalAmount) Average_loan_size
from 
	sba_public_data p
inner join sba_nacis_sector_codes_description d
	on left(p.NAICSCode,2 ) = d.LookupCodes
where 
 year(DateApproved) =2020
 group by 
	d.Sector
order by 3 desc;


--68,116,275,711.7989

--2021

select top 20 d.Sector,
	count(LoanNumber) Number_of_Approved, 
	sum(InitialApprovalAmount) Approved_Amount,
	AVG(InitialApprovalAmount) Average_loan_size
from 
	sba_public_data p
inner join sba_nacis_sector_codes_description d
	on left(p.NAICSCode,2 ) = d.LookupCodes
where 
 year(DateApproved) =2021
 group by 
	d.Sector
order by 3 desc;


with cte as 
(
select top 20 d.Sector,
	count(LoanNumber) Number_of_Approved, 
	sum(InitialApprovalAmount) Approved_Amount,
	AVG(InitialApprovalAmount) Average_loan_size
from 
	sba_public_data p
inner join sba_nacis_sector_codes_description d
	on left(p.NAICSCode,2 ) = d.LookupCodes
where 
 year(DateApproved) =2020
 group by 
	d.Sector
--order by 3 desc;
)
--40,969,946,876.1221

select sector, Number_of_Approved, Approved_Amount,Average_loan_size,
Approved_Amount/SUM(Approved_Amount) over() * 100 Percent_by_amount
from cte
order by 3 desc;





--How much of the PPP loans in 2021 have been fully forgiven 

select
	count(LoanNumber) Number_of_Approved, 
	sum(CurrentApprovalAmount) Current_Approved_Amount,
	AVG(CurrentApprovalAmount) Current_Average_loan_size,
	sum(ForgivenessAmount) Amount_Forgiven,
	sum(ForgivenessAmount)/sum(CurrentApprovalAmount) * 100 as percent_Forgiven
from 
	sba_public_data p
inner join sba_nacis_sector_codes_description d
	on left(p.NAICSCode,2 ) = d.LookupCodes
where 
 year(DateApproved) =2021

order by 3 desc;

---Current_Approved_Amount = 270,826,301,172.408
--- Amount_Forgiven = 239,309,760,027.528
--- percent_Forgiven = 88.362821111375






select
	count(LoanNumber) Number_of_Approved, 
	sum(CurrentApprovalAmount) Current_Approved_Amount,
	AVG(CurrentApprovalAmount) Current_Average_loan_size,
	sum(ForgivenessAmount) Amount_Forgiven,
	sum(ForgivenessAmount)/sum(CurrentApprovalAmount) * 100 as percent_Forgiven
from 
	sba_public_data p
inner join sba_nacis_sector_codes_description d
	on left(p.NAICSCode,2 ) = d.LookupCodes
where 
 year(DateApproved) =2020

order by 3 desc;

---Current_Approved_Amount = 512,264,603,306.066
--- Amount_Forgiven = 493,830,834,400.671
--- percent_Forgiven = 96.4015142201069



--- Year, Month with highest PPP loans approved


select 
		year(DateApproved) year_approved,
		month(DateApproved) month_approved,
	count(LoanNumber) Number_of_Approved, 
		sum(InitialApprovalAmount) Total_Net_Dollars,
		AVG(InitialApprovalAmount) Average_loan_size
from 
	sba_public_data
group by 
	year(DateApproved),
	month(DateApproved)
order by 4 desc;


--Visualize Data for Tableau

Create view ppp_main as 

select
	d.Sector,
	year(DateApproved) year_approved,
	month(DateApproved) month_approved,
	OriginatingLender,
	BorrowerState,
	Race,
	Gender,
	Ethnicity,

	count(LoanNumber) Number_of_Approved, 

	sum(CurrentApprovalAmount) Current_Approved_Amount,
	AVG(CurrentApprovalAmount) Current_Average_loan_size,
	sum(ForgivenessAmount) Amount_Forgiven,

	sum(InitialApprovalAmount) Approved_Amount,
	AVG(InitialApprovalAmount) Average_loan_size
from 
	sba_public_data p
	inner join sba_nacis_sector_codes_description d
	on left(p.NAICSCode,2 ) = d.LookupCodes
group by
	d.Sector,
	year(DateApproved),
	month(DateApproved),
	OriginatingLender,
	BorrowerState,
	Race,
	Gender,
	Ethnicity;



