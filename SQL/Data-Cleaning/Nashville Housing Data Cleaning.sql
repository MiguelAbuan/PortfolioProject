/*
Cleaning Data in SQL Queries
*/


--Standardize Date Format

select SaleDateConverted,CONVERT(date,SaleDate)
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)



--Populate Property Address data

select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns(Address,City,State)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select *
from PortfolioProject..NashvilleHousing


--Owner Address
select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing




alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerPropertySplitCity nvarchar(255);

update NashvilleHousing
set OwnerPropertySplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


select *
from PortfolioProject..NashvilleHousing


--Change Y and N to YES and NO in "Sold as Vacant" field


select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
	when SoldAsVAcant = 'Y' then 'Yes'
	when SoldAsVAcant = 'N' then 'No'
	else SoldAsVAcant
end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVAcant = case when SoldAsVAcant = 'Y' then 'Yes'
	when SoldAsVAcant = 'N' then 'No'
	else SoldAsVAcant
end


--Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
				partition by ParcelID,
							PropertyAddress,
							SaleDate,
							LegalReference 
							order by UniqueID
							) row_num
from NashvilleHousing
--order by ParcelID
)

delete
from RowNumCTE
where row_num > 1


--Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing


alter table PortfolioProject..NashvilleHousing
drop column OWnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject..NashvilleHousing
drop column SaleDate
