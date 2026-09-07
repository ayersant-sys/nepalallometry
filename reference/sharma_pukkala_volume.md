# Estimate tree volume using Sharma-Pukkala and Forest Regulations

Estimates stem volume using the species-specific equations of Sharma and
Pukkala (1990). Stem volume is calculated in dm3 by the original
equation and divided by 1000 to obtain m3.

## Usage

``` r
sharma_pukkala_volume(
  dbh,
  height,
  species,
  branch_group = NULL,
  has_branches = TRUE,
  keep_inputs = FALSE
)
```

## Arguments

- dbh:

  Diameter at breast height in centimetres.

- height:

  Total tree height in metres.

- species:

  Supported Sharma-Pukkala species name or alias.

- branch_group:

  Optional branch category for species without a species-specific Forest
  Regulation branch equation. Accepted values are \`"other_conifer"\`
  and \`"other_broadleaf"\`. The package does not automatically classify
  an unlisted species as conifer or broadleaf.

- has_branches:

  Logical. Whether the tree has branches. Defaults to TRUE. If FALSE,
  branch volume is zero and total tree volume equals stem volume.

- keep_inputs:

  If TRUE, returns detailed calculation components. If FALSE, returns
  total tree volume in m3/tree.

## Value

Total tree volume in m3/tree, or a data frame when \`keep_inputs =
TRUE\`.

## Details

Branch volume is estimated using the species- and DBH-dependent
branch-volume ratios prescribed in Schedule 9 of Nepal's Forest
Regulations 2079.

Total tree volume is:

total tree volume = stem volume + branch volume

## References

Sharma, E. R., and Pukkala, T. (1990). Volume equations and biomass
prediction of forest trees of Nepal. Publication No. 47. Forest Survey
and Statistics Division, Ministry of Forests and Soil Conservation,
Kathmandu, Nepal.

Government of Nepal. Forest Regulations, 2079. Schedule 9.

## Examples

``` r
sharma_pukkala_volume(
  dbh = 60,
  height = 25,
  species = "sal"
)
#> [1] 4.122617

sharma_pukkala_volume(
  dbh = 60,
  height = 25,
  species = "sal",
  keep_inputs = TRUE
)
#>   dbh_cm height_m species_input species_standardized scientific_name
#> 1     60       25           sal       shorea_robusta  Shorea robusta
#>   nepali_name coefficient_a coefficient_b coefficient_c stem_volume_m3
#> 1         sal       -2.4554        1.9026        0.8352       3.050025
#>   has_branches   branch_group branch_s branch_m branch_b branch_ratio
#> 1         TRUE shorea_robusta    0.055    0.341    0.357    0.3516667
#>   branch_volume_m3 total_tree_volume_m3 calibration_dbh_min_cm
#> 1         1.072592             4.122617                   12.7
#>   calibration_dbh_max_cm within_calibration_dbh_range        calibration_status
#> 1                  144.5                         TRUE within_observed_dbh_range
#>   height_calibration_status estimation_status        stem_volume_source
#> 1 not_assessed_not_reported         estimated Sharma and Pukkala (1990)
#>                        branch_volume_source stem_volume_unit branch_volume_unit
#> 1 Nepal Forest Regulations 2079, Schedule 9          m3/tree            m3/tree
#>   total_volume_unit
#> 1           m3/tree
```
