# Estimate total aboveground biomass using FRTC 2025 models

Estimates biomass above the FRTC felling height of 0.30 m. Consequently,
the result excludes stump biomass between ground level and 0.30 m.

## Usage

``` r
frtc_total_biomass(dbh, height, species, keep_inputs = FALSE)
```

## Arguments

- dbh:

  Diameter at breast height in centimetres. Must be positive.

- height:

  Total tree height in metres. Must be positive.

- species:

  Species code, scientific name, or supported Nepali common name. Run
  \[frtc_species()\] for the canonical list.

- keep_inputs:

  If \`TRUE\`, return a data frame containing inputs, normalized
  species, density provenance, calibration limits and status, and
  biomass. If \`FALSE\`, return only the biomass vector.

## Value

Biomass in kg/tree, excluding the 0-30 cm stump. A numeric vector when
\`keep_inputs = FALSE\`; otherwise a data frame containing observed
calibration limits, \`within_calibration_range\`, and
\`calibration_status\`.

## References

Forest Research and Training Centre. (2025). \*Allometric equations for
seven major tree species of Nepal\* (Vol. I). Ministry of Forests and
Environment, Government of Nepal.

## Examples

``` r
frtc_total_biomass(30, 20, "Shorea robusta")
#> [1] 462.3655
frtc_total_biomass(c(20, 30), c(15, 20), c("An", "Pr"))
#> [1] 123.8727 414.2901
```
