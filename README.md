# NSE — Cálculo AMAI por Colonias INEGI

Este repositorio privado documenta el pipeline técnico para el cálculo del NSE AMAI por colonia de INEGI DCAH 2023 e INNE 2025,
integrando datos de AMAI 2024 INEGI MG 2025, INEGI Censo 2020, INEGI DCAH 2023 y ponderaciones AMAI.

## 📁 Estructura del repositorio

- `/docs` — Documentación técnica paso a paso (SQL, GIS, ETL)
- `/data` — Archivos CSV y SHP (no públicos)
- `/scripts` — Scripts SQL y PowerShell
- `/images` — Diagramas y mapas de referencia

## 📘 Índice de documentación

1. [Importar datos AMAI](docs/01_Import_AMAI.md)
2. [Importar geometrias AGEB 2025](docs/02_Boundaries_AGEB_2025.md)
3. [Importar datos_INEGI Censo 2020](docs/03_INEGI_Censo_2020_AGEB.md)
4. [Importar datos INEGI_DCAH_Colonias_2023](docs/04_INEGI_DCAH_Colonias_2023.md)
5. [Intersección Colonias × AGEB](docs/03_Intersections.md)
6. [Ponderación de población AMAI](docs/04_Ponderacion.md)
7. [Validaciones finales](docs/05_Validaciones.md)

---

**Autor:** Juan Carlos Alcaide Blanco
**Organización:** AXSI / Divex Turismo, S.L.  
**Ubicación:** Playa del Carmen, Quintana Roo 
