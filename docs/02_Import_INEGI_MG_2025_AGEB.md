# STEP 2 — Marco Geoestadístico 2025 geometries

Objective: Build table `Boundaries_AGEB_2025` with the official AGEB geometries from INEGI MG 2025.  

This table will be used for:  

- Intersecting neighborhoods (colonias) with AGEB area geometries
- Calculating area proportions
- Weighting AMAI population by neighborhood (colonia)

## Suggested work directories

- D:\AXSI\INEGI\MG_2025 (work files)
- D:\AXSI\INEGI\MG_2025\Download (downloaded file and unzipped content to load into QGIS)
- D:\AXSI\INEGI\MG_2025\AGEB (save the processed AGEB shape MG_AGEB_2025.SHP as EPSG:4023)

## 2.1 Official Download of Marco Geoestadístico 2025

The Marco Geoestadístico 2025 can be downloaded from INEGI:

https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=889463807469

The download file is:

**794551163061_s.zip**

Screen:

[<img src="/docs/images/MG_2025.png" width="1000">](/docs/images/MG_2025.png)

### Save as

D:\AXSI\INEGI\MG_2025\Download\794551163061_s.zip

Inside the ZIP you will find:

- mg_2025_integrado.zip  
  - conjunto_de_datos/  
    - 00a.shp **← main AGEB areas file**

Files inside the dataset:

- 00_ent = State (polygons)  
- 00_mun = Municipality (polygons)
- 00_a = Urban and Rural AGEB (polygons **← AGEB areas**  
- 00_lpr = Locality (point)  
- 00_l = Locality Urban and Rural (polygons)  

## 2.2 Contents of the file 00a.shp

Load `00a.shp` in QGIS, ch eck the layer contains the following fields:


| Field     | Description                          |
|-----------|--------------------------------------|
| CVE_ENT   | State code (2 digits)                |
| CVE_MUN   | Municipality code (3 digits)         |
| CVE_LOC   | Locality code (4 digits)             |
| CVE_AGEB  | AGEB code (4 digits)                 |
| CVEGEO    | Full geographic key (13 digits)      |
| AMBITO    | Urbano / Rural                       |
| geom      | Geometry (Polygon / MultiPolygon)    |

Total records: **82,263 AGEB**  
Original CRS: **MEXICO_IRF‑2008_LLC** 

---

## 2.3 Export from QGIS to CRS EPSG:4326)

Export the layer `00a.shp` as:

**D:\AXSI\INEGI\MG_2025\AGEB\MG_AGEB_2025.shp**  
Make sure select CRS: **EPSG:4326** (very important)

From this new layer MG_AGEB_2025, export to CSV as:

**D:\AXSI\INEGI\MG_2025\Boundaries_AGEB_2025_WKT.csv**

- UTF‑8 encoding  
- TAB delimiter
- WKT as EPSG:4326 coordinates

| Column   | Description |
|----------|-------------|
| WKT      | Geometry in WKT format |
| CVE_ENT  | State code |
| CVE_MUN  | Municipality code |
| CVE_LOC  | Locality code |
| CVE_AGEB | AGEB code |
| CVEGEO   | Full geographic key |
| AMBITO   | Urbano / Rural |

If you edit the CSV you should see something like this:

| WKT | CVE_ENT |CVE_MUN | CVE_LOC | CVE_AGEB | CVEGEO | AMBITO |
|---------------------------------------------------|---------|---------|---------|---------|--------------|-------|
|MULTIPOLYGON (((-102.27 21.87, ... -102.27 21.87)))| 01 | 001 | 0001 | 216A | 010010001216A | Urbano |
|MULTIPOLYGON (((-102.24 21.86, ... -102.24 21.86)))	| 01 | 001 | 0001 | 2649 | 0100100012649 | Urbano |

## 2.4 Create the SQL Staging Table: Boundaries_AGEB_2025_IMPORT

* check file path you used to store INEGI files

```sql
----------------------------------------------------------------
-- 2.4 Create the SQL Staging Table: Boundaries_AGEB_2025_IMPORT
----------------------------------------------------------------
DROP TABLE IF EXISTS dbo.Boundaries_AGEB_2025_IMPORT;

CREATE TABLE Boundaries_AGEB_2025_IMPORT (
    WKT        nvarchar(MAX),
    CVE_ENT    char(2),
    CVE_MUN    char(3),
    CVE_LOC    char(4),
    CVE_AGEB   char(4),
    CVEGEO     nvarchar(13),
    AMBITO     char(10)
);

--------------------------------------
-- Import Boundaries_AGEB_2025_WKT.csv
--------------------------------------
BULK INSERT Boundaries_AGEB_2025_IMPORT 
FROM 'D:\AXSI\INEGI\MG_2025\Boundaries_AGEB_2025_WKT.csv' 
WITH ( 
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001'
);
```

#### Expected result

(82283 rows affected)   
Completion time: 2026-05-24T18:16:03.7467723-05:00   

## 2.5 Create Final Table: Boundaries_AGEB_2025

```sql
-----------------------------------------------
-- 2.5 Create Final Table: Boundaries_AGEB_2025
-----------------------------------------------
DROP TABLE IF EXISTS dbo.Boundaries_AGEB_2025;

CREATE TABLE dbo.Boundaries_AGEB_2025
(
    ID            BIGINT IDENTITY(1,1) PRIMARY KEY,
    CVEGEO        NVARCHAR(13) NOT NULL UNIQUE,

    -- Components of CVEGEO key
    CVE_ENT       CHAR(2)  NULL,
    CVE_MUN       CHAR(3)  NULL,
    CVE_LOC       CHAR(4)  NULL,
    CVE_AGEB      CHAR(4)  NULL,

    -- Type (Ámbito): Urbano, Rural (urban or rural)
    Type          CHAR(10)  NULL,

    -- Geometries
    geom          GEOMETRY NOT NULL,
    geog          GEOGRAPHY NULL,

    -- AMAI data (economic level)
    -- NSE Percetages 
    NSE_AB_PCT        NUMERIC(5,2) NULL,
    NSE_CPLUS_PCT     NUMERIC(5,2) NULL,
    NSE_C_PCT         NUMERIC(5,2) NULL,
    NSE_CMINUS_PCT    NUMERIC(5,2) NULL,
    NSE_DPLUS_PCT     NUMERIC(5,2) NULL,
    NSE_D_PCT         NUMERIC(5,2) NULL,
    NSE_E_PCT         NUMERIC(5,2) NULL,

    -- NSE Dwellings
    NSE_AB            INT NULL,
    NSE_CPLUS         INT NULL,
    NSE_C             INT NULL,
    NSE_CMINUS        INT NULL,
    NSE_DPLUS         INT NULL,
    NSE_D             INT NULL,
    NSE_E             INT NULL,

    -- Label and dweling total
    NSE_LABEL         NVARCHAR(10) NULL,
    NSE_TOTAL         INT NULL
);

-- Spatial indexes
CREATE SPATIAL INDEX SIDX_Boundaries_AGEB_2025_geog
ON dbo.Boundaries_AGEB_2025(geog)
USING GEOGRAPHY_AUTO_GRID;

CREATE SPATIAL INDEX SIDX_Boundaries_AGEB_2025_geom
ON dbo.Boundaries_AGEB_2025(geom)
WITH (BOUNDING_BOX = (-180, -90, 180, 90));

-- Valite geometries
UPDATE Boundaries_AGEB_2025 SET geom = geom.MakeValid() WHERE geom.STIsValid() = 0;
```

#### Expect results

Commands completed successfully.   

---

## 2.6 Insert Data from the Staging Table

```sql
-----------------------------------------
-- 2.6 Insert Data from the Staging Table
-----------------------------------------
INSERT INTO Boundaries_AGEB_2025 (
    CVEGEO, CVE_ENT, CVE_MUN, CVE_LOC, CVE_AGEB, Type, geom
)
SELECT
    CVEGEO,
    CVE_ENT,
    CVE_MUN,
    CVE_LOC,
    CVE_AGEB,
    AMBITO,
    geometry::STGeomFromText(WKT, 4326)
FROM Boundaries_AGEB_2025_IMPORT;

-------------------------
-- drop the staging table
-------------------------
DROP TABLE dbo.Boundaries_AGEB_2025_IMPORT;
```

#### Expected results

(82283 rows affected)   


## 2.7 – Update Boundaries_AGEB_2025 with NSE

```sql
-------------------------------------------------------------------------
-- MG 2025 STEP 2.7 – Update Boundaries_AGEB_2025 with AMAI NSE data
-- Update Boundaries_AGEB_2025 with all AMAI + Calculate Percentages _PCT
-------------------------------------------------------------------------

UPDATE b
SET
    -- Conteos (copiados directamente de AMAI)
    b.NSE_AB        = ISNULL(a.NSE_AB,0),
    b.NSE_CPLUS     = ISNULL(a.NSE_CPLUS,0),
    b.NSE_C         = ISNULL(a.NSE_C,0),
    b.NSE_CMINUS    = ISNULL(a.NSE_CMINUS,0),
    b.NSE_DPLUS     = ISNULL(a.NSE_DPLUS,0),
    b.NSE_D         = ISNULL(a.NSE_D,0),
    b.NSE_E         = ISNULL(a.NSE_E,0),

    -- Totales y etiqueta
    b.NSE_TOTAL     = ISNULL(a.NSE_TOTAL,0),
    b.NSE_LABEL     = a.NSE_LABEL,

    -- Porcentajes calculados sobre el total
    b.NSE_AB_PCT     = CASE WHEN a.NSE_TOTAL > 0 THEN (ISNULL(a.NSE_AB,0) * 100.0 / a.NSE_TOTAL) ELSE 0 END,
    b.NSE_CPLUS_PCT  = CASE WHEN a.NSE_TOTAL > 0 THEN (ISNULL(a.NSE_CPLUS,0) * 100.0 / a.NSE_TOTAL) ELSE 0 END,
    b.NSE_C_PCT      = CASE WHEN a.NSE_TOTAL > 0 THEN (ISNULL(a.NSE_C,0) * 100.0 / a.NSE_TOTAL) ELSE 0 END,
    b.NSE_CMINUS_PCT = CASE WHEN a.NSE_TOTAL > 0 THEN (ISNULL(a.NSE_CMINUS,0) * 100.0 / a.NSE_TOTAL) ELSE 0 END,
    b.NSE_DPLUS_PCT  = CASE WHEN a.NSE_TOTAL > 0 THEN (ISNULL(a.NSE_DPLUS,0) * 100.0 / a.NSE_TOTAL) ELSE 0 END,
    b.NSE_D_PCT      = CASE WHEN a.NSE_TOTAL > 0 THEN (ISNULL(a.NSE_D,0) * 100.0 / a.NSE_TOTAL) ELSE 0 END,
    b.NSE_E_PCT      = CASE WHEN a.NSE_TOTAL > 0 THEN (ISNULL(a.NSE_E,0) * 100.0 / a.NSE_TOTAL) ELSE 0 END
FROM dbo.Boundaries_AGEB_2025 b
INNER JOIN dbo.NSE_AMAI_2024_AGEB a
    ON b.CVEGEO = a.CVEGEO;


-- Verify 100 records so the summ of _PCT give s ~100%

SELECT TOP 100
    CVEGEO,
    NSE_TOTAL,
    NSE_AB_PCT,
    NSE_CPLUS_PCT,
    NSE_C_PCT,
    NSE_CMINUS_PCT,
    NSE_DPLUS_PCT,
    NSE_D_PCT,
    NSE_E_PCT,
    (ISNULL(NSE_AB_PCT,0) + ISNULL(NSE_CPLUS_PCT,0) + ISNULL(NSE_C_PCT,0) 
     + ISNULL(NSE_CMINUS_PCT,0) + ISNULL(NSE_DPLUS_PCT,0) 
     + ISNULL(NSE_D_PCT,0) + ISNULL(NSE_E_PCT,0)) AS SumPercentages
FROM dbo.Boundaries_AGEB_2025
ORDER BY CVEGEO;
```

## 2.8 Geometry Validation and Correction

### Validate invalid geometries

✅ Querys should return nothing

```sql
-----------------------------------------
-- 2.8 Geometry Validation and Correction
-----------------------------------------
SELECT ID, CVEGEO
FROM Boundaries_AGEB_2025
WHERE geom.STIsValid() = 0;
```

#### Expected results

ID	CVEGEO   
None  
(all geometries are valid)   

### Correct invalid geometries using MakeValid

If query returns results, it indicates a problem that must be fixed. Then use the next step to correct them.

1️⃣ Only if Invalid geometries run:
This SQL should make all invalid to valid and return zero rows:

```sql
-----------------------------------------------
-- 1 Correct invalid geometries using MakeValid
-----------------------------------------------
UPDATE Boundaries_AGEB_2025
SET geom = geom.MakeValid()
WHERE geom.STIsValid() = 0;
```

#### Expected results

(0 rows affected)   

---

## 2.9 Copy geometry: geom column to geography: geog column

```sql
-----------------------------------------------------------
-- 2.9 Copy geometry: geom column to geography: geog column
-----------------------------------------------------------
UPDATE Boundaries_AGEB_2025
SET geog = geography::STGeomFromText(geom.STAsText(), 4326);
```

#### Expected results

(82283 rows affected)   

---

### Validate geog (geography)

2️⃣ Missing geography check
This should also return zero rows:

```sql
------------------------------
-- 2 - Missing geography check
------------------------------
SELECT ID
FROM Boundaries_AGEB_2025
WHERE geog IS NULL;
```

#### Expected results

ID  
None  
(all geography fields have a geometry)  

---

## Final Result

The table `Boundaries_AGEB_2025` now contains:

- 82,263 AGEB
- Valid geometries
- Complete CVEGEO
- Urban/Rural scope
- Population and Dwellings fields ready to be filled later

It is used for:

- Intersecting neighborhood (colonias) with AGEB geometries
- Calculating area proportions
- Weighting AMAI population by neighborhood (colonia)
- Serving as the base for NSE calculation per Neighborhood (colonia)






