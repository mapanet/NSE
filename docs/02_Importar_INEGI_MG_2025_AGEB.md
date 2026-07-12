# PASO 2 — Geometrías del Marco Geoestadístico 2025

**Objetivo:** Construir la tabla `Boundaries_AGEB_2025` con las geometrías oficiales de AGEB del Marco Geoestadístico INEGI 2025.

Esta tabla se utilizará para:

- Intersectar colonias (neighborhoods) con las geometrías de área de AGEB  
- Calcular proporciones de área  
- Ponderar la población AMAI por colonia (neighborhood)

## Directorios de trabajo sugeridos

- `D:\AXSI\INEGI\MG_2025` (archivos de trabajo)  
- `D:\AXSI\INEGI\MG_2025\Download` (archivo descargado y contenido descomprimido para cargar en QGIS)  
- `D:\AXSI\INEGI\MG_2025\AGEB` (guardar el shape procesado **MG_AGEB_2025.SHP** en **EPSG:4023**)

## 1 — Descarga oficial del Marco Geoestadístico 2025

El Marco Geoestadístico 2025 puede descargarse desde el sitio oficial de INEGI:

https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=889463807469

Archivo a descargar:

**794551163061_s.zip**

**La página se ve así:**

[<img src="/docs/images/MG_2025.png" width="1000">](/docs/images/MG_2025.png)

### Guardar como

`D:\AXSI\INEGI\MG_2025\Download\794551163061_s.zip`

Dentro del archivo ZIP encontrarás:

- `mg_2025_integrado.zip`  
  - `conjunto_de_datos/`  
    - `00a.shp` **← archivo principal de áreas AGEB**

Contenido de los archivos dentro del dataset (informativo):

- `00_ent` = Entidad federativa (polígonos)  
- `00_mun` = Municipio (polígonos)  
- `00_a` = AGEB urbanas y rurales (polígonos **← áreas AGEB**)  
- `00_lpr` = Localidad (punto)  
- `00_l` = Localidad urbana y rural (polígonos)


## 2 — Contenido del archivo 00a.shp

Carga `00a.shp` en QGIS y verifica que la capa contenga los siguientes campos:

| Campo     | Descripción                              |
|-----------|-------------------------------------------|
| CVE_ENT   | Código de entidad (2 dígitos)             |
| CVE_MUN   | Código de municipio (3 dígitos)           |
| CVE_LOC   | Código de localidad (4 dígitos)           |
| CVE_AGEB  | Código de AGEB (4 dígitos)                |
| CVEGEO    | Clave geográfica completa (13 dígitos)    |
| AMBITO    | Urbano / Rural                            |
| geom      | Geometría (Polygon / MultiPolygon)        |

Total de registros: **82,263 AGEB**  
CRS original: **MEXICO_IRF‑2008_LLC**



## 3 — Exportar desde QGIS a CRS EPSG:4326

Exporta la capa `00a.shp` como:

**D:\AXSI\INEGI\MG_2025\AGEB\MG_AGEB_2025.shp**  
Asegúrate de seleccionar el CRS: **EPSG:4326** (muy importante)

A partir de esta nueva capa `MG_AGEB_2025`, exporta a CSV como:

**D:\AXSI\INEGI\MG_2025\Boundaries_AGEB_2025_WKT.csv**

- Codificación UTF‑8  
- Delimitador TAB  
- Geometría WKT en coordenadas EPSG:4326

### Columnas del CSV

| Columna  | Descripción                     |
|----------|---------------------------------|
| WKT      | Geometría en formato WKT        |
| CVE_ENT  | Código de entidad               |
| CVE_MUN  | Código de municipio             |
| CVE_LOC  | Código de localidad             |
| CVE_AGEB | Código de AGEB                  |
| CVEGEO   | Clave geográfica completa       |
| AMBITO   | Urbano / Rural                  |

Si editas el CSV deberías ver algo similar a:

| WKT | CVE_ENT | CVE_MUN | CVE_LOC | CVE_AGEB | CVEGEO        | AMBITO |
|-----|---------|---------|---------|----------|---------------|--------|
| MULTIPOLYGON (((-102.27 21.87, ... -102.27 21.87))) | 01 | 001 | 0001 | 216A | 010010001216A | Urbano |
| MULTIPOLYGON (((-102.24 21.86, ... -102.24 21.86))) | 01 | 001 | 0001 | 2649 | 0100100012649 | Urbano |


## 4 — Crear la tabla Staging en MS SQL Server

Creamos una tabla de staging para importar los datos, ya que QGIS genera el CSV con la geometría WKT en la primera posición.  
Después copiaremos los datos importados a la tabla final.

*Verifica la ruta del archivo CSV que guardaste.*

```sql
------------------------------
-- 4 Crear la tabla Staging
------------------------------
DROP TABLE IF EXISTS dbo.Boundaries_AGEB_2025_IMPORT;

CREATE TABLE Boundaries_AGEB_2025_IMPORT (
    WKT        nvarchar(MAX),
    CVE_ENT    char(2),
    CVE_MUN    char(3),
    CVE_LOC    char(4),
    CVE_AGEB   char(4),
    CVEGEO     nvarchar(13),
    AMBITO     char(10)
);

------------------------
-- Importar archivo CSV (TSV)
------------------------
BULK INSERT Boundaries_AGEB_2025_IMPORT 
FROM 'D:\AXSI\INEGI\MG_2025\Boundaries_AGEB_2025_WKT.csv' 
WITH ( 
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001'
);
```

#### Resultado esperado

(82283 rows affected)   


## 5 — Crear la tabla final: Boundaries_AGEB_2025


```sql
-----------------------------------------------
-- 5 Crear tabla final: Boundaries_AGEB_2025
-----------------------------------------------
DROP TABLE IF EXISTS dbo.Boundaries_AGEB_2025;

CREATE TABLE dbo.Boundaries_AGEB_2025
(
    ID                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    CVEGEO              NVARCHAR(13) NOT NULL UNIQUE,

    -- Componentes de la clave CVEGEO
    CVE_ENT             CHAR(2)  NULL,
    CVE_MUN             CHAR(3)  NULL,
    CVE_LOC             CHAR(4)  NULL,
    CVE_AGEB            CHAR(4)  NULL,

    -- Tipo (Ámbito): Urbano / Rural
    Type                CHAR(10)  NULL,

    -- Población y viviendas (se llenará con Censo 2020)
    Population          INT NULL,
    Dwellings           INT NULL,
    Occupied_Dwellings  INT NULL,

    -- Geometrías
    geom                GEOMETRY   NOT NULL,
    geog                GEOGRAPHY  NULL
);

-- Índices espaciales
CREATE SPATIAL INDEX SIDX_Boundaries_AGEB_2025_geog
ON dbo.Boundaries_AGEB_2025(geog)
USING GEOGRAPHY_AUTO_GRID;

CREATE SPATIAL INDEX SIDX_Boundaries_AGEB_2025_geom
ON dbo.Boundaries_AGEB_2025(geom)
WITH (BOUNDING_BOX = (-180, -90, 180, 90));
```

#### Resultado esperado

Commands completed successfully.   


## 6 Insertar datos desde la tabla Staging

```sql
-----------------------------------------
-- 6 Insertar datos desde la tabla Staging
-----------------------------------------
INSERT INTO Boundaries_AGEB_2025 (
    CVEGEO, CVE_ENT, CVE_MUN, CVE_LOC, CVE_AGEB, Type, geom
)
SELECT
    CVEGEO,
    CVE_ENT,
    CVE_MUN,
    CVE_LOC,
    CVE_AGEB,
    AMBITO,
    geometry::STGeomFromText(WKT, 4326)
FROM Boundaries_AGEB_2025_IMPORT;

--------------------
-- Validar geometrías
--------------------
UPDATE Boundaries_AGEB_2025 
SET geom = geom.MakeValid() 
WHERE geom.STIsValid() = 0;

-------------------------
-- Eliminar tabla Staging
-------------------------
DROP TABLE dbo.Boundaries_AGEB_2025_IMPORT;
```

#### Resultado esperado

(82283 registros)   


## 8 — Validación y corrección de geometrías

### Validar geometrías inválidas

✅ Las consultas deben regresar **cero registros**

```sql
-----------------------------------------
-- 2.8 Validación y corrección de geometrías
-----------------------------------------
SELECT ID, CVEGEO
FROM Boundaries_AGEB_2025
WHERE geom.STIsValid() = 0;
```

#### Resultado esperado

ID    CVEGEO  
None  
(todas las geometrías son válidas)

### Corregir geometrías inválidas usando MakeValid

Si la consulta devuelve resultados, indica un problema que debe corregirse.  
Usa el siguiente paso para repararlas.

1️⃣ Solo si existen geometrías inválidas:  
Este SQL debe convertir todas las geometrías inválidas en válidas y devolver cero filas:

```sql
---------------------------------------------------
-- 1 Corregir geometrías inválidas usando MakeValid
---------------------------------------------------
UPDATE Boundaries_AGEB_2025
SET geom = geom.MakeValid()
WHERE geom.STIsValid() = 0;
```

#### Resultado esperado

(0 rows affected)   


## 9 — Copiar geometría: columna geom → columna geog


```sql
-----------------------------------------------------------
-- 9 Copiar geometría: columna geom a columna geog
-----------------------------------------------------------
UPDATE Boundaries_AGEB_2025
SET geog = geography::STGeomFromText(geom.STAsText(), 4326);
```

#### Resultado esperado

(82283 rows affected)   

---

### Validar geog (geography)

2️⃣ Verificación de geografía faltante  
Esta consulta también debe regresar **cero filas**:

```sql
-----------------------------------------
-- 2 - Verificación de geografía faltante
----------------------------------------
SELECT ID
FROM Boundaries_AGEB_2025
WHERE geog IS NULL;

```

#### Resultado esperado

ID  
None  
(todas las geometrías geográficas están presentes)

---

## Resultado Final

La tabla `Boundaries_AGEB_2025` ahora contiene:

- 82,263 AGEB  
- Geometrías válidas  
- CVEGEO completo  
- Clasificación Urbano/Rural  
- Campos de Población y Viviendas listos para llenarse posteriormente

Se utiliza para:

- Intersectar colonias con las geometrías de AGEB  
- Calcular proporciones de área  
- Ponderar la población AMAI por colonia  
- Servir como base para el cálculo del NSE por colonia







