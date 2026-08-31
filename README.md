# nepalallometry

`nepalallometry` is an R package under development for reproducible use of
Nepal's national tree allometric equations.

The current first step implements the FRTC (2025) species-specific **total
aboveground biomass** equations for seven major commercial tree species.
These estimates exclude the stump between ground level and 0.30 m, following
the biomass boundary used in the source report.

```r
frtc_total_biomass(
  dbh = 30,
  height = 20,
  species = "Shorea robusta",
  keep_inputs = TRUE
)
```

Inputs use DBH in cm and height in m. Outputs are kg/tree. FRTC-recommended
species-average or DBH-class density is applied internally where required.
The selected total-biomass models for *Castanopsis* spp. and *Pinus
roxburghii* do not use density.

Preferred species entries use lowercase scientific identifiers such as
`schima_wallichii`, or the corresponding Nepali name such as `chilaune`.
Trees without an FRTC model are retained with `NA` biomass and an
`unsupported_species` status; the package never silently substitutes another
equation.

For an inventory containing `tree_id`, `plot_id`, `plot_area_ha`, `species`,
`dbh_cm`, and `height_m`, use:

```r
trees <- estimate_frtc_biomass(inventory)
frtc_plot_summary(trees)
frtc_species_summary(trees)
frtc_dbh_summary(trees)
frtc_forest_summary(frtc_plot_summary(trees))
```

Plot summaries report FRTC-supported aboveground biomass and carbon (carbon
fraction 0.47) in Mg/ha. When unsupported trees occur, outputs are explicitly
marked as partial estimates and include stem-count and basal-area coverage.

The complete CSV workflow can be run with one command:

```r
results <- frtc_biomass_from_csv("forest_inventory.csv")
```

By default, one formatted Excel workbook is saved beside the inventory. It
contains About, Tree Results, Plot Summary, Species Summary, DBH Class Summary,
Forest Summary, Model Registry, and Density Rules worksheets. Use
`output_format = "csv"` for five CSV files or `output_format = "both"` for
both formats. Forest means are calculated from plot-level Mg/ha estimates and
explicitly report how many plots are complete or partial.

All model details are inspectable inside R:

```r
frtc_models()
frtc_equation("sal")
frtc_density()
frtc_density("sal", dbh = 30)
citation("nepalallometry")
```

The same equation and density registries are bundled as plain CSV files under
`inst/extdata`. The registry distinguishes model-fit RMSE (Table 9) from the
operational RMSE obtained with FRTC-recommended densities (Table 11).

## Source

Forest Research and Training Centre (FRTC). 2025. *Allometric Equations for
Seven Major Tree Species of Nepal, Volume I*. Nepal.
