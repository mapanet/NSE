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

## 1.5 Construcción de la clave geográfica CVEGEO

INEGI define CVEGEO como la concatenación de:

- CVE_ENT (2 dígitos)
- CVE_MUN (3 dígitos)
- CVE_LOC (4 dígitos)
- CVE_AGEB (4 dígitos)

Ejemplo:

01 + 001 + 0001 + 0163 = 0100100010163

Fórmula en Excel:

=CVE_ENT & CVE_MUN & CVE_LOC & CVE_AGEB

---

## 1.6 Columnas que se descartan y se corrigen

Las siguientes columnas no participan en el pipeline NSE y se descartan:

- CVE_ENT, NOM_ENT
- CVE_MUN, NOM_MUN
- CVE_LOC, NOM_LOC
- TAMAÑO_DE_LOCALIDAD

Motivos: no participan en joins, no intervienen en cálculos, no aportan valor analítico y agregan ruido.

### Corrección de valores “N/D”

1. Columnas numéricas  
   AB, C+, C, C–, D+, D, E → AMAI marca “N/D” cuando no hay información suficiente.

2. Columna categórica  
   NIVEL_PREDOMINANTE → “N/D” cuando no existe un nivel dominante claro.

Para que el pipeline funcione, se usa:

NULL = dato no disponible

### Regla de normalización

Reemplazar "N/D" por celda vacía ("") para que al importar a SQL se convierta en NULL.

Esto evita errores en:

- SUM()
- Cálculos de porcentajes
- Validaciones
- Consistencia del pipeline

---

## 1.7 Exportar desde Excel a CSV (para su importación a SQL)

El archivo CSV debe quedar como sigue:

| CVEGEO        | AB  | CPLUS | C   | CMINUS | DPLUS | D   | E   | NSE_LABEL | TOTAL |
|---------------|-----|--------|-----|---------|--------|-----|-----|-----------|--------|
| 0100100010017 | 0   | 12     | 39  | 111     | 153    | 331 |     | D         | 648    |
| 010010001006A | 178 | 124    | 60  | 24      | 9      | 4   | 0   | A/B       | 399    |
| 0100100010106 | 183 | 375    | 247 | 128     | 62     | 32  |     | C+        | 1028   |
| 0100100010163 | 35  | 157    | 228 | 167     | 124    | 78  | 0   | C         | 789    |
| 0100100010182 | 345 | 187    | 63  | 46      | 13     | 6   | 0   | A/B       | 660    |
| 0100100010229 | 25  | 36     | 14  | 20      | 9      | 7   | 0   | C+        | 111    |

Guardar como:

NSE_AMAI_2024_AGEB_IMPORT.csv  
(UTF‑8, delimitado por TAB)

### Configuración de exportación

- Formato: CSV
- Separador: TAB
- Codificación: UTF‑8
- Comillas: no usar comillas en los datos
- Sin BOM (Excel ya exporta UTF‑8 sin BOM)
- Sin filas vacías al final
- Sin columnas ocultas

Si fuera necesario, editar el CSV con EditPad Pro o Notepad++ para verificar:

- Codificación UTF‑8 sin BOM
- Delimitador TAB

Nota: Se usa separador TAB por conveniencia, pero puede usarse coma (,) ajustando el `FIELDTERMINATOR` en el BULK INSERT.


