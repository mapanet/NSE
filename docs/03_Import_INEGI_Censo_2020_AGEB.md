# 3 — INEGI Census 2020

Dataset will contain:

Census 2020 data at the block block level (AGEB and MZA).  

## IMPORTANT CLARIFICATIONS

- We will create Census 2020 AGEB at dwelling level (Manzana) dataset to have Population and Dwellings at dwelling level.
- This dataset is used later in calculation NSE Step 5.9 to update Population and Dwellings at Neighborhood level (Colonia) using weighted aggregation.
- It can be used also used with aggregation to update Population and Dwellings at City, Municipality, State levels.
- Using aggregation, we can obtain **Population** and **Dwellings** per AGEB, City, Municaplity, State.  
- Later we can compute: **Unoccupied_Dwellings** = Dwellings – Occupied_Dwellings

**Clartification:** "AGEB" means Geo-Statistical Area and "Manzana" is a Block.

Result table will be: INEGI_Censo_2020_AGEB

|CVEGEO|Type|PK|
|------|----|----|
|CVEGEO|varchar(16)|PRIMARY KEY|
|State|nvarchar(85)|
|Municipality|nvarchar(85)|
|City|nvarchar(110)|
|Population|int|
|Dwellings|int|
|Occupied_Dwellings|int|


## Prepare to Download Census 2020 data

We will download from **INEGI** using data from **SCITEL** system

URL: https://www.inegi.org.mx/app/scitel/Default?ev=10 
Results by AGEB and MZA (AGEB area and urban block)

Screen should look like this image:

[<img src="/docs/images/Censo_2020_1.png" width="400">](/docs/images/Censo_2020_1.png)

### Working folder

D:\INEGI\Censo_2020

## 3.1 — Download SCITEL Data

#### IMPORTANT

In left Panel at select state you will see a gray CSV button, that downloads COMPLETE data. Do not use that, follow steps below.  
(if needed, you can download those, we have a specific PS script to extract specific fields for other purposes).

#### Download procedure

In right panel are select:

1. Indetificacion geografica (Geographic identification, all marked) 
2. Check: Poblacion => Poblacion total (Population Total)
3. Check: Vivenda   => Total de viviendas (Dewlling Total) 
4. Check: Vivenda   => Total de viviendas habitadas (Dewlling Total in use)

#### Repeat this process below until you export the 32 states:

- Left Panel select a state (example: Aguascalientes)
- Bottom-right use black button **Generar Consulta** (you will see the results in a table).
- Bottom-center use black button **Exportar a** (Export to) select **FORMAT** CVS and save the file in your D:\INEGI\Census_2020
- Go back to previous page with browser <= button and select the next state.

Check values screen looks like this:
[<img src="/docs/images/Censo_2020_2.png" width="300" align="top">](/docs/images/Censo_2020_2.png)

Select CSV format and save looks like this:
[<img src="/docs/images/Censo_2020_4.png" width="300" align="top">](/docs/images/Censo_2020_4.png)


#### Verify you have all 32 states files in D:\INEGI\Census_2020

| File name - State code, State name |
|--------------------------------------|
|RESAGEBURB2020 - 01 Aguascalientes.csv|
|RESAGEBURB2020 - 02 Baja California.csv|
|RESAGEBURB2020 - 03 Baja California Sur.csv|
|RESAGEBURB2020 - 04 Campeche.csv|
|RESAGEBURB2020 - 05 Coahuila de Zaragoza.csv|
|RESAGEBURB2020 - 06 Colima.csv|
|RESAGEBURB2020 - 07 Chiapas.csv|
|RESAGEBURB2020 - 08 Chihuahua.csv|
|RESAGEBURB2020 - 09 Ciudad de México.csv|
|RESAGEBURB2020 - 10 Durango.csv|
|RESAGEBURB2020 - 11 Guanajuato.csv|
|RESAGEBURB2020 - 12 Guerrero.csv|
|RESAGEBURB2020 - 13 Hidalgo.csv|
|RESAGEBURB2020 - 14 Jalisco.csv|
|RESAGEBURB2020 - 15 México.csv|
|RESAGEBURB2020 - 16 Michoacán de Ocampo.csv|
|RESAGEBURB2020 - 17 Morelos.csv|
|RESAGEBURB2020 - 18 Nayarit.csv|
|RESAGEBURB2020 - 19 Nuevo León.csv|
|RESAGEBURB2020 - 20 Oaxaca.csv|
|RESAGEBURB2020 - 21 Puebla.csv|
|RESAGEBURB2020 - 22 Querétaro.csv|
|RESAGEBURB2020 - 23 Quintana Roo.csv|
|RESAGEBURB2020 - 24 San Luis Potosí.csv|
|RESAGEBURB2020 - 25 Sinaloa.csv|
|RESAGEBURB2020 - 26 Sonora.csv|
|RESAGEBURB2020 - 27 Tabasco.csv|
|RESAGEBURB2020 - 28 Tamaulipas.csv|
|RESAGEBURB2020 - 29 Tlaxcala.csv|
|RESAGEBURB2020 - 30 Veracruz de Ignacio de la Llave.csv|
|RESAGEBURB2020 - 31 Yucatán.csv|
|RESAGEBURB2020 - 32 Zacatecas.csv|

### Concatenate All files

#### Purpose

Concatenate all 32 state files into a clean CSV ready to bulk import to SQL

### Expected file

**RESAGEBURB2020_ALL_TAB.csv**

- Encoding: UTF-8 no BOM
- TAB separated values
- Replace all values * asterisk to "" (empty) as they are N/A data and must become NULL in SQL


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

### Full PS script

[Concatenate_RESAGEBURB2020_TAB.ps1](../scripts/03_Census_2020/Concatenate_RESAGEBURB2020_TAB.ps1)

### Expected results

RESAGEBURB2020_ALL_TAB.csv

Edit it with EditPad Pro or Notepad to verify data is: 

- UTF-8 No BOM enconding
- TAB delimited
- No astersiks (*)

|ENTIDAD|NOM_ENT|CVE_MUN|NOM_MUN|CVE_LOC|NOM_LOC|AGEB|MZA|POBTOT|VIVTOT|TVIVHAB|
|-------|-------|---|-------|---|-------|----|---|------|------|-------|
01|Aguascalientes|000|Total de la entidad Aguascalientes|0000|Total de la entidad|0000|000|1425607|463972|386671|
01|Aguascalientes|001|Aguascalientes|0000|Total del municipio|0000|000|948990|313256|266942|
01|Aguascalientes|001|Aguascalientes|0001|Total de la localidad urbana|0000|000|863893|286646|246259|
01|Aguascalientes|001|Aguascalientes|0001|Total AGEB urbana|0017|000|2237|1288|648|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|011|115|80|33|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|012|39|23|10|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|018|0|80||
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|019|0|39||



## 3.2 — Import CSV from into SQL

We first create temporary Staging table to import the data as it comes from CSV.

```sql
-----------------------
-- Create staging table 
-----------------------
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
```
#### Expected results

Commands completed successfully.  
Completion time: 2026-05-24T22:04:58.4073590-05:00

```sql
--------------
-- Bulk Insert
--------------
BULK INSERT INEGI_Censo_2020_AGEB_Staging
FROM 'D:\INEGI\Census_2020\RESAGEBURB2020_ALL_TAB.csv'
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

## 3.3 — Create SQL table INEGI_Censo_2020_AGEB

```sql
----------------------------------------------------------------------------
-- Create table INEGI_Censo_2020_AGEB (Census 2020 by AGEB and Census Block)
----------------------------------------------------------------------------
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

#### Expected results

Commands completed successfully.   
Completion time: 2026-05-24T22:09:13.9363948-05:00   

## 3.4 — Copy the data from Staging table to final table INEGI_Censo_2020_AGEB

```sql
----------------------------------------
-- Copy staging to INEGI_Censo_2020_AGEB
----------------------------------------
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

SQL INEGI_Censo_2020_AGEB table with this data:

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

## 3.4 — Final validations

```sql
----------------
-- Count records
----------------

SELECT COUNT(*) AS Records_Written FROM INEGI_Censo_2020_AGEB;

----------------------
-- CVEGEO is correct ?
----------------------

SELECT TOP 10 CVEGEO, LEN(CVEGEO) as Len
FROM INEGI_Censo_2020_AGEB;
```

#### Expected results

Records_Written: **863069**

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

### Delete staging

```sql
-----------------
-- Delete staging
-----------------

DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB_Staging;
GO
```



