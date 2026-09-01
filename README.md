# nepalallometry

<!-- badges: start -->
[![R-CMD-check](https://github.com/ayersant-sys/nepalallometry/actions/workflows/r.yml/badge.svg)](https://github.com/ayersant-sys/nepalallometry/actions/workflows/r.yml)
<!-- badges: end -->

`nepalallometry` provides reproducible access to published allometric
equations for Nepal's forest trees. The current development version implements
the Forest Research and Training Centre (FRTC, 2025) total aboveground biomass
models for seven major commercial tree species.

The estimates represent biomass **above 0.30 m** and therefore exclude the
stump between ground level and the FRTC felling height. DBH is supplied in
centimetres, total height in metres, biomass is returned in kg/tree, and
plot-level biomass is reported in Mg/ha (numerically equal to metric tonnes per
hectare).

## Installation

Install the current development version directly from GitHub:

```r
install.packages("remotes")
remotes::install_github("ayersant-sys/nepalallometry")
library(nepalallometry)
```

The package is not yet on CRAN. After a CRAN release, installation will use
`install.packages("nepalallometry")`.

## Supported species

```r
frtc_species()
```

| Standard identifier | Nepali name | Scientific name |
|---|---|---|
| `alnus_nepalensis` | `utis` | *Alnus nepalensis* |
| `castanopsis_spp` | `katus` | *Castanopsis* spp. |
| `lagerstroemia_parviflora` | `botdhayero` | *Lagerstroemia parviflora* |
| `pinus_roxburghii` | `khotesallo` | *Pinus roxburghii* |
| `shorea_robusta` | `sal` | *Shorea robusta* |
| `schima_wallichii` | `chilaune` | *Schima wallichii* |
| `terminalia_alata` | `asna` | *Terminalia alata* |

Use either the lowercase scientific identifier or the listed Nepali name in
inventory files. Unsupported species are retained with `NA` biomass and an
`unsupported_species` status; another equation is never substituted silently.

## Estimate one tree

```r
frtc_total_biomass(
  dbh = 30,
  height = 20,
  species = "sal",
  keep_inputs = TRUE
)
```

FRTC-recommended wood density is selected internally when an equation requires
density. User-supplied density is intentionally not accepted in this
implementation.

## Calibration ranges and extrapolation

For every supported species, the package compares DBH and height with the
observed minimum and maximum values in the FRTC model-development dataset.

```r
frtc_models()[, c(
  "species_id", "sample_size",
  "dbh_min_cm", "dbh_max_cm",
  "height_min_m", "height_max_m"
)]
```

Predictions outside either observed range are still returned, but the package
issues a warning and marks them with
`within_calibration_range = FALSE`. Use `keep_inputs = TRUE` and inspect
`calibration_status` to identify whether DBH, height, or both are outside the
observed range. These flags identify extrapolation; they are not formal
prediction intervals.

## Sharma-Pukkala biomass

The development version also implements the Sharma and Pukkala (1990)
air-dry biomass method for 21 named species and the explicit
`miscellaneous_terai` and `miscellaneous_hills` groups.

```r
sharma_pukkala_species()

sharma_pukkala_biomass(
  dbh = 30,
  height = 20,
  species = "sal",
  keep_inputs = TRUE
)
```

The function estimates stem biomass internally from the published stem-volume
equation and density, then adds branch and foliage biomass using DBH-interpolated
ratios. Outputs are labelled `air_dry`. Observed calibration limits are available
for DBH only; species-specific height limits were not reported. Miscellaneous
Terai and Hills groups must be entered explicitly and are never selected
automatically.

## Analyse an inventory in R

The required columns are `tree_id`, `plot_id`, `plot_area_ha`,
`species`, `dbh_cm`, and `height_m`.

```r
inventory <- data.frame(
  tree_id = 1:4,
  plot_id = c("p01", "p01", "p02", "p02"),
  plot_area_ha = c(0.05, 0.05, 0.10, 0.10),
  species = c("sal", "chilaune", "pinus_roxburghii", "acacia_catechu"),
  dbh_cm = c(30, 25, 30, 20),
  height_m = c(20, 18, 20, 15)
)

tree_results <- estimate_frtc_biomass(inventory)
plot_results <- frtc_plot_summary(tree_results)
species_results <- frtc_species_summary(tree_results)
dbh_results <- frtc_dbh_summary(tree_results)
forest_results <- frtc_forest_summary(plot_results)

plot_results
forest_results
```

Because `acacia_catechu` has no FRTC model in the current package,
`p02` is marked as a partial estimate. Always inspect
`summary_status`, `stem_coverage_pct`, and
`basal_area_coverage_pct` before interpreting plot or forest summaries.

Carbon is calculated as biomass multiplied by 0.47. This constant can support
consistent reporting, but it does not represent measured species-specific
carbon concentration.

## CSV to one Excel workbook

Create a blank inventory template:

```r
frtc_inventory_template("frtc_inventory.csv", rows = 100)
```

After entering the inventory data in that CSV, run:

```r
results <- frtc_biomass_from_csv(
  input = "frtc_inventory.csv",
  output_format = "excel"
)

results$files
```

The workbook contains:

- About
- Tree Results
- Plot Summary
- Species Summary
- DBH Class Summary
- Forest Summary
- Model Registry
- Calibration Ranges
- Density Rules

Use `output_format = "csv"` for separate CSV outputs or
`output_format = "both"` for both formats.

## Inspect equations and sources

```r
frtc_models()
frtc_equation("sal")
frtc_density()
frtc_density("sal", dbh = 30)
citation("nepalallometry")
```

The model and density registries are also distributed as plain CSV files under
`inst/extdata`. Model-fit RMSE from FRTC Table 9 is distinguished from
operational RMSE obtained using the recommended densities in Table 11.

## Important limitations

- Models are available only for the seven listed species.
- Estimates require measured DBH and total height.
- Biomass excludes the 0-0.30 m stump.
- Unsupported or missing species are not included in supported-biomass totals.
- Partial plot estimates are not estimates of whole-plot biomass.
- The current version does not estimate roots, dead wood, litter, soil carbon,
  missing height, stump biomass, or formal prediction uncertainty.
- Predictions outside the observed species-specific DBH or height range are
  extrapolations and are explicitly flagged.
- Predictions should not be treated as direct measurements of biomass or
  carbon.

## Citation

```r
citation("nepalallometry")
```

Please cite both the package and the original FRTC report when using these
models.

## Source

Forest Research and Training Centre (FRTC). (2025). *Allometric Equations for
Seven Major Tree Species of Nepal, Volume I*. Government of Nepal.

## Development status

This is a development release. Please report problems or suggestions through
the [GitHub issue tracker](https://github.com/ayersant-sys/nepalallometry/issues).
