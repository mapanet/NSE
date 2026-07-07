# NSE — AMAI Socioeconomic Level for INEGI Neighborhoods

This public repository documents the technical pipeline for calculating the AMAI Socioeconomic Level (NSE) at the neighborhood (colonia), locality, municipality/alcaldia and state levels of México, integrating the following official datasets:

- AMAI 2024 (NSE by AGEB)
- INEGI Marco Geoestadístico 2025 (AGEB geometries)
- INEGI DCAH 2025 neighborhoods (colonias)
- Spatial weighting from AGEB (statistical units) geometries → neighborhoods geometries (colonias) 

The objective is to generate a final, reproducible, auditable, and standardized NSE dataset at the colonia level (Layer 6).   
This data can be also created a city layer 5, municipality layer 2, state layer 1.  
Resulting datasets will be used for real estate analysis for properties and development evaluation together with DENUE and OSM data.

[<img src="/docs/images/CDMX_NSE_map.png" width="700">](/docs/images/CDMX_NSE_map.png)

## Relation between AMAI, MG 2025 AGEB geometries, and DCAH geometries

AMAI’s socioeconomic index (NSE) is mapped onto INEGI’s statistical units (AGEBs/AGEEBs).  
The MG_2025 framework provides the official polygon boundaries of AGEBs.  
We then interpolate these values to align with **DCAH neighborhood boundaries**, ensuring local-level socioeconomic classification.

### Diagram

```text
        AMAI (Socioeconomic Index - NSE)
                     │
                     ▼
          AGEB / AGEEB (Statistical Unit)
                     │
                     ▼
   MG 2025 Polygons (Official Boundaries)
                     │
          Interpolation / Spatial Join
                     ▼
   DCAH Boundaries (Neighborhood Units)
                     │
                     ▼
   NSE Assigned to DCAH Neighborhoods
 ```



## 📁 Repository Structure

- `/docs` — Step‑by‑step technical documentation (SQL, GIS, ETL, OSM)
- `/data` — CSV, SHP, and original source files (not public)
- `/scripts` — SQL scripts, PowerShell utilities, Python scripts, automation
- `/images` — Diagrams, maps, and reference figures


## Documentation Index

0. [Data Requirements](docs/00_Data_Requirements.md)   
1. [Import NSE_AMAI_AGEB_2024](docs/01_Import_AMAI.md)   
2. [Import INEGI_MG 2025_AGEB geometries](docs/02_Import_INEGI_MG_2025_AGEB.md)   
3. [Import INEGI DCAH 2025 Neighborhood geometries](docs/03_Import_INEGI_DCAH_2025.md)   
4. [Neighbood boundaries × AGEB spatial intersection](docs/04_NSE_Intersections.md)   
5. [AMAI Households Weighting by Neighborhood](docs/06_Weighting_by_Neighborhood.md)   
6. [Final validations](docs/07_Validations.md)   

---

**Author:** Juan Carlos Alcaide Blanco  
**Organization:** AXSI / Divex Turismo, S.L.  
**Location:** Playa del Carmen, Quintana Roo  

