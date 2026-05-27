# STEP 1 — AMAI Data Ingestion (NSE by AGEB)

Objective: Convert the official AMAI file `NSE_por_AGEB_AMAI.xlsx` into a normalized SQL table ready for the NSE pipeline.

## Suggested work directories

- D:\AXSI\AMAI (work files)
- D:\AXSI\AMAI\Download (download files)

---

## 1.1 Official Source File

AMAI publishes the dataset in its downloads section:

https://www.amai.org/descargas/NSE_por_AGEB_AMAI.xlsx

Depending on the browser, it may download directly as XLSX or open in the Office Online viewer:

https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fwww.amai.org%2Fdescargas%2FNSE_por_AGEB_AMAI.xlsx&wdOrigin=BROWSELINK

Important characteristics of the file:

- It does not include a year in the filename.
- It corresponds to the NSE 2024 methodology.

---

## 1.2 Original File Contents

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

Directory: D:\AXSI\AMAI   
File name: NSE_AMAI_2024_AGEB_IMPORT.xlsx   

---

## 1.3 Edit Excel to format columns as we need

#### Fix the headers, get rid of columns we don't need

Delete Rows:

- NOMBRE ENTIDAD
- NOMBRE MUNICIPIO
- NOMBRE LOCALIDAD
- TAMAÑO DE LOCALIDAD

[<img src="/docs/images/NSE_1.png" width="1000">](/docs/images/NSE_1.png)

File has merged cells as below, and we need to standarize headers:

TOTAL DE VIVIENDAS POR NIVEL SOCIOECONÓMICO   
AB     C+    C     C-     D+     D     E   

Create a new header below:  

[<img src="/docs/images/NSE_2.png" width="1000">](/docs/images/NSE_2.png)

Delete rows 1 and 2

[<img src="/docs/images/NSE_3.png" width="1000">](/docs/images/NSE_3.png)

---

## 1.4 Create CVEGEO by concatenating codes

### Add a new column to the left and name it **CVEGEO**

INEGI defines CVEGEO as the concatenation of:

- ENTIDAD (2 digits)
- MUNICIPIO (3 digits)
- LOCALIDAD (4 digits)
- AGEB (4 digits)

EE + MMM + LLLL + AAAA   with leading zeroes  

Example:  

01 + 001 + 0001 + 0163 = 0100100010163  

### Formula

= ENTIDAD & MUNICIPIO & LOCALIDAD & AGEB   

=TEXT(B2,"00") & TEXT(C2,"000") & TEXT(D2,"0000") & TEXT(E2,"0000")   

- Copy formula to all records
- **Copy calculated CVEGEO as Values**  
- Delete individual codes columns, we will use only CVEGEO:
  - ENTIDAD
  - MUNICIPIO
  - LOCALIDAD
  - AGEB

#### You Excel must look like this

[<img src="/docs/images/NSE_4.png" width="1000">](/docs/images/NSE_4.png)

---

## 1.5 Correction of “N/D” values

1. Numeric columns  
   AB, CPLUS, C, CMUNIS, DPLUS, D, E → AMAI uses “N/D” when there is insufficient information.

2. Categorical column  
   NSE (NIVEL_PREDOMINANTE) → “N/D” when no dominant socioeconomic level exists.

To ensure the pipeline works correctly, we use:

NULL = data not available

### Normalization rule

Replace "N/D" with an empty cell ("") so that when importing into SQL it becomes NULL.

This prevents errors in:

- SUM()
- Percentage calculations
- Validations
- Pipeline consistency

---

## 1.6 Export from Excel to CSV (TSV)

The CSV file should look like this (TAB‑delimited):

| CVEGEO        | NSE_AB  | NSE_CPLUS | NSE_C | NSE_CMINUS | NSE_DPLUS | NSE_D   | NSE_E   | NSE | NSE_TOTAL |
|---------------|---------|-----------|-------|------------|-----------|---------|---------|-----|-----------|
| 0100100010017 | 0   | 12     | 39  | 111     | 153    | 331 |     | D         | 648    |
| 010010001006A | 178 | 124    | 60  | 24      | 9      | 4   | 0   | A/B       | 399    |
| 0100100010106 | 183 | 375    | 247 | 128     | 62     | 32  |     | C+        | 1028   |
| 0100100010163 | 35  | 157    | 228 | 167     | 124    | 78  | 0   | C         | 789    |
| 0100100010182 | 345 | 187    | 63  | 46      | 13     | 6   | 0   | A/B       | 660    |
| 0100100010229 | 25  | 36     | 14  | 20      | 9      | 7   | 0   | C+        | 111    |

Save as:

Directory: D:\AXSI\AMAI   
File name: NSE_AMAI_2024_AGEB_IMPORT.csv   

### Export settings

- Format: CSV  
- Separator: TAB  
- Encoding: UTF‑8  
- Quotes: do not use quotes  
- No BOM (Excel exports UTF‑8 without BOM)  
- No empty rows at the end  
- No hidden columns  

If necessary, edit the CSV with EditPad Pro or Notepad++ to verify:

- UTF‑8 without BOM  
- TAB delimiter  

Note: I use TAB for my personal convenience, you can comma delimiter, just correct BULK INSERT to the appropriate FIELDTERMINATOR = ','.
(the reason always I use TAB since some Mexican data come with " in names, some also may have only one " so with with TAB is easy to debug).

---

## 1.7 Create Final AMAI SQL Table in MS SQL Server 2022

```sql
--------------------------------------------------------
-- 1.7 Create Final AMAI SQL Table in MS SQL Server 2022
--------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[NSE_AMAI_2024_AGEB](
    [CVEGEO] [nvarchar](13) NOT NULL,
    [NSE_AB] [int] NULL,
    [NSE_CPLUS] [int] NULL,
    [NSE_C] [int] NULL,
    [NSE_CMINUS] [int] NULL,
    [NSE_DPLUS] [int] NULL,
    [NSE_D] [int] NULL,
    [NSE_E] [int] NULL,
    [NSE] [nvarchar](10) NULL,
    [NSE_TOTAL] [int] NULL,
 CONSTRAINT [PK_NSE_AMAI_2024_AGEB] PRIMARY KEY CLUSTERED 
(
    [CVEGEO] ASC
) WITH (
    PAD_INDEX = OFF,
    STATISTICS_NORECOMPUTE = OFF,
    IGNORE_DUP_KEY = OFF,
    ALLOW_ROW_LOCKS = ON,
    ALLOW_PAGE_LOCKS = ON,
    OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [PRIMARY]
) ON [PRIMARY]
GO
```

### Expected result

Commands completed successfully.   
Completion time: 2026-05-24T17:09:53.0742807-05:00   

---

## 1.8 Import CSV into MS SQL Server 2022

Make sure the directory path matches where you saved the AMAI CSV file.

```sql
-----------------------------------------
-- 1.9 Import CSV into MS SQL Server 2022
-----------------------------------------
BULK INSERT NSE_AMAI_2024_AGEB
FROM 'D:\AXSI\AMAI\NSE_AMAI_2024_AGEB_IMPORT.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);
```

### Expected result

(246048 rows affected)   
Completion time: 2026-05-24T17:13:16.8534671-05:00   

---

## 1.9 Post‑Import Validations

### Validate duplicate CVEGEO values

```sql
-------------------------------
-- 1.10 Post‑Import Validations
-------------------------------

### Validate that TOTAL = sum of socioeconomic levels

```sql
----------------------------------------------------
-- Validate that TOTAL = sum of socioeconomic levels
----------------------------------------------------
SELECT *
FROM NSE_AMAI_2024_AGEB
WHERE NSE_TOTAL <> (NSE_AB + NSE_CPLUS + NSE_C + NSE_CMINUS + NSE_DPLUS + NSE_D + NSE_E);
```

#### Exprected result

CVEGEO	NSE_AB	NSE_CPLUS	NSE_C	NSE_CMINUS NSE_DPLUS NSE_D NSE_E NSE NSE_TOTAL
None
(this means there is no difference between total vs sum of components)

### Validate correct CVEGEO length (13 characters)

```sql
-------------------------------------------------
-- Validate correct CVEGEO length (13 characters)
-------------------------------------------------
SELECT *
FROM NSE_AMAI_2024_AGEB
WHERE LEN(CVEGEO) <> 13;
```

#### Exprected result

CVEGEO	NSE_AB	NSE_CPLUS	NSE_C	NSE_CMINUS	NSE_DPLUS	NSE_D	NSE_E	NSE	NSE_TOTAL  
None  
(this means all CVEGEO are 13 characters: EEMMMLLLLAAAA)  

## 1.10 Final Result

Your final table IN SQL should look like this:

```sql
-------------------
-- Show top 20 rows
-------------------
SELECT TOP (20) CVEGEO, AB, CPLUS, C, CMINUS, DPLUS, D, E, NSE, TOTAL FROM dbo.NSE_AMAI_2024_AGEB
```

| CVEGEO        | NSE_AB  | NSE_CPLUS | NSE_C   | NSE_CMINUS | NSE_DPLUS | NSE_D   | NSE_E   | NSE | NSE_TOTAL |
|---------------|-----|--------|-----|---------|--------|-----|-----|-----------|--------|
| 0100100010017 | 0   | 12     | 39  | 111     | 153    | 331 |     | D         | 648    |
| 010010001006A | 178 | 124    | 60  | 24      | 9      | 4   | 0   | A/B       | 399    |
| 0100100010106 | 183 | 375    | 247 | 128     | 62     | 32  |     | C+        | 1028   |
| 0100100010163 | 35  | 157    | 228 | 167     | 124    | 78  | 0   | C         | 789    |
| 0100100010182 | 345 | 187    | 63  | 46      | 13     | 6   | 0   | A/B       | 660    |
| 0100100010229 | 25  | 36     | 14  | 20      | 9      | 7   | 0   | C+        | 111    |

This table is the official AMAI source for the **NSE calculation steps**.  




