



--1 CLEANING AND CONVERTING THE DATE COLUMN 
SELECT       SaleDate,
             CONVERT(Date,SaleDate)
FROM         NashvilleHousings


ALTER TABLE  NashvilleHousings
ADD          SaleDateConverted DATE;

UPDATE       NashvilleHousings
SET          SaleDateConverted = CONVERT(Date, SaleDate)


--2 POPULATE PROPERTY ADDRESS DATA

SELECT      *
FROM        NashvilleHousings
WHERE       PropertyAddress IS NULL
ORDER BY    ParcelID

SELECT      A.ParcelID,
            A.PropertyAddress,
			B.ParcelID, 
			B.PropertyAddress, 
			ISNULL(A.PropertyAddress, 
			B.PropertyAddress)
FROM      NashvilleHousings A
JOIN        NashvilleHousings B ON  A.ParcelID = B.ParcelID
	  AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousings A
JOIN NashvilleHousings B 
     ON  A.ParcelID = B.ParcelID
	  AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL




-- 3 BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHousings


 --SPLITTING PROPER ADDRESS
SELECT
 PARSENAME (REPLACE(PropertyAddress, ',' , '.'),2),
 PARSENAME (REPLACE(PropertyAddress, ',' , '.'),1)
 FROM NashvilleHousings;

 
 ALTER TABLE NashvilleHousings
 ADD PropertySplitAddress Nvarchar (255);

UPDATE NashvilleHousings
 SET PropertySplitAddress = PARSENAME (REPLACE(PropertyAddress, ',' , '.'),2)




  --SPLITTING PROPERTY CITY
   ALTER TABLE NashvilleHousings
 ADD PropertySplitCity Nvarchar (255);

 UPDATE NashvilleHousings
  SET PropertySplitCity = PARSENAME (REPLACE(PropertyAddress, ',' , '.'),1)



  --SPLITTING OWNER ADDRESS
    SELECT OwnerAddress
 FROM NashvilleHousings

 SELECT
 PARSENAME (REPLACE(OwnerAddress, ',' , '.'),3),
 PARSENAME (REPLACE(OwnerAddress, ',' , '.'),2),
 PARSENAME (REPLACE(OwnerAddress, ',' , '.'),1)
 FROM NashvilleHousings


 ALTER TABLE NashvilleHousings
 ADD OwnerSplitAddress Nvarchar (255)

 UPDATE NashvilleHousings
 SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',' , '.'),3)


  --SPLITTING OWNER CITY
  ALTER TABLE NashvilleHousings
 ADD OwnerSplitCity Nvarchar (255)

 UPDATE NashvilleHousings
 SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',' , '.'),2)



 ALTER TABLE NashvilleHousings
 ADD OwnerSplitState Nvarchar (255)

 UPDATE NashvilleHousings
 SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',' , '.'),1)





 --4 CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

   SELECT SoldAsVacant, Count(SoldAsVacant)
   FROM NashvilleHousings
   GROUP BY SoldAsVacant
   ORDER BY 2


      SELECT SoldAsVacant,
   CASE
       WHEN SoldAsVacant ='1' THEN 'Yes'
	   WHEN SoldAsVacant ='0' THEN 'No'
	   ELSE 'SoldAsVacant'
	END AS SoldAsVacant
   FROM NashvilleHousings
   

      UPDATE NashvilleHousings
   SET SoldAsVacant=(CASE
       WHEN SoldAsVacant ='1' THEN 'Yes'
	   WHEN SoldAsVacant ='0' THEN 'No'
	   ELSE 'SoldAsVacant'
	END) 




	--5 REMOVE DUPLICATES
-- USING CTE

 SELECT *,
         ROW_NUMBER() OVER(
		 PARTITION BY ParcelID,
		 PropertyAddress,
		 SalePrice,
		 LegalReference
		 ORDER BY
		     UniqueID
			 ) row_num

 FROM NashvilleHousings
 ORDER BY ParcelID



  -- THEN PUT IT IN A CTE 
  WITH RowNumCTE AS(
  SELECT *,
         ROW_NUMBER() OVER(
		 PARTITION BY ParcelID,
		 PropertyAddress,
		 SalePrice,
		 LegalReference
		 ORDER BY
		     UniqueID
			 ) row_num

 FROM NashvilleHousings
 )
SELECT *
FROM RowNumCTE
WHERE Row_Num >1
ORDER BY PropertyAddress



--THEN DELETE ALL DUPLICATES
  WITH RowNumCTE AS(
  SELECT *,
         ROW_NUMBER() OVER(
		 PARTITION BY ParcelID,
		 PropertyAddress,
		 SalePrice,
		 LegalReference
		 ORDER BY
		     UniqueID
			 ) row_num

 FROM NashvilleHousings
 )
DELETE
FROM RowNumCTE
WHERE Row_Num >1


-- CHECK IF ALL DUPLICATES ARE DELETED
  WITH RowNumCTE AS(
  SELECT *,
         ROW_NUMBER() OVER(
		 PARTITION BY ParcelID,
		 PropertyAddress,
		 SalePrice,
		 LegalReference
		 ORDER BY
		     UniqueID
			 ) row_num

 FROM NashvilleHousings
 )
SELECT *
FROM RowNumCTE
WHERE Row_Num >1




-- 6 DELETE UNUSED COLUMNS

SELECT *
FROM NashvilleHousings


ALTER TABLE NashvilleHousings
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
