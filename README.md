# NSE — AMAI Socioeconomic Level Calculation for INEGI Neighborhoods

This private repository documents the technical pipeline for calculating the AMAI Socioeconomic Level (NSE) at the neighborhood (colonia) level, integrating the following official datasets:

- AMAI 2024 (NSE by AGEB)
- INEGI Marco Geoestadístico 2025 (AGEB geometries)
- INEGI Census 2020 (population and dwellings)
- INEGI DCAH 2023 (colonias / neighborhoods)
- Spatial weighting from AGEB → colonia

The objective is to generate a final, reproducible, auditable, and standardized NSE dataset at the colonia level (Layer 6).

---

📁 Repository Structure
/docs — Step‑by‑step technical documentation (SQL, GIS, ETL)
/data — CSV, SHP, and original source files (not public)
/scripts — SQL scripts, PowerShell utilities, automation
/images — Diagrams, maps, and reference figures

---

## 📘 Documentation Index

1. [Import AMAI data](docs/01_Import_AMAI.md)
2. [Import AGEB 2025 geometries](docs/02_Boundaries_AGEB_2025.md)
3. [Import INEGI Census 2020 data](docs/03_INEGI_Census_2020_AGEB.md)
4. [Import INEGI DCAH Neighborhoods 2023](docs/04_INEGI_DCAH_Neighborhoods_2023.md)
5. [Colonias × AGEB spatial intersection](docs/05_Intersections.md)
6. [AMAI population weighting by colonia](docs/06_Weighting_by_Neighborhood.md)
7. [Final validations](docs/07_Validaciones.md)


---

**Author:** Juan Carlos Alcaide Blanco  
**Organization:** AXSI / Divex Turismo, S.L.  
**Location:** Playa del Carmen, Quintana Roo  

