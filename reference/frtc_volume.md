# Estimate FRTC 2025 stem volumes

Implements the selected species-specific stem-volume equations reported
by FRTC (2025) for seven major tree species of Nepal.

## Usage

``` r
frtc_volume(dbh, height, species, keep_inputs = FALSE)
```

## Arguments

- dbh:

  Diameter at breast height in cm.

- height:

  Total tree height in m.

- species:

  Species name, code, or accepted alias for one of the seven FRTC
  species.

- keep_inputs:

  Logical; if `TRUE`, retain inputs, status fields, calibration
  information, and volume-boundary notes.

## Value

A data frame containing FRTC total stem volume over bark, under-bark
stem volume to a 20-cm over-bark top diameter, and under-bark stem
volume to a 10-cm over-bark top diameter, all in m3/tree.

## Details

FRTC volume outputs are stem volumes only. Branches are not included.
The 30-cm stump is excluded. Total volume therefore means total stem
volume over bark, not total tree volume including branches.

The 20-cm and 10-cm top-volume outputs are under-bark stem volumes to
the specified over-bark top diameter. The package does not calculate a
20-cm-top volume when DBH is below 20 cm, or a 10-cm-top volume when DBH
is below 10 cm.

## Examples

``` r
frtc_volume(
  dbh = c(60, 45),
  height = c(25, 22),
  species = c("sal", "pinus_roxburghii"),
  keep_inputs = TRUE
)
#>            species species_code dbh_cm height_m frtc_total_volume_m3
#> 1              sal           Sr     60       25             2.952055
#> 2 pinus_roxburghii           Pr     45       22             1.635950
#>   frtc_volume_ub_20cm_m3 frtc_volume_ub_10cm_m3 top20_status top10_status
#> 1               2.289756               2.274572    estimated    estimated
#> 2               1.147634               1.238026    estimated    estimated
#>   estimation_status calibration_dbh_min_cm calibration_dbh_max_cm
#> 1         estimated                    6.7                  102.4
#> 2         estimated                    6.7                   91.2
#>   calibration_height_min_m calibration_height_max_m within_calibration_range
#> 1                      4.9                     42.0                     TRUE
#> 2                      2.5                     36.4                     TRUE
#>      calibration_status volume_source
#> 1 within_observed_range   FRTC (2025)
#> 2 within_observed_range   FRTC (2025)
#>                                      volume_boundary
#> 1 Stem only; 30-cm stump excluded; branches excluded
#> 2 Stem only; 30-cm stump excluded; branches excluded
```
