# nepalallometry 1.2.2.9000

## Development version

- Improved volume Excel workbooks with reader-friendly column headings, explicit units, wrapped headers, sensible widths, and consistent number formatting.

# nepalallometry 1.2.1

## Volume workflow fixes

- Allow `tree_id` values to repeat across different plots.
- Fix FRTC 2025 stem-volume results and combined-method summaries.
- Preserve separate FRTC volume definitions.
- Warn users when a Sharma–Pukkala tree needs `branch_group`.
- Require `other_broadleaf` or `other_conifer` only when no direct regulatory branch parameter is available.

# nepalallometry 1.2.0

## Graphical interface

- Added `run_gui()` to launch an optional Shiny interface for biomass, carbon, and tree-volume workflows without requiring users to write R code.
- Added CSV/XLSX upload, method selection, result previews, auditable output tables, downloadable Excel workbooks, and a reproducible **View R code** panel.
- Added clearer GUI table labels while preserving the underlying package object names and exported data structure.

## Website and technical documentation

- Added a dedicated **Methods & Equations** page documenting implemented equations, coefficients, wood-density rules, units, biomass/volume boundaries, and source attribution.
- Added a dedicated **Help & Troubleshooting** page covering required columns, method-specific inputs, unsupported species, missing values, and common calculation errors.
- Documented the FRTC biomass and volume model registries, FRTC density rules, Sharma-Pukkala coefficients and species-specific component ratios, Chave et al. (2014) density provenance, Forest Regulations 2079 branch-volume parameters, carbon conversion, and plot/forest summary equations.
- Clarified that Sharma-Pukkala stem volume is converted from dm3 to m3 by dividing by 1000.
- Clarified that Sharma-Pukkala branch and foliage biomass ratios are species/species-group specific and DBH-dependent.
- Added source attribution alongside equations and parameter tables so users can identify the original source of each implemented calculation.

## Volume workflow integration

- Integrated FRTC 2025 and Sharma-Pukkala + Forest Regulations pathways into the high-level `volume()` workflow.
- Preserved method-specific `volume_type` and `volume_definition` fields so biologically different volume definitions are not combined or averaged.
- Improved GUI handling and documentation of method-specific requirements such as `branch_group`.

# nepalallometry 1.1.0

## Tree-volume estimation

- Added `volume()` as the high-level workflow for individual-tree and inventory-level volume estimation.
- Added `frtc_volume()` implementing the published FRTC (2025) equations for total stem volume over bark, stem volume under bark to a 20-cm over-bark top diameter, and stem volume under bark to a 10-cm over-bark top diameter.
- Added `sharma_pukkala_volume()` implementing Sharma and Pukkala (1990) stem-volume equations. Where branch volume is required, branch volume is derived using the applicable branch-to-stem volume ratios specified in Schedule 9 of Nepal's Forest Regulations 2079.
- Added `forest_regulation_branch_parameters()` for inspecting the regulatory branch-volume parameters.
- Added tree-only and inventory-level volume workflows, Excel output, method auditing, coverage information, and calibration/status reporting.
- Added automated tests covering the published FRTC volume coefficients and combined volume workflows.
- Expanded the package website and documentation to cover biomass, carbon, and tree-volume estimation.

## Important volume definitions

- FRTC total volume is total **stem volume over bark** from the 30-cm stump height to the tip; branches and the lower stump are excluded.
- Sharma-Pukkala stem volume and Forest Regulation branch ratios retain their distinct source roles. Total tree volume under this workflow is the Sharma-Pukkala stem-volume estimate plus branch volume derived from the applicable regulatory ratio.
- Method-specific component boundaries are retained and are not silently harmonized.

# nepalallometry 1.0.0

- First stable release focused on aboveground biomass and carbon estimation for Nepal.
