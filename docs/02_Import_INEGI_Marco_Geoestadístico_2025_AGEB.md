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
Later we will compare it with Marco Geoestadístico 2025 to verify whether it the same or somehow have more details).

## 2.2 Contents of the file 00a.shp

When loading `00a.shp` in QGIS, the layer contains the following fields:

### Attribute Table

| Field     | Description                          |
|-----------|--------------------------------------|
| CVE_ENT   | State code (2 digits)                |
| CVE_MUN   | Municipality code (3 digits)         |
| CVE_LOC   | Locality code (4 digits)             |
| CVE_AGEB  | AGEB code (4 digits)                 |
| CVEGEO    | Full geographic key (13 digits)      |
| AMBITO    | Urban / Rural                        |
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

### CSV Columns

| Column   | Description |
|----------|-------------|
| WKT      | Geometry in WKT format |
| CVE_ENT  | State code |
| CVE_MUN  | Municipality code |
| CVE_LOC  | Locality code |
| CVE_AGEB | AGEB code |
| CVEGEO   | Full geographic key |
| AMBITO   | Urban / Rural |

## 2.4 Create the SQL Staging Table: Boundaries_AGEB_2025_IMPORT

```sql
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
Import (TAB + UTF‑8):

```sql
BULK INSERT Boundaries_AGEB_2025_IMPORT 
FROM 'D:\INEGI\Boundaries_AGEB_2025_IMPORT.csv' 
WITH ( 
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001'
);
```

## 2.5 Create Final Table: Boundaries_AGEB_2025

```sql
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
    Residences  int NULL       -- will be filled later
);
```

## 2.6 Insert Data from the Staging Table

```sql
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

Finally, drop the staging table:

```sql
DROP TABLE dbo.Boundaries_AGEB_2025_IMPORT;
```

## 2.7 Geometry Validation and Correction

### Validate invalid geometries

SQL query should return NOTHING

```sql
SELECT ID, CVEGEO
FROM Boundaries_AGEB_2025
WHERE geom.STIsValid() = 0;
```

### Correct invalid geometries using MakeValid

Should return NOTHING if all are fixed (typically returns NOTHING)

```sql
UPDATE Boundaries_AGEB_2025
SET geom = geom.MakeValid()
WHERE geom.STIsValid() = 0;
```

## 2.8 Create the geography Column

SQL queries should return NOTHING

```sql
UPDATE Boundaries_AGEB_2025
SET geog = geography::STGeomFromText(geom.STAsText(), 4326);
```
Validate:

```sql
SELECT ID
FROM Boundaries_AGEB_2025
WHERE geog IS NULL;
```

## 2.9 Create Spatial Indexes

```sql
CREATE SPATIAL INDEX SIDX_Boundaries_AGEB_2025_geom 
ON Boundaries_AGEB_2025(geom);
```

```sql
CREATE SPATIAL INDEX SIDX_Boundaries_AGEB_2025_geog
ON Boundaries_AGEB_2025(geog);
```

## 2.10 Final Result

The table `Boundaries_AGEB_2025` now contains:

- 82,263 AGEB
- Valid geometries
- Complete CVEGEO
- Urban/Rural scope
- Population and Residences fields ready to be filled later

It is used for:

- Intersecting colonias with AGEB
- Calculating area proportions
- Weighting AMAI population by colonia
- Serving as the base for NSE calculation per Neighborhood (colonia)






