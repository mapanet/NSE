# NSE — AMAI Socioeconomic Level of INEGI Neighborhoods

This private repository documents the technical pipeline for calculating the AMAI Socioeconomic Level (NSE) at the neighborhood (colonia) level, integrating the following official datasets:

- AMAI 2024 (NSE by AGEB)
- INEGI Marco Geoestadístico 2025 (AGEB geometries)
- INEGI Census 2020 (population and households at dwelling level)
- INEGI DCAH 2025 neighborhoods (colonias)
- Spatial weighting from AGEB geometries → neighborhoods geometries (colonias) 

The objective is to generate a final, reproducible, auditable, and standardized NSE dataset at the colonia level (Layer 6).

---

## 📁 Repository Structure

- `/docs` — Step‑by‑step technical documentation (SQL, GIS, ETL, OSM)
- `/data` — CSV, SHP, and original source files (not public)
- `/scripts` — SQL scripts, PowerShell utilities, Python scripts, automation
- `/images` — Diagrams, maps, and reference figures

---

## 📘 Documentation Index

0. [Data Requirements](docs/00_Data_Requirements.md)   
1. [Import AMAI data](docs/01_Import_AMAI.md)   
2. [Import AGEB 2025 geometries data](docs/02_Import_Boundaries_AGEB_2025.md)   
3. [Import INEGI Census 2020 data](docs/03_Import_INEGI_Census_2020_AGEB.md)   
4. [Import INEGI AGEML_2026 data](docs/04_Import_AGEML_2026.md)   
5. [Import INEGI DCAH Neighborhoods 2025 data](docs/04_Import_INEGI_DCAH_2025.md)   
8. [Neighboods (Colonias) × AGEB spatial intersection](docs/05_Intersections.md)   
9. [AMAI Households Weighting by Neighborhood](docs/06_Weighting_by_Neighborhood.md)   
10. [Final validations](docs/07_Validations.md)   

---

**Author:** Juan Carlos Alcaide Blanco  
**Organization:** AXSI / Divex Turismo, S.L.  
**Location:** Playa del Carmen, Quintana Roo  

