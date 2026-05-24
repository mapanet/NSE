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

### Prepare a folder structure to store the downlodas IMPORTANT

We need to download individual files, one per state, 32 files in total.
We will download 32 ZIP files and then de decompress them, Prepare a folder structure for original zip's in Downloads folder to keep them away of working folder.

D:\INEGI\Census 2020\   **<= here we will have the CSV files and work on them**

## 3.1 — Download SCITEL Data

In right panel are a variety of data selectors, we will choose the one those we need:
(this selections will remain in place por every state we download)

- "Indetificacion geografica" (Geographic identication, all marked) 
- Check: Poblacion => Poblacion total (Population Total)
- Check: Vivenda   => Total de viviendas (Dewlling Total) 
- Check: Vivenda   => Total de viviendas habitadas (Dewlling Total in use)

- In left Panel select a state: Aguascalientes
- In bottom-right hit the black button "Generar Consulta", you will see the results in a table.
- At bottom, in "Exportar a" (Export to) FORMAT: select CVS and save the file in **D:\INEGI\Census 2020**
- Go back to previous page and select the next state
- Repeat the process until you export the 32 states CSV files

### IMPORTANT

In left Panel when you select a state: Aguascalientes for example, you will see a CSV button right thereto download the COMPLETE CSV file for that state.
Do not not download that file, it contain full set of parameters from Census 2020 and they are a lot.
(we have a specific Power Shell script to use those complete files and extract the addioonal fields for other purposes)


### Verify you are all 32 files in D:\INEGI\Census 2020

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

Concatenate all RESAGEBURB2020 state files into one file: **RESAGEBURB2020_ALL.csv**

### Concatenation script:

**Concatenate_RESAGEBURB2020.ps1**

```powershell
# Force the script to run in its own directory
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)

# Path where the 32 "RESAGEBURB2020 - **NN** Name .csv" files are located
$inputFolder = "D:\Postal Codes Databases\Mexico MX\INEGI.org.mx\Censos 2020\Tabulados AGEB Manzana"

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
|-------|-------------------|---|-----------------------|----|-----------------|-----|---|----------|--------|---------|
|01|Aguascalientes|000|Total Aguascalientes|0000|Total de la entidad|0000|000|463972|60327|1425607|
|01|Aguascalientes|001|Aguascalientes|0000|Total municipio|0000|000|313256|37113|948990|
|01|Aguascalientes|001|Aguascalientes|0001|Total localidad urbana|0000|000|286646|33043|863893|
|01|Aguascalientes|001|Aguascalientes|0001|Total AGEB urbana|0017|000|1288|633|2237|
|01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|001|82|28|170|
|01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|002|83|31|198|


## 3.2 — Import CSV from into SQL:

`D:\INEGI\Census 2020\RESAGEBURB2020_ALL.csv`


