--Cleaning Data in SQL Queries

SELECT count(*)
FROM PortfolioProject.dbo.NHousing;


-- Populate Property Address Data
SELECT *
FROM PortfolioProject.dbo.NHousing
WHERE PropertyAddress IS NULL;

SELECT *
FROM PortfolioProject.dbo.NHousing
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NHousing a
JOIN PortfolioProject.dbo.NHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NHousing a
JOIN PortfolioProject.dbo.NHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NHousing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NHousing;

ALTER TABLE NHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress));

SELECT *
FROM PortfolioProject.dbo.NHousing;


SELECT OwnerAddress
FROM PortfolioProject.dbo.NHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.NHousing;

ALTER TABLE NHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);


ALTER TABLE NHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);


ALTER TABLE NHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);


SELECT *
FROM PortfolioProject.dbo.NHousing;


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NHousing

UPDATE NHousing
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NHousing;


-- Remove Duplicates
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
				) row_num
FROM PortfolioProject.dbo.NHousing
)
DELETE
FROM RowNumCTE
WHERE row_num>1;


--Delete Unused Columns
SELECT *
FROM PortfolioProject.dbo.NHousing;

ALTER TABLE PortfolioProject.dbo.NHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;