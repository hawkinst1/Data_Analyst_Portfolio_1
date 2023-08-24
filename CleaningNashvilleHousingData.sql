/*
	Portfolio Project 1: Cleaning Data in SQL 
*/

select *
from NashvilleHousing

---------------------------------------------------------------------------------------------------------

--Standardise Date Format

select SaleDateConverted, Convert(Date, SaleDate) as 'Formatted Date'
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing 
set SaleDateConverted = Convert(date, saleDate)

---------------------------------------------------------------------------------------------------------

-- Populate property address data

select *
from NashvilleHousing
where PropertyAddress is null
order by ParcelID 

/*
The parcelID is linked to the addresses,
id x has address y,
in some cases address is null,
using another row of id x we can use its address to fill in the null value
Uses a self join
*/

select nullAddress.ParcelID, nullAddress.PropertyAddress, nonNullAddress.ParcelID, nonNullAddress.PropertyAddress, ISNULL(nullAddress.PropertyAddress, nonNullAddress.PropertyAddress) as 'New Address'
from NashvilleHousing nullAddress
join NashvilleHousing nonNullAddress
	on nullAddress.ParcelID = nonNullAddress.ParcelID
	And nullAddress.[UniqueID ] <> nonNullAddress.[UniqueID ]
where nullAddress.PropertyAddress is null


update nullAddress
set PropertyAddress = ISNULL(nullAddress.PropertyAddress, nonNullAddress.PropertyAddress)
from NashvilleHousing nullAddress
join NashvilleHousing nonNullAddress
	on nullAddress.ParcelID = nonNullAddress.ParcelID
	And nullAddress.[UniqueID ] <> nonNullAddress.[UniqueID ]
where nullAddress.PropertyAddress is null

---------------------------------------------------------------------------------------------------------

-- Breaking address into individual columns (Address & City)

select PropertySplitAddress, PropertySplitCity
from NashvilleHousing	

/*
	the ',' deliminater is only used once so we can use it split
*/

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


/*
Alternative way - separating the States too with parsename
*/

select OwnerAddress
from NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
from NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Change Y and N to 'yes' and 'no' in 'sold as vacant' field

select DISTINCT(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  END
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  END

---------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE as (
select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) as row_num
from NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1 
order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Remove unused columns, always check with supervisore first

select *
from NashvilleHousing

alter table NashvilleHousing
drop column TaxDistrict