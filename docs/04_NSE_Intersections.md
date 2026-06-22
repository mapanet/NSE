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

# 1 Check geometries of Boundaries layer 6

```sql
USE INMO
GO

-------------------------------------------------------------------
-- NSE Step 4.0 Check if geomatries of Boundaries layer 6 are valid 
-- All queries must return Nothing
-------------------------------------------------------------------

--------
-- Valid
--------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND geom.STIsValid() = 0;

--------------------------
-- Empty or null Geometres
-- Expected: Nada OK
--------------------------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND (geom IS NULL OR geom.STIsEmpty() = 1);

--------------------
-- Area = 0
-- Expected: Nada OK
--------------------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND geom.STArea() = 0;

---------------------------
-- Incorrect geometric type
-- Expected: Nada OK
---------------------------

SELECT ID, CVEGEO, geom.STGeometryType()
FROM Boundaries
WHERE Layer = 6
  AND geom.STGeometryType() NOT IN ('Polygon','MultiPolygon');

-----------------------
-- Bounding box invalid
-- Expected: Nada OK
-----------------------

SELECT ID, CVEGEO 
FROM Boundaries
WHERE Layer = 6
  AND (geom.STEnvelope().ToString() LIKE '%E+%' OR geom.STEnvelope().ToString() LIKE '%E-%');
```
