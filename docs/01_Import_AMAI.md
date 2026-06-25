# STEP 1 — AMAI 2024 Data Ingestion (NSE by AGEB)

Objective: Convert the official AMAI file `NSE_por_AGEB_AMAI.xlsx` into a normalized SQL table ready for the NSE pipeline.

## Suggested work directories

- D:\AXSI\AMAI (work files)
- D:\AXSI\AMAI\Download (download files)

---

## 1 Official Source File

AMAI publishes the dataset in its downloads section:

https://www.amai.org/descargas/NSE_por_AGEB_AMAI.xlsx

Depending on the browser, it may download directly as XLSX or open in the Office Online viewer:

https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fwww.amai.org%2Fdescargas%2FNSE_por_AGEB_AMAI.xlsx&wdOrigin=BROWSELINK

or

https://www.amai.org/NSE/index.php?queVeo=NSEDES&Logeado=s (download NSE por AGEB)

Important characteristics of the file:

- It does not include a year in the filename.
- It corresponds to the NSE 2024 methodology.


## 2 Original File Contents

The file contains one row per urban AGEB from Census 2020.

Original columns:

| Column | Meaning |
|--------|---------|
| ENTIDAD | State code |
| NOMBRE ENTIDAD | State name |
| MUNICIPIO | Municipality code |
| NOMBRE MUNICIPIO | Municipality name |
| LOCALIDAD | Locality code |
| NOMBRE LOCALIDAD | Locality name |
| AGEB | AGEB code (4 characters) |
| AB | Dwellings in socioeconomic level AB |
| C+ | Dwellings in socioeconomic level C+ |
| C | Dwellings in socioeconomic level C |
| C- | Dwellings in socioeconomic level C- |
| D+ | Dwellings in socioeconomic level D+ |
| D | Dwellings in socioeconomic level D |
| E | Dwellings in socioeconomic level E |
| NIVEL_PREDOMINANTE | Dominant socioeconomic level |
| VIVIENDAS | Total occupied private dwellings |
| TAMAÑO_DE_LOCALIDAD | Locality population range |

#### Save file as 

Directory: D:\AXSI\AMAI\Download   
File name: NSE_por_AGEB_AMAI_2024.xlsx   

### Copy file to working directory

Directory: D:\AXSI\AMAI\
Saves as : NSE_por_AGEB_AMAI_2024-IMPORT.xlsx


## 3 We need to edit Excel file fix:

This the process to clean Excel file to have a importable CSV just so you know

- Get rid of columns we don't need "TAMAÑO_DE_LOCALIDAD"
- We need to standarize headers as file has merged cells in headers:
  - TOTAL DE VIVIENDAS POR NIVEL SOCIOECONÓMICO   
  - AB     C+    C     C-     D+     D     E
  - Replace headers by CVEGEO, ENTIDAD, ENT_NOM, MUN, MUN_NOM, LOC, LOC_NOM, AGEB, AB, CPLUS, C, CMINUS, DPLUS, D, E, NSE, NSE_TOTAL
- Create a new column CVEGEO by concatenating
  - Region codes come as integers but INEGI codes alphanumeric with leading zerores, so will standarize codes:
    - ENTIDAD (2 digits) must format it as 00     
    - MUNICIPIO (3 digits) must format it as 000   
    - LOCALIDAD (4 digits) must format it as 0000      
    - AGEB (4 digits)  
  - Formula CVEGEO: =TEXT(B2, "00") & TEXT(D2,"000") & TEXT(F2, "0000") & TEXT(H2, "0000")
- Replace N/D values by NOTHING so they become NULL when imported to MS SQL, this prevents errors in:
  - SUM()
  - Percentage calculations
  - Validations
  - Pipeline consistency
- Excel save CSV files only UTF-8 comma separated, that creates some locality names with double quotes, 
  the easier way to get clean file is copy the Excel data to Notepad Pro, you will get <tab> separated data
 
We can edit the Excel file and do all that changes manually or use the phyton script below that returns file ready to import.   
Script will make the changes and save file as CSV (TSV) **NSE_por_AGEB_AMAI_2024_IMPORT.csv**   

#### Convert_Excel_to_CSV.py

This script require you install **pandas** and **openpyxl**, in windows CMD (with admin rights) execute:  

pip install pandas   
pip install openpyxl   

Copy the script into *Visual Studio Code* in the same working directory: **D:\AXSI\AMAI\Convert_Excel_to_CSV.py** and run it.   
(verify path and file name if you used different names)

```phyton
import pandas as pd

# 1. Read Excel file without headers
df = pd.read_excel(r"D:\AXSI\AMAI\NSE_por_AGEB_AMAI_2024_IMPORT.xlsx", header=None)

# 2. Drop the first two rows (original headers)
df = df.drop([0, 1]).reset_index(drop=True)

# 3. Define new headers
headers = [
    "ENTIDAD","ENT_NOM","MUN","MUN_NOM","LOC","LOC_NOM","AGEB",
    "AB","CPLUS","C","CMINUS","DPLUS","D","E","NSE","NSE_TOTAL","HABITANTES"
]
df.columns = headers

# 4. Drop HABITANTES column
df = df.drop(columns=["HABITANTES"])

# 5. Format ENTIDAD, MUN, LOC with leading zeros
df["ENTIDAD"] = df["ENTIDAD"].astype(str).str.zfill(2)
df["MUN"]     = df["MUN"].astype(str).str.zfill(3)
df["LOC"]     = df["LOC"].astype(str).str.zfill(4)

# 6. Insert CVEGEO column at position 0
df.insert(0, "CVEGEO", "")

# 7. Build CVEGEO = ENTIDAD + MUN + LOC + AGEB
df["CVEGEO"] = (
    df["ENTIDAD"].astype(str).str.zfill(2) +
    df["MUN"].astype(str).str.zfill(3) +
    df["LOC"].astype(str).str.zfill(4) +
    df["AGEB"].astype(str).str.zfill(4)
)

# 8. Replace "N/D" with empty string
df = df.replace("N/D", "")

# 9. Remove all double quotes
df = df.replace('"', '', regex=True)

# 10. Save as TSV (tab-separated), UTF-8 without BOM
df.to_csv("NSE_por_AGEB_AMAI_2024_IMPORT.csv",
    sep="\t",
    index=False,
    encoding="utf-8"
)
```

### Expected result

D:\AXSI\AMAI\NSE_por_AGEB_AMAI_2024_IMPORT.csv

The CSV file should look like this:

| CVEGEO        |ENTIDAD| ENT_NOM       |MUN| MUN_NOM      |LOC | LOC_NOM      |AGEB|AB |CPLUS|C  |CMINUS|DPLUS|D  |E  |NSE|NSE_TOTAL|
|---------------|-------|---------------|---|--------------|----|--------------|----|---|-----|---|------|-----|---|---|---|---------|
| 0100100010017 |01     |Aguascalientes |001|Aguascalientes|0001|Aguascalientes|0017|  0|   12| 39|   111|  153|331|   |D  |      648|
| 010010001006A |01     |Aguascalientes |001|Aguascalientes|0001|Aguascalientes|006A|178|  124| 60|    24|    9|  4|  0|A/B|      399|
| 0100100010106 |01     |Aguascalientes |001|Aguascalientes|0001|Aguascalientes|0106|183|  375|247|   128|   62| 32|   |C+ |     1028|
| 0100100010163 |01     |Aguascalientes |001|Aguascalientes|0001|Aguascalientes|0163| 35|  157|228|   167|  124| 78|  0|C  |      789|
| 0100100010182 |01     |Aguascalientes |001|Aguascalientes|0001|Aguascalientes|0182|345|  187| 63|    46|   13|  6|  0|A/B|      660|
| 0100100010229 |01     |Aguascalientes |001|Aguascalientes|0001|Aguascalientes|0229|25 |   36| 14|    20|    9|  7|  0|C+ |      111|


## 4 Create Final table in MS SQL Server

```sql
------------------------------------------
-- Create table in SQL: AMAI_AGEB_2024
------------------------------------------

USE INMO
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE IF EXISTS dbo.AMAI_AGEB_2024;

CREATE TABLE [dbo].[AMAI_AGEB_2024](
	[CVEGEO] [nvarchar](20) NOT NULL,
	[ENTIDAD] [varchar](2) NOT NULL,
	[ENT_NOM] [nvarchar](85) NOT NULL,
	[MUN] [varchar](3) NOT NULL,
	[MUN_NOM] [nvarchar](85) NOT NULL,
	[LOC] [varchar](4) NOT NULL,
	[LOC_NOM] [nvarchar](110) NOT NULL,
    [AGEB] [varchar](4) NOT NULL,
	[AB] [int] NULL,
	[CPLUS] [int] NULL,
	[C] [int] NULL,
	[CMINUS] [int] NULL,
	[DPLUS] [int] NULL,
	[D] [int] NULL,
	[E] [int] NULL,
	[NSE] [nvarchar](10) NULL,
	[NSE_TOTAL] [int] NULL,
 CONSTRAINT [PK_AMAI_AGEB_2024] PRIMARY KEY CLUSTERED 
(
	[CVEGEO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

------------------------------------------------
-- Import CSV: NSE_por_AGEB_AMAI_2024_IMPORT.csv
-- Asumes: CSV is TAB
-- File is UTF-8 NO BOM
-- Make sure the directory path matches where you saved the AMAI CSV file.
------------------------------------------------
BULK INSERT AMAI_AGEB_2024
FROM 'D:\AXSI\AMAI\NSE_por_AGEB_AMAI_2024_IMPORT.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);
```

### Expected result

(246048 rows affected)   



## 5 Post‑Import Validations

```sql
----------------------------------------------------
-- Validate that TOTAL = sum of socioeconomic levels
-- Exprected result
-- CVEGEO | AB | CPLUS | C | CMINUS | DPLUS | D | E | NSE | NSE_TOTAL |
-- No records: This means there is no difference between total vs sum of components   

SELECT *
FROM AMAI_AGEB_2024
WHERE NSE_TOTAL <> (AB + CPLUS + C + CMINUS + DPLUS + D + E);

------------------------------------------------
-- Validate correct CVEGEO length (13 characters)
-- Exprected result
-- CVEGEO | AB | CPLUS | C | CMINUS | DPLUS | D | E | NSE | NSE_TOTAL |
-- No records: This means all CVEGEO are 13 characters: EEMMMLLLLAAAA

SELECT *
FROM AMAI_AGEB_2024
WHERE LEN(CVEGEO) <> 13;

------------------------------------------------
-- Final Result
-- SQL to display top 6 records to verify data:
-- Show top 6 rows

SELECT TOP (6) 
  CVEGEO, 
  AB, 
  CPLUS, 
  C, 
  CMINUS, 
  DPLUS, 
  D, 
  E, 
  NSE, 
  NSE_TOTAL   
FROM dbo.AMAI_AGEB_2024
```

Your final table in SQL should look like this:  

| CVEGEO        | AB  | CPLUS | C   | CMINUS | DPLUS | D   | E  | NSE | NSE_TOTAL |
|---------------|-----|-------|-----|--------|-------|-----|----|-----|-----------|
| 0100100010017 | 0   | 12    | 39  | 111    | 153   | 331 |    | D   |        648|
| 010010001006A | 178 | 124   | 60  | 24     | 9     | 4   | 0  | A/B |        399|
| 0100100010106 | 183 | 375   | 247 | 128    | 62    | 32  |    | C+  |       1028|
| 0100100010163 | 35  | 157   | 228 | 167    | 124   | 78  | 0  | C   |        789|
| 0100100010182 | 345 | 187   | 63  | 46     | 13    | 6   | 0  | A/B |        660|
| 0100100010229 | 25  | 36    | 14  | 20     | 9     | 7   | 0  | C+  |        111|

This table is the official AMAI source for the **NSE calculation steps**.  




