select * from..dbo.NashvilleHousing

-- Standardizing the date format

select SaleDate, CONVERT(date, SaleDate)
from..dbo.NashvilleHousing

--update dbo.NashvilleHousing
--set SaleDate = CONVERT(date, SaleDate)

alter table NashvilleHousing
add SaleConvertedDate Date;

update dbo.NashvilleHousing
set SaleConvertedDate = CONVERT(date, SaleDate)

select SaleConvertedDate from NashvilleHousing

-- Populate property address data
select propertyaddress
from nashvillehousing

select *
from nashvillehousing
where propertyaddress is null

-- What we can do is, we can attach an address with a respective parcel id, then
-- for all the addersses that are null, we can cross reference with the parcel id,
-- to fill the columns
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
from nashvillehousing as a
join nashvillehousing as b
on a.ParcelId = b.ParcelID
and a.uniqueID <> b.UniqueID -- not equals
where b.propertyaddress is null

-- Now lets populate the null values
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
from nashvillehousing as a
join nashvillehousing as b
on a.ParcelId = b.ParcelID
and a.uniqueID <> b.UniqueID -- not equals
where b.propertyaddress is null

--Lets update the existing table with these values
update a
set PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
from nashvillehousing as a
join nashvillehousing as b
on a.ParcelId = b.ParcelID
and a.uniqueID <> b.UniqueID -- not equals
where b.propertyaddress is null

select * from NashvilleHousing

-- We removed the null values and populated them with the other values

select PropertyAddress
from NashvilleHousing


select SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)) as Address -- Charindex returns a number for the mentioned item
--,CHARINDEX(',', PropertyAddress)
from NashvilleHousing

-- But we need to eliminate the delimiter from the address

select SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as CityName
from NashvilleHousing

--Now, we want to start at this position at ',' to the end defined by the length of the string
--select 
--SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as CityName
--from NashvilleHousing

-- Lets create two new columns and add the values that we have obtained
alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255)

update dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255)

update dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)+1), LEN(PropertyAddress))

select *
from NashvilleHousing

-- Lets look at the owner address
select owneraddress
from NashvilleHousing

-- Lets split the address using 'parsename'
select
PARSENAME(REPLACE(OwnerAddress,',', '.'),1),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
from NashvilleHousing

-- We need that in reverse order
select
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
from NashvilleHousing

-- Lets now add these columns in our table

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255)

update dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255)

update dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255)

update dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

-- Lets look at the column, SoldAsVacant

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

--Lets change the YES to Y and NO to N, to make the data consistent
select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'YES'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'YES'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant


-- Find DUPLICATES USING ROW NUMBERS
WITH RowNumCTE AS(
select *, 
ROW_NUMBER()OVER(
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference -- Checking duplicates with reference to these columns
order by UniqueID) row_num
from NashvilleHousing
)

Select * from RowNumCTE
where row_num > 1
order by PropertyAddress

-- Lets now delete these rows
WITH RowNumCTE AS(
select *, 
ROW_NUMBER()OVER(
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) row_num
from NashvilleHousing
)

delete from RowNumCTE
where row_num > 1
--order by PropertyAddress

-- Lets check if the duplicates are deleted
WITH RowNumCTE AS(
select *, 
ROW_NUMBER()OVER(
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) row_num
from NashvilleHousing
)

Select * from RowNumCTE
where row_num > 1
order by PropertyAddress

-- ALL DUPLICATES ARE REMOVED


-- Lets delete some unused columns
select * from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress

alter table NashvilleHousing
drop column TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate




