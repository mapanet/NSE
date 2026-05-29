# 4 — INEGI AGEEML 2026

This dataset contains Catalogs of codes and names of State, Municipalty, Locality
Is used on some processes where the data comes with without names.

## Resulting Table: `INEGI_AGEEML_2026-loc`

| Column | Type | Notes |
|--------|------|--------|
| CVEGEO | varchar(16) | **Primary Key** |
| Status | nvarchar](20) | null or Baja (deleted) |
| ISO | [varchar](2) | 'MX' (ISO country code) |
| Country | nvarchar](20) | 'Mexico'
| State | nvarchar(85) ||
| Municipality | nvarchar(85) ||
| City | nvarchar(110) | Locality |
| Type [ varchar](1) | 'U' or 'R' (Urban o Rural |
| Latitude | decimal](15, 6) |  ESPG:4023 |
| Longitude | decimal](15, 6) | ESPG:4023 |
| Altitude | int ||
| geom | geometry | Point ESPG:4023 |
| geog | geography | Point ESPG:4023 |
| Population | int ||
| Dwellings | int |
| CVE_ENT | varchar](2) | State code |
| CVE_MUN | varchar](3) | Municipality code |
| CVE_LOC | varchar](4) | Locality code (city) |

Working folders:

D:\INEGI\AGEEML_2026
D:\INEGI\AGEEML_2026\Download

---

# 3.1 — Download AGEEML 2026 Catalogs


**URL:**  
[https://www.inegi.org.mx/app/scitel/Default?ev=10  ](https://www.inegi.org.mx/app/ageeml/#)
**Section:** Catalogos completos (complete catalogs)
**Catalog:** Catálogo de Localidades Nacional ( 296704 Localidades) Fecha de corte: 2026/04
**Detail:** Minúscula con acento, incluye bajas (ProperCase wi accents, included old deleted

[<img src="/docs/images/INEGI_AGEEEML.png" width="1000">](/docs/images/INEGI_AGEEEML.png)

Download file will be: 

**Directory:** D:\INEGI\AGEEML_2026\Download\   
**File name:** min_con_acento_baja.zip  


---



---

---

# 3.2 — Concatenate All Files into One Clean CSV (TSV)

### Purpose
Combine all 32 state CSV files into a single **UTF‑8 (no BOM)**, **TAB‑separated** file ready for SQL Server bulk import.

### Output File

RESAGEBURB2020_ALL_TAB.csv


- Encoding: **UTF‑8 no BOM**  
- Separator: **TAB**  
- Replace all `*` with empty string (NULL in SQL)

### PowerShell Script

```powershell
# Force the script to run in its own directory
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)

# Path where the 32 "RESAGEBURB2020 - **NN** Name .csv" files are located
$inputFolder = "D:\INEGI\Censo_2020"

# Final combined output file CSV
$outputFile = Join-Path $inputFolder "RESAGEBURB2020_ALL_TAB.csv"

# Get all files that start with RESAGEBURB2020
$files = Get-ChildItem -Path $inputFolder -Filter "RESAGEBURB2020 - *.csv"

# Validation
if ($files.Count -eq 0) {
    Write-Host "No RESAGEBURB2020*.csv files were found"
    exit
}

# Read header from first file and convert commas → tabs
$header = (Get-Content -Path $files[0].FullName -First 1) `
            -replace ",","`t"

# Create output file with header
Set-Content -Path $outputFile -Value $header

# Process each file
foreach ($file in $files) {
    Write-Host "Processing: $($file.Name)"

    # Read all lines except header
    $content = Get-Content -Path $file.FullName | Select-Object -Skip 1

    # Convert commas → tabs AND replace "*" with empty string
    $converted = $content | ForEach-Object {
        $_ -replace "\*", "" -replace ",","`t"
    }

    # Append to final CSV
    Add-Content -Path $outputFile -Value $converted
}

Write-Host "Done. Combined CSV created at:"
Write-Host $outputFile
```

---

### Full PowerShell Script

The full script used to concatenate all 32 state files into a single clean CVS (TSV) is available here:

[Concatenate_RESAGEBURB2020_TAB.ps1](../scripts/03_Censo_2020/Concatenate_RESAGEBURB2020_TAB.ps1)

---

### Expected Output File

After running the script, you should have:

RESAGEBURB2020_ALL_TAB.csv

Open the file using **EditPad Pro**, **Notepad++**, or **VS Code** and verify:

- Encoding: **UTF‑8 (No BOM)**
- Separator: **TAB**
- No asterisks (`*`)
- All rows aligned and complete

Example rows:

| ENTIDAD | NOM_ENT        | CVE_MUN | NOM_MUN                          | CVE_LOC | NOM_LOC                        | AGEB | MZA | POBTOT | VIVTOT | TVIVHAB |
|---------|----------------|---------|-----------------------------------|---------|---------------------------------|------|-----|--------|--------|---------|
| 01      | Aguascalientes | 000     | Total de la entidad Aguascalientes | 0000 | Total de la entidad            | 0000 | 000 | 1425607 | 463972 | 386671 |
| 01      | Aguascalientes | 001     | Aguascalientes                    | 0000 | Total del municipio             | 0000 | 000 | 948990  | 313256 | 266942 |
| 01      | Aguascalientes | 001     | Aguascalientes                    | 0001 | Total de la localidad urbana    | 0000 | 000 | 863893  | 286646 | 246259 |
| 01      | Aguascalientes | 001     | Aguascalientes                    | 0001 | Total AGEB urbana               | 0017 | 000 | 2237    | 1288   | 648     |
| 01      | Aguascalientes | 001     | Aguascalientes                    | 0001 | Aguascalientes                  | 0017 | 011 | 115     | 80     | 33      |
| 01      | Aguascalientes | 001     | Aguascalientes                    | 0001 | Aguascalientes                  | 0017 | 012 | 39      | 23     | 10      |
| 01      | Aguascalientes | 001     | Aguascalientes                    | 0001 | Aguascalientes                  | 0017 | 018 | 0       | 80     |         |
| 01      | Aguascalientes | 001     | Aguascalientes                    | 0001 | Aguascalientes                  | 0017 | 019 | 0       | 39     |         |

---

# 3.3 — Import CSV into SQL Server

We first import the raw CSV into a **staging table**.  
This table mirrors the structure of the SCITEL export.

```sql
----------------------------
-- 3.3 — Import CSV into SQL
----------------------------

-----------------------------
-- 3.3.1 Create staging table
-----------------------------
DROP TABLE IF EXISTS sbo.INEGI_AGEML_2026_loc_BAK;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[INEGI_AGEML_2026_loc_BAK](
	[CVEGEO] [nvarchar](20) NOT NULL,
	[Status] [nvarchar](20) NULL,
	[ISO] [nvarchar](2) NULL,
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
	[CVE_LOC] [varchar](4) NULL
 CONSTRAINT [PK_INEGI_AGEML_2026] PRIMARY KEY CLUSTERED 
(
	[CVEGEO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[INEGI_AGEML_2026_loc_BAK] ADD  CONSTRAINT [DF_INEGI_AGEML_2026_loc_ISO]  DEFAULT (N'MX') FOR [ISO]
GO

ALTER TABLE [dbo].[INEGI_AGEML_2026_loc_BAK] ADD  CONSTRAINT [DF_INEGI_AGEML_2026_loc_Country]  DEFAULT (N'México') FOR [Country]
GO

--------------------
-- 3.3.2 Bulk Insert
--------------------
BULK INSERT INEGI_Censo_2020_AGEB_Staging
FROM 'D:\INEGI\Censo_2020\RESAGEBURB2020_ALL_TAB.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',  -- UTF-8
    TABLOCK
);
GO
```

#### Expected results

(863069 rows affected)      
Completion time: 2026-05-24T22:07:26.4095744-05:00   


## 3.4 — Create Final Table and Copy Data

We now create the final table INEGI_Censo_2020_AGEB, where:

- CVEGEO is a 16‑digit unique identifier: **CVEGEO** = ENTIDAD + MUN + LOC + AGEB + MZA
- Field names are converted to EN‑US
- Population and dwelling fields are standardized

- NOM_ENT → State
- NOM_MUN → Municipality
- NOM_LOC → City
- POBTOT → Population
- VIVTOT → Dwellings
- TVIVHAB → Occupied_Dwellings

## 3.4.1 — Create Final Table

```sql
---------------------------------------------------------------------------
-- 3.4.1 Create table INEGI_Censo_2020_AGEB (Census 2020 by AGEB and Block)
---------------------------------------------------------------------------
DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB;
GO
CREATE TABLE INEGI_Censo_2020_AGEB (
    CVEGEO varchar(16) PRIMARY KEY, -- 16 digit full block code (ENTIDAD + MUN + LOC + AGEB + MZA)
    State nvarchar(85) NULL,
    Municipality nvarchar(85) NULL,
    City nvarchar(110) NULL,
    Population int NULL,
    Dwellings int NULL,
    Occupied_Dwellings int NULL,
);
GO
```

## 3.4.2 — Copy Data from Staging

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
