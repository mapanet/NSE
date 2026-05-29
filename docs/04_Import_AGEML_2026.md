# 4 — INEGI AGEML 2026

This dataset contains Catalogs of codes and names of State, Municipalty, Locality
Is used on some processes where the data comes with without names.

## Resulting Table: `INEGI_AGEML_2026`

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

D:\INEGI\AGEML_2026   
D:\INEGI\AGEML_2026\Download   

---

# 4.1 — Download AGEML 2026 Catalogs

- **URL:**  [https://www.inegi.org.mx/app/ageeml/#](https://www.inegi.org.mx/app/ageeml/#)   
- **Section:** Catalogos completos (complete catalogs)   
- **Catalog:** Catálogo de Localidades Nacional ( 296704 Localidades) Fecha de corte: 2026/04   
- **Detail:** Minúscula con acento, incluye bajas (ProperCase with accents, included old deleted   

[<img src="/docs/images/INEGI_AGEEEML.png" width="1000">](/docs/images/INEGI_AGEEEML.png)

Download file will be: 

**Directory:** D:\INEGI\AGEML_2026\Download\   
**File name:** min_con_acento_baja.zip

Extract from ZIP to working directory:   

AGEEML_20265131154522.xlsx

---
# 4.2 — Convert to CSV before the import to SQL 

### Purpose
Convert to TAB delimited, rename fields for clarity, replace - and * to null as they are "N/A" and get rid of fields we dont need.

Open AGEEML_20265131154522.xlsx in Excel

Delete First 3 rows of titles like "Instituto Nacional de Estadística y Geografía.", etc.

Delete columns:

- NOM_ABR (Abbreviated stat name )
- LATITUD (HH MM SS)
- LONGITUDE  (HH MM SS)
- CVE_CARTA (INEGI map reference)

Insert a row after thye header rename headers and have a more consistent names

|CVEGEO|Estatus|CVE_ENT|NOM_ENT|CVE_MUN|NOM_MUN|CVE_LOC|NOM_LOC|AMBITO|LAT_DECIMAL|LON_DECIMAL|ALTITUD|POB_TOTAL|POB_MASCULINA|POB_FEMENINA|TOTAL DE VIVIENDAS HABITADAS|
|------|-------|-------|-------|-------|-------|-------|-------|------|-----------|-----------|-------|---------|-------------|------------|----------------------------|
|CVEGEO|Status|CVE_ENT|State|CVE_MUN|Municipality|CVE_LOC|City|Type|Latitude|Longitude|Altitude|Population|Population_M|Population_F|Occupied_Dwellings|

### Output File

- Delete first row
- Save as type as **CSV UTF-8 comma delimited**
- Save it as **AGEEML_2026.csv**

### Edit CSV to clean it from dash and asterisks (N/A values)

AGEEML_2026.csv

Open the file using **EditPad Pro**, **Notepad++**, or **VS Code** and:

Replace coma , by TAB
Replace TAB + asterisk (*) values to one TAB (this create a empty values when a value is dash (-) so when imported it become NULL
Replace TAB + dash (-) to one TAB only (this create a empty values as when a value is dash (-) so when imported it become NULL

- Encoding: **UTF‑8 no BOM**  
- Separator: **TAB**  
- Replaced all `*` with empty string (NULL in SQL)
- Replaced all `-` with empty string (NULL in SQL)
- All rows aligned and complete

#### Save

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
---

# 4.3 Create **INEGI_AGEML_2026_Staging**.  

```sql
----------------------------------------------
-- 4.3.1 Create table INEGI_AGEML_2026_Staging
----------------------------------------------
DROP TABLE IF EXISTS dbo.INEGI_AGEML_2026_Staging;
GO

CREATE TABLE [dbo].[INEGI_AGEML_2026_staging](
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

BULK INSERT INEGI_AGEML_2026_staging
FROM 'D:\AXSI\INEGI\AGEEML_2026\AGEML_2026.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',  -- UTF-8
    TABLOCK
);
GO
```

# 4.4 Create final **INEGI_AGEML_2026**.  

```sql
------------------------------------------
-- 4.3.1 Create table INEGI_AGEML_2026
------------------------------------------
DROP TABLE IF EXISTS dbo.INEGI_AGEML_2026;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[INEGI_AGEML_2026](
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
	[Occupied_Dwellings] [int] NULL,
	[CVE_ENT] [varchar](2) NULL,
	[CVE_MUN] [varchar](3) NULL,
	[CVE_LOC] [varchar](4) NULL,
	[State_Ant] [nvarchar](85) NOT NULL,
	[Municipality_Ant] [nvarchar](85) NOT NULL,
	[City_Ant] [nvarchar](110) NOT NULL
 CONSTRAINT [PK_INEGI_AGEML_2026] PRIMARY KEY CLUSTERED 
(
	[CVEGEO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[INEGI_AGEML_2026] ADD  CONSTRAINT [DF_INEGI_AGEML_2026_ISO]  DEFAULT (N'MX') FOR [ISO]
GO

ALTER TABLE [dbo].[INEGI_AGEML_2026] ADD  CONSTRAINT [DF_INEGI_AGEML_2026_Country]  DEFAULT (N'México') FOR [Country]
GO
```

## 3.5 — Copy Data from Staging

```sql
----------------------------------------------
-- 3.4.2 Copy staging to INEGI_Censo_2020_AGEB
----------------------------------------------
INSERT INTO INEGI_Censo_2020_AGEB (
    CVEGEO, -- CVEGEO de 16 digits (Full AGEB Area) concatening codes: ENTIDAD + MUN + LOC + AGEB + MZA
    State, 
    Municipality, 
    City, 
    Population, 
    Dwellings, 
    Occupied_Dwellings
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
```

#### Expected results

The final table should contain:

- 863069 records
- CVEGEO unique for every block

Test query:

```sql
------------------------
-- List first 10 records
------------------------
SELECT TOP (10) CVEGEO, State, Municipality, City, Population, Dwellings, Occupied_Dwellings FROM dbo.INEGI_Censo_2020_AGEB
```

|      CVEGEO    |    State     | Municipality                     | City                       |Population| Dwellings | Occupied_Dwellings |
|----------------|--------------|----------------------------------|----------------------------|----------|-----------|--------------------|
|0100000000000000|Aguascalientes|Total de la entidad Aguascalientes|Total de la entidad         |   1425607|	 463972|386671|
|0100100000000000|Aguascalientes|Aguascalientes                    |Total del municipio         |    948990|	 313256|266942|
|0100100010000000|Aguascalientes|Aguascalientes                    |Total de la localidad urbana|    863893|     286646|246259|
|0100100010017000|Aguascalientes|Aguascalientes                    |Total AGEB urbana	        |      2237|       1288|   648|
|0100100010017001|Aguascalientes|Aguascalientes                    |Aguascalientes              |       170|         82|    54|
|0100100010017002|Aguascalientes|Aguascalientes                    |Aguascalientes	            |       198|         83|    52|
|0100100010017003|Aguascalientes|Aguascalientes                    |Aguascalientes              |       198|         84|    55|
|0100100010017004|Aguascalientes|Aguascalientes                    |Aguascalientes              |       202|         84|    57|
|0100100010017005|Aguascalientes|Aguascalientes                    |Aguascalientes              |       157|         68|    48|
|0100100010017006|Aguascalientes|Aguascalientes                    |Aguascalientes               |      167|         82|    50|



# 3.5 — Final Validations

After loading the final table, we run a set of validation queries to confirm:

- The expected number of records was written
- All CVEGEO codes are correctly generated with 16 digits
- The staging table can be safely removed

---

✔ Validate Record Count

```sql
----------------
-- Count records
----------------
SELECT COUNT(*) AS Records_Written
FROM INEGI_Censo_2020_AGEB;
```

#### Expected results

Records_Written: 863069
This confirms that all block‑level rows from the 32 states were successfully imported (same count as in the CSV).

### ✔ Validate CVEGEO Format (16 Digits)

```sql
----------------------
-- CVEGEO is correct ?
----------------------
SELECT TOP 10
    CVEGEO,
    LEN(CVEGEO) AS Len
FROM INEGI_Censo_2020_AGEB;
```

#### Expected Output

|CVEGEO|Len|
|---------------|-----|
|2402800014141040|	16|
|2402800014141043|	16|
|2402800014141044|	16|
|2402800014141045|	16|
|2402800014141046|	16|
|2402800014141047|	16|
|2402800014141048|	16|
|2402800014141049|	16|
|2402800014141050|	16|
|2402800014141051|	16|

This confirms that:

- All codes were concatenated correctly
- No missing digits
- No malformed CVEGEO values

---

### Remove Staging Table

Once validation is complete, the staging table is no longer needed.

```sql
-----------------
-- Delete staging
-----------------
DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB_Staging;
GO
```
