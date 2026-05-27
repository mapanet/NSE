# 4 — INEGI DCAH 2025 (Neighborhood Polygons)

This document describes the process to import the **INEGI DCAH 2025** dataset, which contains the official polygon boundaries of neighborhoods (*colonias*) and other human settlements in Mexico.  
These geometries are used to build **Boundaries Layer 6**, where the AMAI Socioeconomic Level (NSE) is calculated for each neighborhood.

---

## Dataset Description

**Source:** INEGI — *Delimitación de colonias y otros asentamientos humanos (DCAH)*  
**Edition (edicion):** 2025  
**Coverage (cobertura):** 2025‑01‑01 to 2025‑12‑31  
**Datum:** ITRF2008, Ellipsoid GRS80  
**File type (tipo de archivo):** SHP (530.26 MB)  
**Download URL:** [https://www.inegi.org.mx/programas/dcah/#descargas](https://www.inegi.org.mx/programas/dcah/#descargas)

---

## How to Download

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

D:\INEGI\DCAH

File of 2025 is **794551163078_s.zip**

Inside you will find a series of zip's by state and one named: 00_integrado.zip that contain data of all states.
Extract the files is BOLD:

- 00_integrado.zip
  - catalogos
      - **asentamientos_humanos.csv** (list of neighbohoods)
  - conjunto_de_datos
      - **00as.shp** (SHP file main) Datum: ITRF2008
      - **00as.cpg** (SHP file accesory)
      - **00as.dbf** (SHP file accesory)
      - **00as.prj** (SHP file accesory)
      - **00as.sbn** (SHP file accesory)
      - **00as.sbx** (SHP file accesory)
      - **00as.shx** (SHP file accesory)


---

## File Contents

The dataset includes:

| Field | Description |
|-------|--------------|
| **Polygon geometry** | Neighborhood boundaries |
| **NOM_COLONIA** | Neighborhood name |
| **CVE_ENT** | State code |
| **CVE_MUN** | Municipality code |
| **CVE_LOC** | Locality code |
| *(No population data)* | — |
| *(No dwelling data)* | — |

---

## Purpose in the NSE Pipeline

This dataset is used to:

- Build **Boundaries Layer 6** (Neighborhoods)  
- Perform **spatial intersection** with AGEB polygons  
- Calculate **area‑weighted NSE** values per neighborhood  

---

## Why Area Weighting Is Required

Neighborhoods often cross multiple AGEB boundaries.  
Each AGEB has its own AMAI NSE classification, so the neighborhood inherits a **weighted NSE** based on the proportion of its area that falls within each AGEB.

### Example

| AGEB | % Area in Neighborhood | C+ | C | D+ | E |
|------|------------------------|----|---|----|---|
| A | 70 % | 40 | 30 | 20 | 10 |
| B | 30 % | 10 | 20 | 40 | 30 |

The neighborhood’s weighted values are:

C+ = 0.7 × 40 + 0.3 × 10
C  = 0.7 × 30 + 0.3 × 20


This ensures that the NSE assigned to each neighborhood accurately reflects the socioeconomic composition of the AGEBs it overlaps.

---

## Next Steps

After importing the DCAH polygons:

1. Validate geometry integrity (no empty or self‑intersecting polygons).  
2. Normalize keys (**CVE_ENT**, **CVE_MUN**, **CVE_LOC**).  
3. Intersect with AGEB geometries from **INEGI MG 2025**.  
4. Apply area‑weighted NSE aggregation using **AMAI 2024** and **Census 2020** data.  
5. Generate the final **Layer 6 NSE dataset**.

---

**Result:**  
A complete, validated neighborhood‑level dataset ready for NSE calculation, mapping, and API integration.

