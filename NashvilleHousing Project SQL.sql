SELECT *
FROM [master].[dbo].[NashvilleHousing]

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [master].[dbo].[NashvilleHousing]

UPDATE [master].[dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

ALTER TABLE [master].[dbo].[NashvilleHousing]
ADD SaleDateConverted Date;



--Populate Property Address Data

SELECT *
FROM [master].[dbo].[NashvilleHousing]
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [master].[dbo].[NashvilleHousing] a
JOIN [master].[dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [master].[dbo].[NashvilleHousing] a
JOIN [master].[dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-------------------------------------------------------------------------------------------
---Breaking Out Address into Individual Columns (Address,City,State)


SELECT PropertyAddress
FROM [master].[dbo].[NashvilleHousing]
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS address
FROM [master].[dbo].[NashvilleHousing]

ALTER TABLE [master].[dbo].[NashvilleHousing]
ADD PropertySplitAddress Nvarchar(255);


UPDATE [master].[dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [master].[dbo].[NashvilleHousing]
ADD PropertySplitCity Nvarchar(255);


UPDATE [master].[dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM [master].[dbo].[NashvilleHousing]

====================================================================================================

SELECT OwnerAddress
FROM [master].[dbo].[NashvilleHousing]

--WAS SUPPOSED TO SPLIT COLUMNS 
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', ',') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', ',') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', ',') , 1)
FROM [master].[dbo].[NashvilleHousing]


--SPLIT COLUMN NAMES TO DIFFERENT COLUMNS 
SELECT
SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) AS address
,SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress) +1, LEN(OwnerAddress)) AS address
,SUBSTRING(OwnerAddress,CHARINDEX(', TN',OwnerAddress) +1, LEN(OwnerAddress)) AS address
FROM [master].[dbo].[NashvilleHousing]


SELECT
SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) AS address
,SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress) +1, LEN(OwnerAddress)) AS address
,SUBSTRING(OwnerAddress,CHARINDEX(', TN',OwnerAddress) +1, LEN(OwnerAddress)) AS address
FROM [SQLTutorial].[dbo].[NashvilleHosing]

ALTER TABLE [master].[dbo].[NashvilleHousing]
ADD OwnerSplitAddress Nvarchar(255);


UPDATE [master].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1)

ALTER TABLE [master].[dbo].[NashvilleHousing]
ADD OwnerSplitCity Nvarchar(255);


UPDATE [master].[dbo].[NashvilleHousing]
SET OwnerSplitCity = SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress) +1, LEN(OwnerAddress))

ALTER TABLE [master].[dbo].[NashvilleHousing]
ADD OwnerSplitState Nvarchar(255);


UPDATE [master].[dbo].[NashvilleHousing]
SET OwnerSplitState = SUBSTRING(OwnerAddress,CHARINDEX(', TN',OwnerAddress) +1, LEN(OwnerAddress))



--TO CORRECT THE CITY SPLIT FUNCTION 
SELECT
SUBSTRING(OwnerSplitCity,1,CHARINDEX(',',OwnerSplitCity)-1) AS address
FROM [master].[dbo].[NashvilleHousing]

ALTER TABLE [master].[dbo].[NashvilleHousing]
ADD OwnerSplitCity1 Nvarchar(255);


UPDATE [master].[dbo].[NashvilleHousing]
SET OwnerSplitCity1 = SUBSTRING(OwnerSplitCity,1,CHARINDEX(',',OwnerSplitCity)-1)

ALTER TABLE [master].[dbo].[NashvilleHousing]
DROP COLUMN OwnerSplitState1


==============================================================================================================

--CHANGE Y AND N TO YES AND NO IN "SOLD AS VECANT FIELD 

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM [master].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

SELECT SoldAsVacant
,CASE
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
   END AS SoldAsVacant
FROM [master].[dbo].[NashvilleHousing]


UPDATE [master].[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
   END

=================================================================================================

--REMOVE DUPLICATES WITH CTE FUNCTION


WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID, 
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY
			       UniqueID
			        )row_num
FROM [master].[dbo].[NashvilleHousing]
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

====================================================================
--DELETE UNUSED COLUMNS

SELECT *
FROM [master].[dbo].[NashvilleHousing]

ALTER TABLE [master].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress,SaleDate