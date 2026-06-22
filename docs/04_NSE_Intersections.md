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

# 4 
