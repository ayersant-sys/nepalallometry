# Estimate FRTC biomass and carbon for an inventory data frame

Estimate FRTC biomass and carbon for an inventory data frame

## Usage

``` r
estimate_frtc_biomass(data)
```

## Arguments

- data:

  A data frame containing \`tree_id\`, \`plot_id\`, \`plot_area_ha\`,
  \`species\`, \`dbh_cm\`, and \`height_m\`.

## Value

The original rows with FRTC model metadata, biomass, carbon, basal area,
estimation status, observed calibration limits, and extrapolation status
appended.

## References

Forest Research and Training Centre. (2025). \*Allometric equations for
seven major tree species of Nepal\* (Vol. I). Ministry of Forests and
Environment, Government of Nepal.

Intergovernmental Panel on Climate Change. (2006). \*2006 IPCC
guidelines for national greenhouse gas inventories: Volume 4.
Agriculture, forestry and other land use\*. IGES.
