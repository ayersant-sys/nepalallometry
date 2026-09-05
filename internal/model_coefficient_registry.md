# nepalallometry internal model coefficient registry

**Purpose:** internal audit record of the equations, coefficients, constants, units, component boundaries, and source pathways currently implemented in `nepalallometry`.

This file is not a new model specification. It records the published models as implemented in the package so that future code changes can be checked against the original sources. The package should not refit, harmonize, alter, or biologically constrain published equations unless a future feature explicitly states that it is doing so.

**Maintenance rule:** whenever an equation, coefficient, density value, component definition, source, or calibration rule changes in the code, update this registry in the same commit and verify it against the source publication/regulation.

---

## 1. FRTC (2025) total aboveground biomass

Source: Forest Research and Training Centre (FRTC). 2025. *Allometric Equations for Seven Major Tree Species of Nepal (Volume I).* Kathmandu, Nepal.

Implemented in: `R/frtc-total-biomass.R`

Biomass boundary: above the 0.30 m felling height; stump biomass from ground level to 0.30 m is excluded.

Units: DBH `d` in cm, total height `h` in m, basic wood density `rho` in g/cm3, biomass `B` in kg/tree.

Model forms used by FRTC:

- density power: `B = a * (d^2 * h * rho)^b`
- DBH-height: `B = a * d^b * h^c`

| Species | Code | Equation | a | b | c | Density used by package |
|---|---:|---|---:|---:|---:|---|
| Alnus nepalensis | An | `a*(d^2*h*rho)^b` | 0.067139 | 0.956808 | — | species average 0.4318 |
| Castanopsis spp. | Cs | `a*d^b*h^c` | 0.071253 | 2.318525 | 0.299393 | not required |
| Lagerstroemia parviflora | Lp | `a*(d^2*h*rho)^b` | 0.060964 | 0.971369 | — | species average 0.5651 |
| Pinus roxburghii | Pr | `a*d^b*h^c` | 0.031693 | 2.329281 | 0.519366 | not required |
| Shorea robusta | Sr | `a*(d^2*h*rho)^b` | 0.054968 | 0.980885 | — | DBH-class density |
| Schima wallichii | Sw | `a*(d^2*h*rho)^b` | 0.071359 | 0.951091 | — | species average 0.4869 |
| Terminalia alata | Ta | `a*(d^2*h*rho)^b` | 0.080156 | 0.943341 | — | DBH-class density |

### FRTC recommended basic densities used in total-biomass calculation

| Species | DBH class | Density (g/cm3) |
|---|---|---:|
| Alnus nepalensis | all | 0.4318 |
| Lagerstroemia parviflora | all | 0.5651 |
| Schima wallichii | all | 0.4869 |
| Shorea robusta | <=10 cm | 0.5042 |
| Shorea robusta | >10 to 30 cm | 0.5573 |
| Shorea robusta | >30 to 50 cm | 0.6331 |
| Shorea robusta | >50 cm | 0.6551 |
| Terminalia alata | <=10 cm | 0.4865 |
| Terminalia alata | >10 to 30 cm | 0.5780 |
| Terminalia alata | >30 to 50 cm | 0.6472 |
| Terminalia alata | >50 cm | 0.6819 |

---

## 2. FRTC (2025) tree volume

Source: FRTC (2025), Volume I.

Implemented in: `R/frtc-volume.R`

The package reproduces the selected FRTC equations directly. These are independently fitted equations; no coefficient adjustment or monotonic correction is applied.

Definitions:

- **Total volume:** total stem volume over bark from the 0.30 m stump height to the stem tip; branches excluded.
- **20-cm top volume:** under-bark stem volume from the 0.30 m stump height to the point where over-bark stem diameter reaches 20 cm.
- **10-cm top volume:** under-bark stem volume from the 0.30 m stump height to the point where over-bark stem diameter reaches 10 cm.

Units: DBH `d` in cm, height `h` in m, volume `V` in m3/tree.

### 2.1 Total stem volume over bark

| Species | Code | Equation | n | a | b | c |
|---|---:|---|---:|---:|---:|---:|
| Alnus nepalensis | An | `V=a*d^b*h^c` | 52 | 0.000048 | 1.769901 | 1.165658 |
| Castanopsis spp. | Cs | `V=a*(d^2*h)^b` | 52 | 0.000064 | 0.936534 | — |
| Lagerstroemia parviflora | Lp | `V=a*(d^2*h)^b` | 46 | 0.000064 | 0.936459 | — |
| Pinus roxburghii | Pr | `V=a*(d^2*h)^b` | 96 | 0.000058 | 0.957300 | — |
| Shorea robusta | Sr | `V=a*(d^2*h)^b` | 122 | 0.000059 | 0.948535 | — |
| Schima wallichii | Sw | `V=a*d^b*h^c` | 47 | 0.000047 | 1.677002 | 1.254950 |
| Terminalia alata | Ta | `V=a*(d^2*h)^b` | 61 | 0.000070 | 0.928364 | — |

### 2.2 Under-bark stem volume to 20-cm over-bark top diameter

| Species | Code | Equation | n | a | b | c |
|---|---:|---|---:|---:|---:|---:|
| Alnus nepalensis | An | `V=a*(d^2*h)^b` | 43 | 0.000023 | 1.016204 | — |
| Castanopsis spp. | Cs | `V=a*(d^2*h)^b` | 42 | 0.000009 | 1.089575 | — |
| Lagerstroemia parviflora | Lp | `V=a+b*(d^2*h)` | 31 | -0.147542 | 0.000031 | — |
| Pinus roxburghii | Pr | `V=a*(d^2*h)^b` | 82 | 0.000007 | 1.121720 | — |
| Shorea robusta | Sr | `V=a*(d^2*h)^b` | 107 | 0.000007 | 1.113125 | — |
| Schima wallichii | Sw | `V=a*d^b*h^c` | 39 | 0.000003 | 1.994043 | 1.644049 |
| Terminalia alata | Ta | `V=a*(d^2*h)^b` | 53 | 0.000010 | 1.074116 | — |

### 2.3 Under-bark stem volume to 10-cm over-bark top diameter

| Species | Code | Equation | n | a | b | c |
|---|---:|---|---:|---:|---:|---:|
| Alnus nepalensis | An | `V=a*d^b*h^c` | 51 | 0.000018 | 1.785698 | 1.403011 |
| Castanopsis spp. | Cs | `V=a*(d^2*h)^b` | 49 | 0.000031 | 0.987658 | — |
| Lagerstroemia parviflora | Lp | `V=a*(d^2*h)^b` | 44 | 0.000014 | 1.068129 | — |
| Pinus roxburghii | Pr | `V=a*(d^2*h)^b` | 94 | 0.000014 | 1.064049 | — |
| Shorea robusta | Sr | `V=a*d^b*h^c` | 119 | 0.000011 | 1.960877 | 1.308190 |
| Schima wallichii | Sw | `V=a*d^b*h^c` | 46 | 0.000010 | 1.765752 | 1.523197 |
| Terminalia alata | Ta | `V=a*(d^2*h)^b` | 59 | 0.000021 | 1.013348 | — |

Package guards currently return NA for the 20-cm-top equation when DBH <20 cm and for the 10-cm-top equation when DBH <10 cm. This is an implementation safeguard and not a new fitted equation.

---

## 3. Sharma & Pukkala (1990) stem-volume / biomass parameter table

Source: Sharma, E. R. & Pukkala, T. 1990. *Volume Equations and Biomass Prediction of Forest Trees of Nepal.* Publication 47.

Implemented in: `R/sharma-pukkala-biomass.R` and reused by `R/sharma-pukkala-volume.R`.

Stem-volume equation:

`ln(V_dm3) = a + b*ln(d) + c*ln(h)`

Package conversion: `V_m3 = exp(a + b*ln(d) + c*ln(h))/1000`.

Biomass pathway in the package:

- stem biomass = stem volume x air-dry density
- branch biomass = stem biomass x DBH-dependent branch ratio
- foliage biomass = stem biomass x DBH-dependent foliage ratio
- total biomass = stem + branch + foliage

The Sharma-Pukkala ratio parameters below are distinct from the Forest Regulations 2079 branch-volume ratios in Section 4.

| Species/group | a | b | c | branch s | branch m | branch l | foliage s | foliage m | foliage l | density kg/m3 | n | DBH min | DBH max |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Abies spp. | -2.4453 | 1.7220 | 1.0757 | 0.44 | 0.37 | 0.36 | 0.25 | 0.14 | 0.11 | 480 | 148 | 13.0 | 77.2 |
| Acacia catechu | -2.3256 | 1.6476 | 1.0552 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 960 | 270 | 13.2 | 53.3 |
| Adina cordifolia | -2.5626 | 1.8598 | 0.8783 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 670 | 229 | 13.2 | 121.4 |
| Albizia spp. | -2.4284 | 1.7609 | 0.9662 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 673 | 112 | 15.5 | 119.4 |
| Alnus nepalensis | -2.7761 | 1.9006 | 0.9428 | 0.80 | 1.23 | 1.51 | 0.17 | 0.09 | 0.06 | 390 | 163 | 12.7 | 83.6 |
| Anogeissus latifolia | -2.2720 | 1.7499 | 0.9174 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 880 | 123 | 14.5 | 82.6 |
| Bombax ceiba | -2.3865 | 1.7414 | 1.0063 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 368 | 221 | 14.5 | 137.4 |
| Cedrela toona | -2.1832 | 1.8679 | 0.7569 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 480 | 139 | 13.0 | 91.2 |
| Dalbergia sissoo | -2.1959 | 1.6567 | 0.9899 | 0.68 | 0.68 | 0.68 | 0.01 | 0.01 | 0.01 | 780 | 266 | 14.0 | 78.0 |
| Eugenia jambolana | -2.5693 | 1.8816 | 0.8498 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 770 | 142 | 14.5 | 108.7 |
| Hymenodictyon excelsum | -2.5850 | 1.9437 | 0.7902 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 513 | 125 | 13.5 | 95.5 |
| Lagerstroemia parviflora | -2.3411 | 1.7246 | 0.9702 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 850 | 192 | 13.2 | 80.0 |
| Michelia champaca | -2.0152 | 1.8555 | 0.7630 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 497 | 113 | 16.3 | 136.4 |
| Pinus roxburghii | -2.9770 | 1.9235 | 1.0019 | 0.19 | 0.26 | 0.30 | 0.10 | 0.05 | 0.03 | 650 | 612 | 12.7 | 100.3 |
| Pinus wallichiana | -2.8195 | 1.7250 | 1.1623 | 0.68 | 0.49 | 0.41 | 0.40 | 0.24 | 0.18 | 400 | 340 | 13.0 | 92.7 |
| Quercus spp. | -2.3600 | 1.9680 | 0.7469 | 0.75 | 0.96 | 1.06 | 0.23 | 0.22 | 0.20 | 860 | 152 | 13.0 | 113.0 |
| Schima wallichii | -2.7385 | 1.8155 | 1.0072 | 0.52 | 0.19 | 0.17 | 0.06 | 0.04 | 0.03 | 689 | 47 | 18.3 | 77.5 |
| Shorea robusta | -2.4554 | 1.9026 | 0.8352 | 0.06 | 0.34 | 0.36 | 0.06 | 0.07 | 0.07 | 880 | 895 | 12.7 | 144.5 |
| Terminalia alata | -2.4616 | 1.8497 | 0.8800 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 950 | 492 | 12.7 | 131.1 |
| Trewia nudiflora | -2.4585 | 1.8043 | 0.9220 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 352 | 98 | 15.7 | 70.1 |
| Tsuga spp. | -2.5293 | 1.7815 | 1.0369 | 0.44 | 0.37 | 0.36 | 0.25 | 0.14 | 0.11 | 450 | 94 | 13.7 | 117.9 |
| Miscellaneous species in Terai | -2.3993 | 1.7836 | 0.9546 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 674 | 109 | 14.5 | 114.8 |
| Miscellaneous species in Hills | -2.3204 | 1.8507 | 0.8223 | 0.40 | 0.40 | 0.40 | 0.07 | 0.05 | 0.04 | 674 | 138 | 14.7 | 94.0 |

Sharma-Pukkala branch and foliage ratio interpolation currently implemented:

- `d < 10`: `R = s`
- `10 <= d <= 40`: `R = ((d-10)*m + (40-d)*s)/30`
- `40 < d <= 70`: `R = ((d-40)*l + (70-d)*m)/30`
- `d > 70`: `R = l`

For unsupported actual species, the package does not automatically assign `miscellaneous_terai` or `miscellaneous_hills`; the user must make that classification explicitly.

---

## 4. Nepal Forest Regulations 2079, Schedule 9: branch-volume ratios

Implemented in: `R/sharma-pukkala-volume.R`

Purpose in package: branch volume is calculated as `branch volume = R * Sharma-Pukkala stem volume`, then total tree volume is `stem + branch`.

These regulatory branch-volume ratios are not the same as the Sharma-Pukkala biomass branch ratios listed in Section 3.

| Regulation category | s | m | b |
|---|---:|---:|---:|
| Abies spp. | 0.436 | 0.372 | 0.355 |
| Alnus nepalensis | 0.803 | 1.226 | 1.510 |
| Dalbergia sissoo | 0.684 | 0.684 | 0.684 |
| Pinus roxburghii | 0.189 | 0.256 | 0.300 |
| Pinus wallichiana | 0.683 | 0.488 | 0.410 |
| Quercus spp. | 0.747 | 0.960 | 1.060 |
| Schima wallichii | 0.520 | 0.186 | 0.168 |
| Shorea robusta | 0.055 | 0.341 | 0.357 |
| Other conifer species | 0.436 | 0.372 | 0.355 |
| Other broadleaf species | 0.443 | 0.511 | 0.710 |

Regulation interpolation implemented:

- `d < 10`: `R = s`
- `10 <= d <= 40`: `R = ((d-10)*m + (40-d)*s)/30`
- `40 < d <= 70`: `R = ((d-40)*b + (70-d)*m)/30`
- `d > 70`: `R = b`

The package does not infer whether a non-listed species is broadleaf or conifer. The user must explicitly supply `other_broadleaf` or `other_conifer` where required.

---

## 5. Chave et al. (2014) pantropical biomass model

Implemented in: `R/chave-biomass.R`

Equation used:

`AGB = 0.0673 * (rho * D^2 * H)^0.976`

where:

- `AGB` = oven-dry aboveground biomass, kg/tree
- `rho` = basic wood density, g/cm3
- `D` = DBH, cm
- `H` = total tree height, m

Fixed coefficients used by package:

| coefficient | value |
|---|---:|
| multiplicative coefficient | 0.0673 |
| exponent | 0.976 |

Calibration DBH range flagged by package: 5-212 cm.

Density hierarchy currently implemented:

1. user-supplied basic density, when provided;
2. FRTC 2025 recommended basic density for FRTC species An, Lp, Sr, Sw and Ta;
3. Global Wood Density Database (GWDD) v2.2, using `wsg_est_trunk` at exact infraspecific/binomial level where available;
4. GWDD v2.2 genus-level value where a finer match is unavailable.

The Chave equation itself is not modified when FRTC or GWDD density is used; only the density input source changes.

---

## 6. Carbon conversion constant

Current default carbon fraction used by package biomass workflows:

`Carbon = biomass * 0.47`

Default carbon fraction: **0.47**.

This is a conversion constant, not an allometric model coefficient. Users may supply another carbon fraction where the function interface permits it.

---

## 7. Boundary and comparability reminders

The methods in this registry do not necessarily estimate the same biological or operational quantity.

| Method/output | Main boundary |
|---|---|
| FRTC total biomass | above 0.30 m; stump excluded; stem + branches + foliage according to FRTC definition |
| FRTC total volume | total stem over bark above 0.30 m; branches excluded |
| FRTC 20-cm/10-cm volume | under-bark stem above 0.30 m to specified over-bark top diameter |
| Sharma-Pukkala biomass | air-dry biomass pathway using SP stem volume, density and SP branch/foliage ratios |
| Sharma-Pukkala + Forest Regulation volume | SP stem volume plus branch volume from Forest Regulations 2079 |
| Chave 2014 | pantropical aboveground biomass as defined by Chave et al. (2014) |

Therefore, numerical differences among methods should not automatically be interpreted as model error. Component boundaries, moisture basis, density source, and intended use must be checked first.

---

## 8. Source-code locations to audit

| Component | Source file |
|---|---|
| FRTC biomass coefficients and densities | `R/frtc-total-biomass.R` |
| FRTC volume coefficients | `R/frtc-volume.R` |
| FRTC calibration ranges | `R/calibration-ranges.R` |
| Sharma-Pukkala coefficients, density, biomass ratios | `R/sharma-pukkala-biomass.R` |
| Forest Regulation branch-volume ratios | `R/sharma-pukkala-volume.R` |
| Chave equation and density lookup | `R/chave-biomass.R` |
| High-level biomass workflow | `R/biomass.R` |
| High-level volume workflow | `R/volume.R`, `R/zzz-volume-methods.R` |

---

## 9. Audit status

- FRTC 2025 volume equations: checked against the final FRTC 2025 report and locked by reference tests for all 7 species x 3 volume definitions.
- FRTC 2025 total biomass: recorded from the current implementation based on the FRTC 2025 report.
- Sharma-Pukkala 1990: recorded from the current package implementation; retain the original publication as the authoritative source for future source-by-source audit.
- Forest Regulations 2079 Schedule 9: recorded from the current regulatory implementation; retain the official regulation as the authoritative source.
- Chave et al. 2014: equation recorded from the current package implementation and cited publication.

**Principle:** `nepalallometry` eases correct application of established methods. It does not establish a new allometric equation merely by implementing, combining, summarizing, or exposing the published methods.