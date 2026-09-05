# Changelog

## nepalallometry 1.1.0

### Tree-volume estimation

- Added
  [`volume()`](https://ayersant-sys.github.io/nepalallometry/reference/volume.md)
  as the high-level workflow for individual-tree and inventory-level
  volume estimation.
- Added
  [`frtc_volume()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_volume.md)
  implementing the published FRTC (2025) equations for total stem volume
  over bark, stem volume under bark to a 20-cm over-bark top diameter,
  and stem volume under bark to a 10-cm over-bark top diameter.
- Added
  [`sharma_pukkala_volume()`](https://ayersant-sys.github.io/nepalallometry/reference/sharma_pukkala_volume.md)
  implementing Sharma and Pukkala (1990) stem-volume equations. Where
  branch volume is required, branch volume is derived using the
  applicable branch-to-stem volume ratios specified in Schedule 9 of
  Nepal’s Forest Regulations 2079.
- Added
  [`forest_regulation_branch_parameters()`](https://ayersant-sys.github.io/nepalallometry/reference/forest_regulation_branch_parameters.md)
  for inspecting the regulatory branch-volume parameters.
- Added tree-only and inventory-level volume workflows, Excel output,
  method auditing, coverage information, and calibration/status
  reporting.
- Added automated tests covering the published FRTC volume coefficients
  and combined volume workflows.
- Expanded the package website and documentation to cover biomass,
  carbon, and tree-volume estimation.

### Important volume definitions

- FRTC total volume is total **stem volume over bark** from the 30-cm
  stump height to the tip; branches and the lower stump are excluded.
- Sharma-Pukkala stem volume and Forest Regulation branch ratios retain
  their distinct source roles. Total tree volume under this workflow is
  the Sharma-Pukkala stem-volume estimate plus branch volume derived
  from the applicable regulatory ratio.
- Method-specific component boundaries are retained and are not silently
  harmonized.

## nepalallometry 1.0.0

- First stable release focused on aboveground biomass and carbon
  estimation for Nepal.
