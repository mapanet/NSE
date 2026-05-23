#STEP 1 — AMAI Data Ingestion (NSE by AGEB)

Objective: Convert the official AMAI file NSE_por_AGEB_AMAI.xlsx into a normalized SQL table ready for the NSE pipeline.

##1.1. Official Source File

AMAI publishes the dataset in its downloads section:

Direct XLSX download: https://www.amai.org/descargas/NSE_por_AGEB_AMAI.xlsx

Office Online viewer: https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fwww.amai.org%2Fdescargas%2FNSE_por_AGEB_AMAI.xlsx

Important characteristics: 

- The file name does not include a year.
- It corresponds to the NSE 2024 methodology.
- It is the current version for 2024–2027.

##1.2. Original File Structure

The file contains one row per urban AGEB from Census 2020.

Original columns:
| Column | Meaning |
| --- | --- |
| ENTIDAD | State code |
| NOMBRE ENTIDAD | State name |
| MUNICIPIO | Municipality code |
| NOMBRE MUNICIPIO | Municipality name |
| LOCALIDAD | Locality code |
| NOMBRE LOCALIDAD | Locality name |
| AGEB | AGEB code (4 chars) |
| AB | Dwellings in socioeconomic level AB |
| C+ | Dwellings in socioeconomic level C+ |
| C | Dwellings in socioeconomic level C |
| C- | Dwellings in socioeconomic level C– |
| D+ | Dwellings in socioeconomic level D+ |
| D | Dwellings in socioeconomic level D |
| E | Dwellings in socioeconomic level E |
| NIVEL_PREDOMINANTE | Dominant socioeconomic level |
| VIVIENDAS | Total occupied private dwellings |
| TAMAÑO_DE_LOCALIDAD | Locality population range |


1.4. Header Normalization (Renaming)
To standardize column names using INEGI conventions and prepare the file for SQL import, headers were renamed and saved as:

NSE_AMAI_2024_AGEB_IMPORT.xlsx

| Original | New |
| --- | --- |
| ENTIDAD | CVE_ENT |
| NOMBRE ENTIDAD | NOM_ENT |
| MUNICIPIO | CVE_MUN |
| NOMBRE MUNICIPIO | NOM_MUN |
| LOCALIDAD | CVE_LOC |
| NOMBRE LOCALIDAD | NOM_LOC |
| AGEB | CVE_AGEB |
| AB | AB |
| C+ | CPLUS |
| C | C |
| C- | CMINUS |
| D+ | DPLUS |
| D | D |
| E | E |
| NIVEL_PREDOMINANTE | NSE_LABEL |
| VIVIENDAS | TOTAL |
| TAMAÑO_DE_LOCALIDAD | (discarded) |


1.5. Building the Geographic Key (CVEGEO)
INEGI defines CVEGEO as the concatenation of:

CVE_ENT (2 digits)
CVE_MUN (3 digits)
CVE_LOC (4 digits)
CVE_AGEB (4 digits)

Example:  
01 + 001 + 0001 + 0163 = 0100100010163

Excel formula:

Code
=CVE_ENT & CVE_MUN & CVE_LOC & CVE_AGEB

1.6. Columns to Discard and Data Cleaning
Discarded columns (not used in the NSE pipeline):

CVE_ENT, NOM_ENT
CVE_MUN, NOM_MUN
CVE_LOC, NOM_LOC
TAMAÑO_DE_LOCALIDAD

Reason:  
They do not participate in joins, calculations, or add analytical value.

Handling “N/D” values
AMAI uses “N/D” to indicate missing data:

In numeric columns: AB, CPLUS, C, CMINUS, DPLUS, D, E

In categorical column: NSE_LABEL

Normalization rule:
Replace "N/D" with an empty cell ("") so that SQL imports it as:

Code
NULL = data not available
This prevents errors in:

- SUM()
- Percentage calculations
- Validations
- Pipeline consistency

1.7. Export to CSV (for SQL Import)

The CSV should contain:

Code
CVEGEO  AB  CPLUS   C   CMINUS  DPLUS   D   E   NSE_LABEL   TOTAL
0100100010017   0   12  39  111 153 331     D   648
010010001006A   178 124 60  24  9   4   0   A/B 399
0100100010106   183 375 247 128 62  32      C+  1028
0100100010163   35  157 228 167 124 78  0   C   789
0100100010182   345 187 63  46  13  6   0   A/B 660
0100100010229   25  36  14  20  9   7   0   C+  111
CSV Export Settings
Format: CSV

Separator: TAB

Encoding: UTF‑8 (no BOM)

No quotes

No trailing blank rows

No hidden columns

If needed, verify encoding using EditPad Pro or Notepad++.

1.8. Create SQL Table (SQL Server 2022)
sql
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[NSE_AMAI_2024_AGEB](
    [CVEGEO] [nvarchar](13) NOT NULL,
    [AB] [int] NULL,
    [CPLUS] [int] NULL,
    [C] [int] NULL,
    [CMINUS] [int] NULL,
    [DPLUS] [int] NULL,
    [D] [int] NULL,
    [E] [int] NULL,
    [NSE_LABEL] [nvarchar](10) NULL,
    [TOTAL] [int] NULL,
 CONSTRAINT [PK_NSE_AMAI_2024_AGEB] PRIMARY KEY CLUSTERED ([CVEGEO] ASC)
) ON [PRIMARY]
GO
1.9. Import CSV into SQL Server
sql
BULK INSERT NSE_AMAI_2024_AGEB
FROM 'D:\AMAI\NSE_AMAI_2024_AGEB_IMPORT.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);
1.10. Post‑Import Validations
✔ Check for duplicate CVEGEO
sql
SELECT CVEGEO, COUNT(*)
FROM NSE_AMAI_2024_AGEB
GROUP BY CVEGEO
HAVING COUNT(*) > 1;
✔ Validate TOTAL = sum of levels
sql
SELECT *
FROM NSE_AMAI_2024_AGEB
WHERE TOTAL <> (AB + CPLUS + C + CMINUS + DPLUS + D + E);
✔ Validate CVEGEO length (13 chars)
sql
SELECT *
FROM NSE_AMAI_2024_AGEB
WHERE LEN(CVEGEO) <> 13;
1.11. Final Result
Your final SQL table should look like:

Code
CVEGEO        AB  CPLUS  C   CMINUS  DPLUS  D   E   NSE_LABEL  TOTAL
0100100010017 0   12     39  111     153    331     D          648
010010001006A 178 124    60  24      9      4   0   A/B        399
0100100010106 183 375    247 128     62     32      C+         1028
0100100010163 35  157    228 167     124    78  0   C          789
0100100010182 345 187    63  46      13     6   0   A/B        660
0100100010229 25  36     14  20      9      7   0   C+         111
This table becomes the official AMAI input for all subsequent NSE calculation steps.
