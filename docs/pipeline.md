# Panorama del Pipeline — NSE AMAI para Colonias de INEGI

Esta página resume el flujo completo end‑to‑end utilizado para generar el **NSE AMAI por colonia** (Capa 6 de Boundaries).  
Conecta todos los datasets, pasos SQL, operaciones geoespaciales y procedimientos de validación en un solo pipeline reproducible.

---

## 1. Ingesta de Datos

### 1.1 AMAI NSE 2024
- Indicadores socioeconómicos por AGEB  
- Puntaje compuesto NSE  
- Categoría final AMAI (A/B, C+, C, C-, D+, D)

### 1.2 INEGI MG 2025 (Geometrías de AGEB)
- Polígonos de AGEB urbanas  
- Polígonos de AGEB rurales (AGEEB)  
- Códigos CVEGEO  
- dentificadores de municipio y estado

### 1.3 INEGI DCAH 2025 (Geometrías de colonias)
- Polígonos de colonias  
- CVEGEO  
- Metadatos de municipio y localidad

### 1.4 Localidades INE 2025 (Fallback rural)
- Usadas cuando no existen datos censales para AGEB rurales

---

## 2. Normalización de Claves

Antes de unir datasets:

- Normalizar formatos de CVEGEO  
- Aplicar LTRIM/RTRIM a todos los campos de texto  
- Convertir CHAR → VARCHAR  
- Poner nombres de colonias en mayúsculas  
- Estandarizar códigos de municipio/estado   
  
Esto evita propagación de NULL y errores en los joins.

---

## 3. Intersección Espacial (AGEB ↔ Colonia)

Paso geoespacial central:

- Intersectar polígonos de AGEB con polígonos de colonias  
- Calcular área de intersección  
- Calcular porcentaje de contribución de cada AGEB  
- Generar indicadores socioeconómicos ponderados  

Esto produce la **tabla de intersección AGEB × Colonia.**  


## 4. Interpolación Ponderada por Área

Para cada variable socioeconómica:

**ValorPonderado** = (ÁreaIntersección / ÁreaTotalAGEB) × ValorAMAI

Esto asegura que cada colonia herede valores NSE de forma proporcional.


## 5. Cálculo de NSE

### 5.1 Indicadores Ponderados
Suma de las contribuciones ponderadas de todas las AGEB que intersectan. 

### 5.2 Puntaje Compuesto
Recalcular el puntaje compuesto de AMAI usando variables ponderadas.

### 5.3 Categoría Final NSE
Asignar la categoría AMAI según los umbrales de puntaje.

---

## 6. Generación de Capas

### Capa 6 — Colonias (Neighborhoods)
El resultado final incluye:

- CVEGEO  
- Nombre de la colonia  
- Municipio  
- Puntaje NSE  
- Categoría NSE  
- Geometría  

### Capa 5 — Ciudades  
Agregación de la Capa 6.

### Capa 2 — Municipios  
Agregación por código de municipio.

### Capa 1 — Estados  
Agregación por código de estado.


## 7. Auditorías de Geometría y Territorio

- Validar topología de polígonos   
- Detectar auto‑intersecciones   
- Comparar límites MG 2025 vs DCAH 2025   
- Revisar consistencia de áreas   
- Identificar colonias faltantes   
- Validar alineación de CVEGEO   


## 8. Exportación e Integración con API

Los datasets finales se exportan como:   

- GeoJSON   
- Shapefile   
- Tablas SQL   
- Capas JSON listas para API   

Usando en proyecto piloto de produccion en:

**Platforma AXSI Bienes Raices**  
https://axsi.io/es



