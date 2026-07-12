# PASO 1 — Ingesta de Datos AMAI 2024 (NSE por AGEB)

**Objetivo:** Convertir el archivo oficial **NSE_por_AGEB_AMAI_2024.xlsx** en una tabla SQL normalizada y lista para el pipeline de NSE.

## Directorios de trabajo sugeridos

- **D:\AXSI\AMAI** — archivos de trabajo  
- **D:\AXSI\AMAI\Download** — archivos fuente descargados


---

## 1. — Archivo Fuente Oficial

AMAI publica el dataset en su sección de descargas:

https://www.amai.org/NSE/index.php?queVeo=NSEDES&Logeado=s (descarga de NSE por AGEB)

https://www.amai.org/descargas/NSE_por_AGEB_AMAI.xlsx

Alternativamente, puede accederse desde el portal NSE:

Dependiendo del navegador, puede descargarse directamente como archivo XLSX o abrirse en el visor de Office Online:

https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fwww.amai.org%2Fdescargas%2FNSE_por_AGEB_AMAI.xlsx&wdOrigin=BROWSELINK

Características importantes del archivo:

- El nombre del archivo **no incluye año**.  
- Corresponde a la **metodología NSE 2024**.

---

## 2. — Contenido del Archivo Original

El archivo contiene **una fila por cada AGEB urbana del Censo 2020**.

Columnas originales:

| Columna | Significado |
|---------|-------------|
| ENTIDAD | Código de la entidad federativa |
| NOMBRE ENTIDAD | Nombre de la entidad |
| MUNICIPIO | Código del municipio |
| NOMBRE MUNICIPIO | Nombre del municipio |
| LOCALIDAD | Código de la localidad |
| NOMBRE LOCALIDAD | Nombre de la localidad |
| AGEB | Clave AGEB (4 caracteres) |
| AB | Viviendas en nivel socioeconómico AB |
| C+ | Viviendas en nivel socioeconómico C+ |
| C | Viviendas en nivel socioeconómico C |
| C- | Viviendas en nivel socioeconómico C- |
| D+ | Viviendas en nivel socioeconómico D+ |
| D | Viviendas en nivel socioeconómico D |
| E | Viviendas en nivel socioeconómico E |
| NIVEL_PREDOMINANTE | Nivel socioeconómico predominante (NSE) |
| VIVIENDAS | Total de viviendas particulares habitadas |
| TAMAÑO_DE_LOCALIDAD | Rango de población |

**La página se ve así:**

[<img src="/docs/images/AMAI_2024.png" width="1000">](/docs/images/AMAI_2024.png)


#### Guardar el archivo

Directorio: **D:\AXSI\AMAI\Download**  
Nombre del archivo: **NSE_por_AGEB_AMAI_2024.xlsx**

### Copiar el archivo al directorio de trabajo

Directorio: **D:\AXSI\AMAI\**  
Guardar como: **NSE_por_AGEB_AMAI_2024-IMPORT.xlsx**



## 3. — Editar el Archivo Excel para Generar un CSV Importable

Aunque la siguiente sección proporciona un **SCRIPT EN PYTHON** que automatiza todo el proceso,  
los pasos manuales se documentan aquí para mayor claridad, auditoría y reproducibilidad.

#### 3.1 — Eliminar columna innecesaria

- Eliminar la columna **TAMAÑO_DE_LOCALIDAD**.

#### 3.2 — Corregir filas de encabezado combinadas

- El archivo contiene celdas de encabezado combinadas.


```text
 TOTAL DE VIVIENDAS POR NIVEL SOCIOECONÓMICO   
 AB     C+    C     C-     D+     D     E
 ```

Para estandarizar la estructura:

- Agrega los siguientes encabezados en la fila 3:


```code
CVE_ENT	NOM_ENT	CVE_MUN	NOM_MUN	CVE_LOC	NOM_LOC	CVE_AGEB	NSE_AB	NSE_CPLUS	NSE_C	NSE_CMINUS	NSE_DPLUS	NSE_D	NSE_E	NSE	NSE_TOTAL	POPULATION_RANGE
```

- Eliminar las filas 1 y 2

#### 3.3 — Crear la columna CVEGEO

Inserta una nueva columna en la posición 1 con el encabezado **CVEGEO**.

AMAI proporciona los códigos de región como enteros, pero INEGI utiliza **códigos alfanuméricos con ceros a la izquierda**.  
Estandariza los códigos de la siguiente manera (formato INEGI):


- CVE_ENT → 2 digits (**00**)
- CVE_MUN → 3 digits (**000**)
- CVE_LOC → 4 digits (**0000**)
- CVE_AGEB → 4 digits

Formula para clave CVEGEO:

Ingles:

```excel
=TEXT(B2, "00") & TEXT(D2, "000") & TEXT(F2, "0000") & TEXT(H2, "0000")
```

Español:

```excel
=TEXTO(B2;"00") & TEXTO(D2;"000") & TEXTO(F2;"0000") & TEXTO(H2;"0000")
```

Esto produce un CVEGEO válido conforme al estándar INEGI:

**CVEGEO** = CVE_ENT + CVE_MUN + CVE_LOC + CVE_AGEB  
Formato: **EEMMMLLLLAAAA**


#### 3.4 — Reemplazar valores N/D

Reemplaza todos los valores **N/D** por **celdas vacías** para que se importen como **NULL** en SQL Server.

Esto evita errores en:

- SUM()
- Cálculos de porcentajes
- Scripts de validación
- Revisiones de consistencia del pipeline

Ahora el archivo de Excel debe verse así:

[<img src="/docs/images/NSE_4.png" width="1000">](/docs/NSE_4.png)


#### 3.5 — Generar un CSV limpio

Excel exporta archivos CSV únicamente como **UTF‑8 con comas**, lo cual provoca que algunos nombres de localidades incluyan **comillas dobles**.

La forma más sencilla de obtener un archivo limpio, separado por tabuladores:

1. Seleccionar todos los datos del archivo Excel  
2. Pegarlos en **EditPad Pro** (o herramienta similar)  
3. Esto produce un dataset **separado por TAB** sin los problemas de comillas que genera Excel


#### 3.6 — Guardar el CSV final

Guarda el archivo ya limpiado como:

```code
D:\AXSI\AMAI\NSE_por_AGEB_AMAI_2024_IMPORT.csv
```
Codificación: UTF‑8 (No BOM)

---

## Script de Python

Guarda el siguiente script en: **D:\AXSI\AMAI\Convert_Excel_to_CSV.py**

Este script requiere **pandas** y **openpyxl**.  
En Windows CMD (con privilegios de administrador), ejecuta:

```code
pip install pandas
pip install openpyxl
```

Abre el script en Visual Studio Code y ejecútalo.
(Verifica la ruta y los nombres de archivo si utilizaste otros diferentes.)

```phyton
import pandas as pd

# 1. Leer el archivo Excel sin encabezados
df = pd.read_excel(r"D:\AXSI\AMAI\NSE_por_AGEB_AMAI_2024_IMPORT.xlsx", header=None)

# 2. Eliminar las primeras dos filas (encabezados originales)
df = df.drop([0, 1]).reset_index(drop=True)

# 3. Definir los nuevos encabezados
headers = [
    "CVE_ENT","NOM_ENT","CVE_MUN","NOM_MUN_","CVE_LOC","NOM_LOC","CVE_AGEB",
    "NSE_AB","NSE_CPLUS","NSE_C","NSE_CMINUS","NSE_DPLUS","NSE_D","NSE_E","NSE",
    "NSE_TOTAL","POPULATION_RANGE"
]
df.columns = headers

# 4. Eliminar la columna HABITANTES (si aplica)
#df = df.drop(columns=["POPULATION_RANGE"])

# 5. Formatear ENTIDAD, MUN, LOC con ceros a la izquierda
df["CVE_ENT"] = df["CVE_ENT"].astype(str).str.zfill(2)
df["CVE_MUN"] = df["CVE_MUN"].astype(str).str.zfill(3)
df["CVE_LOC"] = df["CVE_LOC"].astype(str).str.zfill(4)

# 6. Insertar la columna CVEGEO en la posición 0
df.insert(0, "CVEGEO", "")

# 7. Construir CVEGEO = ENTIDAD + MUN + LOC + AGEB
df["CVEGEO"] = (
    df["CVE_ENT"].astype(str).str.zfill(2) +
    df["CVE_MUN"].astype(str).str.zfill(3) +
    df["CVE_LOC"].astype(str).str.zfill(4) +
    df["CVE_AGEB"].astype(str).str.zfill(4)
)

# 8. Reemplazar "N/D" por cadena vacía
df = df.replace("N/D", "")

# 9. Eliminar todas las comillas dobles
df = df.replace('"', '', regex=True)

# 10. Guardar como TSV (separado por tabuladores), UTF-8 sin BOM
df.to_csv(
    r"D:\AXSI\AMAI\NSE_por_AGEB_AMAI_2024_IMPORT.csv",
    sep="\t",
    index=False,
    encoding="utf-8"
)

```

### Resultado esperado

```code
D:\AXSI\AMAI\NSE_por_AGEB_AMAI_2024_IMPORT.csv
```

El archivo CSV debe verse así:
  

| CVEGEO        |CVE_ENT| ENT_NOM       |CVE_MUN| MUN_NOM      |CVE_LOC | LOC_NOM      |CVE_AGEB|NSE_AB |NSE_CPLUS|NSE_C  |NSE_CMINUS|NSE_DPLUS|NSE_D  |NSE_E  |NSE| NSE_TOTAL | POPULATION_RANGE |
|---------------|-------|---------------|-------|--------------|--------|--------------|--------|-------|---------|-------|----------|---------|-------|-------|---|-----------|------------------|
| 0100100010017 |01     |Aguascalientes |001    |Aguascalientes|0001    |Aguascalientes|0017    |      0|       12|     39|       111|      153|    331|       |D  |        648|500,000 a 999,999 |
| 010010001006A |01     |Aguascalientes |001    |Aguascalientes|0001    |Aguascalientes|006A    |    178|      124|     60|        24|        9|      4|      0|A/B|        399|500,000 a 999,999 |
| 0100100010106 |01     |Aguascalientes |001    |Aguascalientes|0001    |Aguascalientes|0106    |    183|      375|    247|       128|       62|     32|       |C+ |       1028|500,000 a 999,999 |
| 0100100010163 |01     |Aguascalientes |001    |Aguascalientes|0001    |Aguascalientes|0163    |     35|      157|    228|       167|      124|     78|      0|C  |        789|500,000 a 999,999 |
| 0100100010182 |01     |Aguascalientes |001    |Aguascalientes|0001    |Aguascalientes|0182    |    345|      187|     63|        46|       13|      6|      0|A/B|        660|500,000 a 999,999 |
| 0100100010229 |01     |Aguascalientes |001    |Aguascalientes|0001    |Aguascalientes|0229    |    25 |       36|     14|        20|        9|      7|      0|C+ |        111|500,000 a 999,999 |


## 4 — Crear la tabla final en MS SQL Server

```sql
------------------------------------------
### 4.1 — Crear tabla final: AMAI_AGEB_2024
------------------------------------------

USE INMO
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE IF EXISTS dbo.AMAI_AGEB_2024;

CREATE TABLE [dbo].[AMAI_AGEB_2024](
	[CVEGEO] [nvarchar](20) NOT NULL,
	[CVE_ENT] [varchar](2) NOT NULL,
	[NOM_ENT] [nvarchar](85) NOT NULL,
	[CVE_MUN] [varchar](3) NOT NULL,
	[NOM_MUN] [nvarchar](85) NOT NULL,
	[CVE_LOC] [varchar](4) NOT NULL,
	[NOM_LOC] [nvarchar](110) NOT NULL,
    [CVE_AGEB] [varchar](4) NOT NULL,
	[NSE_AB] [int] NULL,
	[NSE_CPLUS] [int] NULL,
	[NSE_C] [int] NULL,
	[NSE_CMINUS] [int] NULL,
	[NSE_DPLUS] [int] NULL,
	[NSE_D] [int] NULL,
	[NSE_E] [int] NULL,
	[NSE] [nvarchar](10) NULL,
	[NSE_TOTAL] [int] NULL,
	[POPULATION_RANGE] [varchar](30) NULL,
 CONSTRAINT [PK_AMAI_AGEB_2024] PRIMARY KEY CLUSTERED 
(
	[CVEGEO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-----------------------------------------------------------------------------------
-- 4.2 — Importar el CSV: NSE_por_AGEB_AMAI_2024_IMPORT.csv
-- Importar CSV: NSE_por_AGEB_AMAI_2024_IMPORT.csv  
-- Se asume: el CSV está separado por TAB  
-- Archivo en UTF‑8 SIN BOM  
-- Verifica que la ruta del directorio coincida con donde guardaste el archivo AMAI
-----------------------------------------------------------------------------------
BULK INSERT AMAI_AGEB_2024
FROM 'D:\AXSI\AMAI\NSE_por_AGEB_AMAI_2024_IMPORT.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);
```

### Resultado esperado

(246048 rows affected)   



## 5 — Validaciones tras importar

```sql
----------------------------------------------------
-- Validar que TOTAL = suma de los niveles socioeconómicos
-- Resultado esperado:
-- CVEGEO | NSE_AB | NSE_CPLUS | NSE_C | NSE_CMINUS | NSE_DPLUS | NSE_D | NSE_E | NSE | NSE_TOTAL |
-- Sin registros: Esto significa que no existe diferencia entre el total y la suma de los componentes

SELECT *
FROM AMAI_AGEB_2024
WHERE NSE_TOTAL <> (NSE_AB + NSE_CPLUS + NSE_C + NSE_CMINUS + NSE_DPLUS + NSE_D + NSE_E);

------------------------------------------------
-- Validar que CVEGEO tenga la longitud correcta (13 caracteres)
-- Resultado esperado:
-- CVEGEO | NSE_AB | NSE_CPLUS | NSE_C | NSE_CMINUS | NSE_DPLUS | NSE_D | NSE_E | NSE | NSE_TOTAL |
-- Sin registros: Esto significa que todos los CVEGEO tienen 13 caracteres: EEMMMLLLLAAAA

SELECT
    CVEGEO,
    NSE_AB,
    NSE_CPLUS,
    NSE_C,
    NSE_CMINUS,
    NSE_DPLUS,
    NSE_D,
    NSE_E,
    NSE,
    NSE_TOTAL
FROM dbo.AMAI_AGEB_2024
WHERE LEN(CVEGEO) <> 13;


------------------------------------------------
-- Resultado final
-- SQL para mostrar los primeros 6 registros y verificar los datos:
-- Mostrar las primeras 6 filas


SELECT TOP (6) 
  CVEGEO, 
  CVE_ENT,
  NOM_ENT,
  CVE_MUN,
  NOM_MUN,
  CVE_LOC,
  NOM_LOC,
  CVE_AGEB,
  NSE_AB, 
  NSE_CPLUS, 
  NSE_C, 
  NSE_CMINUS, 
  NSE_DPLUS, 
  NSE_D, 
  NSE_E, 
  NSE, 
  NSE_TOTAL,
  POPULATION_RANGE
FROM dbo.AMAI_AGEB_2024
```

Tu tabla final en SQL debería verse así:   

| CVEGEO        | CVE_ENT | NOM_ENT      | CVE_MUN | NOM_MUN      | CVE_LOC | NOM_LOC        | CVE_AGEB | NSE_AB | NSE_CPLUS | NSE_C | NSE_CMINUS | NSE_DPLUS | NSE_D   | NSE_E  | NSE | NSE_TOTAL | POPULATION_RANGE |
|---------------|---------|--------------|---------|--------------|---------|----------------|----------|--------|-----------|-------|------------|-----------|---------|--------|-----|-----------|------------------|
| 0100100010017 | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes | 0017     |      0 |        12 |    39 |        111 |       153 |     331 |        | D   |        648| 500,000 a 999,999|
| 010010001006A | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes | 006A     |    178 |       124 |    60 |         24 |         9 |       4 |      0 | A/B |        399| 500,000 a 999,999|
| 0100100010106 | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes | 0106     |    183 |       375 |   247 |        128 |        62 |      32 |        | C+  |       1028| 500,000 a 999,999|
| 0100100010163 | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes | 0163     |    35  |       157 |   228 |        167 |       124 |      78 |      0 | C   |        789| 500,000 a 999,999|
| 0100100010182 | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes | 0182     |    345 |       187 |    63 |         46 |        13 |       6 |      0 | A/B |        660| 500,000 a 999,999|
| 0100100010229 | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes | 0229     |    25  |       36  |    14 |         20 |         9 |       7 |      0 | C+  |        111| 500,000 a 999,999|

Esta tabla es la fuente oficial de AMAI para los **pasos de cálculo del NSE**.





