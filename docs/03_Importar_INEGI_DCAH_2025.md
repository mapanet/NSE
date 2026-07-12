# 3.0 INEGI DCAH 2025 (Polígonos de Colonias)

Este documento describe el proceso para importar el dataset **INEGI DCAH 2025**, que contiene los límites poligonales oficiales de colonias y otros asentamientos humanos en México.  
Estas geometrías se utilizan para construir el **Boundaries Layer 6**, donde se calcula el Nivel Socioeconómico AMAI (NSE) para cada colonia.

Directorios sugeridos

Working : D:\AXSI\INEGI\DCAH_2025  
Download: D:\AXSI\INEGI\DCAH_2025\Download  

---

## Descripción del Dataset

**Fuente:** INEGI — *Delimitación de colonias y otros asentamientos humanos (DCAH)*  
**Edición:** 2025  
**Cobertura:** 2025‑01‑01 a 2025‑12‑31  
**Datum:** ITRF2008, Elipsoide GRS80  
**Tipo de archivo:** SHP (530.26 MB)  
**URL de descarga:** https://www.inegi.org.mx/programas/dcah/#descargas

**La página se ve así:**

[<img src="/docs/images/DCAH_2025.png" width="1000">](/docs/images/DCAH_2025.png)

---

## 3.1 Descargar datos

1. Abrir la página de descarga de INEGI DCAH:  
   https://www.inegi.org.mx/programas/dcah/#descargas

Cartografía geoestadística histórica de México  
=> https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=794551131954

Información Topográfica a escala 1:50,000 y sus actualizaciones  
=> https://www.inegi.org.mx/programas/topografia/50000/#descargas

2. En la sección **Filtros**, dejar todas las opciones por defecto:
   - **Entidad:** Estados Unidos Mexicanos  
   - **Escala:** Sin escala  
   - **Edición:** (vacío)

3. Hacer clic en **Consultar** o **Buscar** para mostrar las ediciones disponibles.

4. En la tabla de resultados, seleccionar:
   - **Delimitación de colonias y otros asentamientos humanos 2025**  
   - Tipo de archivo: **SHP**  
   - Tamaño: **530.26 MB**

5. Descargar el archivo ZIP y extraer su contenido en:

Directorio: D:\INEGI\DCAH_2025\Download  
Nombre del archivo: **794551163078_s.zip** (edición 2025)

Dentro encontrarás varios ZIP por estado y uno llamado: **00_integrado.zip**, que contiene datos de todos los estados.  
Extrae los archivos en **negritas**:

- 00_integrado.zip  
  - conjunto_de_datos  
      - **00as.shp** (archivo SHP principal) Datum: ITRF2008  
      - **00as.cpg**  
      - **00as.dbf**  
      - **00as.prj**  
      - **00as.sbn**  
      - **00as.sbx**  
      - **00as.shx**

El dataset incluye:

| Campo | Descripción |
|-------|-------------|
| **CVEGEO** | Código cvegeo de 13 dígitos EEMMMLLLLAAAA (EE estado, MMM municipio, LLLL localidad, AAAA colonia) |
| **CVE_ENT** | Código de estado |
| **CVE_MUN** | Código de municipio |
| **CVE_LOC** | Código de localidad |
| **CVE_ASEN** | Código de asentamiento |
| **CP** | Código postal |
| **FECHA_ACT** | Última actualización MM/YYYY |
| **INSTITUCIO** | Nombre de la institución fuente |
| **NOM_ASEN** | Nombre de la colonia |
| **TIPO** | Tipo de asentamiento (Fraccionamiento, Colonia, etc.) |
| **geom** | Polígono de la colonia |

---
## 3.2 Cargar 00as.shp en QGIS

Verifica que **NOM_ASEN** sea legible (acentos).  
El dataset original viene en **Windows‑1252**, pero QGIS puede cargarlo como **UTF‑8**.  
Si es necesario, ajusta la codificación en:

**Propiedades de la capa → Fuente → Windows‑1252**

Revisa los acentos en la tabla de atributos.

### Exportar como

Directorio: D:\AXSI\INEGI\DCAH_2025  
Nombre del archivo: **Boundaries_INEGI_DCAH_2025.shp**  
CRS: **EPSG:4023**  
Codificación: **UTF‑8**

Después de exportar:

- Elimina la capa original **00as.shp** de QGIS

---

# 3.3 Guardar como CSV con geometrías WKT

Exporta la capa **Boundaries_INEGI_DCAH_2025** a CSV con geometrías WKT:

- Directorio: D:\AXSI\INEGI\DCAH_2025  
- Archivo: **Boundaries_INEGI_DCAH_2025.csv**  
- CRS: **EPSG:4023**  
- Codificación: **UTF‑8**  
- Geometría: **As WKT**  
- Delimitador: **TAB**  
- String quoting: **IF_NEEDED**  
- Escribir BOM: **NO**  
- Agregar archivo guardado al mapa: **Desactivado**

Guardar → **OK**

---

Edita **Boundaries_INEGI_DCAH_2025.csv** con EditPad Pro o Notepad++:

- Reemplaza todas las comillas dobles `"` que aparezcan dentro de las geometrías  
  (por ejemplo: `"MULTIPOLYGON ((( ... )))"`)

Guarda el archivo asegurando:

- **UTF‑8**  
- **Sin BOM**

### Archivo resultante

| Campo | Descripción |
|-------|-------------|
| **WKT** | Polígono de la colonia |
| **CVEGEO** | Código cvegeo de 13 dígitos |
| **CVE_ENT** | Código de estado |
| **CVE_MUN** | Código de municipio |
| **CVE_LOC** | Código de localidad |
| **CVE_ASEN** | Código de asentamiento |
| **CP** | Código postal |
| **FECHA_ACT** | Última actualización MM/YYYY |
| **INSTITUCIO** | Nombre de la institución |
| **NOM_ASEN** | Nombre de la colonia |
| **TIPO** | Tipo de asentamiento (Fraccionamiento, Colonia, etc.) |

---

# 3.4 Subir geometrías CSV a SQL


```sql
-----------------------------------
-- 3.4 — Subir geometrías CSV a SQL
-----------------------------------

-----------------------------
-- 3.4.1 Crear tabla staging
-----------------------------

DROP TABLE IF EXISTS INEGI_DCAH_Staging;
GO

CREATE TABLE INEGI_DCAH_Staging (
    WKT varchar(MAX) NOT NULL,
    CVEGEO varchar(16) NOT NULL,
    CVE_ENT varchar(2) NULL,
    CVE_MUN varchar(3) NOT NULL,
    CVE_LOC varchar(4) NOT NULL,
    CVE_ASEN varchar(4) NOT NULL,
    CP varchar(5) NOT NULL,
    FECHA_ACT varchar(10) NULL,
    INSTITICIO nvarchar(500) NULL,
    NOM_ASEN nvarchar(115) NOT NULL,
    TIPO nvarchar(100) NOT NULL
);
GO

--------------------
-- 3.4.2 Bulk Insert
--------------------
BULK INSERT INEGI_DCAH_Staging
FROM 'D:\AXSI\INEGI\DCAH_2025\Boundaries_INEGI_DCAH_2025.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',  -- UTF-8
    TABLOCK
);
GO
```
### Resultado esperado

(79775 rows affected)

### Revisar resultados en INEGI_DCAH_Staging

```sql
SELECT TOP (5) WKT, GVEGEO, CVE_ENT, CVE_MUN, CVE_LOC, CVE_ASEN, CP, FECHA_ACT, INSTITICIO, NOM_ASEN, TIPO
FROM  dbo.INEGI_DCAH_Staging
```

|WKT|GVEGEO|CVE_ENT|CVE_MUN|CVE_LOC|CVE_ASEN|CP|FECHA_ACT|INSTITICIO|NOM_ASEN|TIPO|
|---|------|-------|-------|-------|--------|--|---------|----------|--------|----|
MULTIPOLYGON|0503300010076|05|033|0001|0076|27810|11/2022|AYUNTAMIENTO|VILLAS DEL AMÉRICA|FRACCIONAMIENTO|
MULTIPOLYGON|0503300010077|05|033|0001|0077|27810|11/2022|AYUNTAMIENTO|NINGUNO|COLONIA|
MULTIPOLYGON|0503300010079|05|033|0001|0079|00000|11/2022|AYUNTAMIENTO|LOS NOGALES|FRACCIONAMIENTO|
MULTIPOLYGON|0503300010081|05|033|0001|0081|00000|11/2022|AYUNTAMIENTO|SAN JOSÉ|COLONIA|
MULTIPOLYGON|0503300010084|05|033|0001|0084|00000|11/2022|AYUNTAMIENTO|EJIDAL VALPARAISO|COLONIA|

---

# 3.5 Crear tabla Boundaries

```sql
CREATE TABLE [dbo].[Boundaries](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CVEGEO] [varchar](16) NULL,
	[Layer] [int] NOT NULL,
	[ISO] [nvarchar](2) NULL,
	[Country] [nvarchar](25) NULL,
	[State] [nvarchar](85) NULL,
	[Municipality] [nvarchar](85) NULL,
	[City] [nvarchar](110) NULL,
	[Neighborhood] [nvarchar](115) NULL,
	[Category] [nvarchar](85) NULL,
	[PostalCode] [varchar](5) NULL,
	[Population] [int] NULL,
	[Dwelings] [int] NULL,
    [Occupied_Dwelings] [int] NULL,
	[Type] [varchar](10) NULL,
	[AreaM2] [float] NULL,
	[geog] [geography] NULL,
	[geom] [geometry] NULL,
	[minLat] [decimal](12, 6) NULL,
	[maxLat] [decimal](12, 6) NULL,
	[minLon] [decimal](12, 6) NULL,
	[maxLon] [decimal](12, 6) NULL,
	[IDS_PROM] [numeric](6, 3) NULL,
	[NSE] [varchar](5) NULL,
	[NSE_LABEL] [varchar](15) NULL,
	[NSE_AB_PCT] [numeric](5, 2) NULL,
	[NSE_CPLUS_PCT] [numeric](5, 2) NULL,
	[NSE_C_PCT] [numeric](5, 2) NULL,
	[NSE_DPLUS_PCT] [numeric](5, 2) NULL,
	[NSE_DE_PCT] [numeric](5, 2) NULL,
	[NSE_AB] [int] NULL,
	[NSE_CPLUS] [int] NULL,
	[NSE_C] [int] NULL,
	[NSE_DPLUS] [int] NULL,
	[NSE_DE] [int] NULL,
	[NSE_TOTAL] [int] NULL,
	[NSE_SCORE] [numeric](6, 3) NULL,
	[LastUpdate] [varchar](10) NULL,
	[Source] [nvarchar](400) NULL
 CONSTRAINT [PK_Boundaries] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Boundaries] ADD  CONSTRAINT [DF_Boundaries_Layer]  DEFAULT ((6)) FOR [Layer]
GO

ALTER TABLE [dbo].[Boundaries] ADD  CONSTRAINT [DF_Boundaries_ISO]  DEFAULT ('MX') FOR [ISO]
GO

ALTER TABLE [dbo].[Boundaries] ADD  CONSTRAINT [DF_Boundaries_Country]  DEFAULT ('México') FOR [Country]
GO
```

--- 

## 3.6 Copiar datos DCAH Staging a Boundaries (Layer = 6)

```sql
------------------------------------------------------------
-- 3.6 — Copy DCAH Staging Data into Boundaries (Layer = 6)
------------------------------------------------------------

INSERT INTO dbo.Boundaries (
    CVEGEO,
    Layer,
    Neighborhood,
    Category,
    PostalCode,
    geom,
    LastUpdate,
    Source
)
SELECT
    CVEGEO,                              -- Unique geographic key
    6 AS Layer,                          -- Neighborhood layer
    NOM_ASEN AS Neighborhood,            -- Neighborhood name (Colonia)
    TIPO AS Category,                    -- Settlement type
    CP AS PostalCode,                    -- Postal code
    geometry::STGeomFromText(WKT, 4326), -- Convert WKT to geometry (EPSG:4326)
    RIGHT(FECHA_ACT, 4) + '-' + LEFT(FECHA_ACT, 2) AS LastUpdate, -- Convert MM/YYYY → YYYY-MM
    INSTITICIO AS Source                 -- Data source
FROM dbo.INEGI_DCAH_Staging;
GO
```

### Resultado esperado

(79775 registros)

### Borrar staging si la copia fue existosa

```sql
DROP TABLE IF EXISTS dbo.INEGI_DCAH_Staging;
```

---

## 3.8 Validar geometrías importadas

Las geometrías WKT importadas deben revisarse para verificar su validez.  
Las geometrías inválidas se reparan utilizando `MakeValid()`.

```sql
----------------------------------
-- 3.8.0 Validar geometrías importadas
----------------------------------

SELECT ID, CVEGEO
FROM dbo.Boundaries
WHERE geom.STIsValid() = 0;
```

### Resultado esperado

ID CVEGEO   
None  
Si el valor es distinto de None, ejecutar el siguiente proceso;  
de lo contrario, continuar con el paso 8.9.


```sql
-------------------------------------------------
-- 3.8.1 Reparar geometrías inválidas (MakeValid)
-------------------------------------------------

UPDATE dbo.Boundaries
SET geom = geom.MakeValid()
WHERE geom.STIsValid() = 0;
```

----

## 3.9 Generar Geography (geog) a partir de Geometry

La columna **geog** almacena la misma geometría en el tipo **geography** de SQL Server (EPSG:4326).  
Esto permite realizar cálculos de distancia y operaciones geodésicas.


```sql
UPDATE dbo.Boundaries
SET geog = geography::STGeomFromText(geom.STAsText(), 4326);
```

### Resultado esperado

(79775 registros)

Validación:

```sql
SELECT ID, CVEGEO
FROM dbo.Boundaries
WHERE geog IS NULL;
```

### Resultado esperao

ID CVEGEO   
None  

---

## 3.10 Calcular campos de Bounding Box

Los valores del bounding box se derivan del *envelope* de la geometría **geom**.

- minLat
- maxLat
- minLon
- maxLon

```sql
UPDATE dbo.Boundaries
SET 
    minLat = geom.STEnvelope().STPointN(1).STY,
    minLon = geom.STEnvelope().STPointN(1).STX,
    maxLat = geom.STEnvelope().STPointN(3).STY,
    maxLon = geom.STEnvelope().STPointN(3).STX;
```

### Resultado esperado

(79775 rows affected)

Validación:

```sql
SELECT TOP 20 CVEGEO, minLat, maxLat, minLon, maxLon
FROM dbo.Boundaries;
```

You should see valid numeric values.

---

## 3.11 Crear índices espaciales

Los índices espaciales mejoran significativamente el rendimiento en consultas de intersección, contención y proximidad.

```sql
------------------------------------------
-- 3.11.1 Índice espacial para geom (geometry)
------------------------------------------
CREATE SPATIAL INDEX SIDX_Boundaries_geom
ON dbo.Boundaries_TEMP(geom)
WITH (BOUNDING_BOX = (-180, -90, 180, 90));

--------------------------------------------
-- 3.11.2 Índice espacial para geog (geography)
--------------------------------------------
CREATE SPATIAL INDEX SIDX_Boundaries_geog
ON dbo.Boundaries_TEMP(geog);
```

### Resultado esperado

Commands completed successfully.

---


## Próximos pasos para calcular el NSE (niveles socioeconómicos)

1. Validar la integridad de las geometrías en **Boundaries_AGEB_2025** y en **Boundaries** capa 6 (sin polígonos vacíos ni auto‑intersecciones).  
2. Revisar y normalizar las claves de Boundaries_AGEB_2025:  
   **CVEGEO = CVE_ENT + CVE_MUN + CVE_LOC + CVE_ASEN**  
3. Intersectar con las geometrías AGEB de **Boundaries_AGEB_2025** (INEGI MG 2025).  
4. Aplicar la agregación NSE ponderada por área utilizando datos **AMAI 2024** y **Censo 2020**.  
5. Enriquecer el **dataset NSE de Boundaries Layer 6** con los cálculos de NSE.

---

**Resultado:**  
Un dataset completo y validado a nivel colonia, listo para el cálculo de NSE, mapeo y uso en la API.

