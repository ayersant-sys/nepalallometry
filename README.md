# nepalallometry

<!-- badges: start -->
[![R-CMD-check](https://github.com/ayersant-sys/nepalallometry/actions/workflows/r.yml/badge.svg)](https://github.com/ayersant-sys/nepalallometry/actions/workflows/r.yml)
<!-- badges: end -->

***nepalallometry*** is an extensible umbrella R package for transparent and
reproducible allometric estimation for Nepal's forest trees. It is designed to
bring published equations, their assumptions, source documentation, validation
checks, and practical inventory workflows into one auditable platform.

## First release focus: biomass and carbon estimation

The first release is centered on `biomass()`, the package's main inventory
workflow for tree-, plot-, species-, DBH-class-, and forest-level biomass and
carbon estimation. It keeps three pathways separate: Forest Research and
Training Centre (FRTC, 2025), Sharma and Pukkala (1990), and Chave et al. (2014).
They are not combined because their species coverage, moisture bases, biomass
boundaries, density treatment, and assumptions differ.

DBH is supplied in centimetres, total height in metres, biomass is returned in
kg/tree, and plot-level biomass is reported in Mg/ha (numerically equal to
metric tonnes per hectare). The biomass definition is recorded for every
pathway. FRTC estimates represent biomass **above 0.30 m** and exclude the stump
between ground level and the FRTC felling height; the other pathways retain
their published biomass boundaries and moisture bases.

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

Sharma and Pukkala (1990) is the original methodological source. Schedule 9 of
Nepal's *Forest Regulations, 2079* provides the regulatory basis for using its
tree-volume parameters. The regulation is therefore cited as an operational
and legal source, not as the origin of the equations.

## Chave et al. (2014) biomass

The package implements the height-inclusive pantropical equation:

```text
AGB = 0.0673 * (wood_density * DBH^2 * height)^0.976
```

```r
chave_biomass(
  dbh = 30,
  height = 20,
  species = "Dalbergia sissoo",
  keep_inputs = TRUE
)
```

Basic density is selected automatically using this hierarchy:

1. FRTC (2025) density for *Alnus nepalensis*, *Lagerstroemia parviflora*,
   *Shorea robusta*, *Schima wallichii*, and *Terminalia alata*;
2. GWDD v2.2 exact infraspecific match;
3. GWDD v2.2 binomial match; and
4. GWDD v2.2 genus match.

The remaining FRTC taxa, *Pinus roxburghii* and *Castanopsis* spp., use GWDD
binomial and genus densities, respectively. GWDD lookup uses the model-derived
trunk estimate `wsg_est_trunk`, not the raw mean. Genus matches trigger a
warning, while taxa with no match return `NA`. The detailed result records the
density source, match level, matched taxon, and database version. Users with a
verified basic-density measurement may override the automatic lookup with
`wood_density`.

Chave results are oven-dry AGB. They are not directly equivalent to
Sharma–Pukkala air-dry biomass, and their biomass boundary differs from the
FRTC boundary that excludes the 0–0.30 m stump.

## Complete biomass inventory workflow

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

result <- biomass(inventory)

summary(result)
forest_summary(result)
plot_summary(result)
species_summary(result)
dbh_summary(result)
tree_results(result)
```

The same command accepts a CSV or Excel workbook:

```r
biomass("forest_inventory.csv")
biomass("forest_inventory.xlsx", sheet = "Inventory")
```

The required columns are `tree_id`, `plot_id`, `plot_area_ha`, `species`,
`dbh_cm`, and `height_m`. `forest_id` and `forest_area_ha` are optional.
Supplying forest area enables estimated total forest biomass and carbon; without
it, the package reports per-hectare forest statistics only.

Unsupported trees remain in the output with `NA` and create a
`partial_tree_coverage` or `no_tree_estimates` flag. Always inspect stem and
basal-area coverage before interpreting a plot or forest estimate.

Carbon is calculated as biomass multiplied by 0.47, the IPCC (2006) default
fraction for aboveground forest biomass. This constant can support consistent
reporting, but it does not represent measured species-specific carbon
concentration. Users may supply another documented fraction where appropriate.

## Excel output

By default, `biomass()` writes one Excel workbook beside a file input, or in
the working directory for a data-frame input. To choose the file name:

```r
result <- biomass(
  "forest_inventory.csv",
  output = "forest_biomass_results.xlsx"
)
```

The workbook contains seven task-oriented sheets:

- `Read_Me`
- `Forest_Summary`
- `Plot_Summary`
- `Species_Summary`
- `DBH_Summary`
- `Tree_Results`
- `Method_Audit`

FRTC, Sharma & Pukkala, and Chave appear as method labels without dates in the
result tables. Their publication years and full sources remain in calculation
notes and model metadata. Wood density is handled automatically where required.
The methods remain separate because their moisture bases, biomass boundaries,
scope, and assumptions differ.

The Excel sheets use simple, unmerged, copyable headings with units. Continuous
values display four decimal places, while counts display as whole numbers.
`Tree_Results` contains the main estimates; density, calibration, biomass
boundary, moisture basis, and citations are retained separately in
`Method_Audit`.

The earlier `biomass_from_csv()` command remains available for compatibility,
but new analyses should use `biomass()`.

The earlier FRTC-only workflow remains available:

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
allometry_references()
```

The model and density registries are also distributed as plain CSV files under
`inst/extdata`. Model-fit RMSE from FRTC Table 9 is distinguished from
operational RMSE obtained using the recommended densities in Table 11.

## Future updates

***nepalallometry*** is intended to grow beyond its first biomass-focused
release. Planned development includes additional Nepal-relevant allometric
models and species, stem-volume estimation, height-diameter relationships, and
other inventory tools where suitable equations and supporting evidence are
available. These additions will be introduced progressively, with their sources,
units, calibration domains, and limitations documented explicitly. The roadmap
describes intended directions and does not promise a particular release date.

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

Use `allometry_references()` to obtain the complete APA-style source registry.
Cite the package and every source used by the selected pathway:

- **FRTC:** Ayer (2026), Forest Research and Training Centre (2025), and IPCC
  (2006) when the default carbon fraction is used.
- **Sharma & Pukkala:** Ayer (2026), Sharma and Pukkala (1990), Government of
  Nepal (2022) for the regulatory context, and IPCC (2006) when the default
  carbon fraction is used.
- **Chave:** Ayer (2026), Chave et al. (2014), FRTC (2025) when an FRTC density
  is used, or both Fischer et al. (2026a, 2026b) when a GWDD density is used,
  and IPCC (2006) when the default carbon fraction is used.

The Excel `Read_Me` sheet includes the same references so exported analyses
remain traceable when shared independently of R.

## References

Ayer, S. (2026). *nepalallometry: Allometric estimation for Nepal's forest
trees* [R package]. https://github.com/ayersant-sys/nepalallometry

Chave, J., Rejou-Mechain, M., Burquez, A., Chidumayo, E., Colgan, M. S.,
Delitti, W. B. C., Duque, A., Eid, T., Fearnside, P. M., Goodman, R. C., Henry,
M., Martinez-Yrizar, A., Mugasha, W. A., Muller-Landau, H. C., Mencuccini, M.,
Nelson, B. W., Ngomanda, A., Nogueira, E. M., Ortiz-Malavassi, E., ...
Vieilledent, G. (2014). Improved allometric models to estimate the aboveground
biomass of tropical trees. *Global Change Biology, 20*(10), 3177-3190.
https://doi.org/10.1111/gcb.12629

Forest Research and Training Centre. (2025). *Allometric equations for seven
major tree species of Nepal* (Vol. I). Ministry of Forests and Environment,
Government of Nepal.

Fischer, F. J., Chave, J., Zanne, A., Jucker, T., Fajardo, A., Fayolle, A.,
Ferreira de Lima, R. A., Vieilledent, G., Beeckman, H., Hubau, W., De Mil, T.,
Wallenus, D., Aldana, A. M., Alvarez-Davila, E., Alves, L. F., Apgaua, D. M. G.,
Arcanjo, F., Bastin, J.-F., Bilous, A., ... Zieminska, K. (2026a). Beyond species
means: The intraspecific contribution to global wood density variation. *New
Phytologist, 249*(6), 2630-2651. https://doi.org/10.1111/nph.70860

Fischer, F. J., Chave, J., Zanne, A., Jucker, T., Fajardo, A., Fayolle, A.,
Ferreira de Lima, R. A., Vieilledent, G., Beeckman, H., Hubau, W., De Mil, T.,
Wallenus, D., Aldana, A. M., Alvarez-Davila, E., Alves, L. F., Apgaua, D. M. G.,
Arcanjo, F., Bastin, J.-F., Bilous, A., ... Zieminska, K. (2026b). *Global Wood
Density Database v2.2* [Data set]. Zenodo.
https://doi.org/10.5281/zenodo.18262736

Government of Nepal. (2022). *Forest Regulations, 2079*. Nepal Law Commission.
https://lawcommission.gov.np/content/12938/12938-forest-regulation-2079/

Intergovernmental Panel on Climate Change. (2006). *2006 IPCC guidelines for
national greenhouse gas inventories: Volume 4. Agriculture, forestry and other
land use* (H. S. Eggleston, L. Buendia, K. Miwa, T. Ngara, & K. Tanabe, Eds.).
Institute for Global Environmental Strategies.
https://www.ipcc-nggip.iges.or.jp/public/2006gl/vol4.html

Sharma, E. R., & Pukkala, T. (1990). *Volume equations and biomass prediction
of forest trees of Nepal* (Publication No. 47). Forest Survey and Statistics
Division, Ministry of Forests and Soil Conservation.

## Development status

This is a development release. Please report problems or suggestions through
the [GitHub issue tracker](https://github.com/ayersant-sys/nepalallometry/issues).
