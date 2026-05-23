# 3 — INEGI_Censo_2020_AGEB (Census 2020)

This dataset contains:

Census 2020 data at the block (manzana) level.  
By aggregating blocks, we obtain **Population** and **Residences** per AGEB.  
If needed later, we can compute:

**Residences_In_Use = VIVTOT – VIVPAR_DES**  
(where **VIVPAR_DES = uninhabited dwellings**)

The file structure is:

ENTIDAD, NOM_ENT, MUN, NOM_MUN, LOC, NOM_LOC, AGEB, MZA, VIVTOT, VIVPAR_DES, POBTOT

Import from:

`D:\Postal Codes Databases\Mexico MX\INEGI.org.mx\Censos 2020\Tabulados AGEB por AGEB- Censo 2020\RESAGEBURB2020_ALL.csv`

To build this file, concatenate all **RESAGEBURB2020** files from each state into:

**RESAGEBURB2020_ALL.csv**

Concatenation script:

**RESAGEBURB2020.ps1**

Make sure to check for `*` characters in the data and replace them with **nothing**.
