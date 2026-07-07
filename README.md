# NSE — AMAI Socioeconomic Level for INEGI Neighborhoods

<p align="center">
<img src="/docs/images/INEGI.webp" alt="INEGI Logo" height="90">
&nbsp;&nbsp;&nbsp;&nbsp;
<img src="/docs/images/AMAI.webp" alt="AMAI Logo" height="90">
</p>

This public repository documents the complete technical pipeline for calculating the AMAI Socioeconomic Level (NSE) at multiple territorial levels in México:

- Neighborhood (colonia)
- Locality
- Municipality / Alcaldía
- State

The workflow integrates official datasets from AMAI, INEGI, and INE, producing a reproducible, auditable, and standardized NSE dataset suitable for GIS, APIs, real estate analytics, and socioeconomic research.

## Official datasets used

- AMAI 2024 — NSE by AGEB (Nivel Socioeconómico AMAI)
- INEGI Marco Geoestadístico 2025 — AGEB geometries
- INEGI DCAH 2025 — Neighborhood (colonia) boundaries
- Spatial weighting — AGEB statistical units → colonia geometries

The final output is Layer 6 (NSE by colonia), with optional aggregation to:

- Layer 5 — City
- Layer 2 — Municipality
- Layer 1 — State

These layers support **real estate analysis, market segmentation, urban planning**, and integration with **DENUE, OSM,** and other geospatial datasets.

## Example: NSE Map of Mexico City

[<img src="/docs/images/CDMX_NSE_map.png" width="700">](/docs/images/CDMX_NSE_map.png)

## Relation between AMAI, MG 2025 AGEB geometries, and DCAH geometries

AMAI’s socioeconomic index (NSE) is originally assigned to AGEB / AGEEB statistical units.
The MG 2025 framework provides the official polygon boundaries for these units.
To obtain NSE at the neighborhood (colonia) level, we perform a spatial interpolation from AGEB polygons to DCAH polygons.

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


---

**Juan Carlos Alcaide Blanco**  
**Organization:** AXSI / Divex Turismo, S.L.  
**Location:** Playa del Carmen, Quintana Roo  
