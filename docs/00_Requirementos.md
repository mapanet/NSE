# Cálculo de NSE para Colonias (Boundaries Layer 6)

Este documento describe el pipeline técnico completo utilizado para calcular el **Nivel Socioeconómico (NSE) AMAI** a nivel **Colonia (Neighborhood)**, conocido como **Boundaries Layer 6**.  
La Capa 6 es el **dataset final enriquecido**, donde cada polígono de colonia contiene su categoría NSE correspondiente y los valores demográficos ponderados.

Aunque las capas **1 (Estado)**, **2 (Municipio)** y **5 (Ciudad)** también reciben valores NSE mediante agregación, este pipeline se enfoca específicamente en la **Capa 6**, donde el NSE se calcula mediante intersecciones espaciales entre polígonos de colonias y datos socioeconómicos y censales a nivel AGEB.



## Descripción general de las capas Boundaries

| Capa | Nivel | Descripción |
|------|--------|-------------|
| **1** | Estado | Valores NSE agregados por estado |
| **2** | Municipio | Valores NSE agregados por municipio |
| **5** | Ciudad | Valores NSE agregados por ciudad |
| **6** | Colonia (Neighborhood) | **Dataset final de NSE producido por este pipeline** |

La Capa 6 se genera intersectando polígonos de colonias con datos NSE y Censo a nivel AGEB, aplicando ponderación demográfica y asignando la categoría NSE final a cada colonia.



## Datasets necesarios

Para generar la Capa 6 (colonias), el pipeline integra **3 datasets oficiales**, cada uno aportando un componente específico al proceso espacial, demográfico y estadístico.

Cada dataset tiene su propia guía de ingestión y procesamiento:

- **Paso 1 — AMAI NSE 2024**
- **Paso 2 — INEGI Marco Geoestadístico 2025 (Geometrías AGEB)**  
- **Paso 3 — INEGI DCAH 2025 (Polígonos de Colonias)**

Para generar la Capa 5 (ciudad), el pipeline integra **1 dataset oficial**, componente específico del proceso espacial, demográfico y estadístico:

- **Paso 8 — INEGI Localidades 2025 (Polígonos de Localidades “Ciudad”)**

Para enriquecimiento posterior (nombres de regiones, población, viviendas):

- **Paso 20 — INEGI Censo 2020 (Datos a nivel manzana/AGEB)**
- **Paso 21 — INEGI Censo 2020 (Nivel Localidad)**  
- **Paso 22 — INEGI AGEEML 2026 (Catálogos de Estado, Municipio y Localidad: códigos y nombres)**


---

## 1. AMAI NSE 2024 (NSE_AMAI_2024_AGEB)

**Fuente:** AMAI  
**Unidad:** Viviendas particulares habitadas  
**Proceso de importación:** [01_Import_AMAI](01_Import_AMAI.md)

Proporciona el número de viviendas por nivel socioeconómico:

- AB  
- C+  
- C  
- C–  
- D+  
- D  
- E  
- TOTAL de viviendas  

Cada registro está asociado a una **CVEGEO (clave AGEB de 13 dígitos)**.

**Usado para:**  
- Valores base de NSE por AGEB  
- Interpolación ponderada por área de AGEB → colonia  
- Cálculo de **NSE_SCORE** y **NSE_LABEL** para cada colonia


## 2. INEGI Marco Geoestadístico 2025 (Geometrías AGEB)

**Fuente:** INEGI MG 2025  
**Proceso de importación:** [02_Importar_INEGI_MG_2025_AGEB](02_Importar_INEGI_MG_2025_AGEB.md)

Proporciona los polígonos oficiales de AGEB para todo el país, incluyendo:

- Geometrías de AGEB urbanas y rurales  
- CVE_ENT, CVE_MUN, CVE_LOC, CVE_AGEB  
- CVEGEO (13 dígitos)  
- Geometría en **EPSG:4326**

**Usado para:**  
- Intersección espacial con colonias  
- Cálculo de proporciones de área  
- Distribución ponderada por área de viviendas AMAI  
- Base geométrica para la Capa 6


## 3. INEGI DCAH 2025 (Polígonos de Colonias)

**Fuente:** INEGI DCAH  
**Proceso de importación:** [05_Importar_INEGI_DCAH_2025](05_Importar_INEGI_DCAH_2025.md)

Proporciona los límites oficiales de colonias (neighborhoods), incluyendo:

- Geometría del polígono  
- Nombre de la colonia  
- CVE_ENT, CVE_MUN, CVE_LOC  
- Sin datos de población ni viviendas  

**Usado para:**  
- Construcción de la Capa 6 de Boundaries  
- Intersección espacial con AGEB  
- Cálculo de NSE ponderado por área  
- Generación del dataset final a nivel colonia


# Resultado Esperado Después de la Ingesta

Una vez que los cuatro datasets están cargados y validados, el sistema está listo para:

- Normalización de claves (CVEGEO, códigos de localidad, etc.)  
- Validación geométrica (topología, traslapes, vacíos)  
- Intersección espacial Colonia × AGEB  
- Distribución AMAI ponderada por área  
- Cálculo de NSE por colonia  
- Generación final de la Capa 6, incluyendo:  
  - **Categoría NSE**  
  - **Puntaje NSE (NSE_SCORE)**  
  - **Viviendas NSE y porcentajes**  
  - **Población**  
  - **Viviendas**  
  - **Viviendas ocupadas**  
  - **Metadatos y campos de auditoría**

La Capa 6 se convierte en el **dataset oficial de NSE para colonias**, utilizado para mapas, analítica y consumo vía API.




