
--Cleanig data in SQL queries

Select *
From project.dbo.NashvilleHousing

--Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



--Populate Propert Address Data

Select *
From project.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From project.dbo.NashvilleHousing a
JOIN project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From project.dbo.NashvilleHousing a
JOIN project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out Address into Individual Columns (Adress, City, State)


Select PropertyAddress
From Project.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Project.dbo.NashvilleHousing


Select OwnerAddress 
From Project.dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
From Project.dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)



--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldasVacant), Count(SoldasVacant)
From Project.dbo.NashvilleHousing
Group by SoldasVacant
order by 2

SELECT SoldasVacant
, CASE WHEN SoldasVacant ='Y' THEN 'YES'
WHEN SoldasVacant ='N' THEN 'NO'
ELSE SoldasVacant
END
From Project.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldasVacant = CASE WHEN SoldasVacant ='Y' THEN 'YES'
WHEN SoldasVacant ='N' THEN 'NO'
ELSE SoldasVacant
END



--Remove Duplicates

WITH RowNumCTE AS(
Select *,
 ROW_NUMBER() Over(
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY
			  UniqueID
			  ) row_num

From Project.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num >1 
--order by PropertyAddress



--Delete Unused Columns


Select *
From Project.dbo.NashvilleHousing

ALTER TABLE Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE Project.dbo.NashvilleHousing
DROP COLUMN SaleDate