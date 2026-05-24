-- Census 2020 AGEB – Step 1.0 Create table INEGI_Censo_2020_AGEB (block / manzana level)

-- SUMMARY:
-- This step builds the Census 2020 AGEB dataset at the dwelling-block (manzana) level.
-- From this block-level data we obtain Population and Households at both the AGEB level
-- and the block level.

-- The resulting dataset is later used in NSE Calculation Step 4.9 to update Population
-- and Households at the Neighborhood (Colonia) level using weighted aggregation.

-- It can also be aggregated to compute Population and Households at the City,
-- Municipality, and State levels.

-- PROCEDURE SUMMARY:
-- 1. Create a staging table for importing raw Census 2020 block-level data.
-- 2. Bulk insert the combined RESAGEBURB2020_ALL_TAB.csv file.
-- 3. Create the final INEGI_Censo_2020_AGEB table with modeled fields.
-- 4. Transform and load data from staging into the final table.
-- 5. Validate record count and CVEGEO length is 16 characters.
-- 6. Drop the staging table.



USE INMO    -- Your DB
GO

----------------------------------------------------------------------------
-- 1. Create a staging table for importing raw Census 2020 block-level data.
----------------------------------------------------------------------------
DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB_Staging;
GO

CREATE TABLE INEGI_Censo_2020_AGEB_Staging (
    ENTIDAD varchar(2) NOT NULL,
    NOM_ENT nvarchar(100) NULL,
    MUN varchar(3) NOT NULL,
    NOM_MUN nvarchar(100) NULL,
    LOC varchar(4) NOT NULL,
    NOM_LOC nvarchar(150) NULL,
    AGEB varchar(4) NOT NULL,
    MZA varchar(3) NOT NULL,
    POBTOT int NULL,
    VIVTOT int NULL,
    TVIVHAB int NULL, 
);
GO

---------------------------------------------------------------
-- 2. Bulk insert the combined RESAGEBURB2020_ALL_TAB.csv file.
---------------------------------------------------------------
BULK INSERT INEGI_Censo_2020_AGEB_Staging
FROM 'D:\Postal Codes Databases\Mexico MX\INEGI.org.mx\Censos 2020\Tabulados AGEB Manzana\RESAGEBURB2020_ALL_TAB.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',  -- UTF-8
    TABLOCK
);
GO


-----------------------------------------------------------------------
-- 3. Create the final INEGI_Censo_2020_AGEB table with modeled fields.
-----------------------------------------------------------------------
DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB;
GO
CREATE TABLE INEGI_Censo_2020_AGEB (
    CVEGEO varchar(16) PRIMARY KEY, -- CVEGEO of 16 dígitos (AGEB) concatenanting ENTIDAD + MUN + LOC + AGEB + MZA
    State nvarchar(85) NULL,
    Municipality nvarchar(85) NULL,
    City nvarchar(110) NULL,
    Population int NULL,
    Hoseholds int NULL,
    Hoseholds_in_use int NULL,
);
GO

----------------------------------------------------------------
-- 4. Transform and load data from staging into the final table.
----------------------------------------------------------------
INSERT INTO INEGI_Censo_2020_AGEB (
    CVEGEO, -- CVEGEO de 16 dígitos (AGEB) concatenando ENTIDAD + MUN + LOC + AGEB + MZA
    State, 
    Municipality, 
    City, 
    Population, 
    Hoseholds, 
    Hoseholds_in_use
)
SELECT
    ENTIDAD + MUN + LOC + AGEB + MZA As CVEGEO, 
    NOM_ENT, 
    NOM_MUN, 
    NOM_LOC,
    POBTOT, 
    VIVTOT, 
    TVIVHAB
FROM INEGI_Censo_2020_AGEB_Staging;
GO


---------------------------------------------------------------
-- 5. Validate record count and CVEGEO length is 16 characters.
---------------------------------------------------------------

SELECT COUNT(*) AS Records_Written FROM INEGI_Censo_2020_AGEB;

SELECT TOP 20 CVEGEO, LEN(CVEGEO) as Len FROM INEGI_Censo_2020_AGEB;

-----------------------------
-- 6. Drop the staging table.
-----------------------------

DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB_Staging;
GO
