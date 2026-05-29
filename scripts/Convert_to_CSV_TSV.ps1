# Input and output paths
$inputFile  = "D:\AXSI\INEGI\AGEEML_2026\AGEEML_202651313653_utf.csv"
$outputFile = "D:\AXSI\INEGI\AGEEML_2026\INEGI_AGEEML_2026.csv"

# Detect encoding
try {
    $raw = Get-Content -Path $inputFile -Encoding UTF8 -ErrorAction Stop
    $encoding = "UTF-8"
} catch {
    $raw = Get-Content -Path $inputFile -Encoding Default
    $encoding = "Windows-1252"
    Write-Host "WARNING: Input file appears to be Windows-1252. Converting to UTF-8..."
}

# Parse header
$header = $raw[0].Split(',')

# Mapping dictionary for normalization
$map = @{
    "CVEGEO" = "CVEGEO"
    "Estatus" = "Status"
    "CVE_ENT" = "CVE_ENT"
    "NOM_ENT" = "NOM_ENT"
    "NOM_ABR" = "NOM_ABR"
    "CVE_MUN" = "CVE_MUN"
    "NOM_MUN" = "NOM_MUN"
    "CVE_LOC" = "CVE_LOC"
    "NOM_LOC" = "NOM_LOC"
    "AMBITO" = "Type"
    "LATITUD" = "LATITUD"
    "LONGITUD" = "LONGITUD"
    "LAT_DECIMAL" = "Latitude"
    "LON_DECIMAL" = "Longitude"
    "ALTITUD" = "Altitude"
    "CVE_CARTA" = "CVE_CARTA"
    "POB_TOTAL" = "Population"
    "POB_MASCULINA" = "Population_M"
    "POB_FEMENINA" = "Population_F"
    "TOTAL DE VIVIENDAS HABITADAS" = "Occupied_Dwellings"
}

# Exclude list
$exclude = @("NOM_ABR","LATITUD","LONGITUD","CVE_CARTA")

# Keep only mapped headers not in exclude
$keepIdx = for ($i=0; $i -lt $header.Length; $i++) {
    $h = $header[$i].Trim()
    if ($exclude -notcontains $h) { $i }
}

# Build normalized header
$newHeader = ($keepIdx | ForEach-Object { $map[$header[$_].Trim()] }) -join "`t"

# Process rows
$lines = @($newHeader)
for ($r=1; $r -lt $raw.Count; $r++) {
    $cols = $raw[$r].Split(',')
    $vals = foreach ($i in $keepIdx) {
        $val = $cols[$i].Trim()

        # Remove quotes first
        $val = $val -replace '"',''

        # Replace dash or asterisk-only values with empty string
        if ($val -eq '-' -or $val -eq '*') { $val = '' }

        $val
    }
    $lines += ($vals -join "`t")
}

# Write UTF-8 output
[System.IO.File]::WriteAllLines($outputFile, $lines, [System.Text.Encoding]::UTF8)

# DONE message
Write-Host "DONE $($lines.Count-1) records written to $outputFile (Encoding: UTF-8)"
