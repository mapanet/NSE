# 21 — INEGI Census 2020 (Block-Level Data)

This dataset contains **Census 2020 population and dwelling data at the block level**  
(AGEB + Manzana). It is a core input for the NSE pipeline.

---

## 📌 Important Clarifications

- We create a **Census 2020 block-level dataset** to obtain **Population**, **Dwellings**, and **Occupied_Dwellings** at the **Manzana (Block)** level.
- This dataset is used in **NSE Step 5.9** to update **Population** and **Dwellings** at the **Neighborhood (Colonia)** level using weighted aggregation.
- It can also be aggregated to obtain totals at the **AGEB**, **City**, **Municipality**, and **State** levels.
- Later we can compute: Unoccupied_Dwellings = Dwellings – Occupied_Dwellings

### Terminology

| Spanish | English | Meaning |
|---------|---------|---------|
| AGEB | Basic Geo‑Statistical Area | INEGI statistical unit |
| Manzana | Block | Smallest urban unit |

---

## Resulting Table: `INEGI_Censo_2020_AGEB`

| Column | Type | Notes |
|--------|------|--------|
| ENTIDAD | varchar(2) | State code |
| NOM_ENT | nvarchar(85) | State name |
| MUN | varchar(3) | Municipality code |
| NOM_MUN | nvarchar(85) | Municipality name |
| LOC | varchar(4) | Locality code |
| NOM_LOC | nvarchar(110) | Locality name |
| AGEB | varchar(4) | Area code |
| MZA | varchar(4) | Block code |
| POBTOT | int | Population |
| VIVTOT | int | Dwelings |
| TVIVHAB | int | Occupied Dwelings |

Working folder:

D:\AXSI\INEGI\Censo_2020\Download


---

# 1 — Download Census 2020 Data (SCITEL)

We download Census 2020 block-level data from **INEGI SCITEL**:

**URL:**  
https://www.inegi.org.mx/app/scitel/Default?ev=10  
**Section:** *Resultados por AGEB y Manzana Urbana*

[<img src="/docs/images/Censo_2020_1.png" width="1000">](/docs/images/Censo_2020_1.png)


### IMPORTANT — Do NOT use the gray CSV or XLSX buttons

In the **left panel**, you will see **gray CSV and XLSX** buttons.  
These export the **full dataset**, which contains to many fields we do not need.

We only want:

- **Population Total**  
- **Total Dwellings**  
- **Occupied Dwellings**  

---

## ✔ Download Procedure (Repeat for All 32 States)

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

D:\AXSI\INEGI\Censo_2020\Tabulados_AGEB_Manzana   

Click the browser **Back** button and select the next state.

Example results:

[<img src="/docs/images/Censo_2020_3.png" width="1000">](/docs/images/Censo_2020_3.png)


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



# 2 — Concatenate All Files into One Clean CSV (TSV)

### Purpose
Combine all 32 state CSV files into a single **UTF‑8 (no BOM)**, **TAB‑separated** file ready for SQL Server bulk import.

### Output File

RESAGEBURB2020_ALL_TAB.csv

- Encoding: **UTF‑8 no BOM**  
- Separator: **TAB**  
- Replace all `*` with empty string (NULL in SQL)

### Python Script

```python
import pandas as pd
import glob

# List all CSV files
csv_files = glob.glob(r"D:\AXSI\INEGI\Censo_2020\Tabulados_AGEB_Manzana\RESAGEBURB2020 - *.csv")

dfs = []
for i, f in enumerate(csv_files):
    print("Reading:", f)
    # Force codes to be strings
    df = pd.read_csv(f, dtype={
        "ENTIDAD": str,
        "MUN": str,
        "LOC": str,
        "AGEB": str,
        "MZA": str
    })
    dfs.append(df)

merged = pd.concat(dfs, ignore_index=True)

# Save as comma-separated
# merged.to_csv(r"D:\AXSI\INEGI\Censo_2020\Tabulados_AGEB_Manzana\RESAGEBURB2020_ALL_COMA.csv", index=False)
# Save tab separated
merged.to_csv(r"D:\AXSI\INEGI\Censo_2020\Tabulados_AGEB_Manzana\RESAGEBURB2020_ALL_TAB.csv", index=False, sep="\t")
```


### Full Phyton Script

The full script used to concatenate all 32 state files into a single clean CVS (TSV) is available here:

[Concatenate_ALL_RESAGEBURB2020.py](../scripts/Concatenate_ALL_RESAGEBURB2020.py)


### Expected Output File

After running the script, you should have:

RESAGEBURB2020_ALL_TAB.csv

You can open the file using **EditPad Pro**, **Notepad++**, or **VS Code** and verify:

- Encoding: **UTF‑8 (No BOM)**
- Separator: **TAB**
- No asterisks (`*`)
- All rows aligned and complete

Example rows:

| ENTIDAD | NOM_ENT        |     MUN | NOM_MUN                            |     LOC | NOM_LOC                      | AGEB | MZA | POBTOT | VIVTOT | TVIVHAB |
|---------|----------------|---------|------------------------------------|---------|------------------------------|------|-----|--------|--------|---------|
| 01      | Aguascalientes | 000     | Total de la entidad Aguascalientes | 0000    | Total de la entidad          | 0000 | 000 | 1425607 | 463972 | 386671 |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0000    | Total del municipio          | 0000 | 000 | 948990  | 313256 | 266942 |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Total de la localidad urbana | 0000 | 000 | 863893  | 286646 | 246259 |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Total AGEB urbana            | 0017 | 000 | 2237    | 1288   | 648    |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Aguascalientes               | 0017 | 011 | 115     | 80     | 33     |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Aguascalientes               | 0017 | 012 | 39      | 23     | 10     |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Aguascalientes               | 0017 | 018 | 0       | 80     |        |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Aguascalientes               | 0017 | 019 | 0       | 39     |        |



# 3 — Import CSV into SQL Server

We first import the raw CSV into  INEGI_Censo_2020_AGEB.    
This table mirrors the structure of the SCITEL export. 

```sql
----------------------
-- Import CSV into SQL
--
-- Create table INEGI_Censo_2020_AGEB (Census 2020 by AGEB and Block)
---------------------------------------------------------------------------
DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB;
GO

CREATE TABLE INEGI_Censo_2020_AGEB (
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
FROM 'D:\AXSI\INEGI\Censo_2020\Tabulados_AGEB_Manzana\RESAGEBURB2020_ALL_TAB.csv'
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


Test query:

```sql
------------------------
-- List first 10 records
------------------------
SELECT TOP (10) ENTIDAD, NOM_ENT, MUN, NOM_MUN, LOC, NOM_LOC, AGEB, MZA, POBTOT, VIVTOT, TVIVHAB FROM dbo.INEGI_Censo_2020_AGEB;
```

| ENTIDAD | NOM_ENT (state)|     MUN | NOM_MUN (municipality)             |     LOC | NOM_LOC (locality)           | AGEB | MZA | POBTOT (population) | VIVTOT (dwellings) | TVIVHAB (occupied dwellings) |
|---------|----------------|---------|------------------------------------|---------|------------------------------|------|-----|--------|--------|---------|
| 01      | Aguascalientes | 000     | Total de la entidad Aguascalientes | 0000    | Total de la entidad          | 0000 | 000 | 1425607 | 463972 | 386671 |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0000    | Total del municipio          | 0000 | 000 | 948990  | 313256 | 266942 |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Total de la localidad urbana | 0000 | 000 | 863893  | 286646 | 246259 |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Total AGEB urbana            | 0017 | 000 | 2237    | 1288   | 648    |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Aguascalientes               | 0017 | 011 | 115     | 80     | 33     |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Aguascalientes               | 0017 | 012 | 39      | 23     | 10     |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Aguascalientes               | 0017 | 018 | 0       | 80     |        |
| 01      | Aguascalientes | 001     | Aguascalientes                     | 0001    | Aguascalientes               | 0017 | 019 | 0       | 39     |        |



# 4 — Update Population y Dwellings in Boundaries_AGEB_2025

```sql
----------------------------------------------------------------------------------------------------------
-- Censo 2020 Step 3.4 — Update Population y Dwellings in Boundaries_AGEB_2025
--
-- NOTE: AGEB polygons are 2025, Census 2020 is block level so just cover Urban areas (no Rural) 
-- There is no Census at AGEB Level.
-- Census at Locality level "9" does, however it may not match Boundaries Neighborhoods, but will see
-- So we are updating poulation in AGEB 2025 to enrich the data and see if helps in the AMAI interpolation
-- Number of record that will update with Population: 35668 or 85000+ Urban not unpdated: 29140
--
-- We will test Censo 2020 at locality level match Neighborhood or AGEMLL 2025 does
----------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB_SUMMARY;
GO

SELECT
    RIGHT('00' + ENTIDAD, 2) +
    RIGHT('000' + MUN, 3) +
    RIGHT('0000' + LOC, 4) +
    RIGHT('0000' + AGEB, 4) AS CVEGEO,
    SUM(VIVTOT) AS VIVTOT,
    SUM(TVIVHAB) AS TVIVHAB,
    SUM(POBTOT) AS POBTOT
INTO INEGI_Censo_2020_AGEB_SUMMARY
FROM INEGI_Censo_2020_AGEB
WHERE LOC <> '0000'
  AND AGEB <> '0000'
  AND MZA <> '000'
GROUP BY
    RIGHT('00' + ENTIDAD, 2) +
    RIGHT('000' + MUN, 3) +
    RIGHT('0000' + LOC, 4) +
    RIGHT('0000' + AGEB, 4);


-- Update Population y Dwellings in Boundaries_AGEB_2025 from Census 2020

UPDATE B
SET 
    B.Population = C.POBTOT,
    B.Dwellings = C.VIVTOT,
    B.Occupied_Dwellings = C.TVIVHAB
FROM Boundaries_AGEB_2025 B
LEFT JOIN INEGI_Censo_2020_AGEB_SUMMARY C
    ON B.CVEGEO = C.CVEGEO;
GO


-- How many AGEB updated with data ?

SELECT COUNT(*) AS AGEB_con_Population 
FROM Boundaries_AGEB_2025
WHERE Population IS NOT NULL;

-- How namy AGENs left without data ?

SELECT COUNT(*) AS AGEB_sin_Population 
FROM Boundaries_AGEB_2025
WHERE Population IS NULL;

-- See some Urban AGEB without data

SELECT CVEGEO, Type, Population, Dwellings, Occupied_Dwellings
FROM Boundaries_AGEB_2025
WHERE Population IS NULL
AND Type = 'Urbana'
ORDER BY CVEGEO;

-- Delete Summary

DROP TABLE IF EXISTS INEGI_Censo_2020_AGEB_SUMMARY;
GO
```


# 5 — Final Validations

After loading the final table, we run a set of validation queries to confirm:

- The expected number of records was written
- All CVEGEO codes are correctly generated with 16 digits
- The staging table can be safely removed

### ✔ Validate Record Count

```sql
----------------
-- Count records
----------------
SELECT COUNT(*) AS Records_Written
FROM INEGI_Censo_2020_AGEB;
```

#### Expected results

Records_Written: 863069
This confirms that all block‑level rows from the 32 states were successfully imported (same count as in the CSV).

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

- All codes concatenated correctly give 16 characters
- No missing digits
- No malformed CVEGEO values






