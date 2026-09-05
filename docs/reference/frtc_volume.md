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
#> Error in frtc_volume(dbh = c(60, 45), height = c(25, 22), species = c("sal",     "pinus_roxburghii"), keep_inputs = TRUE): could not find function "frtc_volume"
```
