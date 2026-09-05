# nepalallometry

<!-- badges: start -->
[![test-coverage](https://github.com/ayersant-sys/nepalallometry/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/ayersant-sys/nepalallometry/actions/workflows/test-coverage.yaml)
[![R-CMD-check](https://github.com/ayersant-sys/nepalallometry/actions/workflows/r.yml/badge.svg)](https://github.com/ayersant-sys/nepalallometry/actions/workflows/r.yml)
[![pkgdown](https://github.com/ayersant-sys/nepalallometry/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/ayersant-sys/nepalallometry/actions/workflows/pkgdown.yaml)
[![release](https://img.shields.io/github/v/release/ayersant-sys/nepalallometry?label=release)](https://github.com/ayersant-sys/nepalallometry/releases/latest)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22299266.svg)](https://doi.org/10.5281/zenodo.22299266)
<!-- badges: end -->

***nepalallometry*** is an extensible umbrella R package for transparent and reproducible allometric estimation for Nepal's forest trees. It brings published equations, assumptions, source documentation, validation checks, and practical inventory workflows into one auditable platform.

## Biomass, Carbon, and Tree Volume Estimation for Nepal

The package currently provides two separate operational workflows:

- `biomass()` for aboveground biomass and carbon estimation using FRTC (2025), Sharma and Pukkala (1990), and Chave et al. (2014) pathways.
- `volume()` for tree-volume estimation using FRTC (2025) stem-volume equations and Sharma-Pukkala (1990) stem-volume equations, with branch volume derived where applicable using the branch-to-stem volume ratios specified in Schedule 9 of Nepal's Forest Regulations 2079.

The methods are reproduced according to their published equations, coefficients, units, and component boundaries. Methodologically different estimates are not silently substituted, averaged, or forced to agree.

> **Release note:** Version 1.0.0 established the first stable biomass-and-carbon release. The current GitHub build extends the package with tree-volume estimation. The Zenodo DOI badge above refers to the archived Version 1.0.0 release.

## Installation

```r
install.packages("remotes")
remotes::install_github("ayersant-sys/nepalallometry")
library(nepalallometry)
```

The package is currently distributed through GitHub and archived on Zenodo; it is not currently available on CRAN.

## Biomass and carbon workflow

For inventory-level biomass analysis, provide one row per tree with `tree_id`, `plot_id`, `plot_area_ha`, `species`, `dbh_cm`, and `height_m`.

```r
inventory <- data.frame(
  tree_id = 1:4,
  plot_id = c("p01", "p01", "p02", "p02"),
  plot_area_ha = c(0.05, 0.05, 0.10, 0.10),
  species = c("sal", "chilaune", "pinus_roxburghii", "acacia_catechu"),
  dbh_cm = c(30, 25, 30, 20),
  height_m = c(20, 18, 20, 15)
)

result <- biomass(inventory)

forest_summary(result)
plot_summary(result)
species_summary(result)
dbh_summary(result)
tree_results(result)
method_audit(result)
```

The three biomass pathways remain separate because their species coverage, moisture bases, biomass boundaries, density treatment, and assumptions differ. FRTC biomass represents biomass above the approximately 0.30-m felling height and therefore excludes the lower stump.

### Individual biomass functions

```r
frtc_total_biomass(30, 20, "sal", keep_inputs = TRUE)
sharma_pukkala_biomass(30, 20, "sal", keep_inputs = TRUE)
chave_biomass(30, 20, "Dalbergia sissoo", keep_inputs = TRUE)
```

Carbon is calculated from biomass using a default carbon fraction of 0.47; users may provide another documented fraction where appropriate.

## Tree volume workflow

Volume estimation is intentionally separate from biomass estimation.

For an individual tree, `plot_id` and `plot_area_ha` are not required:

```r
trees <- data.frame(
  tree_id = c("T1", "T2"),
  species = c("sal", "pinus_roxburghii"),
  dbh_cm = c(60, 45),
  height_m = c(25, 22)
)

v <- volume(trees)
v$tree_results
v$method_audit
```

When `plot_id` and `plot_area_ha` are supplied together, `volume()` automatically provides inventory-level plot, species, DBH-class, and forest summaries.

### FRTC 2025 volume

`frtc_volume()` returns three published stem-volume outputs for the seven FRTC taxa:

- total stem volume over bark from the 30-cm stump height to the tip;
- stem volume under bark to a 20-cm over-bark top diameter; and
- stem volume under bark to a 10-cm over-bark top diameter.

Branches are excluded from all FRTC volume outputs, and the 30-cm stump is outside the FRTC stem-volume boundary.

```r
frtc_volume(60, 25, "sal", keep_inputs = TRUE)
```

The 10-cm and 20-cm equations were fitted independently in the source report. `nepalallometry` reproduces the published equations and does not alter their predictions to force mathematical monotonicity.

### Sharma-Pukkala volume with Forest Regulation branch ratios

`sharma_pukkala_volume()` estimates **stem volume using the published equations of Sharma and Pukkala (1990)**. Where branch volume is required, the package applies the **branch-to-stem volume ratios specified in Schedule 9 of Nepal's Forest Regulations 2079**. Thus, Sharma and Pukkala (1990) remains the source of the stem-volume equation, while the Forest Regulations provide the regulatory procedure for deriving branch volume.

**Total tree volume = Sharma-Pukkala stem volume + branch volume derived from the applicable Forest Regulation ratio.**

```r
sharma_pukkala_volume(60, 25, "sal", keep_inputs = TRUE)
```

For species with a species-specific regulatory branch category, no `branch_group` is needed. For other supported Sharma-Pukkala stem-volume species, users may explicitly assign `other_broadleaf` or `other_conifer` when appropriate. The package does not infer this classification automatically.

### Important volume comparability note

The method label **total volume** does not imply an identical component boundary across methods:

- Sharma-Pukkala with Forest Regulation branch ratios: total volume = Sharma-Pukkala stem volume + branch volume derived from the applicable regulatory ratio.
- FRTC total volume = total stem volume over bark only; branches and the 30-cm stump are excluded.

These outputs should therefore be reported with their method and boundary and should not be averaged as if they estimated the same physical quantity.

## File and Excel workflows

Both high-level workflows accept R data frames, CSV files, and Excel workbooks.

```r
biomass("forest_inventory.xlsx", sheet = "Inventory")
volume("tree_inventory.xlsx")
```

For biomass inventories and inventory-level volume analyses, exported workbooks provide task-oriented summaries plus `Tree_Results` and `Method_Audit`. Tree-only volume inputs produce a compact workbook containing `Read_Me`, `Tree_Results`, and `Method_Audit`.

## Supported taxa and model information

```r
frtc_species()
sharma_pukkala_species()
frtc_models()
frtc_equation("sal")
frtc_density("sal", dbh = 30)
forest_regulation_branch_parameters()
allometry_references()
```

Unsupported species are retained and flagged rather than silently assigned another equation. Calibration/extrapolation information is retained where the source data permit it.

## Core principle

***nepalallometry*** implements published methods; it does not make methodologically different estimates equivalent. The package can make calculations reproducible and expose assumptions, coverage, boundaries, and provenance, but it cannot remove biological or model uncertainty.

## Important limitations

- FRTC biomass and volume currently cover the seven taxa published in FRTC (2025), Volume I.
- Measured DBH and total height are required by the current workflows.
- FRTC biomass excludes the 0-0.30 m stump.
- FRTC volume is stem-only and excludes the 0-0.30 m stump and branches.
- Unsupported or missing trees are not silently replaced by another model.
- Partial estimates are not estimates of the unsupported portion of a plot or forest.
- Calibration flags identify extrapolation; they are not formal prediction intervals.
- The package does not currently estimate roots, dead wood, litter, soil carbon, missing height, stump biomass, or formal allometric prediction uncertainty.
- Biomass, carbon, and volume outputs are model-based estimates, not direct measurements.

## Citation

```r
citation("nepalallometry")
allometry_references()
```

For the archived Version 1.0.0 release:

Ayer, S. (2026). *nepalallometry: Allometric estimation for Nepal's forest trees* (Version 1.0.0) [R package]. Zenodo. DOI: 10.5281/zenodo.22299266

Users should also cite the methodological and regulatory sources used by their selected pathway, including FRTC (2025), Sharma and Pukkala (1990), Chave et al. (2014), Nepal's Forest Regulations 2079, IPCC (2006), and relevant wood-density sources as applicable.

## Future development

***nepalallometry*** is designed as an umbrella package. Future development may add further officially published Nepal-relevant allometric equations, species coverage, height-diameter relationships, and other inventory tools. New modules will retain explicit sources, units, calibration domains, component boundaries, and limitations.

## Development status

The current development build is maintained on GitHub. Please report problems or suggestions through the GitHub issue tracker.
