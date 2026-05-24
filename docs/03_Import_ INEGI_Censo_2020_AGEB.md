# 3 — INEGI_Censo_2020_AGEB (Census 2020)

This dataset contains:

Census 2020 data at the block block level (AGEB and MZA).  
By aggregating blocks, we can obtain **Population** and **Residences** per AGEB, City, Municaplity, State.  

If needed later, we can compute:

ENTIDAD,NOM_ENT,MUN,NOM_MUN,LOC,NOM_LOC,AGEB,MZA,POBTOT,VIVTOT,TVIVHAB

**Residences_In_Use = VIVTOT – TVIVHAB**  
(where TVIVHAB = habited dwellings)

## Prepare to Download Census 2020 data

We will download from **INEGI** using data from **SCITEL** system

URL: https://www.inegi.org.mx/app/scitel/Default?ev=10 
(Results by AGEB and MZA (AGEB area and urban block "Manzana")

### Download folder

D:\INEGI\Census_2020

## 3.1 — Download SCITEL Data

### IMPORTANT

In left Panel at select a state you will see a gray CSV button, that downloads COMPLETE data. Do not use that, follow steps below.  
(if needed, you can download those, we have a specific PS script to extract specific fields for other purposes).

#### Download

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


### Verify you are all 32 files in D:\INEGI\Census_2020

| File name - (State code, State name) |
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

Concatenate all RESAGEBURB2020 state files into one file: RESAGEBURB2020_ALL.csv
Result with be a UTF-8 no BOM, TAB separated values to import to MS SQL 2022
Replace all values with * asterisk by "" (empty) as they are N/A, so when we import they become NULL

### Concatenation script

**Concatenate_RESAGEBURB2020_TAB.ps1**

```powershell
# Force the script to run in its own directory
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)

# Path where the 32 "RESAGEBURB2020 - **NN** Name .csv" files are located
$inputFolder = "D:\INEGI\Census_2020"

# Final combined output file CSV (TSV)
$outputFile = Join-Path $inputFolder "RESAGEBURB2020_ALL.csv"

# Get all files that start with RESAGEBURB2020
$files = Get-ChildItem -Path $inputFolder -Filter "RESAGEBURB2020*.csv"

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

## 3.1 — The resulting file structure:

Edit RESAGEBURB2020_ALL.csv file to verify you have this info separated by TAB
Powershell script replaced all values with asterkisk (*) to empty so when we import N/A values result in NULL

|ENTIDAD|NOM_ENT|MUN|NOM_MUN|LOC|NOM_LOC|AGEB|MZA|POBTOT|VIVTOT|TVIVHAB|
|-------|-------|---|-------|---|-------|----|---|------|------|-------|
01|Aguascalientes|000|Total de la entidad Aguascalientes|0000|Total de la entidad|0000|000|1425607|463972|386671|
01|Aguascalientes|001|Aguascalientes|0000|Total del municipio|0000|000|948990|313256|266942|
01|Aguascalientes|001|Aguascalientes|0001|Total de la localidad urbana|0000|000|863893|286646|246259|
01|Aguascalientes|001|Aguascalientes|0001|Total AGEB urbana|0017|000|2237|1288|648|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|011|115|80|33|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|012|39|23|10|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|013|12|13|4|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|014|171|83|44|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|015|93|54|29|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|016|11|11|5|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|017|49|80|11|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|018|0|80||
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|019|0|39||
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|020|7|5|3|
01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|021|6|4|1|


## 3.2 — Import CSV from into SQL:

`D:\INEGI\Census_2020\RESAGEBURB2020_ALL.csv`


