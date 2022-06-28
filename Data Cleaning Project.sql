
--Cleaning Data in SQL Queries

select * from NashvilleHousing;










--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, CONVERT(date,SaleDate) from NashvilleHousing;

Update NashvilleHousing 
set SaleDate = CONVERT(date,SaleDate);

ALTER TABLE NashvilleHousing 
add SaleDateConverted Date;

Update NashvilleHousing 
set SaleDateConverted = CONVERT(date,SaleDate);









 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * from NashvilleHousing
--where PropertyAddress is null;
order by ParcelID;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

--Where PropertyAddress is null









--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress from NashvilleHousing;


select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from NashvilleHousing;


alter table NashvilleHousing 
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing 
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Where PropertyAddress is null
--order by ParcelID

select * from NashvilleHousing;

select OwnerAddress from NashvilleHousing;

select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)


from NashvilleHousing;



alter table NashvilleHousing 
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress= PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing 
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity= PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing 
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState= PARSENAME(replace(OwnerAddress,',','.'),1)

select * from NashvilleHousing;




----------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant),count(SoldAsVacant) 
from NashvilleHousing 
group by SoldAsVacant
order by 2;




select SoldAsVacant
,	CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NashvilleHousing ;

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NashvilleHousing ;
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
with RowNUMCTE AS(
select *,
	ROW_NUMBER() over (
	partition by [ParcelID], 
				[PropertyAddress],
				[SalePrice],
				[SaleDate],
				[LegalReference]
				order by [UniqueID ]) row_num
from NashvilleHousing
--order by ParcelID
)
select * from RowNUMCTE
where row_num > 1
order by PropertyAddress;



with RowNUMCTE AS(
select *,
	ROW_NUMBER() over (
	partition by [ParcelID], 
				[PropertyAddress],
				[SalePrice],
				[SaleDate],
				[LegalReference]
				order by [UniqueID ]) row_num
from NashvilleHousing
--order by ParcelID
)
delete from RowNUMCTE
where row_num > 1;



--order by ParcelID






---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


select * from NashvilleHousing;

alter table NashvilleHousing
drop column [OwnerAddress], [TaxDistrict], [PropertyAddress];


alter table NashvilleHousing
drop column [SaleDate];






-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
