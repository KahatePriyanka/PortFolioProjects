--Cleaning data in SQL Querries
select * 
from PortfolioProject.dbo.NashvilleHousing

--Standardise date format
select SaleDateCoverted ,convert(Date,SaleDate) 
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SaleDate = Convert(Date,SaleDate)

alter table PortfolioProject.dbo.NashvilleHousing
add SaleDateCoverted Date;

update PortfolioProject.dbo.NashvilleHousing
set SaleDateCoverted  = Convert(Date,SaleDate)


--populate property address data

select * 
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
isnull(a.PropertyAddress,b.PropertyAddress) as UpdatedAdreess
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]!= b.[UniqueID ]
where a.PropertyAddress is  null

update a
set PropertyAddress =isnull(a.PropertyAddress,b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]!= b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns(Adress,city ,state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
substring (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,substring (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing



alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress  = substring (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


alter table PortfolioProject.dbo.NashvilleHousing
add PropertysplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertysplitCity  = substring (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


select *
from PortfolioProject.dbo.NashvilleHousing

--Breaking out address into individual columns(Adress,city ,state) with simple method 


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress  = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnersplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set  OwnersplitCity  = PARSENAME(replace(OwnerAddress,',','.'),2)


alter table PortfolioProject.dbo.NashvilleHousing
add OwnersplitState nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnersplitState  = PARSENAME(replace(OwnerAddress,',','.'),1)


--change   Y and N to yes and no  in 'sold as vacant' field


select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant 
	end
from PortfolioProject.dbo.NashvilleHousing
	

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant  = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant 
	end


--Remove Duplictaes
	
--with rowNumCTE as
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				SaleDate,
				LegalReference
				order by 
					uniqueID
					)row_num
from PortfolioProject.dbo.NashvilleHousing


--Delete unused column

select * 
from PortfolioProject.dbo.NashvilleHousing


alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
Drop column SaleDate