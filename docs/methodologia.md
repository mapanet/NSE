# Metodología — Nivel Socioeconómico AMAI (NSE) para Colonias INEGI

Este documento describe la metodología completa utilizada para generar **Layer 6 — NSE por colonia**, integrando los indicadores socioeconómicos de AMAI con los datasets territoriales de INEGI.  
Incluye ingestión, normalización, procesamiento espacial, interpolación, clasificación y pasos de auditoría.


---

## 1. Panorama General

AMAI publica indicadores socioeconómicos (NSE) a nivel **AGEB**.  
INEGI proporciona dos datasets territoriales clave:

- **MG 2025** — geometrías oficiales de AGEB  
- **DCAH 2025** — geometrías de colonias (asentamientos humanos)

Para obtener NSE a nivel colonia, se realizan los siguientes pasos:

1. **Ingesta** de los datasets AMAI + INEGI  
2. **Normalización** de claves e identificadores  
3. **Intersección espacial** entre polígonos de AGEB y colonias  
4. **Interpolación ponderada por área** de los indicadores socioeconómicos  
5. **Clasificación conforme a AMAI**  
6. **Generación de capas finales**  
7. **Auditorías geométricas y territoriales**


---

## 2. Datasets

### 2.1 AMAI 2024 — NSE por AGEB
AMAI proporciona indicadores socioeconómicos para cada AGEB:

- Características del hogar  
- Educación  
- Bienes y activos  
- Servicios  
- Puntaje compuesto de NSE  
- Categoría final de NSE (A/B, C+, C, C-, D+, D)

### 2.2 INEGI MG 2025 — Geometrías AGEB
Límites poligonales oficiales para:

- **AGEB urbanas**  
- **AGEEB rurales**

Incluye:

- CVEGEO  
- Código de municipio  
- Código de estado  
- Geometría (polígono)

### 2.3 INEGI DCAH 2025 — Geometrías de Colonias
Límites poligonales de colonias para todos los municipios/alcaldías.

Incluye:

- CVEGEO  
- Nombre de la colonia  
- Código de municipio  
- Geometría (polígono)

### 2.4 Localidades INE 2025 (Fallback Rural)
Usadas cuando no existe información censal rural por AGEB.

---

## 3. Normalización de Claves

Antes de cualquier procesamiento espacial, todas las claves deben normalizarse:

- `LTRIM(RTRIM())` en todos los campos de texto  
- Convertir CHAR → VARCHAR  
- Normalizar formatos de CVEGEO  
- Estandarizar códigos de municipio y estado  
- Eliminar espacios finales  
- Convertir a mayúsculas nombres de localidades y colonias  

Esto evita errores en joins y propagación de valores NULL.

---

## 4. Intersección Espacial (AGEB × Colonia)

El núcleo de la metodología es la **intersección de polígonos** entre:

- Polígonos AGEB (MG 2025)  
- Polígonos de colonias (DCAH 2025)

### 4.1 Resultado de la Intersección

Para cada par de polígonos que intersectan:

- Geometría de intersección  
- Área de intersección  
- Porcentaje del área del AGEB que contribuye a la colonia  
- Indicadores socioeconómicos ponderados  

### 4.2 Contribución Ponderada por Área

Para cada variable socioeconómica:

**ValorPonderado** = (ÁreaIntersección / ÁreaTotalAGEB) × ValorAMAI

Esto garantiza que cada AGEB contribuya proporcionalmente a la colonia según el traslape espacial.

---

## 5. Cálculo de NSE

Después de la interpolación, cada colonia tiene indicadores socioeconómicos ponderados.

### 5.1 Puntaje Compuesto

El puntaje compuesto de AMAI se recalcula usando variables ponderadas:

**NSE_Score** = Σ (IndicadoresPonderados × PesosAMAI)

### 5.2 Categoría Final de NSE

El puntaje se asigna a las categorías oficiales de AMAI:

- **A/B**  
- **C+**  
- **C**  
- **C-**  
- **D+**  
- **D**

Los umbrales siguen la metodología oficial de AMAI.

---

## 6. Generación de Capas

### 6.1 Layer 6 — NSE por Colonia
Salida final:

- CVEGEO  
- Nombre de colonia  
- Municipio  
- Estado  
- Puntaje NSE  
- Categoría NSE  
- Geometría  

### 6.2 Layer 5 — Ciudad
Agregación del Layer 6 por límites de ciudad.

### 6.3 Layer 2 — Municipio
Agregación por código de municipio.

### 6.4 Layer 1 — Estado
Agregación por código de estado.

---

## 7. Lógica Rural (ITER)

INEGI no publica datos censales rurales por AGEB.  
Para evitar propagación de NULL:

- Usar indicadores de localidades INE 2025  
- Asignar NSE rural basado en características de localidad  
- Aplicar reglas AMAI para clasificación rural  
- Garantizar que todas las colonias (urbanas + rurales) reciban valores NSE válidos

---

## 8. Auditorías Geométricas y Territoriales

Para asegurar calidad de datos:

### 8.1 Validez Geométrica
- Revisar self‑intersections  
- Validar topología de polígonos  
- Reparar geometrías inválidas

### 8.2 Consistencia Territorial
- Verificar alineación de CVEGEO  
- Revisar códigos de municipio/estado  
- Detectar colonias faltantes  
- Comparar límites MG 2025 vs DCAH 2025

### 8.3 Revisión de Áreas
- Verificar que las áreas de intersección sumen correctamente  
- Detectar anomalías (fragmentos mínimos, traslapes, huecos)

---

## 9. Formato de Salida

Los datasets finales de NSE se exportan como:

- GeoJSON  
- Shapefile  
- Tablas SQL  
- Capas JSON listas para API  

Usados en producción en:

**Plataforma AXSI Real Estate**  
https://axsi.io/es


---

## 10. Related Documentation

- [Requerimeitos](00_REquerimientos.md)  
- [Importar AMAI NSE 2024](01_Importar_AMAI.md)  
- [Importar INEGI MG 2025 AGEB geometrias](02_Importar_INEGI_MG_2025_AGEB.md)  
- [Importar INEGI DCAH 2025 Neighborhood geometries](03_Importar_INEGI_DCAH_2025.md)  
- [Interseccion Espacial areas AGEB × Colonias](04_NSE_Intersecciones.md)  
- [Descripción general del pipeline](pipeline.md)  
- [Notas INEGI](inegi.md)  
- [Notas AMAI](amai.md)

---

## Author

**Juan Carlos Alcaide Blanco**  
AXSI / Divex Turismo, S.L.  
Playa del Carmen, Quintana Roo


