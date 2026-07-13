# AMAI Notes & Classification Rules

This document summarizes the AMAI socioeconomic methodology and classification rules used in the NSE pipeline.

---

## 1. Panorama general del NSE de AMAI

AMAI define los niveles socioeconómicos con base en:  

- Características del hogar
- Educación
- Bienes
- Servicios
- Puntaje socioeconómico compuesto  

Las categorías oficiales son:

- **A/B**  
- **C+**  
- **C**  
- **C-**  
- **D+**  
- **D**

---

## 2. Variables de AMAI

Las variables clave incluyen:  

- Tamaño del hogar
- Nivel educativo
- Acceso a internet
- Propiedad de vehículo
- Propiedad de computadora/tableta
- Características de la vivienda
- Acceso a servicios

Estas se agregan para formar un puntaje compuesto.

---

## 3. Cálculo del Puntaje Compuesto

AMAI aplica pesos a cada variable:

**NSE_Score** = Σ (Indicador  × Peso)

En el pipeline de colonias, cada indicador se **pondera por área** según el traslape con AGEB

---

## 4. Umbrales de Categoría

AMAI define rangos de puntaje para cada categoría.  
Estos umbrales se aplican después de la interpolación.  

Ejemplo (ilustrativo):  

- A/B: ≥ 90  
- C+: 75–89  
- C: 60–74  
- C-: 45–59  
- D+: 30–44  
- D: < 30

---

## 5. Clasificación Rural

Dado que las AGEB rurales no cuentan con datos censales:

- Usar los indicadores de localidades del INE
- Aplicar las reglas rurales de AMAI
- Asegurar que las colonias rurales reciban valores NSE válidos

---

## 6. Notas para la Implementación

- Usar siempre el dataset AMAI 2024
- No mezclar AMAI con tablas socioeconómicas de INEGI
- Mantener exactamente los pesos y umbrales definidos por AMAI
- Documentar cualquier lógica de fallback rural
- Validar las sumas de interpolación y las asignaciones de categoría


