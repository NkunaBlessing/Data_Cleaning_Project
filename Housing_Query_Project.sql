/*
In this project I used the Nashville housing database to clean the data before it can be analyzed.
*/

--Getting all the data from the table.
SELECT * FROM PortfolioProject..Nashville_Housing
 
--Converting SaleDate from datetime format to date format.
SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..Nashville_Housing

UPDATE PortfolioProject..Nashville_Housing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE PortfolioProject..Nashville_Housing
ADD SaleDateConverted DATE;

UPDATE PortfolioProject..Nashville_Housing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


/*The below query populates the PropertyAddress that is because on that column some rows are null.
**Where the ParcelID is the same also the PropertyAddress is the same, I populate those 
**null rows with the same PropertyAddress where the ParcelID is the same.*/

SELECT Nash1.ParcelID, Nash2.ParcelID, Nash1.PropertyAddress, Nash2.PropertyAddress, ISNULL(Nash1.PropertyAddress, Nash2.PropertyAddress)
FROM PortfolioProject..Nashville_Housing Nash1
JOIN PortfolioProject..Nashville_Housing Nash2
     ON Nash1.ParcelID = Nash2.ParcelID
	 AND Nash1.[UniqueID ] != Nash2.[UniqueID ]
WHERE Nash1.PropertyAddress IS NULL

UPDATE Nash1
SET PropertyAddress = ISNULL(Nash1.PropertyAddress, Nash2.PropertyAddress)
FROM PortfolioProject..Nashville_Housing Nash1
JOIN PortfolioProject..Nashville_Housing Nash2
    ON Nash1.ParcelID = Nash2.ParcelID
	AND Nash1.[UniqueID ] <> Nash2.[UniqueID ]
WHERE Nash1.PropertyAddress IS NULL 

--Splitting the PropertyAddress into address and city.
SELECT REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress), ',', '.'), 1)) AS [Address]
, REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress), ',', '.'), 2)) AS [City]
FROM PortfolioProject..Nashville_Housing

ALTER TABLE PortfolioProject..Nashville_Housing
ADD Property_Address NVARCHAR(225)

UPDATE PortfolioProject..Nashville_Housing
SET Property_Address = REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress), ',', '.'), 1))

ALTER TABLE PortfolioProject..Nashville_Housing
ADD Property_City NVARCHAR(225)

UPDATE PortfolioProject..Nashville_Housing
SET Property_City = REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress), ',', '.'), 2))


--Splitting the OwnerAddress column to address, city and state.

SELECT 
REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),1)) AS [Address]
,REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 2)) AS [City]
,REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 3)) AS [State]
FROM PortfolioProject..Nashville_Housing

ALTER TABLE PortfolioProject..Nashville_Housing
ADD Owner_Address NVARCHAR(225)

UPDATE PortfolioProject..Nashville_Housing
SET Owner_Address = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),1))

ALTER TABLE PortfolioProject..Nashville_Housing
ADD Owner_City NVARCHAR(225)

UPDATE PortfolioProject..Nashville_Housing
SET Owner_City = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 2))

ALTER TABLE PortfolioProject..Nashville_Housing
ADD Owner_State NVARCHAR(225)

UPDATE PortfolioProject..Nashville_Housing
SET Owner_State = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 3))


--Changing "Y" to Yes and "N" to No.

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..Nashville_Housing

ALTER TABLE PortfolioProject..Nashville_Housing
ADD Sold_As_Vacant NVARCHAR (225)

UPDATE PortfolioProject..Nashville_Housing
SET Sold_As_Vacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                          WHEN SoldAsVacant = 'N' THEN 'No'
	                      ELSE SoldAsVacant
	                      END

--Removing duplicates

WITH cte AS (
SELECT *
, ROW_NUMBER() OVER (
   PARTITION BY 
       ParcelID
	 , Property_Address
	 , LandUse
	 , SaleDate
	 , SalePrice
	 , SalePrice
     , LegalReference
	ORDER BY
	   ParcelID
	 , Property_Address
	 , LandUse
	 , SaleDate
	 , SalePrice
	 , SalePrice
     , LegalReference )
	 row_num
FROM PortfolioProject..Nashville_Housing
)
DELETE FROM cte
WHERE row_num > 1

-- Delete unsed columns

ALTER TABLE PortfolioProject..Nashville_Housing
DROP COLUMN SoldAsVacant, OwnerAddress, ConvertSaleDate, SaleDate, PropertyAddress

-- Handling null values

select ParcelID
, coalesce(OwnerName, 'N/A') as OwnerName
, coalesce(TaxDistrict, 'N/A') as TaxDistrict
, coalesce(Owner_Address, 'N/A') as Onwer_Address
, coalesce(Owner_City, 'N/A') as Owner_City
, coalesce(Owner_State, 'N/A') as Owner_State
from PortfolioProject..Nashville_Housing
order by ParcelID

ALTER TABLE PortfolioProject..Nashville_Housing
ADD Owner_Name NVARCHAR(225),
	Tax_District NVARCHAR(225),
	OwnerAddress NVARCHAR(225),
	OwnerCity NVARCHAR(225),
	OwnerState NVARCHAR(225)

UPDATE PortfolioProject..Nashville_Housing
SET  Owner_Name = coalesce(OwnerName, 'N/A'),
     Tax_District = coalesce(TaxDistrict, 'N/A'), 
     OwnerAddress = coalesce(Owner_Address, 'N/A'),
	 OwnerCity = coalesce(Owner_City, 'N/A'), 
     OwnerState = coalesce(Owner_State, 'N/A') 

 SELECT ParcelID
, CASE WHEN Acreage IS NULL THEN 'N/A'
       ELSE CAST(Acreage AS NVARCHAR(25)) END AS Acreage
, CASE WHEN LandValue IS NULL THEN 'N/A'
       ELSE CAST(LandValue AS NVARCHAR(25)) END AS LandValue
, CASE WHEN BuildingValue IS NULL THEN 'N/A'
       ELSE CAST(BuildingValue AS NVARCHAR(25)) END AS BuildingValue
, CASE WHEN TotalValue IS NULL THEN 'N/A'
       ELSE CAST(TotalValue AS NVARCHAR(25)) END AS TotalValue
, CASE WHEN YearBuilt IS NULL THEN 'N/A'
       ELSE CAST(YearBuilt AS NVARCHAR(25)) END AS YearBuilt
, CASE WHEN Bedrooms IS NULL THEN 'N/A'
       ELSE CAST(Bedrooms AS NVARCHAR(25)) END AS Bedrooms
, CASE WHEN FullBath IS NULL THEN 'N/A'
       ELSE CAST(FullBath AS NVARCHAR(25)) END AS FullBath
, CASE WHEN HalfBath IS NULL THEN 'N/A'
       ELSE CAST(HalfBath AS NVARCHAR(25)) END AS HalfBath	   	   	      		   	    
FROM PortfolioProject..Nashville_Housing
ORDER BY ParcelID

ALTER TABLE PortfolioProject..Nashville_Housing
ADD Acreage_New NVARCHAR(25)
, Land_Value NVARCHAR(25)
, Bulding_Value NVARCHAR(25)
, Total_Value NVARCHAR(25)
, Year_Built NVARCHAR(25)
, Bedrooms_New NVARCHAR(25)
, Full_Bath NVARCHAR(25)
, Half_Bath NVARCHAR(25)

UPDATE PortfolioProject..Nashville_Housing
SET Acreage_New = CASE WHEN Acreage IS NULL THEN 'N/A'
       ELSE CAST(Acreage AS NVARCHAR(25)) END
, Land_Value =  CASE WHEN LandValue IS NULL THEN 'N/A'
       ELSE CAST(LandValue AS NVARCHAR(25)) END
, Bulding_Value =  CASE WHEN BuildingValue IS NULL THEN 'N/A'
       ELSE CAST(BuildingValue AS NVARCHAR(25)) END
, Total_Value =	 CASE WHEN TotalValue IS NULL THEN 'N/A'
       ELSE CAST(TotalValue AS NVARCHAR(25)) END  
, Year_Built =  CASE WHEN YearBuilt IS NULL THEN 'N/A'
       ELSE CAST(YearBuilt AS NVARCHAR(25)) END
, Bedrooms_New = CASE WHEN Bedrooms IS NULL THEN 'N/A'
       ELSE CAST(Bedrooms AS NVARCHAR(25)) END
, Full_Bath = CASE WHEN FullBath IS NULL THEN 'N/A'
       ELSE CAST(FullBath AS NVARCHAR(25)) END
, Half_Bath = CASE WHEN HalfBath IS NULL THEN 'N/A'
       ELSE CAST(HalfBath AS NVARCHAR(25)) END	   	   	   	   
	    
-- Since the null values have been handled, delete the columns that have been updated from.

AlTER TABLE PortfolioProject..Nashville_Housing
DROP COLUMN Owner_Address
, Owner_City
, Owner_State
, OwnerName
, TaxDistrict
, Acreage
, LandValue
, BuildingValue
, TotalValue
, YearBuilt
, Bedrooms
, FullBath
, HalfBath