# STEP 1 — AMAI Data Ingestion (NSE by AGEB)

Objective: Convert the official AMAI file `NSE_por_AGEB_AMAI.xlsx` into a normalized SQL table ready for the NSE pipeline.

---

## 1.1 Official Source File

AMAI publishes the dataset in its downloads section:

https://www.amai.org/descargas/NSE_por_AGEB_AMAI.xlsx

Depending on the browser, it may download directly as XLSX or open in the Office Online viewer:

https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fwww.amai.org%2Fdescargas%2FNSE_por_AGEB_AMAI.xlsx&wdOrigin=BROWSELINK

Important characteristics of the file:

- It does not include a year in the filename.
- It corresponds to the NSE 2024 methodology.
- It is the valid version for 2024–2027.

---

## 1.2 Original File Contents

The file contains one row per urban AGEB from Census 2020.

Original columns:

| Column | Meaning |
|--------|---------|
| ENTIDAD | State code |
| NOMBRE ENTIDAD | State name |
| MUNICIPIO | Municipality code |
| NOMBRE MUNICIPIO | Municipality name |
| LOCALIDAD | Locality code |
| NOMBRE LOCALIDAD | Locality name |
| AGEB | AGEB code (4 characters) |
| AB | Dwellings in socioeconomic level AB |
| C+ | Dwellings in socioeconomic level C+ |
| C | Dwellings in socioeconomic level C |
| C- | Dwellings in socioeconomic level C- |
| D+ | Dwellings in socioeconomic level D+ |
| D | Dwellings in socioeconomic level D |
| E | Dwellings in socioeconomic level E |
| NIVEL_PREDOMINANTE | Dominant socioeconomic level |
| VIVIENDAS | Total occupied private dwellings |
| TAMAÑO_DE_LOCALIDAD | Locality population range |

---

## 1.4 Header Normalization (Renaming)

To standardize column names using INEGI conventions and prepare the file for SQL import, headers were renamed and saved as:

`NSE_AMAI_2024_AGEB_IMPORT.xlsx`

| Original | New |
|----------|-----|
| ENTIDAD | CVE_ENT |
| NOMBRE ENTIDAD | NOM_ENT |
| MUNICIPIO | CVE_MUN |
| NOMBRE MUNICIPIO | NOM_MUN |
| LOCALIDAD | CVE_LOC |
| NOMBRE LOCALIDAD | NOM_LOC |
| AGEB | CVE_AGEB |
| AB | AB |
| C+ | CPLUS |
| C | C |
| C- | CMINUS |
| D+ | DPLUS |
| D | D |
| E | E |
| NIVEL PREDOMINANTE | NSE_LABEL |
| VIVIENDAS | TOTAL |
| TAMAÑO DE LOCALIDAD | (discarded, not used in any calculation) |



