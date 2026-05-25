# 3 — INEGI Census 2020

Dataset will contain:

Census 2020 data at the block block level (AGEB and MZA).  

- By aggregating blocks, we can obtain **Population** and **Dwellings** per AGEB, City, Municaplity, State.  
- Later we can compute: **Unoccupied_Dwellings** = Dwellings – Occupied_Dwellings

*Result table:* INEGI_Censo_2020_AGEB

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

### Work folder

D:\INEGI\Census_2020

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
$inputFolder = "D:\INEGI\Census_2020"

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

### Full Power Shell script

[Concatenate_RESAGEBURB2020_TAB.ps1](../scripts/powershell/Concatenate_RESAGEBURB2020_TAB.ps1)

### Expected reults

RESAGEBURB2020_ALL_TAB.csv

Edit it to verify data is: 

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


## 3.2 — Import CSV from into SQL:

### Census 2020 AGEB Step 1.0 Create table INEGI_Censo_2020_AGEB (block level / manzana).

-- SUMMARY: We will create Census 2020 AGEB at dwelling level (Manzana) dataset to have Population and Hoseholds at AGEB and dwelling level.
-- This dataset is used later, in calculation NSE Step 4.9 to update Population and Hoseholds at Neighborhood level (Colonia) level using weighted aggregation.
-- It can be used also used with aggregation to update Population and Hoseholds at City, Municipality, State levels.

-- We use a temporary Staging table to import the date, then transfor it to modeled INEGI_Censo_2020_AGEB.
#### Expected results

SQL table **INEGI_Censo_2020_AGEB** with primary key CVEGEO  

|Field|Type | Description | Key |
|------|-------------|--------------------------------------------------------|-----------|
|CVEGEO| varchar(16) |CVEGEO 16 dígits: ENTIDAD + MUN + LOC + AGEB + MZA|PRIMARY KEY|
|State| nvarchar(85) |State name||
|Municipality| nvarchar(85) |Municipality name||
|City| nvarchar(110) |City name||
|Population| int |Total Population||
|Dwellings| int |Total Dwellings||
|Occupied_Dwellings| int |Occupied Dwellings||
    
    
```sql
-----------------------
-- Create staging table 
-----------------------
DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB_Staging;
GO

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

------------------------------------------------------------------------
-- Create table INEGI_Censo_2020_AGEB (Census 2020 by AGEB and Dwelling)
------------------------------------------------------------------------
DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB;
GO
CREATE TABLE INEGI_Censo_2020_AGEB (
    CVEGEO varchar(16) PRIMARY KEY, -- CVEGEO of 16 dígits (AGEB) concatenating ENTIDAD + MUN + LOC + AGEB + MZA
    State nvarchar(85) NULL,
    Municipality nvarchar(85) NULL,
    City nvarchar(110) NULL,
    Population int NULL,
    Hoseholds int NULL,
    Hoseholds_in_use int NULL,
);
GO

----------------------------------------
-- Copy staging to INEGI_Censo_2020_AGEB
----------------------------------------
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

--------
-- Count
--------

SELECT COUNT(*) AS Records_Written FROM INEGI_Censo_2020_AGEB;

----------------------
-- CVEGEO is correct ?
----------------------

SELECT TOP 20 CVEGEO, LEN(CVEGEO) as Len
FROM INEGI_Censo_2020_AGEB;

-----------------
-- Delete staging
-----------------

DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB_Staging;
GO
```

### Validation results

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
|2402800014141052|	16|
|2402800014141053|	16|
|2402800014156000|	16|
|2402800014156001|	16|
|2402800014156002|	16|
|2402800014156003|	16|
|2402800014156004|	16|
|2402800014156005|	16|
|2402800014156006|	16|
|2402800014156007|	16|

### Full script

[01.0_AGEB_CreateTable.sql](../scripts/SQL/Censo_2020/01.0_AGEB_CreateTable.sql)




