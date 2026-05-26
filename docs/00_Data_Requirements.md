# NSE Calculation for Neighborhoods (Boundaries Layer 6)

This document describes the complete technical pipeline used to calculate the AMAI Socioeconomic Level (NSE) at the Neighborhood (Colonia) level, known as **Boundaries Layer 6**.  
Layer 6 is the **final enriched dataset**, where each neighborhood polygon contains its corresponding NSE category and weighted demographic values.

Although Boundaries Layers **1 (State)**, **2 (Municipality)**, and **5 (City)** also receive NSE values through aggregation, this pipeline focuses specifically on **Layer 6**, where NSE is calculated using spatial intersections between neighborhood polygons and AGEB‑level socioeconomic and census data.

To generate Layer 6, the pipeline integrates four official datasets.  
Each dataset contributes a specific component to the spatial, demographic, and statistical process:

---

### **1. AMAI NSE 2024 (NSE_AMAI_2024_AGEB)**  
Provides socioeconomic indicators at the AGEB level.

### **2. INEGI Marco Geoestadístico 2025 (AGEB Geometries)**  
Provides the official AGEB boundaries required for spatial weighting.

### **3. INEGI Census 2020 (AGEB Block‑Level Data)**  
Provides population and dwelling counts used for demographic weighting.

### **4. INEGI DCAH 2023 (Neighborhood Polygons)**  
Provides the official neighborhood geometries used to aggregate NSE to Layer 6.

---

**Summary:**  
Layer 6 is produced by intersecting neighborhood polygons with AGEB‑level NSE and Census data, applying demographic weighting, and assigning the final NSE category to each neighborhood.  
This dataset is used for **mapping, analytics, and API consumption**.


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

