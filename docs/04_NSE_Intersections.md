# 4 NSE calculation fro Boundaries layer = 6 (Neighborhoods)

## Purpose in the NSE Pipeline

This dataset is used to:

- Build **Boundaries Layer 6** (Neighborhoods)  
- Perform **spatial intersection** with AGEB polygons  
- Calculate **area‑weighted NSE** values per neighborhood  


## Why Area Weighting Is Required

Neighborhoods often cross multiple AGEB boundaries.  
Each AGEB has its own AMAI NSE classification, so the neighborhood inherits a **weighted NSE** based on the proportion of its area that falls within each AGEB.

### Example

| AGEB | % Area in Neighborhood | C+ | C | D+ | E |
|------|------------------------|----|---|----|---|
| A | 70 % | 40 | 30 | 20 | 10 |
| B | 30 % | 10 | 20 | 40 | 30 |

The neighborhood’s weighted values are:

C+ = 0.7 × 40 + 0.3 × 10
C  = 0.7 × 30 + 0.3 × 20

This ensures that the NSE assigned to each neighborhood accurately reflects the socioeconomic composition of the AGEBs it overlaps.

--

# 1 Check geometries

```sql
------------------------------------------------------
-- NSE Step 4.0 — Validate geometries
-- Boundaries layer 6 (neighborhoods) and MG 2025 AGEB
-- Neighborhoods: Boundaries Layer = 6
-- AGEB:          Boundaries_AGEB_2025
------------------------------------------------------

-------------------------------------
-- Boundaries Layer 6 (neighborhoods)
-- Expected: Nothing = OK
-------------------------------------

-------------------------
-- Invalidd Geometries
-------------------------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND geom.STIsValid() = 0;

---------------------------
-- Empty or null Geometries
---------------------------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND (geom IS NULL OR geom.STIsEmpty() = 1);

-----------
-- Area = 0
-----------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND geom.STArea() = 0;

--------------------------
-- Incorrect geometry type
--------------------------

SELECT ID, CVEGEO, geom.STGeometryType()
FROM Boundaries
WHERE Layer = 6
  AND geom.STGeometryType() NOT IN ('Polygon','MultiPolygon');

----------------------------------------------
-- Bounding box suspicious (weird coordinates)
----------------------------------------------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND (geom.STEnvelope().ToString() LIKE '%E+%' OR geom.STEnvelope().ToString() LIKE '%E-%');

----------------------------------------
-- Inconsitent SRID (must be EPSG: 4326)
----------------------------------------

SELECT DISTINCT geom.STSrid AS SRID
FROM Boundaries
WHERE Layer = 6;


------------------------------
-- AGEB (Boundaries_AGEB_2025)
------------------------------

---------------------
-- Invalid Geometries
---------------------

SELECT ID, CVEGEO 
FROM Boundaries_AGEB_2025
WHERE geom.STIsValid() = 0;

---------------------------
-- Empty or null Geometries
---------------------------

SELECT ID, CVEGEO 
FROM Boundaries_AGEB_2025
WHERE geom IS NULL OR geom.STIsEmpty() = 1;

-----------
-- Area = 0
-----------

SELECT ID, CVEGEO 
FROM Boundaries_AGEB_2025
WHERE geom.STArea() = 0;

--------------------------
-- Incorrect geometry type
--------------------------

SELECT ID, CVEGEO, geom.STGeometryType()
FROM Boundaries_AGEB_2025
WHERE geom.STGeometryType() NOT IN ('Polygon','MultiPolygon');

-----------------------------------
-- Suspicious Bounding box E+ or E-
-----------------------------------

SELECT ID, CVEGEO 
FROM Boundaries_AGEB_2025
WHERE geom.STEnvelope().ToString() LIKE '%E+%' 
   OR geom.STEnvelope().ToString() LIKE '%E-%';

------------------------------------
-- SRID inconsistente (must be 4326)
------------------------------------

SELECT DISTINCT geom.STSrid AS SRID
FROM Boundaries_AGEB_2025;
```

# 2 Create Intersection Boundaries (layer=6) ↔ AGEB

This will create a table of Neighborhoods that instersect AGEB units and cross reference **CVE_COLONIA** (Neighborhood) to **CVE_AGEB** and area where Neighborrhood is within an AGEB.

```sql
----------------------------------------------------------
-- NSE Step 4.2 — Intersection Boundaries (layer=6) ↔ AGEB
----------------------------------------------------------

-- Creates COLONIA_AGEB_INTERSECT
-- Expected result: ~267,718 records

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
-- Validation: How many records were generated in COLONIA_AGEB_INTERSECT
-- Expected result: ~267,718 records
-------------------------------------------------------------------------

SELECT COUNT(*) AS Records FROM COLONIA_AGEB_INTERSECT;

---------------------------------------------------------------------------
-- Validation: Check that no neighborhoods exist without AGEB intersections
-- Expected result: 0
---------------------------------------------------------------------------

SELECT COUNT(*) 
FROM Boundaries B
LEFT JOIN COLONIA_AGEB_INTERSECT I
    ON B.CVEGEO = I.CVE_COLONIA
WHERE B.layer = 6
  AND I.CVE_COLONIA IS NULL;
```

# 3 Create COLONIA_NSE (weighted population)

``sql
-- NSE Step 4.3 — Create COLONIA_NSE (weighted population)
-- Corrected version: excludes AGEBs without AMAI population

-- Why this table is necessary:
-- Each neighborhood (colonia) intersects multiple AGEBs
-- Each AGEB has different AMAI population values
-- Each neighborhood covers a different percentage of each AGEB
-- We need to weight population by intersection area
-- Then sum by neighborhood
-- Then calculate percentages
-- Then calculate NSE_SCORE
-- Then determine dominant NSE
-- Then assign NSE_LABEL
-- Boundaries layer 6 cannot do this directly

-- IMPORTANT:
-- We will collapse some AMAI levels to simplity for real estate:
-- NSE_AB
-- NSE_CPLUS
-- NSE_C = NSE_C + NSE_MINUS
-- NSE_PLUS
-- NSE_DE = NSE_D + NSE_E

-- Exclusions:
-- ✔ AGEBs without population
-- ✔ Prevents one intersection with TOTAL_POP = 0 from breaking the whole neighborhood
-- ✔ AMAI-compatible
-- ✔ 100% robust

DROP TABLE IF EXISTS COLONIA_NSE;
GO

SELECT
    I.CVE_COLONIA,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_AB     ELSE 0 END) AS NSE_AB,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_CPLUS  ELSE 0 END) AS NSE_CPLUS,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * (A.NSE_C + A.NSE_CMINUS) ELSE 0 END) AS NSE_C,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_DPLUS  ELSE 0 END) AS NSE_DPLUS,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * (A.NSE_D + A.NSE_E) ELSE 0 END) AS NSE_DE,
    SUM(CASE WHEN A.NSE_TOTAL IS NOT NULL THEN I.pct_area * A.NSE_TOTAL  ELSE 0 END) AS NSE_TOTAL
INTO COLONIA_NSE
FROM COLONIA_AGEB_INTERSECT I
LEFT JOIN NSE_AMAI_2024_AGEB A
    ON I.CVE_AGEB = A.CVEGEO
GROUP BY I.CVE_COLONIA;
GO

---------------------------------------
-- Validation: Expected ~79,775 records
-- same number of records as Boundaries
---------------------------------------

SELECT COUNT(*) AS Records_NSE_COLONIA FROM COLONIA_NSE;

-----------------------------------------------
-- Validation: Neighborhoods with NSE_TOTAL = 0
-- Must return ~12708 where AMAI NSE_TOTAL = 0
-----------------------------------------------

SELECT COUNT(*) AS Colonias_No_Pop
FROM COLONIA_NSE
WHERE NSE_TOTAL = 0;

------------------------------------------------------
-- Validation example: 
-- Neighborhood El Cielo (CVE_COLONIA = 2300800010017)
-- CVE_COLONIA   NSE_AB  NSE_PLUS NSE_C   NSE_DPLUS NSE_DE  NSE_TOTAL
-- 2300800010017 16.0024 19.0050  21.0063 0.00106   0.00043 56.01529
------------------------------------------------------

SELECT *
FROM COLONIA_NSE
WHERE CVE_COLONIA = '2300800010017';
``

# 4 Calculate percentages by neighborhood (colonia)

This generates percentages per level and prepares everything for NSE_SCORE, dominant NSE, and NSE_LABEL:

NSE_AB_PCT
NSE_CPLUS_PCT
NSE_C_PCT   (C + C-)
NSE_DPLUS_PCT
NSE_DE_PCT  (D + E)

```sql
-- NSE Step 4.4 — Calculate percentages by neighborhood (colonia)

-- This generates:
-- NSE_AB_PCT
-- NSE_CPLUS_PCT
-- NSE_C_PCT   (C + C-)
-- NSE_DPLUS_PCT
-- NSE_DE_PCT  (D + E)
-- Prepares everything for NSE_SCORE, dominant NSE, and NSE_LABEL

-- We already have:
-- Boundaries ✔
-- COLONIA_AGEB_INTERSECT ✔
-- COLONIA_NSE ✔ (79,775 colonias with weighted population)

-- This step is critical because it converts weighted population into percentages,
-- which then feed into NSE_SCORE, dominant NSE, and NSE_LABEL.

--------------------------------------------
-- 1 Add the percentage columns to the table
--------------------------------------------

ALTER TABLE COLONIA_NSE
ADD NSE_AB_PCT      numeric(5,2),
    NSE_CPLUS_PCT   numeric(5,2),
    NSE_C_PCT       numeric(5,2),
    NSE_DPLUS_PCT   numeric(5,2),
    NSE_DE_PCT      numeric(5,2);
GO

--------------------------
-- 2 Calculate percentages
--------------------------

UPDATE COLONIA_NSE
SET
    NSE_AB_PCT      = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_AB     * 100.0 / NSE_TOTAL, 2) END,
    NSE_CPLUS_PCT   = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_CPLUS  * 100.0 / NSE_TOTAL, 2) END,
    NSE_C_PCT       = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_C      * 100.0 / NSE_TOTAL, 2) END,
    NSE_DPLUS_PCT   = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_DPLUS  * 100.0 / NSE_TOTAL, 2) END,
    NSE_DE_PCT      = CASE WHEN NSE_TOTAL > 0 THEN ROUND(NSE_DE     * 100.0 / NSE_TOTAL, 2) END;
GO

----------------------------------------------------------------------
-- Validation 1: Check that no percentages are NULL when NSE_TOTAL > 0
----------------------------------------------------------------------

SELECT *
FROM COLONIA_NSE
WHERE NSE_TOTAL > 0
  AND (NSE_AB_PCT IS NULL OR NSE_CPLUS_PCT IS NULL OR NSE_C_PCT IS NULL OR NSE_DPLUS_PCT IS NULL OR NSE_DE_PCT IS NULL);

----------------------------------------------------
-- Validation 2: Check that percentages sum to ~100%
----------------------------------------------------

SELECT TOP 20
    CVE_COLONIA,
    NSE_AB_PCT + NSE_CPLUS_PCT + NSE_C_PCT + NSE_DPLUS_PCT + NSE_DE_PCT AS SUM_PCT
FROM COLONIA_NSE;

---------------------------------------------------------------------------------
-- Validation 3: Confirm no colonias with NSE_TOTAL > 0 have all percentages NULL
---------------------------------------------------------------------------------

SELECT *
FROM COLONIA_NSE
WHERE NSE_TOTAL > 0
  AND NSE_AB_PCT IS NULL
  AND NSE_CPLUS_PCT IS NULL
  AND NSE_C_PCT IS NULL
  AND NSE_DPLUS_PCT IS NULL
  AND NSE_DE_PCT IS NULL;
```

# 5 

```sql
---------------------------------------------------------
-- NSE Step 4.5 — Calculate IDS_PROM and NSE_SCORE
-- IDS_PROM  = weighted raw index (0–700)
-- NSE_SCORE = normalized index (1–7 scale)
---------------------------------------------------------

-- This is the weighted AMAI index, using simplified categories:
--
-- IDS_PROM:
-- Category   Weight
-- A/B        7
-- C+         6
-- C          5   (C + C-)
-- D+         3
-- D/E        1   (D + E)
--
-- NSE_SCORE = IDS_PROM / 100 (scale 1–7)

-----------------------------------------
-- 1. Drop previous columns if they exist
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
-- 2. Add clean columns
-----------------------
ALTER TABLE COLONIA_NSE
ADD IDS_PROM  numeric(10,4),
    NSE_SCORE numeric(10,4);
GO

---------------------------------------------------------------
-- 3. Calculate IDS_PROM (raw index) and NSE_SCORE (normalized)
---------------------------------------------------------------
UPDATE COLONIA_NSE
SET 
    IDS_PROM =
          ISNULL(NSE_AB_PCT,0)     * 7
        + ISNULL(NSE_CPLUS_PCT,0)  * 6
        + ISNULL(NSE_C_PCT,0)      * 5
        + ISNULL(NSE_DPLUS_PCT,0)  * 3
        + ISNULL(NSE_DE_PCT,0)     * 1,

    NSE_SCORE =
    (
          ISNULL(NSE_AB_PCT,0)     * 7
        + ISNULL(NSE_CPLUS_PCT,0)  * 6
        + ISNULL(NSE_C_PCT,0)      * 5
        + ISNULL(NSE_DPLUS_PCT,0)  * 3
        + ISNULL(NSE_DE_PCT,0)     * 1
    ) / 100.0;
GO

---------------------------------------------------------
-- Validation
---------------------------------------------------------

-- 1. Verify NSE_SCORE is not NULL when NSE_TOTAL > 0
SELECT *
FROM COLONIA_NSE
WHERE NSE_TOTAL > 0 AND NSE_SCORE IS NULL;

-- 2. Inspect typical values
SELECT TOP 20 CVE_COLONIA, IDS_PROM, NSE_SCORE
FROM COLONIA_NSE
ORDER BY NSE_SCORE DESC;
```
