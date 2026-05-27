# 4.1 INEGI DCAH 2025 (Neighborhood Polygons)

This document describes the process to import the **INEGI DCAH 2025** dataset, which contains the official polygon boundaries of neighborhoods (*colonias*) and other human settlements in Mexico.  
These geometries are used to build **Boundaries Layer 6**, where the AMAI Socioeconomic Level (NSE) is calculated for each neighborhood.

33 Suggested working directories

Working directory: D:\INEGI\DCAH_2025
Download directory: D:\INEGI\DCAH_2025\Download

---

## Dataset Description

**Source:** INEGI — *Delimitación de colonias y otros asentamientos humanos (DCAH)*  
**Edition (edicion):** 2025  
**Coverage (cobertura):** 2025‑01‑01 to 2025‑12‑31  
**Datum:** ITRF2008, Ellipsoid GRS80  
**File type (tipo de archivo):** SHP (530.26 MB)  
**Download URL:** [https://www.inegi.org.mx/programas/dcah/#descargas](https://www.inegi.org.mx/programas/dcah/#descargas)

---

## 4.1 Download data

1. Open the INEGI DCAH download page:  
   [https://www.inegi.org.mx/programas/dcah/#descargas](https://www.inegi.org.mx/programas/dcah/#descargas)

2. In the **Filters** section, leave all options as default:
   - **Entity:** Estados Unidos Mexicanos  
   - **Scale:** Sin escala  
   - **Edition:** (leave blank)

3. Click **Consultar** or **Buscar** to display available editions.

4. From the results table, select:
   - **Delimitación de colonias y otros asentamientos humanos 2025**  
   - File type: **SHP**  
   - Size: **530.26 MB**

5. Download the ZIP file and extract the contents into:

Directory: D:\INEGI\DCAH_2025\Download
File name: **794551163078_s.zip** 2025 edition

Inside you will find a series of zip's by state and one named: 00_integrado.zip that contain data of all states.
Extract the files is BOLD:

- 00_integrado.zip
  - conjunto_de_datos
      - **00as.shp** (SHP file main) Datum: ITRF2008
      - **00as.cpg** (SHP file accesory)
      - **00as.dbf** (SHP file accesory)
      - **00as.prj** (SHP file accesory)
      - **00as.sbn** (SHP file accesory)
      - **00as.sbx** (SHP file accesory)
      - **00as.shx** (SHP file accesory)

Dataset include:

| Field | Description |
|-------|--------------|
| **CVEGEO** | cvegeo code 13 digits EEMMMLLLLAAAA (EE state, MMM municipality LLLL City AAAA Neighborhood |
| **CVE_ENT** | State code |
| **CVE_MUN** | Municipality code |
| **CVE_LOC** | Locality code |
| **CVE_ASEN** | Locality code |
| **CP** | Postal code |
| **FECHA_ACT** | Last Update MM/YYYY |
| **INSTITUCIO** | Source name |
| **NOM_ASEN** | Neighborhood name |
| **TIPO** | Category name (Fraccionamiento, Colonia, etc. (Urbanization type) |
| **geom** | Neighborhood boundary polygon |

---

## 4.2 Load the 00as.shp into QGIS


Verify NOM_ASEN is legible (data originally is Windows-1252 but file is load as UTF-8)
(if needed, use layer Properties > Source > Windows-1252 to set encoding, check accents in Attributes table)

Export it as:

Directory: D:\AXSI\INEGI\DCAH_2025
File name: Boundaries_INEGI_DCAH_2025.shp
CRS: **ESPG:4023**
Encoding: **UTF-8**

- Delete source 00as.shp layer in QGIS

---

# 4.3 Save as CSV with WKT geometries

Export Boundaries_INEGI_DCAH_2025 layer to CSV with WKT geometries

Directory: D:\AXSI\INEGI\DCAH_2025
File name: Boundaries_INEGI_DCAH_2025.CSV
CRS: **ESPG:4023**
Encoding: **UTF-8**
Geomtry: **As WKT**
Delimirer: **TAB**
String quting: **IF_NEEDED**
Write BOM: **NO**
Add saved file to MAP: **Uncheck**

Save "OK"

----

Edit Boundaries_INEGI_DCAH_2025.CSV with NotePad Pro or Notepad+

Replace all " created in the geometries "MULTIPOLYGON ((( ... )))"

Save file, making sure is **UTF-8*** and **No BOM**

### Result file

| Field | Description |
|-------|--------------|
| **WTK** | Neighborhood boundary polygon |
| **CVEGEO** | cvegeo code 13 digits
| **CVE_ENT** | State code |
| **CVE_MUN** | Municipality code |
| **CVE_LOC** | Locality code |
| **CVE_ASEN** | Locality code |
| **CP** | Postal code |
| **FECHA_ACT** | Last Update MM/YYYY |
| **INSTITUCIO** | Source name |
| **NOM_ASEN** | Neighborhood name |
| **TIPO** | Category name (Fraccionamiento, Colonia, etc. (Urbanization type) |

# 4.4 Upload CSV geometries to SQL







## Next Steps

After importing the DCAH polygons:

1. Validate geometry integrity (no empty or self‑intersecting polygons).  
2. Normalize keys **CVEGEO** = CVE_ENT + CVE_MUN + CVE_LOC + CVE_ASEN  
3. Intersect with AGEB geometries from **INEGI MG 2025**.  
4. Apply area‑weighted NSE aggregation using **AMAI 2024** and **Census 2020** data.  
5. Generate the final **Layer 6 NSE dataset**.

---

**Result:**  
A complete, validated neighborhood‑level dataset ready for NSE calculation, mapping, and API integration.

