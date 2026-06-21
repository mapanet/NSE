# NSE — AMAI Socioeconomic Level of INEGI Neighborhoods

This private repository documents the technical pipeline for calculating the AMAI Socioeconomic Level (NSE) at the neighborhood (colonia) level, integrating the following official datasets:

- AMAI 2024 (NSE by AGEB)
- INEGI Marco Geoestadístico 2025 (AGEB geometries)
- INEGI DCAH 2025 neighborhoods (colonias)
- Spatial weighting from AGEB (statatistical units) geometries → neighborhoods geometries (colonias) 

The objective is to generate a final, reproducible, auditable, and standardized NSE dataset at the colonia level (Layer 6).

Relation:

**AMAI**’s socioeconomic classifications ((A/B, C+, C, C-, D+, D, E)) are mapped onto AGEBs to ensure that market data aligns with official census geography.
**MG 2025** polygons provide the spatial layer that defines the exact boundaries of each AGEB
This means AMAI’s indices can be georeferenced directly to MG 2025 polygons, allowing integration of market intelligence with census-based demographic and housing data.

---

## 📁 Repository Structure

- `/docs` — Step‑by‑step technical documentation (SQL, GIS, ETL, OSM)
- `/data` — CSV, SHP, and original source files (not public)
- `/scripts` — SQL scripts, PowerShell utilities, Python scripts, automation
- `/images` — Diagrams, maps, and reference figures

---

## Documentation Index

0. [Data Requirements](docs/00_Data_Requirements.md)   
1. [Import NSE_AMAI_AGEB_2024](docs/01_Import_AMAI.md)   
2. [Import AGEB 2025 geometries](docs/02_Import_INEGI_MG_2025_AGEB.md)   
3. [Import INEGI DCAH Neighborhoods 2025 geometries](docs/03_Import_INEGI_DCAH_2025.md)   
4. [Neighbood boundaries × AGEB spatial intersection](docs/05_Intersections.md)   
5. [AMAI Households Weighting by Neighborhood](docs/06_Weighting_by_Neighborhood.md)   
6. [Final validations](docs/07_Validations.md)   


---

**Author:** Juan Carlos Alcaide Blanco  
**Organization:** AXSI / Divex Turismo, S.L.  
**Location:** Playa del Carmen, Quintana Roo  

