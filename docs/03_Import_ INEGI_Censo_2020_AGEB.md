# 3 — INEGI_Censo_2020_AGEB (Census 2020)

This dataset contains:

Census 2020 data at the block (manzana) level.  
By aggregating blocks, we obtain **Population** and **Residences** per AGEB.  
If needed later, we can compute:

**Residences_In_Use = VIVTOT – VIVPAR_DES**  
(where **VIVPAR_DES = uninhabited dwellings**)

## Prepare to Download Census 2020 data

We will download from **INEGI** using data from **SCITEL** system

URL: https://www.inegi.org.mx/app/scitel/Default?ev=10

### Prepare a folder structure to store the downlodas IMPORTANT

We need to download individual files, one per state, 32 files in total.
We will download 32 ZIP files and then de decompress them, Prepare a folder structure for original zip's in Downloads folder to keep them away of working folder.

D:\INEGI\Census 2020\             **<= here we will have the CSV files and work on them**
D:\INEGI\Census 2020\Downloads\   **<= place here the downloaded files**

## 3.1 — Download SCITEL Data

In right panel are a variety of data selectors, we will choose the one those we need. This selections will remain in place por every state we download.

- "Indetificacion geografica" (Geographic identication)
- Check: Poblacion => Poblacion total (Population Total)
- Check: Vivenda => Total de viviendas (Dewlling Total) 
- Check: Vivenda => Total de viviendas habitadas (Dewlling Total in use)

- In left Panel select a state: Aguascalientes
- Download file: Next to the State name you will see the formats available XLSX or CSV, choose **CSV** and download file.
- Save in a folder **D:\INEGI\Census 2020\Downloads\**

### Download Files:

- Files contain state code in the name "resageburb_01csv20.zip" where **01** is the state of Aguascalientes
- Decompress each file into working folder **D:\INEGI\Census 2020\**

You should get all this files in the working folder D:\INEGI\Census 2020 (state code and name are listed only for reference)

| File name | State code | State name |
|----------------------|----|----------------------------|
|resageburb_01csv20.csv|01|Aguascalientes|
|resageburb_02csv20.csv|02|Baja California|
|resageburb_03csv20.csv|03|Baja California Sur|
|resageburb_04csv20.csv|04|Campeche|
|resageburb_05csv20.csv|05|Coahuila de Zaragoza|
|resageburb_06csv20.csv|06|Colima|
|resageburb_07csv20.csv|07|Chiapas|
|resageburb_08csv20.csv|08|Chihuahua|
|resageburb_09csv20.csv|09|Ciudad de México|
|resageburb_10csv20.csv|10|Durango|
|resageburb_11csv20.csv|11|Guanajuato|
|resageburb_12csv20.csv|12|Guerrero|
|resageburb_13csv20.csv|13|Hidalgo|
|resageburb_14csv20.csv|14|Jalisco|
|resageburb_15csv20.csv|15|México|
|resageburb_16csv20.csv|16|Michoacán de Ocampo|
|resageburb_17csv20.csv|17|Morelos|
|resageburb_18csv20.csv|18|Nayarit|
|resageburb_19csv20.csv|19|Nuevo León|
|resageburb_20csv20.csv|20|Oaxaca|
|resageburb_21csv20.csv|21|Puebla|
|resageburb_22csv20.csv|22|Querétaro|
|resageburb_23csv20.csv|23|Quintana Roo|
|resageburb_24csv20.csv|24|San Luis Potosí|
|resageburb_25csv20.csv|25|Sinaloa|
|resageburb_26csv20.csv|26|Sonora|
|resageburb_27csv20.csv|27|Tabasco|
|resageburb_28csv20.csv|28|Tamaulipas|
|resageburb_29csv20.csv|29|Tlaxcala.|
|resageburb_30csv20.csv|30|Veracruz de Ignacio de la Llave|
|resageburb_31csv20.csv|31|Yucatán|
|resageburb_32csv20.csv|32|Zacatecas|

### Concatenate All files

Use the following Power Shell script to concatenate all **RESAGEBURB** state files into one file:

**RESAGEBURB2020_ALL.csv**

### Concatenation script:

**RESAGEBURB2020.ps1**

```powershell
# Force the script to run in its own directory
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)

# Path where the 32 "RESAGEBURB2020_**NN**CSV20.csv" files are located
$inputFolder = "D:\INEGI\Census 2020"

# Final combined output file
$outputFile = Join-Path $inputFolder "RESAGEBURB2020_ALL.csv"

# Get all files that start with RESAGEBURB_
$files = Get-ChildItem -Path $inputFolder -Filter "RESAGEBURB_*.csv"

# Validation
if ($files.Count -eq 0) {
    Write-Host "No RESAGEBURB_*.csv files were found"
    exit
}

# Read the header from the first file (using absolute path)
$header = Get-Content -Path $files[0].FullName -First 1

# Create the final file with the header
Set-Content -Path $outputFile -Value $header

# Concatenate all files, skipping the header
foreach ($file in $files) {
    Write-Host "Processing: $($file.Name)"

    # Read all lines except the first one (header)
    $content = Get-Content -Path $file.FullName | Select-Object -Skip 1

    # Append to the final file
    Add-Content -Path $outputFile -Value $content
}

Write-Host "Done. Combined file created at:"
Write-Host $outputFile

## 3.1 — The resulting file structure:

Edit RESAGEBURB2020_ALL.csv file to verify you have this info separated for coma:

|ENTIDAD|NOM_ENT|MUN|NOM_MUN|LOC|NOM_LOC|AGEB|MZA|VIVTOT|VIVPAR_DES|POBTOT|
|-------|-------------------|---|--------------------------|----|-----------------|-----|---|----------|--------|----------|
|01|Aguascalientes|000|Total de la entidad Aguascalientes|0000|Total de la entidad|0000|000|463972|60327|1425607|
|01|Aguascalientes|001|Aguascalientes|0000|Total del municipio|0000|000|313256|37113|948990|
|01|Aguascalientes|001|Aguascalientes|0001|Total de la localidad urbana|0000|000|286646|33043|863893|
|01|Aguascalientes|001|Aguascalientes|0001|Total AGEB urbana|0017|000|1288|633|2237|
|01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|001|82|28|170|
|01|Aguascalientes|001|Aguascalientes|0001|Aguascalientes|0017|002|83|31|198|

## 3.2 — Import CSV from into SQL:

`D:\INEGI\Census 2020\RESAGEBURB2020_ALL.csv`


