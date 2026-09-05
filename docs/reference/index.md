# Package index

## Complete inventory workflow

Estimate biomass and extract auditable summaries.

- [`biomass()`](https://ayersant-sys.github.io/nepalallometry/reference/biomass.md)
  : Estimate biomass and produce complete inventory summaries
- [`forest_summary()`](https://ayersant-sys.github.io/nepalallometry/reference/forest_summary.md)
  [`plot_summary()`](https://ayersant-sys.github.io/nepalallometry/reference/forest_summary.md)
  [`species_summary()`](https://ayersant-sys.github.io/nepalallometry/reference/forest_summary.md)
  [`dbh_summary()`](https://ayersant-sys.github.io/nepalallometry/reference/forest_summary.md)
  [`tree_results()`](https://ayersant-sys.github.io/nepalallometry/reference/forest_summary.md)
  [`method_audit()`](https://ayersant-sys.github.io/nepalallometry/reference/forest_summary.md)
  : Extract biomass result tables

## Biomass pathways

Run individual published biomass methods.

- [`frtc_total_biomass()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_total_biomass.md)
  : Estimate total aboveground biomass using FRTC 2025 models
- [`sharma_pukkala_biomass()`](https://ayersant-sys.github.io/nepalallometry/reference/sharma_pukkala_biomass.md)
  : Estimate biomass using Sharma and Pukkala (1990)
- [`chave_biomass()`](https://ayersant-sys.github.io/nepalallometry/reference/chave_biomass.md)
  : Estimate aboveground biomass using Chave et al. (2014)

## Volume estimation

Estimate individual-tree or forest-inventory volume using supported
pathways.

- [`volume()`](https://ayersant-sys.github.io/nepalallometry/reference/volume.md)
  : Estimate individual-tree or forest-inventory volume
- [`frtc_volume()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_volume.md)
  : Estimate FRTC 2025 stem volumes
- [`sharma_pukkala_volume()`](https://ayersant-sys.github.io/nepalallometry/reference/sharma_pukkala_volume.md)
  : Estimate tree volume using Sharma-Pukkala and Forest Regulations
- [`forest_regulation_branch_parameters()`](https://ayersant-sys.github.io/nepalallometry/reference/forest_regulation_branch_parameters.md)
  : Forest Regulation branch-volume parameters

## Models, species, and sources

Inspect supported taxa, equations, density rules, and references.

- [`frtc_species()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_species.md)
  : Species supported by the FRTC 2025 equations
- [`frtc_models()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_models.md)
  : Inspect the FRTC 2025 total-biomass model registry
- [`frtc_equation()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_equation.md)
  : Display one FRTC total-biomass equation
- [`frtc_density()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_density.md)
  : Inspect FRTC-recommended densities for total biomass
- [`sharma_pukkala_species()`](https://ayersant-sys.github.io/nepalallometry/reference/sharma_pukkala_species.md)
  : List Sharma-Pukkala biomass species and parameters
- [`allometry_references()`](https://ayersant-sys.github.io/nepalallometry/reference/allometry_references.md)
  : Inspect sources used by nepalallometry

## FRTC compatibility workflow

Earlier FRTC-specific estimators and export functions.

- [`estimate_frtc_biomass()`](https://ayersant-sys.github.io/nepalallometry/reference/estimate_frtc_biomass.md)
  : Estimate FRTC biomass and carbon for an inventory data frame
- [`frtc_plot_summary()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_plot_summary.md)
  : Summarize FRTC-supported biomass and carbon by plot
- [`frtc_species_summary()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_species_summary.md)
  : Summarize FRTC-supported biomass and carbon by plot and species
- [`frtc_dbh_summary()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_dbh_summary.md)
  : Summarize FRTC-supported biomass and carbon by plot and DBH class
- [`frtc_forest_summary()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_forest_summary.md)
  : Summarize biomass and carbon across inventory plots
- [`frtc_inventory_template()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_inventory_template.md)
  : Create a simple FRTC inventory CSV template
- [`frtc_biomass_from_csv()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_biomass_from_csv.md)
  : Run the FRTC biomass workflow from a CSV file
- [`biomass_from_csv()`](https://ayersant-sys.github.io/nepalallometry/reference/biomass_from_csv.md)
  : Compatibility wrapper for CSV biomass inventories
