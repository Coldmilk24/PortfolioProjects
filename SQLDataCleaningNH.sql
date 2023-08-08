--Data Cleaning Project(Nashville Housing Dataset)



--Reformatting Date

/* this didn't work for some reason
Update HousingInfo..NashvilleHousing
SET Date = Conert(Date, SaleDate)
*/

/*
ALTER TABLE HousingInfo..NashvilleHousing
ADD SaleDateConverted Date;
*/

UPDATE HousingInfo..NashvilleHousing
SET SaleDateConverted = Convert(date, SaleDate)

SELECT SaleDateConverted
FROM HousingInfo..NashvilleHousing

-----------------------------------------------------------------------------------------------
--Populating Null Addresses

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
FROM HousingInfo..NashvilleHousing a
JOIN HousingInfo..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] --Ensures we work in different rows
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingInfo..NashvilleHousing a
JOIN HousingInfo..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL






---------------------------------------------------------------------------------------------------------
-- Seperating out Addresses into different cols (Address, City, State)
-- ',' is our delimiter

--PropertyAddress

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as SplitAddress,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as SplitCity
FROM HousingInfo..NashvilleHousing



ALTER TABLE HousingInfo..NashvilleHousing
ADD SplitAddress Nvarchar(255);

UPDATE HousingInfo..NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);



ALTER TABLE HousingInfo..NashvilleHousing
ADD SplitCity Nvarchar(255);

UPDATE HousingInfo..NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));



SELECT * 
FROM HousingInfo..NashvilleHousing;




--Owner Address

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as SplitOwnerAddress, --Parsename works back to front
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as SplitOwnerCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as SplitOwnerState
FROM HousingInfo..NashvilleHousing



ALTER TABLE HousingInfo..NashvilleHousing
ADD SplitOwnerAddress NVarChar(255);

UPDATE HousingInfo..NashvilleHousing
SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);


ALTER TABLE HousingInfo..NashvilleHousing
ADD SplitOwnerCity NVarChar(255);

UPDATE HousingInfo..NashvilleHousing
SET SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);


ALTER TABLE HousingInfo..NashvilleHousing
ADD SplitOwnerState NVarChar(255);

UPDATE HousingInfo..NashvilleHousing
SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);



SELECT * 
FROM HousingInfo..NashvilleHousing;





----------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No respectively in Sold as Vacant col


SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM HousingInfo..NashvilleHousing
GROUP BY SoldAsVacant
Order BY 2 DESC

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM HousingInfo..NashvilleHousing

UPDATE HousingInfo..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END





---------------------------------------------------------------------------------------------
-- Removing Duplicates


WITH RowNumCTE AS(
SELECT *,
			ROW_NUMBER() OVER (
						PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
						ORDER BY  UniqueID ) row_num

FROM HousingInfo..NashvilleHousing )


--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1





---------------------------------------------------------------------------------










