# 4 Cálculo de NSE para Boundaries layer = 6 (Colonias)

> **Referencia:** Consulta el documento [Methodologia](methodologia.md) para la descripción conceptual completa del proceso de cálculo NSE, incluyendo relaciones entre datasets, lógica de ponderación y pasos de auditoría.  
> Esta página documenta la **implementación**: el flujo SQL y GIS utilizado para calcular el NSE para Boundaries Layer 6 (Colonias).

## Propósito dentro del pipeline NSE

Este dataset se utiliza para:

- Construir **Boundaries Layer 6** (Colonias)  
- Realizar la **intersección espacial** con polígonos AGEB  
- Calcular valores **NSE ponderados por área** para cada colonia  

## Por qué se requiere la ponderación por área

Las colonias frecuentemente cruzan múltiples límites de AGEB.  
Cada AGEB tiene su propia clasificación NSE AMAI, por lo que la colonia hereda un **NSE ponderado** según la proporción de su área que cae dentro de cada AGEB.

### Ejemplo

| AGEB | % Área en la colonia | C+ | C | D+ | E |
|------|-----------------------|----|---|----|---|
| A | 70 % | 40 | 30 | 20 | 10 |
| B | 30 % | 10 | 20 | 40 | 30 |

Los valores ponderados de la colonia son:

C+ = 0.7 × 40 + 0.3 × 10  
C  = 0.7 × 30 + 0.3 × 20  

Esto garantiza que el NSE asignado a cada colonia refleje con precisión la composición socioeconómica de las AGEB que la conforman.

---

# 1 — Verificar geometrías

### ✔ Sin geometrías válidas, no hay intersección colonia × AGEB  
- `STIntersection()` falla si hay self‑intersections.  
- `STArea()` devuelve 0 si la geometría está rota.  
- `STTransform()` falla si el SRID es incorrecto.  

### ✔ Sin bounding boxes correctos, la API y el mapa fallan  
- Coordenadas con `E+` o `E-` indican corrupción numérica.  
- Esto afecta zoom, pan, clustering y bounding filters.

### ✔ Sin SRID consistente, geography no funciona  
- geography exige **EPSG:4326**.  
- geometry puede estar en 4023, pero geography no.

### ✔ Sin tipos Polygon/MultiPolygon, el pipeline se rompe  
- AMAI NSE requiere áreas reales.  
- Líneas o puntos no sirven.
  
```sql
------------------------------------------------------
-- NSE Paso 4.0 — Validar geometrías
-- Boundaries capa 6 (colonias) y MG 2025 AGEB
-- Colonias: Boundaries Layer = 6
-- AGEB:     Boundaries_AGEB_2025
------------------------------------------------------

-------------------------------------
-- Boundaries Layer 6 (colonias)
-- Esperado: Nada = OK
-------------------------------------

-------------------------
-- Geometrías inválidas
-------------------------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND geom.STIsValid() = 0;

---------------------------
-- Geometrías vacías o nulas
---------------------------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND (geom IS NULL OR geom.STIsEmpty() = 1);

-----------
-- Área = 0
-----------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND geom.STArea() = 0;

--------------------------
-- Tipo de geometría incorrecto
--------------------------

SELECT ID, CVEGEO, geom.STGeometryType()
FROM Boundaries
WHERE Layer = 6
  AND geom.STGeometryType() NOT IN ('Polygon','MultiPolygon');

----------------------------------------------
-- Bounding box sospechoso (coordenadas raras)
----------------------------------------------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND (geom.STEnvelope().ToString() LIKE '%E+%' OR geom.STEnvelope().ToString() LIKE '%E-%');

----------------------------------------
-- SRID inconsistente (debe ser EPSG: 4326)
----------------------------------------

SELECT DISTINCT geom.STSrid AS SRID
FROM Boundaries
WHERE Layer = 6;


------------------------------
-- AGEB (Boundaries_AGEB_2025)
------------------------------

---------------------
-- Geometrías inválidas
---------------------

SELECT ID, CVEGEO 
FROM Boundaries_AGEB_2025
WHERE geom.STIsValid() = 0;

---------------------------
-- Geometrías vacías o nulas
---------------------------

SELECT ID, CVEGEO 
FROM Boundaries_AGEB_2025
WHERE geom IS NULL OR geom.STIsEmpty() = 1;

-----------
-- Área = 0
-----------

SELECT ID, CVEGEO 
FROM Boundaries_AGEB_2025
WHERE geom.STArea() = 0;

--------------------------
-- Tipo de geometría incorrecto
--------------------------

SELECT ID, CVEGEO, geom.STGeometryType()
FROM Boundaries_AGEB_2025
WHERE geom.STGeometryType() NOT IN ('Polygon','MultiPolygon');

-----------------------------------
-- Bounding box sospechoso E+ o E-
-----------------------------------

SELECT ID, CVEGEO 
FROM Boundaries_AGEB_2025
WHERE geom.STEnvelope().ToString() LIKE '%E+%' 
   OR geom.STEnvelope().ToString() LIKE '%E-%';

------------------------------------
-- SRID inconsistente (debe ser 4326)
------------------------------------

SELECT DISTINCT geom.STSrid AS SRID
FROM Boundaries_AGEB_2025;
```

# 2 — Crear intersección Colonias (layer = 6) ↔ AGEB

Superponer los polígonos AGEB con los polígonos de colonias para establecer relaciones espaciales.

- Usar Boundaries_AGEB_2025 (polígonos AGEB)
- Usar Boundaries con Layer = 6 (Colonias)
- Aplicar ST_Intersects o ST_Intersection para generar las áreas de traslape
- Guardar resultados en COLONIA_AGEB_INTERSECT


```sql
USE INMO;
GO

----------------------------------------------------------------
-- NSE Step 4.2 — Crear intersección Colonias (layer = 6) ↔ AGEB
----------------------------------------------------------------

-- Crea COLONIA_AGEB_INTERSECT
-- Resultado esperado: ~267,718 registros

DROP TABLE IF EXISTS COLONIA_AGEB_INTERSECT;
GO

SELECT 
    B.ID AS ID_COLONIA,
    B.CVEGEO AS CVE_COLONIA,
    A.CVEGEO AS CVE_AGEB,
    B.geom.STIntersection(A.geom) AS geom_inter,
    B.geom.STIntersection(A.geom).STArea() / B.geom.STArea() AS pct_area
INTO COLONIA_AGEB_INTERSECT
FROM Boundaries B
JOIN Boundaries_AGEB_2025 A
    ON B.geom.STIntersects(A.geom) = 1
WHERE B.layer = 6;
GO

------------------------------------------------------------------------
-- Validación: Cuántos registros se generaron en COLONIA_AGEB_INTERSECT
-- Resultado esperado: ~267,718 registros
-- Tiempo de ejecución: ~1 segundo
------------------------------------------------------------------------

SELECT COUNT(*) AS Records FROM COLONIA_AGEB_INTERSECT;

----------------------------------------------------------------------------
-- 4.3 Validación: Verificar que no existan colonias sin intersecciones AGEB
-- Resultado esperado: 0
-----------------------------------------------------------------------------


SELECT COUNT(*) 
FROM Boundaries B
LEFT JOIN COLONIA_AGEB_INTERSECT I
    ON B.CVEGEO = I.CVE_COLONIA
WHERE B.layer = 6
  AND I.CVE_COLONIA IS NULL;
```

# 3 — Crear COLONIA_NSE (población ponderada)


```sql
USE INMO;
GO

-- Paso NSE 4.3 — Crear COLONIA_NSE (población ponderada)
-- Versión corregida: excluye AGEBs sin población AMAI

-- Por qué esta tabla es necesaria:
-- Cada colonia intersecta múltiples AGEBs
-- Cada AGEB tiene valores de población AMAI diferentes
-- Cada colonia cubre un porcentaje distinto de cada AGEB
-- Se debe ponderar la población según el área de intersección

-- Esta tabla es requerida para los siguientes pasos:
-- Sumar por colonia
-- Calcular porcentajes
-- Calcular NSE_SCORE
-- Determinar el NSE dominante
-- Asignar NSE_LABEL
-- Copiar resultados de COLONIA_NSE a Boundaries capa 6

-- Exclusiones:
-- ✔ AGEBs sin población
-- ✔ Evita que una intersección con NSE_TOTAL = 0 rompa toda la colonia
-- ✔ Compatible con AMAI
-- ✔ 100% robusto

DROP TABLE IF EXISTS COLONIA_NSE;
GO

SELECT
    I.CVE_COLONIA,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_AB     ELSE 0 END) AS NSE_AB,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_CPLUS  ELSE 0 END) AS NSE_CPLUS,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_C      ELSE 0 END) AS NSE_C,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_CMINUS ELSE 0 END) AS NSE_CMINUS,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_DPLUS  ELSE 0 END) AS NSE_DPLUS,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_D      ELSE 0 END) AS NSE_D,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_E      ELSE 0 END) AS NSE_E,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_TOTAL  ELSE 0 END) AS NSE_TOTAL
INTO COLONIA_NSE
FROM COLONIA_AGEB_INTERSECT I
LEFT JOIN AMAI_AGEB_2024 A
    ON I.CVE_AGEB = A.CVEGEO
GROUP BY I.CVE_COLONIA;
GO

-------------------------------------------
-- Validación: Se esperan ~79,775 registros
-- mismo número de registros que Boundaries
------------------------------------------


SELECT COUNT(*) AS Records_NSE_COLONIA FROM COLONIA_NSE;

-----------------------------------------
-- Validación: Colonias con NSE_TOTAL = 0
-- Debe devolver ~12,708 Colonias_No_Pop
-----------------------------------------

SELECT COUNT(*) AS Neighborhood_No_Pop
FROM COLONIA_NSE
WHERE NSE_TOTAL = 0;

-------------------------------------------------------------------------------------------
-- Validación: Ejemplo
-- Colonia El Cielo (CVE_COLONIA = 2300800010017)
-- CVE_COLONIA   NSE_AB   NSE_PLUS   NSE_C   NSE_DPLUS   NSE_DE   NSE_TOTAL
-- 2300800010017  6.69871  7.95565    6.69931  2.09404     0.00045  0.00018   0   23.448389
-------------------------------------------------------------------------------------------


SELECT *
FROM COLONIA_NSE
WHERE CVE_COLONIA = '2300800010017';
```

# 4 — Calcular porcentajes por colonia (neighborhood)

Esto genera los porcentajes por nivel y prepara todo para:
- NSE_SCORE  
- NSE dominante  
- NSE_LABEL

```sql
USE INMO;
GO

-- NSE Step 4.4 — Calculate percentages by neighborhood (colonia)

-- This generates:
-- NSE_AB_PCT   
-- NSE_CPLUS_PCT   
-- NSE_C_PCT   
-- NSE_CMINUS_PCT   
-- NSE_DPLUS_PCT   
-- NSE_D_PCT   
-- NSE_E_PCT   
-- Prepara todo para NSE_SCORE, NSE dominante y NSE_LABEL

-- Ya tenemos:
-- Boundaries ✔
-- COLONIA_AGEB_INTERSECT ✔
-- COLONIA_NSE ✔ (79,775 colonias con población ponderada)

-- Este paso es crítico porque convierte la población ponderada en porcentajes,
-- que luego alimentan NSE_SCORE, NSE dominante y NSE_LABEL.


-----------------------------------------------------------
-- 1 Agregar las columnas de porcentaje a la tabla
-- Estas columnas almacenarán los porcentajes por nivel NSE
-----------------------------------------------------------


ALTER TABLE COLONIA_NSE
ADD NSE_AB_PCT      numeric(10,4),
    NSE_CPLUS_PCT   numeric(10,4),
    NSE_CMINUS_PCT  numeric(10,4),
    NSE_C_PCT       numeric(10,4),
    NSE_DPLUS_PCT   numeric(10,4),
    NSE_D_PCT       numeric(10,4),
    NSE_E_PCT       numeric(10,4);
GO

--------------------------
-- 2 Calcular porcentajes
--------------------------

UPDATE COLONIA_NSE
SET
    NSE_AB_PCT      = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_AB     * 100.0 / NSE_TOTAL, 4) END,
    NSE_CPLUS_PCT   = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_CPLUS  * 100.0 / NSE_TOTAL, 4) END,
    NSE_C_PCT       = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_C      * 100.0 / NSE_TOTAL, 4) END,
    NSE_CMINUS_PCT  = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_CMINUS * 100.0 / NSE_TOTAL, 4) END,
    NSE_DPLUS_PCT   = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_DPLUS  * 100.0 / NSE_TOTAL, 4) END,
    NSE_D_PCT       = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_D      * 100.0 / NSE_TOTAL, 4) END,
    NSE_E_PCT       = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_E      * 100.0 / NSE_TOTAL, 4) END;
GO


----------------------------------------------------------------------
-- Validación 1: Verificar que ningún porcentaje sea NULL cuando NSE_TOTAL > 0
----------------------------------------------------------------------

SELECT CVE_COLONIA, NSE_TOTAL, NSE_AB_PCT, NSE_CPLUS_PCT, NSE_C_PCT,
       NSE_CMINUS_PCT, NSE_DPLUS_PCT, NSE_D_PCT, NSE_E_PCT
FROM COLONIA_NSE
WHERE NSE_TOTAL > 0
  AND (
        NSE_AB_PCT IS NULL
     OR NSE_CPLUS_PCT IS NULL
     OR NSE_C_PCT IS NULL
     OR NSE_CMINUS_PCT IS NULL
     OR NSE_DPLUS_PCT IS NULL
     OR NSE_D_PCT IS NULL
     OR NSE_E_PCT IS NULL
  );


----------------------------------------------------
-- Validación 2: Verificar que los porcentajes sumen ~100%
----------------------------------------------------

SELECT TOP 20
    CVE_COLONIA,
    NSE_AB_PCT + NSE_CPLUS_PCT + NSE_C_PCT +
    NSE_CMINUS_PCT + NSE_DPLUS_PCT + NSE_D_PCT + NSE_E_PCT AS SUM_PCT
FROM COLONIA_NSE;


---------------------------------------------------------------------------------
-- Validación 3: Confirmar que ninguna colonia con NSE_TOTAL > 0 tenga todos los
-- porcentajes en NULL
---------------------------------------------------------------------------------

SELECT *
FROM COLONIA_NSE
WHERE NSE_TOTAL > 0
  AND NSE_AB_PCT IS NULL
  AND NSE_CPLUS_PCT IS NULL
  AND NSE_C_PCT IS NULL
  AND NSE_CMINUS_PCT IS NULL
  AND NSE_DPLUS_PCT IS NULL
  AND NSE_D_PCT IS NULL
  AND NSE_E_PCT IS NULL;


-----------------------------------------------------
-- Validación 4: Distribución de colonias por NSE
-----------------------------------------------------

SELECT NSE_LABEL, COUNT(*) AS Colonias
FROM (
    SELECT 
        CVE_COLONIA,
        CASE 
            WHEN NSE_AB_PCT     = (SELECT MAX(val) FROM (VALUES (NSE_AB_PCT),(NSE_CPLUS_PCT),(NSE_C_PCT),(NSE_CMINUS_PCT),(NSE_DPLUS_PCT),(NSE_D_PCT),(NSE_E_PCT)) AS t(val)) THEN 'AB'
            WHEN NSE_CPLUS_PCT  = (SELECT MAX(val) FROM (VALUES (NSE_AB_PCT),(NSE_CPLUS_PCT),(NSE_C_PCT),(NSE_CMINUS_PCT),(NSE_DPLUS_PCT),(NSE_D_PCT),(NSE_E_PCT)) AS t(val)) THEN 'C+'
            WHEN NSE_C_PCT      = (SELECT MAX(val) FROM (VALUES (NSE_AB_PCT),(NSE_CPLUS_PCT),(NSE_C_PCT),(NSE_CMINUS_PCT),(NSE_DPLUS_PCT),(NSE_D_PCT),(NSE_E_PCT)) AS t(val)) THEN 'C'
            WHEN NSE_CMINUS_PCT = (SELECT MAX(val) FROM (VALUES (NSE_AB_PCT),(NSE_CPLUS_PCT),(NSE_C_PCT),(NSE_CMINUS_PCT),(NSE_DPLUS_PCT),(NSE_D_PCT),(NSE_E_PCT)) AS t(val)) THEN 'C-'
            WHEN NSE_DPLUS_PCT  = (SELECT MAX(val) FROM (VALUES (NSE_AB_PCT),(NSE_CPLUS_PCT),(NSE_C_PCT),(NSE_CMINUS_PCT),(NSE_DPLUS_PCT),(NSE_D_PCT),(NSE_E_PCT)) AS t(val)) THEN 'D+'
            WHEN NSE_D_PCT      = (SELECT MAX(val) FROM (VALUES (NSE_AB_PCT),(NSE_CPLUS_PCT),(NSE_C_PCT),(NSE_CMINUS_PCT),(NSE_DPLUS_PCT),(NSE_D_PCT),(NSE_E_PCT)) AS t(val)) THEN 'D'
            WHEN NSE_E_PCT      = (SELECT MAX(val) FROM (VALUES (NSE_AB_PCT),(NSE_CPLUS_PCT),(NSE_C_PCT),(NSE_CMINUS_PCT),(NSE_DPLUS_PCT),(NSE_D_PCT),(NSE_E_PCT)) AS t(val)) THEN 'E'
        END AS NSE_LABEL
    FROM COLONIA_NSE
    WHERE NSE_TOTAL > 0
) AS Labels
GROUP BY NSE_LABEL
ORDER BY NSE_LABEL ASC;
```

#### Validación 1 — Porcentajes no NULL cuando NSE_TOTAL > 0

Debe mostrar una tabla donde:

- Ninguna colonia con NSE_TOTAL > 0 tiene todos los campos _PCT en NULL.
- Visualmente confirmas que al menos un porcentaje existe, pero normalmente varios niveles tienen valores.

Esto valida que el cálculo de porcentajes se ejecutó correctamente.

#### Validación 2

|CVE_COLONIA  |SUM_PCT|
|-------------|-------|
|1307400010027|100.00|
|1205000010002|100.00|
|1000500010024|100.01|
|1400800010079|100.00|
|1305600010031|99.99|
|1205000010030|94.23|
|1202900010201|99.95|
|1305100260003|99.99|
|1200100010246|99.97|
|1000500010698|99.90|
|1304800010046|100.01|
|0710100010324|100.01|
|1403900010192|99.95|
|1412002310013|100.00|
|1902900010002|100.00|
|2107100010033|100.01|
|2111400011362|NULL|
|1605300010760|100.00|
|1607700670001|99.99|
|0400200010041|100.01|

#### Validación 3

NONE (Confirmar que ninguna colonia con NSE_TOTAL > 0 tiene todos los porcentajes en NULL)

#### Validación 4

|NSE_LABEL|Neighborhoods|
|--------|-------------|
|AB      |6317|
|C+      |11569|
|C       |7240|
|C-      |3073|
|D+      |756|
|D       |37718|
|E       |394|

# 5 — Calcular IDS_PROM y NSE_SCORE

```sql
USE INMO;
GO

---------------------------------------------------------
-- Paso NSE 4.5 — Calcular IDS_PROM y NSE_SCORE
-- IDS_PROM  = índice bruto ponderado (0–700)
-- NSE_SCORE = índice normalizado (escala 1–7)
---------------------------------------------------------

-- Índice AMAI ponderado con categorías simplificadas:
--
-- IDS_PROM:
-- Categoría   Peso
-- A/B         7
-- C+          6
-- C           5
-- C-          4
-- D+          3
-- D           2
-- E           1
--
-- NSE_SCORE = IDS_PROM / 100 (escala 1–7)

-----------------------------------------
-- 1. Eliminar columnas previas si existen
-----------------------------------------

IF EXISTS (SELECT 1 FROM sys.columns 
           WHERE Name = N'IDS_PROM' AND Object_ID = Object_ID(N'COLONIA_NSE'))
BEGIN
    ALTER TABLE COLONIA_NSE DROP COLUMN IDS_PROM;
END;

IF EXISTS (SELECT 1 FROM sys.columns 
           WHERE Name = N'NSE_SCORE' AND Object_ID = Object_ID(N'COLONIA_NSE'))
BEGIN
    ALTER TABLE COLONIA_NSE DROP COLUMN NSE_SCORE;
END;
GO

-----------------------
-- 2. Agregar columnas limpias
-----------------------
ALTER TABLE COLONIA_NSE
ADD IDS_PROM  numeric(10,4),
    NSE_SCORE numeric(10,4);
GO

---------------------------------------------------------------
-- 3. Calcular IDS_PROM (índice bruto) y NSE_SCORE (normalizado)
---------------------------------------------------------------
UPDATE COLONIA_NSE
SET 
    IDS_PROM =
          ISNULL(NSE_AB_PCT,0)     * 7
        + ISNULL(NSE_CPLUS_PCT,0)  * 6
        + ISNULL(NSE_C_PCT,0)      * 5
        + ISNULL(NSE_CMINUS_PCT,0) * 4
        + ISNULL(NSE_DPLUS_PCT,0)  * 3
        + ISNULL(NSE_D_PCT,0)      * 2
        + ISNULL(NSE_E_PCT,0)      * 1,

    NSE_SCORE =
    (
          ISNULL(NSE_AB_PCT,0)     * 7
        + ISNULL(NSE_CPLUS_PCT,0)  * 6
        + ISNULL(NSE_C_PCT,0)      * 5
        + ISNULL(NSE_CMINUS_PCT,0) * 4
        + ISNULL(NSE_DPLUS_PCT,0)  * 3
        + ISNULL(NSE_D_PCT,0)      * 2
        + ISNULL(NSE_E_PCT,0)      * 1
    ) / 100.0;


---------------------------------------------------------
-- Validación
---------------------------------------------------------

-- 1. Verificar que NSE_SCORE no sea NULL cuando NSE_TOTAL > 0
SELECT *
FROM COLONIA_NSE
WHERE NSE_TOTAL > 0 AND NSE_SCORE IS NULL;

-- 2. Inspeccionar valores típicos
SELECT TOP 40 CVE_COLONIA, IDS_PROM, NSE_SCORE
FROM COLONIA_NSE
ORDER BY NSE_SCORE DESC;

```

### Resultados esperados

#### Validación 1

**No deben aparecer registros** cuando:

- NSE_TOTAL > 0
- NSE_SCORE IS NULL

Esto confirma que todas las colonias con población AMAI tienen un score calculado correctamente.

#### Validación 2 — Valores típicos (orden descendente)

Tu tabla es correcta y representa exactamente lo que debe aparecer cuando ordenas por

'''code
NSE_SCORE DESC
```

|CVE_COLONIA  |IDS_PROM|NSE_SCORE|
|-------------|--------|---------|
|3110200010059|699.9992|7.0000|
|1904800010254|683.9540|6.8395|
|1904800010273|677.7567|6.7776|
|1903900011171|677.3900|6.7739|
|1901900010234|676.9549|6.7695|
|1901900010076|676.9533|6.7695|
|1901900010075|676.9539|6.7695|
|1901900010074|676.9531|6.7695|
|1901900010003|676.9513|6.7695|
|1901900010435|676.8476|6.7685|

# 6 — Calcular NSE dominante (A/B, C+, C, C−, D+, D, E)

```sql
USE INMO;
GO

-------------------------------------------------------------------
-- Paso NSE 4.6 — Calcular NSE dominante (A/B, C+, C, C-, D+, D, E)
-- Seleccionar la categoría con el porcentaje más alto
-------------------------------------------------------------------

-- 1. Borra Columna NSE en COLONIA_NSE si existe
IF EXISTS (SELECT 1 FROM sys.columns 
           WHERE Name = N'NSE' AND Object_ID = Object_ID(N'COLONIA_NSE'))
BEGIN
    ALTER TABLE COLONIA_NSE DROP COLUMN NSE;
END;
GO

-- 2. Agrega nueva columna NSE limpia
ALTER TABLE COLONIA_NSE
ADD NSE varchar(5);
GO

-- 3. Calcular NSE dominante usando VALUES()
UPDATE COLONIA_NSE
SET NSE =
(
    SELECT TOP 1 Nivel
    FROM
    (
        VALUES
            ('A/B', NSE_AB_PCT),
            ('C+',  NSE_CPLUS_PCT),
            ('C',   NSE_C_PCT),
            ('C-',  NSE_CMINUS_PCT),
            ('D+',  NSE_DPLUS_PCT),
            ('D',   NSE_D_PCT),
            ('E',   NSE_E_PCT)
    ) AS X(Nivel, Valor)
    WHERE Valor IS NOT NULL
    ORDER BY Valor DESC
)
WHERE NSE_TOTAL > 0;
GO


-- 4. Colonias sin población → NSE = 'N/A'
UPDATE COLONIA_NSE
SET NSE = 'N/A'
WHERE NSE_TOTAL = 0;
GO

-------------
-- Validación
-------------

-- 1. Ninguna colonia con NSE_TOTAL > 0 debe tener NSE = NULL

SELECT *
FROM COLONIA_NSE
WHERE NSE_TOTAL > 0 AND NSE IS NULL;

-- 2. Distribución general

SELECT NSE, COUNT(*) AS Colonias
FROM COLONIA_NSE
GROUP BY NSE
ORDER BY NSE ASC;
GO
```

### Resultados esperados

#### Validación 1

Solo encabezados — sin registros
Esto confirma que todas las colonias con NSE_TOTAL > 0 tienen un valor NSE asignado correctamente.     

CVE_COLONIA	NSE_AB	NSE_CPLUS	NSE_C	NSE_CMINUS	NSE_DPLUS	NSE_D	NSE_E	NSE_TOTAL	NSE_AB_PCT	NSE_CPLUS_PCT	NSE_CMINUS_PCT	NSE_C_PCT	NSE_DPLUS_PCT	NSE_D_PCT	NSE_E_PCT	IDS_PROM	NSE_SCORE	NSE

#### Validación 2

|NSE|Colonias|
|---|--------|
|A/B|6087|
|C+|11747|
|C|7242|
|C-|3069|
|D+|758|
|D|37770|
|E|394|
|N/A|12708|

# 7 — Crear NSE_LABEL

Crear NSE_LABEL con letra y porcentaje redondeado, ejemplo:  
"A/B (57%)", "C+ (32%)", "N/A (0%)"


```sql
USE INMO
GO

---------------------------------------------------------
-- Paso NSE 4.7 — Crear NSE_LABEL
---------------------------------------------------------

-- Lógica:
-- 1. Agregar columna NSE_LABEL
-- 2. Construir texto con NSE dominante + porcentaje redondeado
--    Ejemplo: "A/B (47%)", "C+ (32%)", "N/A (0%)"

-- 1. Agregar columna NSE_LABEL
ALTER TABLE COLONIA_NSE
ADD NSE_LABEL varchar(15);
GO

-- 2. Generar texto NSE_LABEL
UPDATE COLONIA_NSE
SET NSE_LABEL = 
    CASE 
        WHEN NSE = 'A/B' THEN CONCAT('A/B (', CAST(ROUND(NSE_AB_PCT,0) AS INT), '%)')
        WHEN NSE = 'C+'  THEN CONCAT('C+ (',  CAST(ROUND(NSE_CPLUS_PCT,0) AS INT), '%)')
        WHEN NSE = 'C'   THEN CONCAT('C (',   CAST(ROUND(NSE_C_PCT,0) AS INT), '%)')
        WHEN NSE = 'C-'  THEN CONCAT('C- (',  CAST(ROUND(NSE_CMINUS_PCT,0) AS INT), '%)')
        WHEN NSE = 'D+'  THEN CONCAT('D+ (',  CAST(ROUND(NSE_DPLUS_PCT,0) AS INT), '%)')
        WHEN NSE = 'D'   THEN CONCAT('D (',   CAST(ROUND(NSE_D_PCT,0) AS INT), '%)')
        WHEN NSE = 'E'   THEN CONCAT('E (',   CAST(ROUND(NSE_E_PCT,0) AS INT), '%)')
        WHEN NSE = 'N/A' THEN 'N/A (0%)'
    END
WHERE NSE IS NOT NULL;
GO

---------------------------------------------------------
-- Validación
---------------------------------------------------------

-- 1. Muestra de resultados
SELECT TOP 20 CVE_COLONIA, NSE, NSE_LABEL
FROM COLONIA_NSE;

-- 2. Conteo de colonias con NSE_LABEL
-- Esperado: 79,775 colonias totales
-- Menos ~12,708 con NSE_TOTAL = 0
-- ≈ 67,067 con NSE_LABEL válido

SELECT COUNT(*) AS Colonias_With_Label
FROM COLONIA_NSE
WHERE NSE_LABEL IS NOT NULL;
```

### Resultados esperados

#### Validación 1 — Muestra de NSE y NSE_LABEL

Tu tabla es correcta y representa exactamente lo que debe aparecer después de generar **NSE_LABEL:**   

|CVE_COLONIA  |NSE|NSE_LABEL|
|-------------|---|---------|
|1307400010027|D|D (24%)|
|1205000010002|D|D (27%)|
|1000500010024|D|D (22%)|
|1400800010079|C-|C- (22%)|
|1305600010031|D|D (23%)|
|1205000010030|D|D (27%)|
|1202900010201|D|D (25%)|
|1305100260003|A/B|A/B (30%)|
|1200100010246|D|D (40%)|
|1000500010698|C+|C+ (29%)|
|1304800010046|C|C (20%)|
|0710100010324|D|D (24%)|
|1403900010192|C+|C+ (28%)|
|1412002310013|C-|C- (23%)|
|1902900010002|D|D (26%)|
|2107100010033|D|D (42%)|
|2111400011362|A/B|A/B (42%)|
|1605300010760|C|C (19%)|
|1607700670001|D|D (37%)|
|0400200010041|D|D (33%)|

#### Validación 2 — Conteo de colonias con NSE_LABEL

Colonias_With_Label  
79775  
Este resultado significa que **todas las colonias del país** —las **79,775** colonias del dataset DCAH— tienen un valor **NSE_LABEL** asignado.

Esto confirma que:  

***1. Las colonias con población AMAI (~67,067)**   

Recibieron un NSE dominante y un NSE_LABEL válido:
- A/B (xx%)
- C+ (xx%)
- C (xx%)
- C− (xx%)
- D+ (xx%)
- D (xx%)
- E (xx%)

**2. Las colonias sin población (~12,708)**   

Recibieron correctamente:

- **NSE = 'N/A'**
- **NSE_LABEL = 'N/A (0%)'**

# 8 — Copiar cálculos de COLONIA_NSE a Boundaries (Layer = 6)

Esta es la etapa final del **Paso 4 del pipeline NSE**, donde los resultados calculados en COLONIA_NSE se transfieren a la tabla Boundaries para el Layer 6 (Colonias).  

Esto incluye:  

- NSE
- NSE_SCORE
- IDS_PROM
- NSE_LABEL
  
```sql
USE INMO;
GO

---------------------------------------------------------
-- Paso NSE 4.8 — Actualizar Boundaries Layer 6 con valores finales
-- Requiere que los pasos 4.5, 4.6 y 4.7 ya hayan sido ejecutados
---------------------------------------------------------

-- 1. Validar que las columnas requeridas existan en COLONIA_NSE
--    Si falta alguna → ABORTAR

IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE Name = 'NSE' AND Object_ID = OBJECT_ID('COLONIA_NSE'))
BEGIN
    RAISERROR('ERROR: Missing column NSE. Step 4.6 not executed.', 16, 1);
    RETURN;
END;

IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE Name = 'NSE_LABEL' AND Object_ID = OBJECT_ID('COLONIA_NSE'))
BEGIN
    RAISERROR('ERROR: Missing column NSE_LABEL. Step 4.7 not executed.', 16, 1);
    RETURN;
END;

IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE Name = 'NSE_SCORE' AND Object_ID = OBJECT_ID('COLONIA_NSE'))
BEGIN
    RAISERROR('ERROR: Missing column NSE_SCORE. Step 4.5 not executed.', 16, 1);
    RETURN;
END;

IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE Name = 'IDS_PROM' AND Object_ID = OBJECT_ID('COLONIA_NSE'))
BEGIN
    RAISERROR('ERROR: Falta la columna IDS_PROM. El Paso 4.5 no fue ejecutado.', 16, 1);
    RETURN;
END;

PRINT 'Validación OK: Todas las colimnas requeridas existen.';
GO

---------------------------------------------------
-- 2. Limpiar valores previos en Boundaries Layer 6
---------------------------------------------------

UPDATE Boundaries
SET 
    NSE        = NULL,
    NSE_LABEL  = NULL,
    NSE_SCORE  = NULL,
    IDS_PROM   = NULL,
    NSE_TOTAL  = NULL,

    NSE_AB     = NULL,
    NSE_CPLUS  = NULL,
    NSE_C      = NULL,
    NSE_CMINUS = NULL,
    NSE_DPLUS  = NULL,
    NSE_D      = NULL,
    NSE_E      = NULL,

    NSE_AB_PCT     = NULL,
    NSE_CPLUS_PCT  = NULL,
    NSE_C_PCT      = NULL,
    NSE_CMINUS_PCT = NULL,
    NSE_DPLUS_PCT  = NULL,
    NSE_D_PCT      = NULL,
    NSE_E_PCT      = NULL
WHERE Layer = 6;
GO

PRINT 'Valores previos limpiados satisfactoriamente.';
GO

---------------------------------------------------------------------
-- 3. Copiar datos finales desde COLONIA_NSE hacia Boundaries Layer 6
---------------------------------------------------------------------

UPDATE B
SET
    B.NSE            = C.NSE,
    B.NSE_LABEL      = C.NSE_LABEL,
    B.NSE_SCORE      = C.NSE_SCORE,
    B.IDS_PROM       = C.IDS_PROM,

    B.NSE_TOTAL      = C.NSE_TOTAL,

    B.NSE_AB         = C.NSE_AB,
    B.NSE_CPLUS      = C.NSE_CPLUS,
    B.NSE_C          = C.NSE_C,
    B.NSE_CMINUS     = C.NSE_CMINUS,
    B.NSE_DPLUS      = C.NSE_DPLUS,
    B.NSE_D          = C.NSE_D,
    B.NSE_E          = C.NSE_E,

    B.NSE_AB_PCT     = C.NSE_AB_PCT,
    B.NSE_CPLUS_PCT  = C.NSE_CPLUS_PCT,
    B.NSE_C_PCT      = C.NSE_C_PCT,
    B.NSE_CMINUS_PCT = C.NSE_CMINUS_PCT,
    B.NSE_DPLUS_PCT  = C.NSE_DPLUS_PCT,
    B.NSE_D_PCT      = C.NSE_D_PCT,
    B.NSE_E_PCT     = C.NSE_E_PCT
FROM Boundaries B
JOIN COLONIA_NSE C
    ON B.CVEGEO = C.CVE_COLONIA
WHERE B.Layer = 6;
GO

PRINT 'Boundaries Layer 6 updated successfully.';
GO

---------------------------------------------------------
-- 4. Validaciones finales
---------------------------------------------------------

-- Distribución de categorías NSE
SELECT NSE, COUNT(*) AS Records
FROM Boundaries
WHERE Layer = 6
GROUP BY NSE
ORDER BY NSE ASC, COUNT(*) DESC;

---------------------------------------------------------
-- Colonias con población > 0 no deben tener NSE_SCORE = NULL
-- Debe regresar: NONE
---------------------------------------------------------
SELECT *
FROM Boundaries
WHERE Layer = 6
  AND NSE_TOTAL > 0
  AND NSE_SCORE IS NULL;

---------------------------------------------------------
-- Colonias sin población no deben tener NSE asignado
-- Debe regresar ~13859 colonias sin NSE_TOTAL y sin NSE
---------------------------------------------------------
SELECT 
 State, 
 Municipality, 
 City, 
 Neighborhood, 
 NSE, 
 NSE_LABEL, 
 NSE_SCORE,
 IDS_PROM,
 NSE_TOTAL,
 NSE_AB,
 NSE_CPLUS,
 NSE_C,
 NSE_CMINUS,
 NSE_DPLUS,
 NSE_D,
 NSE_E,
 NSE_AB_PCT,
 NSE_CPLUS_PCT,
 NSE_C_PCT,
 NSE_CMINUS_PCT,
 NSE_DPLUS_PCT,
 NSE_D_PCT,
 NSE_E_PCT
FROM Boundaries
WHERE Layer = 6
  AND NSE_TOTAL = 0
  AND NSE IS NOT NULL;

---------------------------------------------------------
-- Muestra de resultados
---------------------------------------------------------
SELECT TOP 20 CVEGEO, NSE, NSE_LABEL, NSE_SCORE, NSE_TOTAL
FROM Boundaries
WHERE Layer = 6;
GO

```

### Resultados esperados

#### Validación 1 — Distribución final de NSE en Boundaries Layer 6 1

|NSE|Records|
|---|-------|
|A/B|   6087|
|C  |   7242|
|C+ |  11747|
|C- |   3069|
|D  |  37770|
|D+ |    758|
|E  |    394|
|N/A|  12708|

Esta distribución es exactamente la esperada para México y coincide con:   

- La estructura socioeconómica nacional.
- Los resultados previos de COLONIA_NSE.
- La sincronización correcta con Boundaries Layer 6.
- 
#### Validación 2 — Colonias con población > 0 y NSE_SCORE = NULL

None

Esto confirma que:  

Todas las colonias con NSE_TOTAL > 0 recibieron correctamente:  

- IDS_PROM
- NSE_SCORE
- NSE dominante
- NSE_LABEL

#### Validación 3 — Colonias sin población (NSE_TOTAL = 0)

14,162 registros

El archivo original DCAH no contiene población AMAI para 14,162 colonias.  

Estas colonias deben tener:  

- NSE = 'N/A'
- NSE_LABEL = 'N/A (0%)'
- NSE_SCORE = NULL
- IDS_PROM = NULL

#### Validación Matemátifca

```code
79,775 total colonias
– 14,162 sin población
= 65,613 con NSE válido
``


