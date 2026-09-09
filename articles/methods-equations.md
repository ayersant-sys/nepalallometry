# Methods & Equations

This page documents the equations, coefficients, density rules, units,
calculation boundaries, and source information implemented in
*nepalallometry*. The package operationalizes published methods;
coefficients are not re-fitted by the package. Users should consult the
original sources when a method is used for scientific or regulatory
work.

## 1. Biomass and carbon

### 1.1 FRTC 2025 total aboveground biomass

The FRTC pathway uses species-specific equations selected and reported
by the Forest Research and Training Centre (FRTC, 2025). The implemented
models use one of two forms:

$$B = a\left( D^{2}H\rho \right)^{b}$$

or

$$B = aD^{b}H^{c}$$

where $B$ is biomass (kg tree$^{- 1}$), $D$ is DBH (cm), $H$ is total
height (m), $\rho$ is basic wood density (g cm$^{- 3}$), and $a$, $b$,
and $c$ are published coefficients.

The implemented response is total aboveground biomass **above 0.30 m**;
the 0–0.30 m stump is excluded.

**Source:** Forest Research and Training Centre (2025), *Allometric
equations for seven major tree species of Nepal* (Vol. I).

#### Species, equations and coefficients

The table below is generated directly from the package model registry so
that the website reflects the coefficients actually used by
*nepalallometry*. Equations are displayed in standard mathematical
notation rather than the internal R-style representation.

| Species                  | Nepali name | Equation                             |        a |        b |        c |   n | DBH min (cm) | DBH max (cm) | Height min (m) | Height max (m) | Density basis        |
|:-------------------------|:------------|:-------------------------------------|---------:|---------:|---------:|----:|-------------:|-------------:|---------------:|---------------:|:---------------------|
| Alnus nepalensis         | utis        | $B = a\left( D^{2}H\rho \right)^{b}$ | 0.067139 | 0.956808 |       NA |  52 |          7.4 |         83.4 |           4.50 |           36.6 | FRTC species average |
| Castanopsis spp.         | katus       | $B = aD^{b}H^{c}$                    | 0.071253 | 2.318525 | 0.299393 |  52 |          5.4 |         76.4 |           4.55 |           29.4 | not required         |
| Lagerstroemia parviflora | botdhayero  | $B = a\left( D^{2}H\rho \right)^{b}$ | 0.060964 | 0.971369 |       NA |  46 |          7.1 |         58.1 |           5.50 |           29.3 | FRTC species average |
| Pinus roxburghii         | khotesallo  | $B = aD^{b}H^{c}$                    | 0.031693 | 2.329281 | 0.519366 |  96 |          6.7 |         91.2 |           2.50 |           36.4 | not required         |
| Shorea robusta           | sal         | $B = a\left( D^{2}H\rho \right)^{b}$ | 0.054968 | 0.980885 |       NA | 122 |          6.7 |        102.4 |           4.90 |           42.0 | FRTC DBH class       |
| Schima wallichii         | chilaune    | $B = a\left( D^{2}H\rho \right)^{b}$ | 0.071359 | 0.951091 |       NA |  47 |          5.5 |         67.5 |           5.00 |           32.8 | FRTC species average |
| Terminalia alata         | asna        | $B = a\left( D^{2}H\rho \right)^{b}$ | 0.080156 | 0.943341 |       NA |  61 |          5.4 |        103.2 |           4.80 |           38.4 | FRTC DBH class       |

**Source:** FRTC (2025), selected total-biomass equations and
coefficients; calibration ranges are from the FRTC model-development
dataset as recorded in the package registry.

#### FRTC wood-density rules

Wood density is required only for FRTC models using
$B = a\left( D^{2}H\rho \right)^{b}$. For *Castanopsis* spp. and *Pinus
roxburghii*, density is not required by the selected FRTC biomass
equation. *Shorea robusta* and *Terminalia alata* use DBH-class-specific
densities; *Alnus nepalensis*, *Lagerstroemia parviflora*, and *Schima
wallichii* use species-average densities.

| Species ID               | DBH class (cm) | Density (g/cm3) | Density basis   | Source             |
|:-------------------------|:---------------|----------------:|:----------------|:-------------------|
| alnus_nepalensis         | all            |          0.4318 | species_average | FRTC 2025 Table 11 |
| castanopsis_spp          | not required   |              NA | not_required    | FRTC 2025 Table 11 |
| lagerstroemia_parviflora | all            |          0.5651 | species_average | FRTC 2025 Table 11 |
| pinus_roxburghii         | not required   |              NA | not_required    | FRTC 2025 Table 11 |
| shorea_robusta           | 5-10           |          0.5042 | dbh_class       | FRTC 2025 Table 11 |
| shorea_robusta           | \>10-30        |          0.5573 | dbh_class       | FRTC 2025 Table 11 |
| shorea_robusta           | \>30-50        |          0.6331 | dbh_class       | FRTC 2025 Table 11 |
| shorea_robusta           | \>50           |          0.6551 | dbh_class       | FRTC 2025 Table 11 |
| schima_wallichii         | all            |          0.4869 | species_average | FRTC 2025 Table 11 |
| terminalia_alata         | 5-10           |          0.4865 | dbh_class       | FRTC 2025 Table 11 |
| terminalia_alata         | \>10-30        |          0.5780 | dbh_class       | FRTC 2025 Table 11 |
| terminalia_alata         | \>30-50        |          0.6472 | dbh_class       | FRTC 2025 Table 11 |
| terminalia_alata         | \>50           |          0.6819 | dbh_class       | FRTC 2025 Table 11 |

**Source:** FRTC (2025), Table 11. These density rules are part of the
FRTC biomass pathway implemented in *nepalallometry*.

### 1.2 Sharma & Pukkala 1990 biomass

The Sharma & Pukkala pathway first calculates species-specific stem
volume using the published volume equation:

$$V_{s} = \frac{\exp\left( a + b\ln D + c\ln H \right)}{1000}$$

The original equation produces volume in dm$^{3}$; *nepalallometry*
therefore **divides by 1000 to return m$^{3}$**.

Stem biomass is then:

$$B_{s} = V_{s}\rho$$

where $\rho$ is the air-dry wood density in kg m$^{- 3}$ reported by
Sharma & Pukkala (1990).

Branch and foliage biomass ratios are **species-specific and
DBH-dependent**. Each species or species group has separate published
small-, medium-, and large-tree ratios for branches and foliage. For
species or species group $j$, *nepalallometry* first selects that
group’s published parameters and then calculates the applicable branch
and foliage ratios independently from DBH:

$$B_{b} = B_{s}R_{b,j}(D)$$

$$B_{f} = B_{s}R_{f,j}(D)$$

and total aboveground biomass is:

$$B_{t} = B_{s} + B_{b} + B_{f}$$

For each component (branch or foliage), the selected species-specific
ratio is interpolated according to DBH as:

$$R_{j}(D) = s_{j},\quad D < 10$$

$$R_{j}(D) = \frac{(D - 10)m_{j} + (40 - D)s_{j}}{30},\quad 10 \leq D \leq 40$$

$$R_{j}(D) = \frac{(D - 40)l_{j} + (70 - D)m_{j}}{30},\quad 40 < D \leq 70$$

$$R_{j}(D) = l_{j},\quad D > 70$$

where $s_{j}$, $m_{j}$, and $l_{j}$ are the published small-, medium-,
and large-tree ratios for species or species group $j$. **Separate
parameter sets are used for branches and foliage.** Thus, the package
does not apply one common branch or foliage ratio across species; it
selects the species-specific parameters first and then applies the DBH
interpolation.

**Source:** Sharma and Pukkala (1990), *Volume equations and biomass
prediction of forest trees of Nepal* (Publication No. 47).

#### Species, coefficients, densities and component ratios

| Species/group                  | Nepali name   |       a |      b |      c | Air-dry density (kg/m3) | Branch s | Branch m | Branch l | Foliage s | Foliage m | Foliage l |   n | DBH min (cm) | DBH max (cm) |
|:-------------------------------|:--------------|--------:|-------:|-------:|------------------------:|---------:|---------:|---------:|----------:|----------:|----------:|----:|-------------:|-------------:|
| Abies spp.                     | thingre_salla | -2.4453 | 1.7220 | 1.0757 |                     480 |     0.44 |     0.37 |     0.36 |      0.25 |      0.14 |      0.11 | 148 |         13.0 |         77.2 |
| Acacia catechu                 | khair         | -2.3256 | 1.6476 | 1.0552 |                     960 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 270 |         13.2 |         53.3 |
| Adina cordifolia               | haldu_karma   | -2.5626 | 1.8598 | 0.8783 |                     670 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 229 |         13.2 |        121.4 |
| Albizia spp.                   | siris         | -2.4284 | 1.7609 | 0.9662 |                     673 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 112 |         15.5 |        119.4 |
| Alnus nepalensis               | uttis         | -2.7761 | 1.9006 | 0.9428 |                     390 |     0.80 |     1.23 |     1.51 |      0.17 |      0.09 |      0.06 | 163 |         12.7 |         83.6 |
| Anogeissus latifolia           | dhauti        | -2.2720 | 1.7499 | 0.9174 |                     880 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 123 |         14.5 |         82.6 |
| Bombax ceiba                   | simal         | -2.3865 | 1.7414 | 1.0063 |                     368 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 221 |         14.5 |        137.4 |
| Cedrela toona                  | tuni          | -2.1832 | 1.8679 | 0.7569 |                     480 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 139 |         13.0 |         91.2 |
| Dalbergia sissoo               | sisau         | -2.1959 | 1.6567 | 0.9899 |                     780 |     0.68 |     0.68 |     0.68 |      0.01 |      0.01 |      0.01 | 266 |         14.0 |         78.0 |
| Eugenia jambolana              | jamun         | -2.5693 | 1.8816 | 0.8498 |                     770 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 142 |         14.5 |        108.7 |
| Hymenodictyon excelsum         | kuda          | -2.5850 | 1.9437 | 0.7902 |                     513 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 125 |         13.5 |         95.5 |
| Lagerstroemia parviflora       | botdhayero    | -2.3411 | 1.7246 | 0.9702 |                     850 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 192 |         13.2 |         80.0 |
| Michelia champaca              | champ         | -2.0152 | 1.8555 | 0.7630 |                     497 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 113 |         16.3 |        136.4 |
| Pinus roxburghii               | khote_salla   | -2.9770 | 1.9235 | 1.0019 |                     650 |     0.19 |     0.26 |     0.30 |      0.10 |      0.05 |      0.03 | 612 |         12.7 |        100.3 |
| Pinus wallichiana              | gobre_salla   | -2.8195 | 1.7250 | 1.1623 |                     400 |     0.68 |     0.49 |     0.41 |      0.40 |      0.24 |      0.18 | 340 |         13.0 |         92.7 |
| Quercus spp.                   | khasru        | -2.3600 | 1.9680 | 0.7469 |                     860 |     0.75 |     0.96 |     1.06 |      0.23 |      0.22 |      0.20 | 152 |         13.0 |        113.0 |
| Schima wallichii               | chilaune      | -2.7385 | 1.8155 | 1.0072 |                     689 |     0.52 |     0.19 |     0.17 |      0.06 |      0.04 |      0.03 |  47 |         18.3 |         77.5 |
| Shorea robusta                 | sal           | -2.4554 | 1.9026 | 0.8352 |                     880 |     0.06 |     0.34 |     0.36 |      0.06 |      0.07 |      0.07 | 895 |         12.7 |        144.5 |
| Terminalia alata               | asna          | -2.4616 | 1.8497 | 0.8800 |                     950 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 492 |         12.7 |        131.1 |
| Trewia nudiflora               | gutel         | -2.4585 | 1.8043 | 0.9220 |                     352 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 |  98 |         15.7 |         70.1 |
| Tsuga spp.                     | hemlock       | -2.5293 | 1.7815 | 1.0369 |                     450 |     0.44 |     0.37 |     0.36 |      0.25 |      0.14 |      0.11 |  94 |         13.7 |        117.9 |
| Miscellaneous species in Terai | NA            | -2.3993 | 1.7836 | 0.9546 |                     674 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 109 |         14.5 |        114.8 |
| Miscellaneous species in Hills | NA            | -2.3204 | 1.8507 | 0.8223 |                     674 |     0.40 |     0.40 |     0.40 |      0.07 |      0.05 |      0.04 | 138 |         14.7 |         94.0 |

**Source:** Sharma and Pukkala (1990). The table reproduces the
species/species-group coefficients, air-dry wood densities, branch
ratios, foliage ratios, sample sizes, and observed DBH ranges
implemented in *nepalallometry*.

The table includes the **Miscellaneous species in Terai** and
**Miscellaneous species in Hills** models. When a tree is not
represented by a named Sharma & Pukkala model and a miscellaneous
equation is appropriate, the user must explicitly identify the
applicable Terai or Hills group; the package does not infer this
geographic classification.

### 1.3 Chave et al. 2014

The height-inclusive pantropical aboveground-biomass equation
implemented by the package is:

$$AGB = 0.0673\left( \rho D^{2}H \right)^{0.976}$$

where $AGB$ is oven-dry aboveground biomass (kg tree$^{- 1}$), $D$ is
DBH (cm), $H$ is total height (m), and $\rho$ is basic wood density (g
cm$^{- 3}$), defined as oven-dry mass divided by fresh volume.

**Equation source:** Chave et al. (2014), *Global Change Biology*,
20(10), 3177–3190.

#### Where does the Chave wood density come from?

Because wood density enters the Chave equation directly,
*nepalallometry* records both the density value and its provenance. The
implemented lookup hierarchy is:

1.  **User-supplied density.** If a non-missing `wood_density` is
    supplied, that value overrides the automatic lookup for that tree.
2.  **FRTC 2025 density.** For the five FRTC species for which FRTC
    provides a recommended density for biomass estimation (*Alnus
    nepalensis*, *Lagerstroemia parviflora*, *Shorea robusta*, *Schima
    wallichii*, and *Terminalia alata*), the package uses the
    FRTC (2025) recommended basic density. For *Shorea robusta* and
    *Terminalia alata*, this is DBH-class specific; for the other three
    it is the FRTC species average.
3.  **Global Wood Density Database v2.2 (GWDD v2.2).** If an FRTC
    density is not available, the package searches its bundled GWDD v2.2
    tables. Matching proceeds from an accepted exact infraspecific
    taxon, where applicable, to binomial and then genus level. The
    package uses the GWDD model-derived trunk-density field
    `wsg_est_trunk`.
4.  **No defensible match.** If no density is available after these
    steps, Chave biomass is returned as `NA`; the package does not
    invent a density.

Thus, **Chave does not automatically use one universal density source
for every species**. The output records `wood_density_g_cm3`,
`density_source`, `density_match_level`, `density_taxon_matched`, and
`density_value_field` so the value used for each tree can be audited.

**Density sources:** FRTC (2025), Table 11, for the five applicable FRTC
species; Fischer et al. (2026a) for the scientific description of Global
Wood Density Database v2; and Fischer et al. (2026b), Global Wood
Density Database v2.2, for the bundled density data used by the package.

For example:

``` r
chave_biomass(30, 20, "sal", keep_inputs = TRUE)
chave_biomass(30, 20, "Dalbergia sissoo", keep_inputs = TRUE)
```

The FRTC density rules shown above are therefore also the densities used
first by the Chave pathway for those five FRTC species. Other taxa can
use GWDD v2.2 according to the hierarchy above.

### 1.4 Carbon conversion

Carbon is derived from biomass rather than estimated by a separate
allometric equation:

$$C = AGB \times CF$$

where $CF$ is the carbon fraction. The default in *nepalallometry* is
0.47.

**Source:** IPCC (2006), *2006 IPCC Guidelines for National Greenhouse
Gas Inventories*, Volume 4: Agriculture, Forestry and Other Land Use.

## 2. Tree volume

### 2.1 FRTC 2025 stem volume

FRTC selected equations use one of three forms:

$$V = aD^{b}H^{c}$$

$$V = a\left( D^{2}H \right)^{b}$$

or

$$V = a + b\left( D^{2}H \right)$$

where $V$ is m$^{3}$ tree$^{- 1}$, $D$ is DBH (cm), and $H$ is total
height (m).

FRTC reports three **different volume definitions**: total stem volume
over bark (`total_ob`), under-bark stem volume to a 20-cm over-bark top
diameter (`ub_20cm`), and under-bark stem volume to a 10-cm over-bark
top diameter (`ub_10cm`). All exclude the 0.30-m stump and branches.
These outputs should not be summed or averaged.

**Source:** FRTC (2025), Tables 6–8, as reproduced in the package volume
registry.

#### Species-specific FRTC volume coefficients

The following coefficients reproduce the selected FRTC (2025) equations
implemented in the package.

| Species                  | Volume definition       | Equation                         |         a |        b |        c |
|:-------------------------|:------------------------|:---------------------------------|----------:|---------:|---------:|
| Alnus nepalensis         | Total over-bark stem    | $V = aD^{b}H^{c}$                |  0.000048 | 1.769901 | 1.165658 |
| Castanopsis spp.         | Total over-bark stem    | $V = a\left( D^{2}H \right)^{b}$ |  0.000064 | 0.936534 |       NA |
| Lagerstroemia parviflora | Total over-bark stem    | $V = a\left( D^{2}H \right)^{b}$ |  0.000064 | 0.936459 |       NA |
| Pinus roxburghii         | Total over-bark stem    | $V = a\left( D^{2}H \right)^{b}$ |  0.000058 | 0.957300 |       NA |
| Shorea robusta           | Total over-bark stem    | $V = a\left( D^{2}H \right)^{b}$ |  0.000059 | 0.948535 |       NA |
| Schima wallichii         | Total over-bark stem    | $V = aD^{b}H^{c}$                |  0.000047 | 1.677002 | 1.254950 |
| Terminalia alata         | Total over-bark stem    | $V = a\left( D^{2}H \right)^{b}$ |  0.000070 | 0.928364 |       NA |
| Alnus nepalensis         | Under-bark to 20-cm top | $V = a\left( D^{2}H \right)^{b}$ |  0.000023 | 1.016204 |       NA |
| Castanopsis spp.         | Under-bark to 20-cm top | $V = a\left( D^{2}H \right)^{b}$ |  0.000009 | 1.089575 |       NA |
| Lagerstroemia parviflora | Under-bark to 20-cm top | $V = a + b\left( D^{2}H \right)$ | -0.147542 | 0.000031 |       NA |
| Pinus roxburghii         | Under-bark to 20-cm top | $V = a\left( D^{2}H \right)^{b}$ |  0.000007 | 1.121720 |       NA |
| Shorea robusta           | Under-bark to 20-cm top | $V = a\left( D^{2}H \right)^{b}$ |  0.000007 | 1.113125 |       NA |
| Schima wallichii         | Under-bark to 20-cm top | $V = aD^{b}H^{c}$                |  0.000003 | 1.994043 | 1.644049 |
| Terminalia alata         | Under-bark to 20-cm top | $V = a\left( D^{2}H \right)^{b}$ |  0.000010 | 1.074116 |       NA |
| Alnus nepalensis         | Under-bark to 10-cm top | $V = aD^{b}H^{c}$                |  0.000018 | 1.785698 | 1.403011 |
| Castanopsis spp.         | Under-bark to 10-cm top | $V = a\left( D^{2}H \right)^{b}$ |  0.000031 | 0.987658 |       NA |
| Lagerstroemia parviflora | Under-bark to 10-cm top | $V = a\left( D^{2}H \right)^{b}$ |  0.000014 | 1.068129 |       NA |
| Pinus roxburghii         | Under-bark to 10-cm top | $V = a\left( D^{2}H \right)^{b}$ |  0.000014 | 1.064049 |       NA |
| Shorea robusta           | Under-bark to 10-cm top | $V = aD^{b}H^{c}$                |  0.000011 | 1.960877 | 1.308190 |
| Schima wallichii         | Under-bark to 10-cm top | $V = aD^{b}H^{c}$                |  0.000010 | 1.765752 | 1.523197 |
| Terminalia alata         | Under-bark to 10-cm top | $V = a\left( D^{2}H \right)^{b}$ |  0.000021 | 1.013348 |       NA |

**Source:** FRTC (2025), Tables 6–8. Coefficients are reproduced without
re-fitting, adjustment, or harmonization.

### 2.2 Sharma & Pukkala stem volume

The stem-volume equation is:

$$V_{s,dm^{3}} = \exp\left( a + b\ln D + c\ln H \right)$$

followed by the explicit unit conversion:

$$V_{s,m^{3}} = \frac{V_{s,dm^{3}}}{1000}$$

or equivalently:

$$V_{s} = \frac{\exp\left( a + b\ln D + c\ln H \right)}{1000}$$

This division by 1000 is part of the implemented calculation and is
required because the original Sharma & Pukkala equation reports stem
volume in dm$^{3}$.

The species-specific $a$, $b$, and $c$ coefficients are the same Sharma
& Pukkala coefficients listed in the biomass table above.

**Source:** Sharma and Pukkala (1990), *Volume equations and biomass
prediction of forest trees of Nepal* (Publication No. 47).

### 2.3 Forest Regulations 2079 branch volume

Branch volume is calculated from the Sharma & Pukkala stem volume using
the branch ratio prescribed in Schedule 9 of Nepal’s Forest Regulations
2079:

$$V_{b} = R(D)V_{s}$$

The DBH-dependent ratio is:

$$R(D) = s,\quad D < 10$$

$$R(D) = \frac{(D - 10)m + (40 - D)s}{30},\quad 10 \leq D \leq 40$$

$$R(D) = \frac{(D - 40)b + (70 - D)m}{30},\quad 40 < D \leq 70$$

$$R(D) = b,\quad D > 70$$

and total tree volume is:

$$V_{t} = V_{s} + V_{b}$$

**Source:** Government of Nepal (2022), *Forest Regulations, 2079*,
Schedule 9.

#### Forest Regulations branch groups and parameters

| Branch group      | Species/group           | Nepali name       |     s |     m |     b |
|:------------------|:------------------------|:------------------|------:|------:|------:|
| abies_spp         | Abies spp.              | Thingre salla     | 0.436 | 0.372 | 0.355 |
| alnus_nepalensis  | Alnus nepalensis        | Uttis             | 0.803 | 1.226 | 1.510 |
| dalbergia_sissoo  | Dalbergia sissoo        | Sissoo            | 0.684 | 0.684 | 0.684 |
| pinus_roxburghii  | Pinus roxburghii        | Khote salla       | 0.189 | 0.256 | 0.300 |
| pinus_wallichiana | Pinus wallichiana       | Gobre salla       | 0.683 | 0.488 | 0.410 |
| quercus_spp       | Quercus spp.            | Khasru            | 0.747 | 0.960 | 1.060 |
| schima_wallichii  | Schima wallichii        | Chilaune          | 0.520 | 0.186 | 0.168 |
| shorea_robusta    | Shorea robusta          | Sal               | 0.055 | 0.341 | 0.357 |
| other_conifer     | Other conifer species   | Other conifers    | 0.436 | 0.372 | 0.355 |
| other_broadleaf   | Other broadleaf species | Other broadleaves | 0.443 | 0.511 | 0.710 |

**Source:** Government of Nepal (2022), *Forest Regulations, 2079*,
Schedule 9, branch-volume parameters implemented in *nepalallometry*.

The applicable `branch_group` must therefore be supplied for the
Sharma–Pukkala + Forest Regulations volume workflow. The package does
not silently assign an unspecified regulatory branch group.

## 3. Plot and forest summaries

For a plot of area $A$ hectares, a tree-level quantity $Y_{i}$ is
expanded as:

$$Y_{plot} = \frac{\sum\limits_{i}Y_{i}}{A}$$

For $n$ plots, the standard error is:

$$SE = \frac{SD}{\sqrt{n}}$$

and the two-sided 95% confidence interval for the mean is:

$$\bar{Y} \pm t_{0.975,n - 1}SE$$

These intervals describe sampling uncertainty in the mean across plots.
They are not individual-tree prediction intervals and do not propagate
allometric-model uncertainty.

**Source:** These aggregation and summary calculations are implemented
by *nepalallometry* from the supplied plot areas and plot-level
estimates; they are not additional allometric equations from FRTC,
Sharma & Pukkala, or Chave.

## 4. Method boundaries and interpretation

The methods are not automatically interchangeable estimates of exactly
the same biological quantity:

- FRTC biomass excludes the 0–0.30 m stump (FRTC, 2025);
- Chave biomass follows the aboveground-biomass definition of Chave et
  al. (2014);
- Sharma & Pukkala biomass uses the published air-dry density and
  species-specific component-ratio pathway (Sharma & Pukkala, 1990);
- FRTC volume represents stem volume and excludes branches and the
  0.30-m stump (FRTC, 2025);
- FRTC’s three volume outputs are distinct volume definitions (FRTC,
  2025);
- Sharma–Pukkala + Forest Regulations total volume includes branch
  volume (Sharma & Pukkala, 1990; Government of Nepal, 2022); and
- carbon is calculated from biomass using the default carbon fraction of
  0.47 (IPCC, 2006).

Differences among supported methods can be used to examine sensitivity
to methodological choice, but their spread is **not a formal estimate of
uncertainty or accuracy**.

## 5. Inspecting methods in R

The following functions allow users to inspect the implemented
coefficients, density rules, branch parameters, and source registry
directly:

``` r
frtc_models()
frtc_equation("sal")
frtc_density()
sharma_pukkala_species()
forest_regulation_branch_parameters()
chave_biomass(30, 20, "sal", keep_inputs = TRUE)
allometry_references()
```

## 6. References

The full references below are generated from the same package reference
registry used by *nepalallometry* documentation and output workbooks.

|     | Short citation                             | Full reference                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|:----|:-------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2   | Forest Research and Training Centre (2025) | Forest Research and Training Centre. (2025). Allometric equations for seven major tree species of Nepal (Vol. I). Ministry of Forests and Environment, Government of Nepal.                                                                                                                                                                                                                                                                                                                          |
| 3   | Sharma and Pukkala (1990)                  | Sharma, E. R., & Pukkala, T. (1990). Volume equations and biomass prediction of forest trees of Nepal (Publication No. 47). Forest Survey and Statistics Division, Ministry of Forests and Soil Conservation.                                                                                                                                                                                                                                                                                        |
| 4   | Government of Nepal (2022)                 | Government of Nepal. (2022). Forest Regulations, 2079. Nepal Law Commission. <https://lawcommission.gov.np/content/12938/12938-forest-regulation-2079/>                                                                                                                                                                                                                                                                                                                                              |
| 5   | Chave et al. (2014)                        | Chave, J., Rejou-Mechain, M., Burquez, A., Chidumayo, E., Colgan, M. S., Delitti, W. B. C., Duque, A., Eid, T., Fearnside, P. M., Goodman, R. C., Henry, M., Martinez-Yrizar, A., Mugasha, W. A., Muller-Landau, H. C., Mencuccini, M., Nelson, B. W., Ngomanda, A., Nogueira, E. M., Ortiz-Malavassi, E., … Vieilledent, G. (2014). Improved allometric models to estimate the aboveground biomass of tropical trees. Global Change Biology, 20(10), 3177-3190. <https://doi.org/10.1111/gcb.12629> |
| 6   | Fischer et al. (2026a)                     | Fischer, F. J., Chave, J., Zanne, A., Jucker, T., Fajardo, A., Fayolle, A., Ferreira de Lima, R. A., Vieilledent, G., Beeckman, H., Hubau, W., De Mil, T., Wallenus, D., Aldana, A. M., Alvarez-Davila, E., Alves, L. F., Apgaua, D. M. G., Arcanjo, F., Bastin, J.-F., Bilous, A., … Zieminska, K. (2026a). Beyond species means: The intraspecific contribution to global wood density variation. New Phytologist, 249(6), 2630-2651. <https://doi.org/10.1111/nph.70860>                          |
| 7   | Fischer et al. (2026b)                     | Fischer, F. J., Chave, J., Zanne, A., Jucker, T., Fajardo, A., Fayolle, A., Ferreira de Lima, R. A., Vieilledent, G., Beeckman, H., Hubau, W., De Mil, T., Wallenus, D., Aldana, A. M., Alvarez-Davila, E., Alves, L. F., Apgaua, D. M. G., Arcanjo, F., Bastin, J.-F., Bilous, A., … Zieminska, K. (2026b). Global Wood Density Database v2.2 \[Data set\]. Zenodo. <https://doi.org/10.5281/zenodo.18262736>                                                                                       |
| 8   | IPCC (2006)                                | Intergovernmental Panel on Climate Change. (2006). 2006 IPCC guidelines for national greenhouse gas inventories: Volume 4. Agriculture, forestry and other land use (H. S. Eggleston, L. Buendia, K. Miwa, T. Ngara, & K. Tanabe, Eds.). Institute for Global Environmental Strategies. <https://www.ipcc-nggip.iges.or.jp/public/2006gl/vol4.html>                                                                                                                                                  |
