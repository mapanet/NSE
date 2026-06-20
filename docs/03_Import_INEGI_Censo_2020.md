# 3 — INEGI Census 2020 (Locality-Level Data)

This dataset contains **Census 2020 population and dwelling data at the LOCALITY level**  
It is a enrichment input for the Boundaries layer 6 Population, Dwellings, Occupied_Dwellings.

---

## 📌 Important Clarifications

- We create a **Census 2020 locality-level dataset** to obtain **Population**, **Dwellings**, and **Occupied_Dwellings** at the **LOCALITY** level.
- This dataset is used in **NSE Step 5.9.1** to update **Population, Dwellings, Occupied_Dwellings in boundaries layer 6 (DCAH Neighborhoods).
- Later we can compute: Unoccupied_Dwellings = Dwellings – Occupied_Dwellings

## Resulting Table: `INEGI_Censo_2020_AGEB`

| Column | Type | Notes |
|--------|------|--------|
| CVEGEO | varchar(13) | Geocode (ENTIDAD + MUN + LOC |
| ENTIDAD | varchar(2) | State code |
| NOM_ENT | nvarchar(85) | State name |
| MUN | varchar(3) | Municipality code |
| NOM_MUN | nvarchar(85) | Municipality name |
| LOC | varchar(4) | Locality code |
| NOM_LOC | nvarchar(110) | Locality name |
| LATITUD | decimal(12, 6) | Latitude |
| LONGITUD | decimal(12, 6) | Longitude |
| POBTOT | int | Population |
| VIVTOT | int | Dwelings |
| TVIVHAB | int | Occupied Dwelings |

Working folder:

D:\AXSI\INEGI\Censo_2020\Tabulados_AGEB_Localidad


---

# 3.1 — Download Census 2020 Data (SCITEL)

We download Census 2020 block-level data from **INEGI SCITEL**:

**URL:**  
https://www.inegi.org.mx/app/scitel/Default?ev=9  
**Section:** *Resultados por loccalidad (ITER) 2020*

[<img src="/docs/images/Censo_2020_ITER_localidad.png" width="1000">](/docsCenso_2020_ITER_localidad.png)

---

### IMPORTANT — Do NOT use the gray CSV or XLSX buttons

In the **left panel**, you will see **gray CSV and XLSX** buttons.  
These export the **full dataset**, which contains to many fields we do not need.

We only want:

- **Population Total**  
- **Total Dwellings**  
- **Occupied Dwellings**  

---

## ✔ Download Procedure

In the **right panel**, select:

1. **Identificación geográfica** → all checked  
2. **Población** → *Población total*  
3. **Vivienda** → *Total de viviendas*  
4. **Vivienda** → *Total de viviendas habitadas*  

Repeat for All 32 States:

1. In the **left panel**, select a state (example: *Aguascalientes*).  
2. Bottom‑right → click **Generar Consulta** (Generate Query).  
3. Bottom‑center → click **Exportar a → CSV**.  
4. Save the file into:

D:\AXSI\INEGI\Censo_2020\Tabulados_AGEB_Localidad  

5. Click the browser **Back** button and select the next state.

Example results:

[<img src="/docs/images/Censo_2020_3.png" width="1000">](/docs/images/Censo_2020_3.png)

---

## ✔ Verify All 32 Files Are Downloaded

| File Name |
|-----------|
| ITER2020 - 01 Aguascalientes.csv |
| ITER2020 - 02 Baja California.csv |
| ITER2020 - 03 Baja California Sur.csv |
| ITER2020 - 04 Campeche.csv |
| ITER2020 - 05 Coahuila de Zaragoza.csv |
| ITER2020 - 06 Colima.csv |
| ITER2020 - 07 Chiapas.csv |
| ITER2020 - 08 Chihuahua.csv |
| ITER2020 - 09 Ciudad de México.csv |
| ITER2020 - 10 Durango.csv |
| ITER2020 - 11 Guanajuato.csv |
| ITER2020 - 12 Guerrero.csv |
| ITER2020 - 13 Hidalgo.csv |
| ITER2020 - 14 Jalisco.csv |
| ITER2020 - 15 México.csv |
| ITER2020 - 16 Michoacán de Ocampo.csv |
| ITER2020 - 17 Morelos.csv |
| ITER2020 - 18 Nayarit.csv |
| ITER2020 - 19 Nuevo León.csv |
| ITER2020 - 20 Oaxaca.csv |
| ITER2020 - 21 Puebla.csv |
| ITER2020 - 22 Querétaro.csv |
| ITER2020 - 23 Quintana Roo.csv |
| ITER2020 - 24 San Luis Potosí.csv |
| ITER2020 - 25 Sinaloa.csv |
| ITER2020 - 26 Sonora.csv |
| ITER2020 - 27 Tabasco.csv |
| ITER2020 - 28 Tamaulipas.csv |
| ITER2020 - 29 Tlaxcala.csv |
| ITER2020 - 30 Veracruz.csv |
| ITER2020 - 31 Yucatán.csv |
| ITER2020 - 32 Zacatecas.csv |

---

# 3.2 — Concatenate All Files into One Clean CSV (TSV)

### Purpose
Combine all 32 state CSV files into a single **UTF‑8 (no BOM)**, **TAB‑separated** file ready for SQL Server bulk import.

### Output File

ITER2020_ALL_TAB.csv

- Encoding: **UTF‑8 no BOM**  
- Separator: **TAB**  
- Replace all `*` with empty string (NULL in SQL)

### Python Script

```python
import pandas as pd
import glob

# List all locality-level CSV files
csv_files = glob.glob(r"D:\AXSI\INEGI\Censo_2020\Tabulados_AGEB_Localidad\ITER2020 - *.csv")

dfs = []
for f in csv_files:
    print("Reading:", f)
    # Force codes to be strings
    df = pd.read_csv(f, dtype={
        "ENTIDAD": str,
        "MUN": str,
        "LOC": str
    })
    # Remove asterisks
    df = df.replace(r"\*", "", regex=True)
    dfs.append(df)

# Merge all files
merged = pd.concat(dfs, ignore_index=True)

# Save tab-separated file
output_path = r"D:\AXSI\INEGI\Censo_2020\Tabulados_AGEB_Localidad\ITER2020_ALL_TAB.csv"
merged.to_csv(output_path, index=False, sep="\t")

print("Merged file saved to:", output_path)
```

### Full Phyton Script

[Concatenate_ALL_ITER2020.py](../scripts/Concatenate_ALL_ITER2020.py)

---

### 2.3.1 Convert Latutude HHMMSS to decimal, add CVEGEO

### Output File

ITER2020_ALL_COORDS_TAB.csv

- Encoding: **UTF‑8 no BOM**  
- Separator: **TAB**  
- Replace any `*` with empty string (NULL in SQL)
- Converts Latitude and Longitude from HHMMSS to decinal ESPG:4326
- Checks Altitude to be integer (some fields have dash like "00-2"

### Python Script

```python
import csv
import os

def dms_to_decimal(dms_str):
    """
    Convert DMS (degrees°minutes'seconds"Direction) to decimal degrees.
    Example input: "102°17'45.768\" W"
    """
    try:
        parts = dms_str.replace("°"," ").replace("'"," ").replace('"'," ").split()
        deg, minutes, seconds, direction = parts
        decimal = float(deg) + float(minutes)/60 + float(seconds)/3600
        if direction.upper() in ['S','W']:
            decimal *= -1
        return round(decimal, 6)
    except Exception:
        return None

def process_file():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    input_file = os.path.join(base_dir, "ITER2020_ALL_TAB.csv")
    output_file = os.path.join(base_dir, "ITER2020_ALL_COORDS_TAB.csv")

    with open(input_file, newline='', encoding='utf-8') as infile, \
         open(output_file, 'w', newline='', encoding='utf-8') as outfile:

        reader = csv.DictReader(infile, delimiter='\t')

        # Build new header order: CVEGEO first
        fieldnames = ['CVEGEO'] + [fn for fn in reader.fieldnames if fn not in ['LATITUD','LONGITUD']]
        # Place LATITUD and LONGITUD together before ALTITUD
        alt_index = fieldnames.index('ALTITUD')
        fieldnames.insert(alt_index, 'LATITUD')
        fieldnames.insert(alt_index+1, 'LONGITUD')

        writer = csv.DictWriter(outfile, fieldnames=fieldnames, delimiter='\t')
        writer.writeheader()

        written, skipped = 0, 0

        for row in reader:
            loc = row.get('LOC','').strip()
            lat = row.get('LATITUD','').strip()
            lon = row.get('LONGITUD','').strip()
            alt = row.get('ALTITUD','').strip()

            if not lat or not lon or loc in ['0000','9998','9999']:
                skipped += 1
                continue

            # Build CVEGEO = ENTIDAD + MUN + LOC
            row['CVEGEO'] = f"{row.get('ENTIDAD','').strip()}{row.get('MUN','').strip()}{loc}"

            # Convert coordinates
            row['LATITUD'] = dms_to_decimal(lat)
            row['LONGITUD'] = dms_to_decimal(lon)

            # Clean and force ALTITUD to integer
            if alt:
                alt_clean = alt.replace('-', '')  # remove dashes
                try:
                    row['ALTITUD'] = int(float(alt_clean))
                except:
                    row['ALTITUD'] = None
            else:
                row['ALTITUD'] = None

            # Force population and housing counts to integers
            for col in ['POBTOT','VIVTOT','TVIVHAB']:
                try:
                    row[col] = int(float(row[col]))
                except:
                    pass

            writer.writerow(row)
            written += 1

    print(f"Finished. Written: {written} rows, Skipped: {skipped} rows.")

if __name__ == "__main__":
    process_file()
```

### Full Phyton Script

The full script used to concatenate all 32 state files into a single clean CVS (TSV) is available here:

[convert_coords.py](../scripts/convert_coords.py)


### Expected Output File

After running the script, you should have:

ITER2020_ALL_COORDS_TAB.csv

You can open the file using **EditPad Pro**, **Notepad++**, or **VS Code** and verify:

- Encoding: **UTF‑8 (No BOM)**
- Separator: **TAB**
- No asterisks (`*`)
- All rows aligned and complete

Example rows:

| CVEGEO  | ENTIDAD | NOM_ENT        | MUN | NOM_MUN      | LOC | NOM_LOC                        | LATITUD |  LONGITUD | ALTITUD | POBTOT | VIVTOT | TVIVHAB |
|---------|---------|----------------|-----|--------------|-----|--------------------------------|---------|-----------|---------|--------|--------|---------|
|010010001|       01|Aguascalientes	|001   |Aguascalientes|0001 |Aguascalientes                  |21.879823|-102.296047|     1878|  863893|  286646|   246259|
|010010094|       01|Aguascalientes	|001   |Aguascalientes|0094 |Granja Adelita                  |21.871875|-102.373531|     1902|       5|       3|        2|
|010010096|       01|Aguascalientes	|001   |Aguascalientes|0096 |Agua Azul                       |21.883756|-102.357122|     1861|      41|      15|       12|
|010010102|       01|Aguascalientes	|001   |Aguascalientes|0102 |Los Arbolitos [Rancho]          |21.780181|-102.357295|     1861|       8|       2|        2|
|010010104|       01|Aguascalientes	|001   |Aguascalientes|0104 |Ardillas de Abajo (Las Ardillas)|21.945068|-102.191921|     1989|       1|       8|        1|
|010010106|       01|Aguascalientes	|001   |Aguascalientes|0106 |Arellano                        |21.801773|-102.273955|     1892|    1169|     318|      281|
|010010112|       01|Aguascalientes	|001   |Aguascalientes|0112 |Bajío los Vázquez               |21.747494|-102.124817|     1971|      41|      16|        9|
|010010120|       01|Aguascalientes	|001   |Aguascalientes|0120 |Buenavista de Peñuelas          |21.719147|-102.293195|     1871|    1054|     329|      255|
|010010121|       01|Aguascalientes	|001   |Aguascalientes|0121 |Cabecita 3 Marías (Rancho Nuevo)|21.774682|-102.412992|     1908|     192|      64|       47|

---

# 3.3 — Import CSV into SQL Server

Create table INEGI_Censo_2020 in MS SQL 2022.    

```sql
----------------------------
-- 3.3 — Import CSV into SQL
----------------------------

----------------------------------------------------------------
-- 3.3.1 Create table INEGI_Censo_2020 (Census 2020 by Locality)
----------------------------------------------------------------
DROP TABLE IF EXISTS INEGI_Censo_2020;
GO

CREATE TABLE [dbo].[INEGI_Censo_2020](
	[CVEGEO] [nvarchar](13) NOT NULL,
	[ENTIDAD] [varchar](2) NULL,
	[NOM_ENT] [nvarchar](85) NULL,
	[MUN] [varchar](3) NULL,
	[NOM_MUN] [nvarchar](85) NULL,
	[LOC] [varchar](4) NULL,
	[NOM_LOC] [nvarchar](110) NULL,
	[LATITUD] [decimal](12, 6) NULL,
	[LONGITUD] [decimal](12, 6) NULL,
	[ALTITUD] [int] NULL,
	[POBTOT] [int] NULL,
	[VIVTOT] [int] NULL,
	[TVIVHAB] [int] NULL,
 CONSTRAINT [PK_INEGI_Censo_2020] PRIMARY KEY CLUSTERED 
(
	[CVEGEO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

--------------------
-- 3.3.2 Bulk Insert
--------------------
BULK INSERT INEGI_Censo_2020
FROM 'D:\AXSI\INEGI\Censo_2020\Tabulados_AGEB_Localidad\ITER2020_ALL_COORDS_TAB.csv'
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

(189432 rows affected)      


Test query:

```sql
------------------------
-- List first 10 records
------------------------
SELECT        TOP (10) CVEGEO, ENTIDAD, NOM_ENT, MUN, NOM_MUN, LOC, NOM_LOC, LATITUD, LONGITUD, ALTITUD, POBTOT, VIVTOT, TVIVHAB FROM dbo.INEGI_Censo_2020
```

| CVEGEO  | ENTIDAD | NOM_ENT        | MUN | NOM_MUN      | LOC | NOM_LOC                        | LATITUD |  LONGITUD | ALTITUD | POBTOT | VIVTOT | TVIVHAB |
|---------|---------|----------------|-----|--------------|-----|--------------------------------|---------|-----------|---------|--------|--------|---------|
|010010001|       01|Aguascalientes	|001   |Aguascalientes|0001 |Aguascalientes                  |21.879823|-102.296047|     1878|  863893|  286646|   246259|
|010010094|       01|Aguascalientes	|001   |Aguascalientes|0094 |Granja Adelita                  |21.871875|-102.373531|     1902|       5|       3|        2|
|010010096|       01|Aguascalientes	|001   |Aguascalientes|0096 |Agua Azul                       |21.883756|-102.357122|     1861|      41|      15|       12|
|010010102|       01|Aguascalientes	|001   |Aguascalientes|0102 |Los Arbolitos [Rancho]          |21.780181|-102.357295|     1861|       8|       2|        2|
|010010104|       01|Aguascalientes	|001   |Aguascalientes|0104 |Ardillas de Abajo (Las Ardillas)|21.945068|-102.191921|     1989|       1|       8|        1|
|010010106|       01|Aguascalientes	|001   |Aguascalientes|0106 |Arellano                        |21.801773|-102.273955|     1892|    1169|     318|      281|
|010010112|       01|Aguascalientes	|001   |Aguascalientes|0112 |Bajío los Vázquez               |21.747494|-102.124817|     1971|      41|      16|        9|
|010010120|       01|Aguascalientes	|001   |Aguascalientes|0120 |Buenavista de Peñuelas          |21.719147|-102.293195|     1871|    1054|     329|      255|
|010010121|       01|Aguascalientes	|001   |Aguascalientes|0121 |Cabecita 3 Marías (Rancho Nuevo)|21.774682|-102.412992|     1908|     192|      64|       47|

---



---
