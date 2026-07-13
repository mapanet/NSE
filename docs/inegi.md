# Notas de INEGI y Consideraciones Territoriales

Este documento resume consideraciones territoriales y geométricas importantes al trabajar con datasets de INEGI para el cálculo del NSE.

---

## 1. INEGI MG 2025 — Notas sobre AGEB

### 1.1 AGEB Urbanas vs Rurales

- Las AGEB urbanas cuentan con datos completos del censo   
- Las AGEB rurales (AGEEB) no incluyen tablas censales socioeconómicas   
- AMAI NSE solo se publica para AGEB urbanas   

### 1.2 Estructura de CVEGEO
CVEGEO está compuesto por:

- Estado (2 dígitos)  
- Municipio (3 dígitos)  
- Localidad (4 dígitos)  
- AGEB (4 dígitos)  

La normalización es necesaria para realizar joins correctos.

### 1.3 Calidad de Geometría
Los polígonos MG 2025 generalmente tienen alta calidad, pero pueden incluir:

- Fragmentos mínimos (slivers)  
- Traslapes en límites  
- Inconsistencias de topología en zonas rurales

---

## 2. INEGI DCAH 2025 — Notas sobre Colonias

### 2.1 Límites de Colonias
Las colonias son límites administrativos definidos por los municipios.
**No** siempre se alinean con los límites de las AGEB.

### 2.2 Colonias Faltantes
Algunos municipios no publican datasets completos de colonias.  
Ejemplos:

- Esatdo de México  
- Las Arboledas  
- Algunos municipios rurales

### 2.3 Problemas de Geometría
Problemas comunes:

- Auto‑intersecciones  
- Multipolígonos con huecos  
- Colonias traslapadas  
- Anillos sin cerrar

Estos deben validarse antes de realizar intersecciones.

---

## 3. Consideraciones Territoriales

### 3.1 Desalineación AGEB ↔ Colonia
Las colonias frecuentemente cruzan múltiples AGEB.  
Por ello se requiere interpolación ponderada por área.

### 3.2 Fallback Rural
Dado que las AGEB rurales no tienen datos censales:

- Usar indicadores de localidades del INE  
- Aplicar reglas de clasificación rural de AMAI  
- Asegurar que todas las colonias reciban valores NSE válidos

### 3.3 Cambios en Límites Municipales

Los municipios pueden actualizar límites entre MG 2020 → MG 2025.
Siempre usar el dataset MG más reciente.


## 4. Validaciones Recomendadas

- `ST_IsValid` en todas las geometrías  
- Revisión de consistencia de áreass  
- Normalización de CVEGEO  
- Reparación de topología (`ST_MakeValid`)  
- Revisión de suma de áreas de intersección  
- Detección de colonias faltantes

---

## 5. Notas para Uso en Producción

- Almacenar siempre CVEGEO normalizado  
- Mantener datasets de INEGI versionados  
- Documentar anomalías territoriales  
- Conservar logs de auditoría para reparaciones geométricas
