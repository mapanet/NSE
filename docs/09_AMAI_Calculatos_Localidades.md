# 9.1 — Cargar valores NSE en Boundaries Layer 5 (Localidades)

**AMAI_LOC_2024** ya contiene **CVEGEO a nivel localidad**  
(CVEGEO de 9 dígitos). No se necesita aplicar *substring*.
Una vez que carguemos los valores NSE en Boundaries Layer 5, se realizará la **agregación en el nivel 2 (municipio) y nivel 1 (estado).**

```sql
USE INMO;
GO

------------------------------------------------------------
-- PASO 1 — Limpiar AMAI_LOC_2024 (dataset NSE a nivel localidad)
------------------------------------------------------------
-- NSE_TOTAL = NULL cuando NSE_TOTAL = 0
-- Esto evita cálculos inválidos de porcentajes más adelante.
-- Resultado esperado: 152 filas afectadas
------------------------------------------------------------


UPDATE AMAI_LOC_2024
SET NSE_TOTAL = NULL
WHERE NSE_TOTAL = 0;


---------------------------------------------------------
-- PASO 2 — Restablecer todos los campos NSE en Boundaries
---------------------------------------------------------
-- Capas afectadas:
-- Layer 1 = Estado
-- Layer 2 = Municipio
-- Layer 5 = Localidad (Ciudad)
-- Resultado: 53,789 filas afectadas
---------------------------------------------------------


UPDATE Boundaries
SET
    NSE = NULL,
    NSE_LABEL = NULL,
    NSE_AB_PCT = NULL,
    NSE_CPLUS_PCT = NULL,
    NSE_C_PCT = NULL,
    NSE_CMINUS_PCT = NULL,
    NSE_DPLUS_PCT = NULL,
    NSE_D_PCT = NULL,
    NSE_E_PCT = NULL,
    NSE_AB = NULL,
    NSE_CPLUS = NULL,
    NSE_C = NULL,
    NSE_CMINUS = NULL,
    NSE_DPLUS = NULL,
    NSE_D = NULL,
    NSE_E = NULL,
    NSE_TOTAL = NULL,
    NSE_SCORE = NULL
WHERE Layer IN (1, 2, 5);


---------------------------------------------------------
-- PASO 3 — Cargar valores NSE en Layer 5 (Localidades)
---------------------------------------------------------
-- AMAI_LOC_2024 ya contiene CVEGEO a nivel localidad
-- (CVEGEO de 9 dígitos). No se necesita aplicar substring.
-- Resultado: 51,279 filas afectadas
---------------------------------------------------------


UPDATE L5
SET 
    L5.NSE_AB      = S.NSE_AB,
    L5.NSE_CPLUS   = S.NSE_CPLUS,
    L5.NSE_C       = S.NSE_C,
    L5.NSE_CMINUS  = S.NSE_CMINUS,
    L5.NSE_DPLUS   = S.NSE_DPLUS,
    L5.NSE_D       = S.NSE_D,
    L5.NSE_E       = S.NSE_E,
    L5.NSE_TOTAL   = S.NSE_TOTAL
FROM Boundaries AS L5
LEFT JOIN (
    SELECT 
        CVEGEO AS CVE_LOC,
        SUM(NSE_AB)      AS NSE_AB,
        SUM(NSE_CPLUS)   AS NSE_CPLUS,
        SUM(NSE_C)       AS NSE_C,
        SUM(NSE_CMINUS)  AS NSE_CMINUS,
        SUM(NSE_DPLUS)   AS NSE_DPLUS,
        SUM(NSE_D)       AS NSE_D,
        SUM(NSE_E)       AS NSE_E,
        SUM(NSE_TOTAL)   AS NSE_TOTAL
    FROM AMAI_LOC_2024
    WHERE NSE_TOTAL IS NOT NULL
    GROUP BY CVEGEO
) AS S
    ON L5.CVEGEO = S.CVE_LOC
WHERE L5.Layer = 5;


---------------------------------------------------------------------
-- PASO 4 — Resumir Localidades (Layer 5) → Municipios (Layer 2)
---------------------------------------------------------------------
-- El CVEGEO de municipio = primeros 5 dígitos
-- Resultado: 2,478 filas afectadas
---------------------------------------------------------------------


UPDATE L2
SET 
    L2.NSE_AB      = S.NSE_AB,
    L2.NSE_CPLUS   = S.NSE_CPLUS,
    L2.NSE_C       = S.NSE_C,
    L2.NSE_CMINUS  = S.NSE_CMINUS,
    L2.NSE_DPLUS   = S.NSE_DPLUS,
    L2.NSE_D       = S.NSE_D,
    L2.NSE_E       = S.NSE_E,
    L2.NSE_TOTAL   = S.NSE_TOTAL
FROM Boundaries AS L2
LEFT JOIN (
    SELECT 
        LEFT(CVEGEO, 5) AS CVE_MUN,
        SUM(NSE_AB)      AS NSE_AB,
        SUM(NSE_CPLUS)   AS NSE_CPLUS,
        SUM(NSE_C)       AS NSE_C,
        SUM(NSE_CMINUS)  AS NSE_CMINUS,
        SUM(NSE_DPLUS)   AS NSE_DPLUS,
        SUM(NSE_D)       AS NSE_D,
        SUM(NSE_E)       AS NSE_E,
        SUM(NSE_TOTAL)   AS NSE_TOTAL
    FROM Boundaries
    WHERE Layer = 5
      AND NSE_TOTAL IS NOT NULL
    GROUP BY LEFT(CVEGEO, 5)
) AS S
    ON L2.CVEGEO = S.CVE_MUN
WHERE L2.Layer = 2;


-----------------------------------------------------------------
-- PASO 5 — Resumir Municipios (Layer 2) → Estados (Layer 1)
-----------------------------------------------------------------
-- El CVEGEO de estado = primeros 2 dígitos
-- Resultado: 32 filas afectadas
-----------------------------------------------------------------


UPDATE L1
SET 
    L1.NSE_AB      = S.NSE_AB,
    L1.NSE_CPLUS   = S.NSE_CPLUS,
    L1.NSE_C       = S.NSE_C,
    L1.NSE_CMINUS  = S.NSE_CMINUS,
    L1.NSE_DPLUS   = S.NSE_DPLUS,
    L1.NSE_D       = S.NSE_D,
    L1.NSE_E       = S.NSE_E,
    L1.NSE_TOTAL   = S.NSE_TOTAL
FROM Boundaries AS L1
LEFT JOIN (
    SELECT 
        LEFT(CVEGEO, 2) AS CVE_ENT,
        SUM(NSE_AB)      AS NSE_AB,
        SUM(NSE_CPLUS)   AS NSE_CPLUS,
        SUM(NSE_C)       AS NSE_C,
        SUM(NSE_CMINUS)  AS NSE_CMINUS,
        SUM(NSE_DPLUS)   AS NSE_DPLUS,
        SUM(NSE_D)       AS NSE_D,
        SUM(NSE_E)       AS NSE_E,
        SUM(NSE_TOTAL)   AS NSE_TOTAL
    FROM Boundaries
    WHERE Layer = 2
      AND NSE_TOTAL IS NOT NULL
    GROUP BY LEFT(CVEGEO, 2)
) AS S
    ON L1.CVEGEO = S.CVE_ENT
WHERE L1.Layer = 1;
```


# 9.2 — Calcular campos de porcentaje NSE (_PCT)

IMPORTANTE:  
- Los porcentajes deben calcularse **ÚNICAMENTE** para las Layers **1, 2 y 5.**
- Si **NSE_TOTAL es NULL**, todos los campos de porcentaje deben permanecer **NULL.**
- Esto evita divisiones inválidas y mantiene intacta la lógica de “N/D”.

```sql
USE INMO;
GO

----------------------------------------------------------------
-- PASO 9.2 — Calcular campos de porcentaje NSE (_PCT)
----------------------------------------------------------------
-- IMPORTANTE:
-- Los porcentajes deben calcularse ÚNICAMENTE para las Layers 1, 2 y 5.
-- NSE_TOTAL NO debe ser NULL; de lo contrario, los porcentajes permanecen NULL.
-- Esto evita divisiones inválidas y preserva la lógica de “N/D”.
-- Resultado esperado: 52,586 filas afectadas
----------------------------------------------------------------


UPDATE Boundaries
SET
    NSE_AB_PCT      = (NSE_AB      * 100.0 / NSE_TOTAL),
    NSE_CPLUS_PCT   = (NSE_CPLUS   * 100.0 / NSE_TOTAL),
    NSE_C_PCT       = (NSE_C       * 100.0 / NSE_TOTAL),
    NSE_CMINUS_PCT  = (NSE_CMINUS  * 100.0 / NSE_TOTAL),
    NSE_DPLUS_PCT   = (NSE_DPLUS   * 100.0 / NSE_TOTAL),
    NSE_D_PCT       = (NSE_D       * 100.0 / NSE_TOTAL),
    NSE_E_PCT       = (NSE_E       * 100.0 / NSE_TOTAL)
WHERE Layer IN (1, 2, 5)
  AND NSE_TOTAL IS NOT NULL;
```

# 9.3 Calcular NSE_SCORE (AMAI IDS)

Pesos oficiales de puntuación de AMAI:  

|Level|Score|
|-----|-----|
|AB   |    7|
|C+   |    6|
|C    |    5|
|C−   |    4|
|D+   |    3|
|D    |    2|
|E    |    1|

Fórmula:
IDS = Σ (porcentaje_nivel * puntaje_nivel)

```sql
USE INMO;
GO

---------------------------------------------------------
--   PASO 9.3 — Calcular NSE_SCORE (AMAI IDS)
---------------------------------------------------------
--   Pesos oficiales de AMAI:
--   Nivel   Puntaje
--   AB      7
--   C+      6
--   C       5
--   C−      4
--   D+      3
--   D       2
--   E       1
--
--   Fórmula:
--   IDS = Σ (porcentaje_nivel * puntaje_nivel)
--
--   Notas:
-- Los niveles faltantes deben tratarse como 0 (ISNULL).
-- Solo calcular para Layers 1, 2 y 5.
-- Solo calcular cuando NSE_TOTAL NO sea NULL.
---------------------------------------------------------

UPDATE Boundaries
SET NSE_SCORE =
    (
          (ISNULL(NSE_AB_PCT,     0) * 7)
        + (ISNULL(NSE_CPLUS_PCT,  0) * 6)
        + (ISNULL(NSE_C_PCT,      0) * 5)
        + (ISNULL(NSE_CMINUS_PCT, 0) * 4)
        + (ISNULL(NSE_DPLUS_PCT,  0) * 3)
        + (ISNULL(NSE_D_PCT,      0) * 2)
        + (ISNULL(NSE_E_PCT,      0) * 1)
    ) / 100.0
WHERE Layer IN (1, 2, 5)
  AND NSE_TOTAL IS NOT NULL;


---------------------------------------------------------
-- PASO 8.3b — Calcular IDS_PROM
---------------------------------------------------------
UPDATE Boundaries
SET IDS_PROM =
(
      (ISNULL(NSE_AB,      0) * 7)
    + (ISNULL(NSE_CPLUS,   0) * 6)
    + (ISNULL(NSE_C,       0) * 5)
    + (ISNULL(NSE_CMINUS,  0) * 4)
    + (ISNULL(NSE_DPLUS,   0) * 3)
    + (ISNULL(NSE_D,       0) * 2)
    + (ISNULL(NSE_E,       0) * 1)
) / NULLIF(NSE_TOTAL, 0)
WHERE Layer IN (1, 2, 5)
  AND NSE_TOTAL IS NOT NULL;


---------------------------------------------------------
--   Consultas de validación
---------------------------------------------------------

SELECT TOP 10 
    CVEGEO,
    NSE_TOTAL,
    NSE_AB_PCT,
    NSE_CPLUS_PCT,
    NSE_C_PCT,
    NSE_CMINUS_PCT,
    NSE_DPLUS_PCT,
    NSE_D_PCT,
    NSE_E_PCT
FROM Boundaries
WHERE Layer = 5
 AND NSE_TOTAL IS NOT NULL
ORDER BY CVEGEO;

SELECT TOP 10 CVEGEO, NSE_SCORE, IDS_PROM
FROM Boundaries
WHERE Layer = 5
 AND NSE_TOTAL IS NOT NULL
ORDER BY CVEGEO;
```

#### Validación 1

Muestra los porcentakes del capa = 5

|CVEGEO   |NSE_TOTAL|NSE_AB_PCT|NSE_CPLUS_PCT|NSE_C_PCT|NSE_CMINUS_PCT|NSE_DPLUS_PCT|NSE_D_PCT|NSE_E_PCT|
|---------|---------|----------|-------------|---------|--------------|-------------|---------|---------|
|100010001|	   3395 |7.19	   |        11.52|    15.49|	     16.73|	       17.85|	 26.98|	    4.24|
|100010004|	    233 |0.00	   |         1.72|     3.00|	      8.58|	       20.17|	 47.21|	   19.31|
|100010005|	    192 |1.04	   |         5.21|	   4.17|	     10.94|	       21.88|	 44.27|	   12.50|
|100010010|	   87	|0.00	   |         3.45|	  16.09|	     18.39|	       22.99|	 35.63|	    3.45|
|100010012|	  226	|0.44	   |         1.33|	   4.42|	      7.52|	       30.09|	 45.58|	   10.62|
|100010022|	  37	|2.70	   |         0.00|    16.22|	      8.11|	       13.51|	 43.24|	   16.22|
|100010028|	  103	|1.94	   |         1.94|	   3.88|	     18.45|	       25.24|	 42.72|	    5.83|
|100010041|	  36	|2.78	   |         0.00|	   5.56|	      5.56|	       22.22|	 55.56|	    8.33|
|100010042|	  192	|0.52	   |         2.60|	   4.69|	     17.19|	       22.40|	 40.10|	   12.50|
|100010045|	  33	|12.12	   |        24.24|	  27.27|	     12.12|	       12.12|	 12.12|	    0.00|

#### Validación 2

|CVEGEO   |NSE_SCORE|
|---------|---------|
|100010001|	3.756|
|100010004|	2.339|
|100010005|	2.698|
|100010010|	3.184|
|100010012|	2.553|
|100010022|	2.757|
|100010028|	2.854|
|100010041|	2.556|
|100010042|	2.714|
|100010045|	4.757|

# 9.4 — Calcular NSE (nivel dominante) y NSE_LABEL

Aplica a:
- Layer 1 = Estado
- Layer 2 = Municipio
- Layer 5 = Localidad (Ciudad)

Lógica:
- NSE = nivel socioeconómico dominante basado en el porcentaje más alto.
- Si todos los porcentajes son NULL → NSE = NULL (sin datos AMAI).
- Si todos los porcentajes son 0 → NSE = 'E' (nivel AMAI más bajo).
- NSE_LABEL = NSE + porcentaje redondeado (porcentaje entero).

```sql
USE INMO;
GO

------------------------------------------------------------
--   PASO 9.4 — Calcular NSE (nivel dominante) y NSE_LABEL
------------------------------------------------------------
--   Aplica a:
--     - Layer 1 = Estado
--     - Layer 2 = Municipio
--     - Layer 5 = Localidad (Ciudad)
--
--   Lógica:
-- NSE = nivel socioeconómico dominante basado en el porcentaje más alto.
-- Si todos los porcentajes son NULL → NSE = NULL (sin datos AMAI).
-- Si todos los porcentajes son 0 → NSE = 'E' (nivel AMAI más bajo).
-- NSE_LABEL = NSE + porcentaje redondeado (porcentaje entero).
-------------------------------------------------------------


---------------------------------------------------------
--  G0 — Restablecer NSE y NSE_LABEL para layers 1, 2, 5
---------------------------------------------------------

UPDATE Boundaries
SET NSE = NULL,
    NSE_LABEL = NULL
WHERE Layer IN (1, 2, 5);


---------------------------------------------------------
--  G1 — Asignar NSE (nivel AMAI dominante)
--  Maneja correctamente los casos de NULL y de ceros
---------------------------------------------------------

UPDATE B
SET NSE =
    CASE 
        WHEN Dom.Level IS NOT NULL THEN Dom.Level
        WHEN Stats.NonNullCount = 0 THEN NULL      -- all NULL → no AMAI data
        ELSE 'E'                                   -- all 0 → lowest level
    END
FROM Boundaries B

OUTER APPLY (
    /* Nivel dominante entre porcentajes > 0 */
    SELECT TOP 1 Level
    FROM (
        SELECT 'A/B' AS Level, B.NSE_AB_PCT      AS Value
        UNION ALL SELECT 'C+',  B.NSE_CPLUS_PCT
        UNION ALL SELECT 'C',   B.NSE_C_PCT
        UNION ALL SELECT 'C-',  B.NSE_CMINUS_PCT
        UNION ALL SELECT 'D+',  B.NSE_DPLUS_PCT
        UNION ALL SELECT 'D',   B.NSE_D_PCT
        UNION ALL SELECT 'E',   B.NSE_E_PCT
    ) X
    WHERE X.Value IS NOT NULL AND X.Value > 0
    ORDER BY X.Value DESC
) Dom

OUTER APPLY (
    /* Contar valores no nulos para detectar “sin datos AMAI” */
    SELECT 
        COUNT(Value) AS NonNullCount,
        MAX(Value)   AS MaxValue
    FROM (
        SELECT B.NSE_AB_PCT      AS Value
        UNION ALL SELECT B.NSE_CPLUS_PCT
        UNION ALL SELECT B.NSE_C_PCT
        UNION ALL SELECT B.NSE_CMINUS_PCT
        UNION ALL SELECT B.NSE_DPLUS_PCT
        UNION ALL SELECT B.NSE_D_PCT
        UNION ALL SELECT B.NSE_E_PCT
    ) Y
) Stats

WHERE B.Layer IN (1, 2, 5);



---------------------------------------------------------
--   G2 — Asignar NSE_LABEL (nivel + porcentaje entero)
---------------------------------------------------------


UPDATE Boundaries
SET NSE_LABEL = 
    CASE 
        WHEN NSE IS NULL THEN 'N/A'

        WHEN NSE = 'A/B' THEN 
            'A/B (' + CAST(CAST(ISNULL(NSE_AB_PCT, 0) AS INT) AS VARCHAR(3)) + '%)'

        WHEN NSE = 'C+' THEN 
            'C+ (' + CAST(CAST(ISNULL(NSE_CPLUS_PCT, 0) AS INT) AS VARCHAR(3)) + '%)'

        WHEN NSE = 'C' THEN 
            'C (' + CAST(CAST(ISNULL(NSE_C_PCT, 0) AS INT) AS VARCHAR(3)) + '%)'

        WHEN NSE = 'C-' THEN 
            'C- (' + CAST(CAST(ISNULL(NSE_CMINUS_PCT, 0) AS INT) AS VARCHAR(3)) + '%)'

        WHEN NSE = 'D+' THEN 
            'D+ (' + CAST(CAST(ISNULL(NSE_DPLUS_PCT, 0) AS INT) AS VARCHAR(3)) + '%)'

        WHEN NSE = 'D' THEN 
            'D (' + CAST(CAST(ISNULL(NSE_D_PCT, 0) AS INT) AS VARCHAR(3)) + '%)'

        WHEN NSE = 'E' THEN 
            'E (' + CAST(CAST(ISNULL(NSE_E_PCT, 0) AS INT) AS VARCHAR(3)) + '%)'
    END
WHERE Layer IN (1, 2, 5);


-- Validaciones

SELECT TOP 10 CVEGEO, NSE_LABEL
FROM Boundaries
WHERE Layer = 5
 AND NSE_TOTAL IS NOT NULL
ORDER BY NSE_LABEL, CVEGEO;
```

#### Resultado esperado

53789 rows affected

#### Validación

Muestra los primeros 10 registros de Boundarues layer = 5 (localidad) con NSE_LABEL

|CVEGEO   |NSE_LABEL |
|---------|----------|
|100010001|	D/E (31%)|
|100010004|	D/E (66%)|
|100010005|	D/E (56%)|
|100010010|	D/E (39%)|
|100010012|	D/E (56%)|
|100010022|	D/E (59%)|
|100010028|	D/E (48%)|
|100010041|	D/E (63%)|
|100010042|	D/E (52%)|
|100010045|	C (27%)  |










