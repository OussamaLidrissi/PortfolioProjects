/*

Cleaning Data in SQL Queries

*/

select * from NashvilleHousing

-------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
select saleDateConverted, CONVERT(Date,SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

alter table NashvilleHousing
add saleDateConverted Date;

update NashvilleHousing
set saleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------------------

-- Populate Property Adress data
-- here we find some columns we the same parcelID whit the same property Adress and others that have null values 

select * --PropertyAddress
from NashvilleHousing where PropertyAddress is null

select a.ParcelID , a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from NashvilleHousing


select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 ) as adress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as adress

from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAdress nvarchar(255);

update NashvilleHousing
set PropertySplitAdress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 )

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

select *
from NashvilleHousing



select OwnerAddress
from NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAdress nvarchar(255);

update NashvilleHousing
set OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


select *
from NashvilleHousing

-------------------------------------------------------------------------------------------------------------

---- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)

from NashvilleHousing
group by (SoldAsVacant)

--Case Statementn
select SoldAsVacant,
case
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
	end


-------------------------------------------------------------------------------------------------------------

-- Remove Duplicate
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
--delete
select * 
From RowNumCTE
where row_num > 1
order by PropertyAddress


-------------------------------------------------------------------------------------------------------------

-- Delete unused Columns
-- because we split the owner adress to much better form adress/city/state we will delete "ownerAdress" also "SaleDate" because we did change the date form in first of this project

select * 
from NashvilleHousing


alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
