# NSE — Nivel Socioeconómico AMAI para Colonias de INEGI

<p align="center">
  <img src="/docs/images/INEGI.webp" alt="INEGI Logo" height="90">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="/docs/images/AMAI.webp" alt="AMAI Logo" height="90">
</p>

Este repositorio documenta el pipeline completo, reproducible y auditable para calcular el **Nivel Socioeconómico (NSE) AMAI** en múltiples unidades territoriales de México:

- Colonia  
- Localidad  
- Municipio / Alcaldía  
- Estado  

El flujo integra datasets oficiales de **AMAI**, **INEGI** y **INE**, generando capas NSE estandarizadas para uso en **GIS**, **APIs**, **analítica inmobiliaria**, **segmentación de mercado** e **inteligencia territorial**.

---

## 🎯 Objetivo del repositorio

Generar la **Capa 6 (NSE por colonia)** utilizando:

- Valores NSE AMAI 2024 (por AGEB)  
- Geometrías AGEB del INEGI MG 2025  
- Geometrías de colonias del INEGI DCAH 2025  
- Interpolación espacial AGEB → colonia mediante ponderación por área  

El dataset resultante se utiliza en producción en:

### 🌐 Plataforma AXSI Real Estate  
Explora el mapa interactivo de NSE por ciudades o colonias de México:  
**https://axsi.io/es**

---

## 📊 Datasets oficiales utilizados

### AMAI 2024 — NSE por AGEB  
Clasificación socioeconómica (A/B, C+, C, C-, D+, D) asignada a unidades estadísticas.

### INEGI Marco Geoestadístico 2025  
Geometrías oficiales de polígonos AGEB / AGEEB.

### INEGI DCAH 2025  
Límites de colonias para todos los municipios y alcaldías del país.

### INE 2025 — Localidades  
Usado para lógica de respaldo en zonas rurales cuando no existe información censal por AGEB.

### Ponderación espacial  
Interpolación AGEB → colonia mediante uniones espaciales ponderadas por área.

---

## 🗺️ Ejemplo: Mapa NSE de la Ciudad de México

[<img src="/docs/images/CDMX_NSE_map.png" width="700">](/docs/images/CDMX_NSE_map.png)

Este mapa se genera utilizando el pipeline SQL + GIS documentado en este repositorio.

---

## 🔗 Relación entre AMAI, geometrías AGEB MG 2025 y geometrías DCAH

AMAI asigna valores NSE a unidades estadísticas AGEB / AGEEB.  
INEGI MG 2025 provee los límites oficiales de estas unidades.  
INEGI DCAH 2025 provee los límites de colonias.

Para obtener NSE a nivel colonia se realizan:

- Intersecciones espaciales  
- Interpolación ponderada por área  
- Normalización de claves  
- Reglas de agregación compatibles con AMAI  

### 📐 Diagrama

```text
        AMAI (Índice Socioeconómico - NSE)
                     │
                     ▼
          AGEB / AGEEB (Unidad Estadística)
                     │
                     ▼
   MG 2025 Polígonos (Límites Oficiales)
                     │
          Interpolación / Unión Espacial
                     ▼
   DCAH Colonias (Unidades Territoriales)
                     │
                     ▼
   NSE Asignado a Colonias (Capa 6)
 ```

## Resumen de la Metodología

0. [Requirementos](docs/00_Requirementos.md)   

1. [Importar NSE_AMAI_AGEB_2024](docs/01_Importar_AMAI.md)   
Importación de indicadores socioeconómicos AMAI 2024 para AGEBs.

2. [Importar INEGI_MG 2025_AGEB geometries](docs/02_Importar_INEGI_MG_2025_AGEB.md)   
Normalizar claves, validar geometrías y preparar los polígonos de AGEB.

3. [Importar INEGI DCAH 2025 Colonias geometrias](docs/03_Importar_INEGI_DCAH_2025.md)   
Normalización de nombres de colonias, códigos CVEGEO e identificadores municipales

4. [Geometrias de Colonias × AGEB interseccion espacial](docs/04_NSE_Intersecciones.md)   

- Cálculo de contribuciones ponderadas por área AGEB → colonia
- Aplicación de fórmulas AMAI: indicadores socioeconómicos ponderados por colonia
- Asignación de categoría NSE (A/B, C+, C, C-, D+, D)
- Generación de Capa 6: dataset final de NSE por colonia

8. Agregación opcional: 

   Capa  5 — Ciudad  
   Capa  2 — Municipio   
   Capa  1 — Estado   

8. [Importar_AMAI_Localitdades](docs/08_AMAI_Localidades.md)

9. [AMAI_Calculos_Localidades](docs/09_AMAI_Calculis_Localidades.md)



## 📁 Repository Structure

- `/docs` — Documentación técnica paso a paso (SQL, GIS, ETL, OSM)
- `/data` — Archivos CSV, SHP y fuentes originales (no públicos)
- `/scripts` — Scripts SQL, utilidades PowerShell, scripts Python, automatización
- `/images` — 

---

**Juan Carlos Alcaide Blanco**  
**Organizacion:** AXSI / Divex Turismo, S.L.  
**Localidad:** Playa del Carmen, Quintana Roo  
