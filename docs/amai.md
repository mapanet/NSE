# AMAI Notes & Classification Rules

This document summarizes the AMAI socioeconomic methodology and classification rules used in the NSE pipeline.

---

## 1. AMAI NSE Overview

AMAI defines socioeconomic levels based on:

- Household characteristics  
- Education  
- Assets  
- Services  
- Composite socioeconomic score  

The official categories are:

- **A/B**  
- **C+**  
- **C**  
- **C-**  
- **D+**  
- **D**

---

## 2. AMAI Variables

Key variables include:

- Household size  
- Education level  
- Internet access  
- Vehicle ownership  
- Computer/tablet ownership  
- Housing characteristics  
- Access to services  

These are aggregated into a composite score.

---

## 3. Composite Score Calculation

AMAI applies weights to each variable:

**NSE_Score** = Σ (Indicator × Weight)

In the neighborhood (colonia) pipeline, each indicator is **area‑weighted** based on AGEB overlap.

---

## 4. Category Thresholds

AMAI defines score ranges for each category.  
These thresholds are applied after interpolation.

Example (illustrative):

- A/B: ≥ 90  
- C+: 75–89  
- C: 60–74  
- C-: 45–59  
- D+: 30–44  
- D: < 30

---

## 5. Rural Classification

Since rural AGEBs lack census data:

- Use INE locality indicators  
- Apply AMAI rural rules  
- Ensure rural colonias receive valid NSE values

---

## 6. Notes for Implementation

- Always use AMAI 2024 dataset  
- Do not mix AMAI with INEGI socioeconomic tables  
- Maintain AMAI weights and thresholds exactly  
- Document any rural fallback logic  
- Validate interpolation sums and category assignments


