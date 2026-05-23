# NSE — Cálculo AMAI por Colonias INEGI

Este repositorio privado documenta el pipeline técnico para el cálculo del Nivel Socioeconómico (NSE) AMAI por colonia, integrando datos de:

- AMAI 2024 (NSE por AGEB)
- INEGI Marco Geoestadístico 2025 (AGEB)
- INEGI Censo 2020 (población y viviendas)
- INEGI DCAH 2023 (colonias)
- Ponderaciones espaciales AGEB → colonia

El objetivo es generar un dataset final de NSE por colonia (Layer 6) con metodología reproducible, auditable y estandarizada.

---

## 📁 Estructura del repositorio

- `/docs` — Documentación técnica paso a paso (SQL, GIS, ETL)
- `/data` — Archivos CSV, SHP y fuentes originales (no públicos)
- `/scripts` — Scripts SQL, PowerShell y utilidades
- `/images` — Diagramas, mapas y capturas de referencia

---

## 📘 Índice de documentación

1. [Importar datos AMAI](docs/01_Import_AMAI.md)
2. [Importar geometrías AGEB 2025](docs/02_Boundaries_AGEB_2025.md)
3. [Importar datos INEGI Censo 2020](docs/03_INEGI_Censo_2020_AGEB.md)
4. [Importar datos INEGI DCAH Colonias 2023](docs/04_INEGI_DCAH_Colonias_2023.md)
5. [Intersección Colonias × AGEB](docs/05_Intersections.md)
6. [Ponderación de población AMAI por colonia](docs/06_Ponderacion.md)
7. [Validaciones finales](docs/07_Validaciones.md)

---

**Autor:** Juan Carlos Alcaide Blanco  
**Organización:** AXSI / Divex Turismo, S.L.  
**Ubicación:** Playa del Carmen, Quintana Roo  

