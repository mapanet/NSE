# 3 — INEGI Census 2020 (Block-Level Data)

This dataset contains **Census 2020 population and dwelling data at the block level**  
(AGEB + Manzana). It is a core input for the NSE pipeline.

---

## 📌 Important Clarifications

- We create a **Census 2020 block-level dataset** to obtain **Population**, **Dwellings**, and **Occupied_Dwellings** at the **Manzana (Block)** level.
- This dataset is used in **NSE Step 5.9** to update **Population** and **Dwellings** at the **Neighborhood (Colonia)** level using weighted aggregation.
- It can also be aggregated to obtain totals at the **AGEB**, **City**, **Municipality**, and **State** levels.
- Later we compute: Unoccupied_Dwellings = Dwellings – Occupied_Dwellings


### Terminology

| Spanish | English | Meaning |
|---------|---------|---------|
| AGEB | Basic Geo‑Statistical Area | INEGI statistical unit |
| Manzana | Block | Smallest urban unit |

---

## 📄 Resulting Table: `INEGI_Censo_2020_AGEB`

| Column | Type | Notes |
|--------|------|--------|
| CVEGEO | varchar(16) | **Primary Key** |
| State | nvarchar(85) |
| Municipality | nvarchar(85) |
| City | nvarchar(110) |
| Population | int |
| Dwellings | int |
| Occupied_Dwellings | int |

#### Working folder

D:\INEGI\

---

# 3.1 — Download Census 2020 Data (SCITEL)

We download Census 2020 block-level data from **INEGI SCITEL**:

**URL:**  
https://www.inegi.org.mx/app/scitel/Default?ev=10  
**Section:** *Resultados por AGEB y Manzana Urbana*

[<img src="/docs/images/Censo_2020_1.png" width="1000">](/docs/images/Censo_2020_1.png)

---

## ⚠️ IMPORTANT — Do NOT use the gray CSV or XLSX button

In the **left panel**, you will see a **gray CSV and XLSX buttons**.  
This downloads the **full dataset**, which contains many fields we do not need.

We only want **Population**, **Total Dwellings**, and **Occupied Dwellings**.

---

# ✔ Download Procedure (Repeat for All 32 States)

In the **right panel**, select:

1. **Identificación geográfica** → all checked  
2. **Población** → *Población total*  
3. **Vivienda** → *Total de viviendas*  
4. **Vivienda** → *Total de viviendas habitadas*  

Then repeat the following steps for each state:

1. In the **left panel**, select a state (example: *Aguascalientes*).  
2. Bottom‑right → click **Generar Consulta** (Generate Query).  
3. Bottom‑center → click **Exportar a → CSV**.  
4. Save the file into:

D:\INEGI\Censo_2020\


5. Click the browser **Back** button and select the next state.

Example result:

[<img src="/docs/images/Censo_2020_3.png" width="1000">](/docs/images/Censo_2020_3.png)

---

## ✔ Verify All 32 Files Are Downloaded

| File Name |
|-----------|
| RESAGEBURB2020 - 01 Aguascalientes.csv |
| RESAGEBURB2020 - 02 Baja California.csv |
| RESAGEBURB2020 - 03 Baja California Sur.csv |
| RESAGEBURB2020 - 04 Campeche.csv |
| RESAGEBURB2020 - 05 Coahuila de Zaragoza.csv |
| RESAGEBURB2020 - 06 Colima.csv |
| RESAGEBURB2020 - 07 Chiapas.csv |
| RESAGEBURB2020 - 08 Chihuahua.csv |
| RESAGEBURB2020 - 09 Ciudad de México.csv |
| RESAGEBURB2020 - 10 Durango.csv |
| RESAGEBURB2020 - 11 Guanajuato.csv |
| RESAGEBURB2020 - 12 Guerrero.csv |
| RESAGEBURB2020 - 13 Hidalgo.csv |
| RESAGEBURB2020 - 14 Jalisco.csv |
| RESAGEBURB2020 - 15 México.csv |
| RESAGEBURB2020 - 16 Michoacán de Ocampo.csv |
| RESAGEBURB2020 - 17 Morelos.csv |
| RESAGEBURB2020 - 18 Nayarit.csv |
| RESAGEBURB2020 - 19 Nuevo León.csv |
| RESAGEBURB2020 - 20 Oaxaca.csv |
| RESAGEBURB2020 - 21 Puebla.csv |
| RESAGEBURB2020 - 22 Querétaro.csv |
| RESAGEBURB2020 - 23 Quintana Roo.csv |
| RESAGEBURB2020 - 24 San Luis Potosí.csv |
| RESAGEBURB2020 - 25 Sinaloa.csv |
| RESAGEBURB2020 - 26 Sonora.csv |
| RESAGEBURB2020 - 27 Tabasco.csv |
| RESAGEBURB2020 - 28 Tamaulipas.csv |
| RESAGEBURB2020 - 29 Tlaxcala.csv |
| RESAGEBURB2020 - 30 Veracruz.csv |
| RESAGEBURB2020 - 31 Yucatán.csv |
| RESAGEBURB2020 - 32 Zacatecas.csv |

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

# Final combined output file CSV (TSV)
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

    # Append to final TSV
    Add-Content -Path $outputFile -Value $converted
}

Write-Host "Done. Combined TSV created at:"
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

| ENTIDAD | NOM_ENT       | CVE_MUN | NOM_MUN                         | CVE_LOC | NOM_LOC                       | AGEB | MZA | POBTOT | VIVTOT | TVIVHAB |
|---------|---------------|---------|----------------------------------|---------|--------------------------------|------|-----|--------|--------|---------|
| 01      | Aguascalientes| 000     | Total de la entidad Aguascalientes | 0000 | Total de la entidad           | 0000 | 000 | 1425607 | 463972 | 386671 |
| 01      | Aguascalientes| 001     | Aguascalientes                   | 0000 | Total del municipio            | 0000 | 000 | 948990  | 313256 | 266942 |
| 01      | Aguascalientes| 001     | Aguascalientes                   | 0001 | Total de la localidad urbana   | 0000 | 000 | 863893  | 286646 | 246259 |
| 01      | Aguascalientes| 001     | Aguascalientes                   | 0001 | Total AGEB urbana              | 0017 | 000 | 2237    | 1288   | 648     |
| 01      | Aguascalientes| 001     | Aguascalientes                   | 0001 | Aguascalientes                 | 0017 | 011 | 115     | 80     | 33      |
| 01      | Aguascalientes| 001     | Aguascalientes                   | 0001 | Aguascalientes                 | 0017 | 012 | 39      | 23     | 10      |
| 01      | Aguascalientes| 001     | Aguascalientes                   | 0001 | Aguascalientes                 | 0017 | 018 | 0       | 80     |         |
| 01      | Aguascalientes| 001     | Aguascalientes                   | 0001 | Aguascalientes                 | 0017 | 019 | 0       | 39     |         |

---

# 3.3 — Import CSV (TSV) into SQL Server

We first import the raw TSV into a **staging table**.  
This table mirrors the structure of the SCITEL export.

```sql
---------------------------------
-- 3.3 — Import CSV (TSV) into SQL
---------------------------------

-----------------------------
-- 3.3.1 Create staging table
-----------------------------
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
    TVIVHAB int NULL
);
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


## 3.4 — Create SQL table INEGI_Censo_2020_AGEB and copy data from staging table

We now create the final table INEGI_Censo_2020_AGEB, where:

✔ CVEGEO is a 16‑digit unique identifier **CVEGEO** = ENTIDAD + MUN + LOC + AGEB + MZA

✔ Field names are converted to EN‑US

- NOM_ENT → State
- NOM_MUN → Municipality
- NOM_LOC → City

✔ Population and dwelling fields are standardized  

- POBTOT → Population
- VIVTOT → Dwellings
- TVIVHAB → Occupied_Dwellings

## 3.4.1 — Create Final Table

```sql
----------------------------------------------------------------------------------
-- 3.4.1 Create table INEGI_Censo_2020_AGEB (Census 2020 by AGEB and Census Block)
----------------------------------------------------------------------------------
DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB;
GO
CREATE TABLE INEGI_Censo_2020_AGEB (
    CVEGEO varchar(16) PRIMARY KEY, -- CVEGEO of 16 dígits (AGEB) concatenating ENTIDAD + MUN + LOC + AGEB + MZA
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

## ✔ Validate Record Count

```sql
----------------
-- Count records
----------------
SELECT COUNT(*) AS Records_Written
FROM INEGI_Censo_2020_AGEB;
```

#### Expected results

Records_Written: 863069
This confirms that all block‑level rows from the 32 states were successfully imported.

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



