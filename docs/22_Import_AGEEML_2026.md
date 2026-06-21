# 22 — INEGI AGEEML 2026

This dataset contains the catalogs of codes and names of State, Municipalty and Locality and coordinates latitude, longitude.
Is used on some processes where the data comes with without names and/or georeference.

## Resulting Table: `INEGI_AGEEML_2026`

| Column | Type | Notes |
|--------|------|--------|
| CVEGEO | varchar(16) | **Primary Key** |
| Status | nvarchar(20) | null or Baja (deleted) |
| ISO | varchar(2) | 'MX' (ISO country code) |
| Country | nvarchar](20) | 'Mexico'
| State | nvarchar(85) ||
| Municipality | nvarchar(85) ||
| City | nvarchar(110) | Locality |
| Type | varchar](1) | 'U' or 'R' (Urban o Rural |
| Latitude | decimal(15, 6) |  ESPG:4023 |
| Longitude | decimal(15, 6) | ESPG:4023 |
| Altitude | int ||
| geom | geometry | Point ESPG:4023 |
| geog | geography | Point ESPG:4023 |
| Population | int ||
| Dwellings | int |
| CVE_ENT | varchar(2) | State code |
| CVE_MUN | varchar(3) | Municipality code |
| CVE_LOC | varchar(4) | Locality code (city) |
| State_Ant	| nvarchar(85) | original State name (will rename some state names with short names ) |
| Municipality_Ant | nvarchar(85) | original Municipality name |
| City_Ant | nvarchar(110) | original City name |
## Working folders:

D:\INEGI\AGEEML_2026   
D:\INEGI\AGEEML_2026\Download   

---

# 1 — Download AGEEML 2026 Catalogs

- **URL:**  [https://www.inegi.org.mx/app/ageeml/#](https://www.inegi.org.mx/app/ageeml/#)   
- **Section:** Catalogos completos (complete catalogs)   
- **Catalog:** Catálogo de Localidades Nacional ( 296704 Localidades) Fecha de corte: 2026/04   
- **Detail:** Minúscula con acento, incluye bajas (ProperCase with accents, included old deleted   

[<img src="/docs/images/INEGI_AGEEEML.png" width="1000">](/docs/images/INEGI_AGEEEML.png)

Download file will be: 

**Directory:** D:\INEGI\AGEEML_2026\Download\   
**File name:** min_con_acento_baja.zip

Extract from ZIP to working directory:   

D:\INEGI\AGEEML_2026\AGEEML_202651313653_utf.csv



# 2 — Convert to CSV before the import to SQL 

### Purpose
Convert to TAB delimited, rename fields for clarity, replace - and * to null as they are "N/A" and get rid of fields we dont need.

We will use a Power Shell script to generates a clean CSV (TSV) as we need to delete columns like:

- NOM_ABR (Abbreviated stat name )
- LATITUD (HH MM SS)
- LONGITUDE  (HH MM SS)
- CVE_CARTA (INEGI map reference)

AGGEEML Catalogs use asterisk (*) and dash (-) in Population and Dwelings when there is no info ("N/A") so we will rbeplace then by NOTHING so when we import they become NULL

### Script

The full script used to generate a single clean CVS (TSV) is available here:

[Convert_to_CSV_TSV.ps1](../scripts/Convert_to_CSV_TSV.ps1)

Process is slow (about 1 hour) but will save a clean file ready to import: 

**D:\INEGI\AGEEML_2026\AGEEML_2026.tsv**

Example rows:

|CVEGEO|Status|CVE_ENT|State|CVE_MUN|Municipality|CVE_LOC|City|Type|Latitude|Longitude|Altitude|Population|Population_M|Population_F|Occupied_Dwellings|
|------|------|-------|-----|-------|------------|-------|----|----|--------|---------|--------|----------|------------|------------|------------------|
|010010001||01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|U|21.879822|102.296046|1878|863893|419168|444725|246259|
|010010094||01|Aguascalientes|001|Aguascalientes|0094|Granja Adelita|R|21.871874|102.37353|1901|5|||2|
|010010096||01|Aguascalientes|001|Aguascalientes|0096|Agua Azul|R|21.883756|102.357122|1861|41|24|17|12|
|010010100||01|Aguascalientes|001|Aguascalientes|0100|Rancho Alegre|R|21.854683|102.372731|1879|0|0|0|0|
|010010102||01|Aguascalientes|001|Aguascalientes|0102|Los Arbolitos [Rancho]|R|21.78018|102.357295|1861|8|||2|
|010010104||01|Aguascalientes|001|Aguascalientes|0104|Ardillas de Abajo (Las Ardillas)|R|21.945067|102.19192|1994|1|||1|
|010010106||01|Aguascalientes|001|Aguascalientes|0106|Arellano|R|21.801773|102.273954|1891|1169|613|556|281|
|010010112||01|Aguascalientes|001|Aguascalientes|0112|Bajío los Vázquez|R|21.747494|102.124816|1971|41|20|21|9|
|010010113||01|Aguascalientes|001|Aguascalientes|0113|Bajío de Montoro|R|21.757883|102.290131|1871|0|0|0|0|
|010010114|Baja|01|Aguascalientes|001|Aguascalientes|0114|Residencial San Nicolás [Baños la Cantera]|R|21.849498|102.355422|1859|||||
|010010120||01|Aguascalientes|001|Aguascalientes|0120|Buenavista de Peñuelas|R|21.719147|102.293195|1871|1054|542|512|255|
|010010121||01|Aguascalientes|001|Aguascalientes|0121|Cabecita 3 Marías (Rancho Nuevo)|R|21.774682|102.412992|1905|192|92|100|47|




# 3 — Create **INEGI_AGEEML_2026_Staging**   

```sql
-----------------------------------------
-- Create table INEGI_AGEEML_2026_Staging
-----------------------------------------
DROP TABLE IF EXISTS dbo.INEGI_AGEEML_2026_Staging;
GO

CREATE TABLE [dbo].[INEGI_AGEEML_2026_Staging](
    [CVEGEO] [nvarchar](16) NOT NULL,
    [Status] [nvarchar](20) NULL,
    [CVE_ENT] [varchar](2) NULL,
    [State] [nvarchar](85) NOT NULL,
    [CVE_MUN] [varchar](3) NULL,
    [Municipality] [nvarchar](85) NOT NULL,
	[CVE_LOC] [varchar](4) NULL,
    [City] [nvarchar](110) NOT NULL,
    [Type] [varchar](1) NOT NULL,
    [Latitude] [decimal](15, 6) NOT NULL,
    [Longitude] [decimal](15, 6) NOT NULL,
    [Altitude] [int] NOT NULL,
    [Population] [int] NULL,
    [Population_M] [int] NULL,
    [Population_F] [int] NULL,
    [Occupied_Dwellings] [int] NULL
    CONSTRAINT [PK_INEGI_AGEML_2026_Staging] PRIMARY KEY CLUSTERED ([CVEGEO] ASC)
) ON [PRIMARY];
GO

--------------
-- Bulk insert
--------------
BULK INSERT INEGI_AGEEML_2026_staging
FROM 'D:\AXSI\INEGI\AGEEML_2026\AGEEML_2026.tsv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',  -- UTF-8
    TABLOCK
);
GO
```

### Expected reult

(361168 rows affected)   
All records uploaded



# 4 — Create final **INEGI_AGEEML_2026**   

We will include in the final table some extra fields to save original names since we wil normalize some of them:  

- State_Ant
- Municipality_Ant
- City_Ant

Will include the geom (geometry) and geog (geography) to store Latitude and Longitude for spatial needs.
	
```sql
---------------------------------
-- Create table INEGI_AGEEML_2026
---------------------------------
DROP TABLE IF EXISTS dbo.INEGI_AGEEML_2026;
GO

CREATE TABLE [dbo].[INEGI_AGEEML_2026](
	[CVEGEO] [nvarchar](16) NOT NULL,
	[Status] [nvarchar](20) NULL,
	[ISO] [varchar](2) NULL,
	[Country] [nvarchar](20) NULL,
	[State] [nvarchar](85) NOT NULL,
	[Municipality] [nvarchar](85) NOT NULL,
	[City] [nvarchar](110) NOT NULL,
	[Type] [nvarchar](1) NOT NULL,
	[Latitude] [decimal](15, 6) NOT NULL,
	[Longitude] [decimal](15, 6) NOT NULL,
	[Altitude] [int] NOT NULL,
	[geom] [geometry] NULL,
	[geog] [geography] NULL,
	[Population] [int] NULL,
	[Population_M] [int] NULL,
    [Population_F] [int] NULL,
	[Occupied_Dwellings] [int] NULL,
	[CVE_ENT] [varchar](2) NULL,
	[CVE_MUN] [varchar](3) NULL,
	[CVE_LOC] [varchar](4) NULL,
	[State_Ant] [nvarchar](85) NULL,
	[Municipality_Ant] [nvarchar](85) NULL,
	[City_Ant] [nvarchar](110) NULL
 CONSTRAINT [PK_INEGI_AGEEML_2026] PRIMARY KEY CLUSTERED 
(
	[CVEGEO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[INEGI_AGEEML_2026] ADD  CONSTRAINT [DF_INEGI_AGEEML_2026_ISO]  DEFAULT (N'MX') FOR [ISO]
GO

ALTER TABLE [dbo].[INEGI_AGEEML_2026] ADD  CONSTRAINT [DF_INEGI_AGEEML_2026_Country]  DEFAULT (N'México') FOR [Country]
GO
```


# 5 — Copy Data from Staging table

```sql
------------------------------------------
-- Copy staging table to INEGI_AGEEML_2026
------------------------------------------
INSERT INTO INEGI_AGEEML_2026 (
    CVEGEO,
    Status,
    CVE_ENT,
    State,
    CVE_MUN,
    Municipality,
    CVE_LOC,
    City,
    Type,
    Latitude,
    Longitude,
    Altitude,
    Population,
    Population_M,
    Population_F,
    Occupied_Dwellings
)
SELECT
    CVEGEO,
    Status,
    CVE_ENT,
    State,
    CVE_MUN,
    Municipality,
    CVE_LOC,
    City,
    Type,
    Latitude,
    Longitude,
    Altitude,
    Population,
    Population_M,
    Population_F,
    Occupied_Dwellings
FROM INEGI_AGEEML_2026_Staging;
```

#### Expected results

(361168 rows affected)   
All records copied

### Finally drop staging table

```sql
DROP TABLE IF EXISTS dbo.INEGI_AGEEML_2026_Staging;
GO
```


# 6 — Updates to final table

```sql
---------------------------------------------------------------------------------
-- Copy original names to _Ant to keep original naemes as we will use short names
---------------------------------------------------------------------------------

Update INEGI_AGEEML_2026 set 
  State_Ant = State,
  Municipality_Ant = Municipality,
  City_Ant = City

--------------------------------------
-- Update state names to short version
--------------------------------------

Update INEGI_AGEEML_2026 set State = 'Coahuila' WHERE State = 'Coahuila de Zaragoza' AND CVE_ENT = '05'
Update INEGI_AGEEML_2026 set State = 'Michoacán' WHERE State = 'Michoacán de Ocampo' AND CVE_ENT = '16'
Update INEGI_AGEEML_2026 set State = 'Veracruz' WHERE State = 'Veracruz de Ignacio de la Llave' AND CVE_ENT = '30'
```

#### Expect results

(12492 rows affected)   
(14318 rows affected)   
(28958 rows affected)  



# 7 — Create geom (geometry) and geog (geography) from latitude, longitude

We will use spatial intersections later so and have spatial index

```sql
--------------------------------------------------------------------------------
-- Create geom as POINT (geometry, SRID 4326) from Latitude and Longitude values
-- geometry::Point(X,Y,4326) → X = Lon, Y = Lat
--------------------------------------------------------------------------------
UPDATE INEGI_AGEEML_2026
SET geom = geometry::Point(Longitude, Latitude, 4326);

----------------
-- Validate geom
----------------
SELECT CVEGEO as CVGGEO_Invalid
FROM INEGI_AGEEML_2026
WHERE geom.STIsValid() = 0;
```

#### Expect results

361168 geom (geometries) created   
No CVEGEO_Invalid   

If any invalid, check why:

```sql
---------------------------
-- If any invalid, show why
---------------------------
SELECT CVEGEO, geom.STIsValid(), geom.IsValidDetailed()
FROM INEGI_AGEEML_2026
WHERE geom.STIsValid() = 0;
```

### Copy geom (geometry) to geog (geography)

```sql
---------------------------------------------
-- Copy geom (geometries) to geog (geography)
---------------------------------------------
UPDATE INEGI_AGEEML_2026
SET geog = geography::Point(Latitude, Longitude, 4326);

----------------
-- Validate geog
----------------
SELECT CVEGEO As CVEGEO_Invalid
FROM INEGI_AGEEML_2026
WHERE geog.STIsValid() = 0;
```

#### Expect results

361168 geog (geography geometries) created   
No CVEGEO_Invalid   



# 8 — Final Validations

✔ Validate Record Count

```sql
----------------
-- Count records
----------------
SELECT COUNT(*) AS Records_Written
FROM INEGI_AGEEML_2026;
```

#### Expected results

Records_Written: 361168
This confirms that all were successfully imported (same count as in the CSV).

### ✔ Visualize the data

```sql
SELECT TOP 20 
CVEGEO, 
Status, 
ISO, 
Country, 
State, 
Municipality, 
City, 
Type, 
Latitude, 
Longitude, 
Altitude, 
geom, 
geog, 
Population, 
Population_M, 
Population_F, 
Occupied_Dwellings, 
CVE_ENT, 
CVE_MUN, 
CVE_LOC, 
State_Ant, 
Municipality_Ant, 
City_Ant
FROM dbo.INEGI_AGEEML_2026
```
