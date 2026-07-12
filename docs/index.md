# Documentación Nivel Socioeconómico AMAI para Colonias INEGI

Este sitio contiene la documentación técnica completa del pipeline de **NSE (Nivel Socioeconómico AMAI 2024)** desarrollado por mapanet / AXSI.  
Explica los datasets, la metodología, el procesamiento espacial, el flujo SQL y los pasos de validación necesarios para generar **Layer 6 — NSE por colonia** para todo México.

---

## 📘 Panorama General

El pipeline NSE integra:

- **Valores NSE AMAI 2024** (por AGEB)
- **Geometrías INEGI MG 2025** (AGEB / AGEEB)
- **Delimitación de Colonias INEGI DCAH 2025** (polígonos de colonias)
- **Localidades INE 2025** (fallback rural)
- Interpolación ponderada por área desde AGEB → colonia

El resultado es un dataset socioeconómico reproducible y listo para auditoría, utilizado en producción en AXSI Real Estate.


---

## 📁 Documentation Index

### 0. [Requerimientos](00_Requerimientos.md)
### 1. [Importar AMAI NSE 2024](01_Importar_AMAI.md)
### 2. [Importar INEGI MG 2025 — Geometrías AGEB](02_Importar_INEGI_MG_2025_AGEB.md)
### 3. [Importar INEGI DCAH 2025 — Geometrías de Colonias](03_Importar_INEGI_DCAH_2025.md)
### 4. [intersecciones Espaciales de Áreas AGEB × Colonias](04_NSE_intersecciones.md)
### 5. [Metodología de Cálculo de NSE](methodologia.md)
### 6. [Descripción general del pipeline](pipeline.md)
### 7. [Notas INEGI y Consideraciones Territoriales](inegi.md)
### 8. [Notas AMAI y Reglas de Clasificación](amai.md)

---

## 🗺️ Mapa NSE en Vivo (CDMX)

El dataset final de NSE se utiliza en producción en:

**Plataforma AXSI Mercado inmoboliario**  
https://axsi.io/es

---

## 🧩 Acerca de este proyecto

Repositorio:  
https://github.com/mapanet/NSE/

Author: **Juan Carlos Alcaide Blanco**  
Organization: **AXSI / Divex Turismo, S.L.**  
Location: **Playa del Carmen, Quintana Roo**
