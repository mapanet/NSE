# NSE Calculation for Neighborhoods (Boundaries Layer 6)

## Brief Description

This document describes the complete technical pipeline used to calculate the AMAI Socioeconomic Level (NSE) at the Neighborhood (Colonia) level, also known as Boundaries Layer 6.  
The process integrates four official datasets:

- AMAI NSE 2024
- INEGI Marco Geoestadístico 2025
- INEGI Census 2020
- INEGI DCAH 2023

Each contributing essential spatial, demographic, and statistical components required to generate a final, auditable NSE dataset for all neighborhoods in Mexico.

---

## 1. AMAI NSE 2024 (NSE_AMAI_2024_AGEB)

**Source:** AMAI  
**Unit:** Occupied private dwellings  
**Description:**  
Official AMAI dataset containing the number of dwellings per socioeconomic level:

- AB  
- C+  
- C  
- C–  
- D+  
- D  
- E  
- TOTAL dwellings  

Each record is associated with a **CVEGEO (13‑digit AGEB key)**.

**Used for:**

✔ Base NSE values per AGEB  
✔ Area‑weighted interpolation from AGEB → colonia  
✔ Calculation of NSE_SCORE and NSE_LABEL for each neighborhood  

---

## 2. INEGI Marco Geoestadístico 2025 (AGEB Geometries)
#### (INEGI AGEB: Geo‑Statistical Area)

**Source:** INEGI MG 2025  
**Description:**  
Official AGEB polygons for the entire country, including:

- Urban and rural AGEB geometries  
- CVE_ENT, CVE_MUN, CVE_LOC, CVE_AGEB  
- CVEGEO (13 digits)  
- Urban/Rural classification  
- Geometry in **EPSG:4326**

**Used for:**  
✔ Spatial intersection with neighborhoods (colonias)  
✔ Area proportion calculations  
✔ Area‑weighted distribution of AMAI dwellings  
✔ Geometric foundation for Layer 6  

---

## 3. INEGI Census 2020 (AGEB)

**Source:** INEGI SCINCE 2020  
**Description:**  
Demographic and housing data at the AGEB level:

- Total population  
- Total dwellings
- Occupied dwellings  
- CVEGEO (13 digits)

**Used for:**  
✔ Enriching the final Layer 6 dataset with:  
  - **Population**  
  - **Residences**  
✔ Does *not* affect the NSE calculation itself  

---

## 4. INEGI DCAH 2023 (Neighborhood Polygons)

**Source:** INEGI DCAH  
**Description:**  
Official neighborhood (colonia) boundaries, including:

- Polygon geometry  
- Neighborhood name  
- CVE_ENT, CVE_MUN, CVE_LOC  
- No population data  
- No dwelling data  

**Used for:**  
✔ Building Boundaries Layer 6  
✔ Spatial intersection with AGEB  
✔ Area‑weighted NSE calculation  
✔ Generating the final neighborhood‑level (colonia) dataset  

---

## Expected Output After Ingestion

Once all four datasets are loaded and validated, the system is ready for:

- Key normalization (CVEGEO, locality codes, etc.)  
- Geometry validation (topology, overlaps, empties)  
- Neighborhoods (Colonias) × AGEB spatial intersection  
- Area‑weighted AMAI distribution  
- NSE calculation per neighborhood (colonia)  
- Final Layer 6 generation (NSE, population, residences, metadata)

