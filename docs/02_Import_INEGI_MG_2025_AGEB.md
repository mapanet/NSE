# STEP 2 — Marco Geoestadístico 2025

Objective: Build the table `Boundaries_AGEB_2025` using the official AGEB geometries from INEGI MG 2025.  
This table will be used for:

- Intersecting colonias with AGEB
- Calculating area proportions
- Weighting AMAI population by colonia

## 2.1 Official Download of Marco Geoestadístico 2025

The Marco Geoestadístico 2025 can be downloaded from INEGI:

https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=889463807469

The downloaded file is:

**794551163061_s.zip**

Inside the ZIP you will find:

- mg_2025_integrado.zip  
  - conjunto_de_datos/  
    - 00a.shp **← main AGEB file**

Files inside the dataset:

- a = Urban AGEB (polygon) **← this is the one we need**  
- ar = Rural AGEB (polygon)  
- m = Block (manzana) (polygon)  
- l = Locality (point)  
- lpr = Locality (polygon)  
- ent = State (polygon)  
- mun = Municipality (polygon)

### CDMX Note

Mexico City provides an independent AGEB 2023 dataset:

https://datos.cdmx.gob.mx/dataset/ageb-urbanas-areas-geoestadisticas-basicas-urbanas

We will not use it here.  
Later we will compare it with Marco Geoestadístico 2025 to verify whether it is the same or if somehow have more detail).

## 2.2 Contents of the file 00a.shp

When loading `00a.shp` in QGIS, the layer contains the following fields:


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
Original CRS: **MEXICO_IRF‑2008_LLC** (will be converted to **EPSG:4326**)

---

## 2.3 Export from QGIS

Export the layer `00a.shp` as:

**Boundaries_AGEB_2025.shp**  
CRS: **EPSG:4326** (very important)

From this new layer, export to CSV as:

**Boundaries_AGEB_2025_WKT.csv**

- UTF‑8 encoding  
- TAB delimiter
- WKT with EPSG:4326 coordinates

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
|MULTIPOLYGON (((-102.27 21.87, ... -102.27 21.87)))| 01 | 001 | 0001 | 216A | 010010001216A | Urbana |
|MULTIPOLYGON (((-102.24 21.86, ... -102.24 21.86)))	| 01 | 001 | 0001 | 2649 | 0100100012649 | Urbana |

## 2.4 Create the SQL Staging Table: Boundaries_AGEB_2025_IMPORT

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
```

### Expected result

Commands completed successfully.
Completion time: 2026-05-24T18:11:21.7628144-05:00

**Import Boundaries_AGEB_2025_WKT.csv**

* check file path you used to store INEGI files

```sql
--------------------------------------
-- Import Boundaries_AGEB_2025_WKT.csv
--------------------------------------
BULK INSERT Boundaries_AGEB_2025_IMPORT 
FROM 'D:\INEGI\Boundaries_AGEB_2025_WKT.csv' 
WITH ( 
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001'
);
```

### Expected result

(82283 rows affected)
Completion time: 2026-05-24T18:16:03.7467723-05:00

## 2.5 Create Final Table: Boundaries_AGEB_2025

```sql
-----------------------------------------------
-- 2.5 Create Final Table: Boundaries_AGEB_2025
-----------------------------------------------
CREATE TABLE Boundaries_AGEB_2025 (
    ID          bigint IDENTITY(1,1) PRIMARY KEY,
    CVEGEO      nvarchar(13) NOT NULL,
    CVE_ENT     char(2),
    CVE_MUN     char(3),
    CVE_LOC     char(4),
    CVE_AGEB    char(4),
    Type        char(10),      -- Urban / Rural
    geom        geometry,      -- EPSG:4326
    geog        geography,     -- EPSG:4326
    Population  int NULL,      -- will be filled later
    Dwellings   int NULL       -- will be filled later
);
```
### Expect results

Commands completed successfully.
Completion time: 2026-05-24T18:18:21.1765627-05:00

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
```

### Expected results

(82283 rows affected)
Completion time: 2026-05-24T18:21:38.1908732-05:00

## If all ok => Drop the staging table

```sql
-------------------------
-- drop the staging table
-------------------------
DROP TABLE dbo.Boundaries_AGEB_2025_IMPORT;
```

## 2.7 Geometry Validation and Correction

### Validate invalid geometries

✅ Querys should return nothing

```sql
-----------------------------------------
-- 2.7 Geometry Validation and Correction
-----------------------------------------
SELECT ID, CVEGEO
FROM Boundaries_AGEB_2025
WHERE geom.STIsValid() = 0;
```
### Expected results

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

### Expected results

(0 rows affected)
Completion time: 2026-05-24T18:32:20.6926452-05:00


## 2.8 Copy geometry: geom column to geography: geog column

```sql
-----------------------------------------------------------
-- 2.8 Copy geometry: geom column to geography: geog column
-----------------------------------------------------------
UPDATE Boundaries_AGEB_2025
SET geog = geography::STGeomFromText(geom.STAsText(), 4326);
```

### Expected results

(82283 rows affected)
Completion time: 2026-05-24T18:38:41.5409824-05:00

### Validate geog:

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

### Expected results

ID
None
(all geography has gemoetry)

## 2.9 Create Spatial Indexes

```sql
-----------------------------
-- 2.9 Create Spatial Indexes
----------------------------
CREATE SPATIAL INDEX SIDX_Boundaries_AGEB_2025_geom
ON dbo.Boundaries_AGEB_2025(geom)
WITH (
    BOUNDING_BOX = (-180, -90, 180, 90)
);
```

### Expected results

Commands completed successfully.
Completion time: 2026-05-24T18:47:16.7518921-05:00

```sql
CREATE SPATIAL INDEX SIDX_Boundaries_AGEB_2025_geog
ON Boundaries_AGEB_2025(geog);
```

### Expected results

Commands completed successfully.
Completion time: 2026-05-24T18:47:16.7518921-05:00


## 2.10 Final Result

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






