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

### 3.1 — Download SCITEL Data

In right panel are a variety of data selectors, we will choose the one those we need. This selections will remain in place por every state we download.

- "Indetificacion geografica" (Geographic identication)
- Check: Poblacion => Poblacion total (Population Total)
- Check: Vivenda => Total de viviendas (Dewlling Total) and Total de viviendas habitadas (Dewlling Total in use)

- In left Panel select a state: Aguascalientes
- Download file: Next to the State name you will see the formats available XLSX or CSV, choose **CSV** and download file.
- Save in a folder D:\INEGI\Census 2020\Downloads\

Download Files:

Files are named with state code in the name "resageburb_01csv20.zip" where 01 on resageburb_**01**csv20.zip means 01 Aguascalientes

| File name | State code | State name |
|----------------------|----|----------------------------|
|resageburb_01csv20.zip|01|Aguascalientes|
|resageburb_02csv20.zip|02|Baja California|
|resageburb_03csv20.zip|03|Baja California Sur|
|resageburb_04csv20.zip|04|Campeche|
|resageburb_05csv20.zip|05|Coahuila de Zaragoza|
|resageburb_06csv20.zip|06|Colima|
|resageburb_07csv20.zip|07|Chiapas|
|resageburb_08csv20.zip|08|Chihuahua|
|resageburb_09csv20.zip|09|Ciudad de México|
|resageburb_10csv20.zip|10|Durango|
|resageburb_11csv20.zip|11|Guanajuato|
|resageburb_12csv20.zip|12|Guerrero|
|resageburb_13csv20.zip|13|Hidalgo|
|resageburb_14csv20.zip|14|Jalisco|
|resageburb_15csv20.zip|15|México|
|resageburb_16csv20.zip|16|Michoacán de Ocampo|
|resageburb_17csv20.zip|17|Morelos|
|resageburb_18csv20.zip|18|Nayarit|
|resageburb_19csv20.zip|19|Nuevo León|
|resageburb_20csv20.zip|20|Oaxaca|
|resageburb_21csv20.zip|21|Puebla|
|resageburb_22csv20.zip|22|Querétaro|
|resageburb_23csv20.zip|23|Quintana Roo|
|resageburb_24csv20.zip|24|San Luis Potosí|
|resageburb_25csv20.zip|25|Sinaloa|
|resageburb_26csv20.zip|26|Sonora|
|resageburb_27csv20.zip|27|Tabasco|
|resageburb_28csv20.zip|28|Tamaulipas|
|resageburb_29csv20.zip|29|Tlaxcala.|
|resageburb_30csv20.zip|30|Veracruz de Ignacio de la Llave|
|resageburb_31csv20.zip|31|Yucatán|
|resageburb_32csv20.zip|32|Zacatecas|

The file structure is:

ENTIDAD, NOM_ENT, MUN, NOM_MUN, LOC, NOM_LOC, AGEB, MZA, VIVTOT, VIVPAR_DES, POBTOT

Import from:

`D:\Postal Codes Databases\Mexico MX\INEGI.org.mx\Censos 2020\Tabulados AGEB por AGEB- Censo 2020\RESAGEBURB2020_ALL.csv`

To build this file, concatenate all **RESAGEBURB2020** files from each state into:

**RESAGEBURB2020_ALL.csv**

Concatenation script:

**RESAGEBURB2020.ps1**

Make sure to check for `*` characters in the data and replace them with **nothing**.
