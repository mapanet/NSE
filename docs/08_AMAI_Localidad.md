08 — Ingesta de Datos AMAI LOCALIDAD 2024 (NSE por Localidad)

**Objetivo:**  
Convertir el archivo oficial NSE_por_localidad_AMAI_2024.xlsx en una tabla SQL normalizada, lista para integrarse al pipeline NSE.

📁 Directorios de trabajo sugeridos

- `D:\AXSI\AMAI` — working files
- `D:\AXSI\AMAI\Download`  — downloaded source files

---

## 1 — Archivo Oficial

AMAI publica el dataset en su sección de descargas:  

https://www.amai.org/NSE/index.php?queVeo=NSEDES&Logeado=s  
(Descarga: NSE por localidad)


Características importantes del archivo

- El nombre del archivo no incluye el año.
- El contenido corresponde a la metodología NSE 2024.
- Es el dataset oficial para calcular NSE por localidad (LOC).
- Se utiliza como complemento del dataset por AGEB para zonas rurales.

[<img src="/docs/images/AMAI_2024.png" width="1000">](/docs/images/AMAI_2024.png)

---

## 2 — Contenido del Archivo Original

El archivo NSE_por_localidad_AMAI_2024.xlsx contiene una fila por localidad urbana del Censo 2020.

Este dataset es el insumo oficial para calcular NSE por Localidad (LOC) dentro del pipeline AXSI, especialmente para:

- Zonas rurales sin AGEB urbana,
- Localidades pequeñas,
- Localidades con población dispersa,
- Localidades donde AMAI no publica NSE por AGEB.

Columnas originales del archivo AMAI:

| Columna | Significado |
|--------|---------|
| CLAVE LOCALIDAD | Código CVEGEO de la localidad |
| ENTIDAD | Código de estado (2 dígitos) |
| NOMBRE ENTIDAD | Nombre del estado |
| MUNICIPIO | Código de municipio (3 dígitos) |
| NOMBRE MUNICIPIO | Nombre del municipio |
| LOCALIDAD | Código de localidad (4 dígitos) |
| NOMBRE LOCALIDAD | Nombre de la localidad |
| AB | Viviendas en nivel socioeconómico AB |
| C+ | Viviendas en nivel socioeconómico C+ |
| C | Viviendas en nivel socioeconómico C |
| C- | Viviendas en nivel socioeconómico C- |
| D+ | Viviendas en nivel socioeconómico D+ |
| D | Viviendas en nivel socioeconómico D |
| E | Viviendas en nivel socioeconómico E |
| NIVEL_PREDOMINANTE | Nivel socioeconómico dominante (NSE) |
| VIVIENDAS | Total de viviendas particulares habitadas |
| TAMAÑO_DE_LOCALIDAD | Rango de población de la localidad |

#### Guardar el archivo

Directory: D:\AXSI\AMAI\Download   
File name: NSE_por_localidad_AMAI_2024.xlsx   

### Copiar el archivo al directorio de trabajo

**Directorio:**  
`D:\AXSI\AMAI\Download`

**Nombre del archivo:**  
`NSE_por_localidad_AMAI_2024.xlsx`

### Copiar el archivo al directorio de trabajo

**Directorio:**  
`D:\AXSI\AMAI\`

**Guardar como:**  
`NSE_por_localidad_AMAI_2024-IMPORT.xlsx`

Este archivo será editado, normalizado y convertido a CSV para su ingesta en SQL.

## 3. — Editar el archivo Excel para producir un CSV importable

Aunque la siguiente sección incluye un **script PYTHON** que automatiza todo el proceso,
los pasos manuales se documentan aquí para **claridad, auditoría y reproducibilidad**.

#### 3.1 — Eliminar columna innecesaria

- TAMAÑO_DE_LOCALIDAD

#### 3.2 — Corregir filas de encabezados combinados

- El archivo contiene celdas combinadas:

```text
 TOTAL DE VIVIENDAS POR NIVEL SOCIOECONÓMICO   
 AB     C+    C     C-     D+     D     E
 ```

Para estandarizar:

- Agregar encabezados estandarizados en la fila 3:

```code
CVEGEO	CVE_ENT	NOM_ENT	CVE_MUN	NOM_MUN	CVE_LOC	NOM_LOC	NSE_AB	NSE_CPLUS	NSE_C	NSE_CMINUS	NSE_DPLUS	NSE_D	NSE_E	NSE	NSE_TOTAL	POPULATION_RANGE
```

- Eliminar filas 1 y 2

#### 3.4 — 3.4 — Reemplazar valores *N/D*

Reemplazar todos los valores N/D por celdas vacías para que SQL Server los importe como NULL.

Esto evita errores en:  

- SUM()
- Cálculo de porcentajes
- Scripts de validación
- Chequeos de consistencia del pipeline

Excel debe verse así después del reemplazo:

[<img src="/docs/images/NSE_6.png" width="1000">](/docs/NSE_6.png)

#### Procedimiento recomendado (sin errores de Excel)

Excel exporta CSV solo **UTF‑8 with commas**, esto aun genera que el archivo puede contener nombres con comillas.  
  
La forma mas facil de crear el CSV (TSV) limpio:   

1. Seleccionar toda la tabla en Excel
2. Copiar
3. Pegar en EditPad Pro (o cualquier editor de texto avanzado)

#### 3.6 — Guardar en archivo CSV (TSV)

Guarda el archivo limpio como:

```code
D:\AXSI\AMAI\NSE_por_AGEB_AMAI_2024_IMPORT.csv
```
Codificación: UTF‑8 (No BOM)

---

## Script de Phyton

Guarda el siguiente script en:   
`D:\AXSI\AMAI\Convert_Excel_to_CSV.py`

Este script requiere las librerías **pandas** y **openpyxl**.  
Instálalas desde CMD en Windows (como administrador):  

```code
pip install pandas   
pip install openpyxl
```

Luego abre el script en Visual Studio Code y ejecútalo.  
(Verifica la ruta y los nombres de archivo si utilizaste otros diferentes.)   

```phyton
import pandas as pd

# 1. Leer el archivo Excel SIN encabezados
df = pd.read_excel(r"D:\AXSI\AMAI\NSE_por_localidad_AMAI_2024_IMPORT.xlsx", header=None)

# 2. Eliminar las primeras dos filas
df = df.drop([0, 1]).reset_index(drop=True)

# 3. Definir los encabezados estandarizados para el pipeline NSE
headers = [
    "CVEGEO", "CVE_ENT","NOM_ENT","CVE_MUN","NOM_MUN","CVE_LOC","NOM_LOC",
    "NSE_AB","NSE_CPLUS","NSE_C","NSE_CMINUS","NSE_DPLUS","NSE_D","NSE_E","NSE",
    "NSE_TOTAL","POPULATION_RANGE"
]
df.columns = headers

# 4. (Opcional) Eliminar columna de población
#df = df.drop(columns=["POPULATION_RANGE"])

# 5. Normalizar códigos geográficos con ceros a la izquierda
df["CVE_ENT"] = df["CVE_ENT"].astype(str).str.zfill(2)
df["CVE_MUN"] = df["CVE_MUN"].astype(str).str.zfill(3)
df["CVE_LOC"] = df["CVE_LOC"].astype(str).str.zfill(4)

# 6. (Opcional) Insertar CVEGEO si se requiere reconstruirlo
# En este archivo AMAI, CVEGEO ya viene incluido.
# Si se quisiera reconstruir:
# df.insert(0, "CVEGEO", "")

# 7. Build CVEGEO = ENTIDAD + MUN + LOC + AGEB
#df["CVEGEO"] = (
#    df["CVE_ENT"].astype(str).str.zfill(2) +
#    df["CVE_MUN"].astype(str).str.zfill(3) +
#3    df["CVE_LOC"].astype(str).str.zfill(4)
#)

# 7. Reemplazar valores "N/D" por vacío
df = df.replace("N/D", "")

# 8. Eliminar comillas dobles en todo el dataset
df = df.replace('"', '', regex=True)

# 9. Guardar archivo como TSV (TAB-separated), UTF‑8 sin BOM
df.to_csv(r"D:\AXSI\AMAI\NSE_por_localidad_AMAI_2024_IMPORT.csv",
    sep="\t",
    index=False,
    encoding="utf-8"
)
```

### Resultado esperado

```code
D:\AXSI\AMAI\NSE_por_localidad_AMAI_2024_IMPORT.csv
```

El archivo CSV (TSV) debe verse así:   

| CVEGEO    |CVE_ENT| ENT_NOM       |CVE_MUN| MUN_NOM      |CVE_LOC | LOC_NOM              |NSE_AB |NSE_CPLUS|NSE_C  |NSE_CMINUS|NSE_DPLUS|NSE_D  |NSE_E  |NSE| NSE_TOTAL | POPULATION_RANGE |
|-----------|-------|---------------|-------|--------------|--------|----------------------|-------|---------|-------|----------|---------|-------|-------|---|-----------|------------------|
| 010010102 |01     |Aguascalientes |001    |Aguascalientes|0001    |Los Arbolitos [Rancho]|      0|       12|     39|       111|      153|    331|       |D  |        648|500,000 a 999,999 |
| 010010204 |01     |Aguascalientes |001    |Aguascalientes|0001    |Ardillas de Abajo     |    178|      124|     60|        24|        9|      4|      0|A/B|        399|500,000 a 999,999 |
| 010010106 |01     |Aguascalientes |001    |Aguascalientes|0001    |Arellano              |    183|      375|    247|       128|       62|     32|       |C+ |       1028|500,000 a 999,999 |
| 010010112 |01     |Aguascalientes |001    |Aguascalientes|0001    |Bajío los Vázquez     |     35|      157|    228|       167|      124|     78|      0|C  |        789|500,000 a 999,999 |
| 010010120 |01     |Aguascalientes |001    |Aguascalientes|0001    |Buenavista de Peñuelas|    345|      187|     63|        46|       13|      6|      0|A/B|        660|500,000 a 999,999 |
| 010010121 |01     |Aguascalientes |001    |Aguascalientes|0001    |Cabecita 3 Marías     |    25 |       36|     14|        20|        9|      7|      0|C+ |        111|500,000 a 999,999 |


## 4 —Crear tabla final en MS SQL Server

```sql
------------------------------------------
-- Crear tabla final: AMAI_LOC_2024
------------------------------------------

USE INMO
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE IF EXISTS dbo.AMAI_LOC_2024;

CREATE TABLE [dbo].[AMAI_LOC_2024](
	[CVEGEO] [nvarchar](20) NOT NULL,
	[CVE_ENT] [varchar](2) NOT NULL,
	[NOM_ENT] [nvarchar](85) NOT NULL,
	[CVE_MUN] [varchar](3) NOT NULL,
	[NOM_MUN] [nvarchar](85) NOT NULL,
	[CVE_LOC] [varchar](4) NOT NULL,
	[NOM_LOC] [nvarchar](110) NOT NULL,
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
 CONSTRAINT [PK_AMAI_LOC_2024] PRIMARY KEY CLUSTERED 
(
	[CVEGEO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

------------------------------------------------------------
-- Import CSV (TSV): NSE_por_localidad_AMAI_2024_IMPORT.csv
-- Asume: archivo delimitado por TAB
-- Codificación: UTF-8 SIN BOM
-- Verifica que la ruta coincida con tu directorio real
------------------------------------------------------------
BULK INSERT AMAI_LOC_2024
FROM 'D:\AXSI\AMAI\NSE_por_localidad_AMAI_2024_IMPORT.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);
```

### Resultado esperado

(189432 registros)   



## 5 — Validaciones posteriores a la importación

```sql
---------------------------------------------------
-- Validar que TOTAL = suma de los niveles socioeconómicos
-- Resultado esperado
-- CVEGEO | NSE_AB | NSE_CPLUS | NSE_C | NSE_CMINUS | NSE_DPLUS | NSE_D | NSE_E | NSE | NSE_TOTAL |
-- Sin registros: Esto significa que no existe diferencia entre el total y la suma de los componentes

SELECT *
FROM AMAI_LOC_2024
WHERE NSE_TOTAL <> (NSE_AB + NSE_CPLUS + NSE_C + NSE_CMINUS + NSE_DPLUS + NSE_D + NSE_E);

------------------------------------------------
-- Validar que CVEGEO tenga la longitud correcta (9 caracteres)
-- Resultado esperado
-- CVEGEO | NSE_AB | NSE_CPLUS | NSE_C | NSE_CMINUS | NSE_DPLUS | NSE_D | NSE_E | NSE | NSE_TOTAL |
-- Sin registros: Esto significa que todos los CVEGEO tienen 9 caracteres: EEMMMLLLL

SELECT *
FROM AMAI_LOC_2024
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
FROM dbo.AMAI_LOC_2024
```

Tu tabla final en SQL debería verse así:
  

| CVEGEO        | CVE_ENT | NOM_ENT      | CVE_MUN | NOM_MUN      | CVE_LOC | NOM_LOC        | NSE_AB | NSE_CPLUS | NSE_C | NSE_CMINUS | NSE_DPLUS | NSE_D   | NSE_E  | NSE | NSE_TOTAL | POPULATION_RANGE |
|---------------|---------|--------------|---------|--------------|---------|----------------|--------|-----------|-------|------------|-----------|---------|--------|-----|-----------|------------------|
| 0100100010017 | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes |      0 |        12 |    39 |        111 |       153 |     331 |        | D   |        648| 500,000 a 999,999|
| 010010001006A | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes |    178 |       124 |    60 |         24 |         9 |       4 |      0 | A/B |        399| 500,000 a 999,999|
| 0100100010106 | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes |    183 |       375 |   247 |        128 |        62 |      32 |        | C+  |       1028| 500,000 a 999,999|
| 0100100010163 | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes |    35  |       157 |   228 |        167 |       124 |      78 |      0 | C   |        789| 500,000 a 999,999|
| 0100100010182 | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes |    345 |       187 |    63 |         46 |        13 |       6 |      0 | A/B |        660| 500,000 a 999,999|
| 0100100010229 | 01	  |Aguascalientes| 001     |Aguascalientes|0001	    | Aguascalientes |    25  |       36  |    14 |         20 |         9 |       7 |      0 | C+  |        111| 500,000 a 999,999|

Esta tabla es la fuente oficial de AMAI para los pasos de cálculo del NSE.

