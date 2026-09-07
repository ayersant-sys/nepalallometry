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
#> Error in sharma_pukkala_volume(dbh = 60, height = 25, species = "sal"): could not find function "sharma_pukkala_volume"

sharma_pukkala_volume(
  dbh = 60,
  height = 25,
  species = "sal",
  keep_inputs = TRUE
)
#> Error in sharma_pukkala_volume(dbh = 60, height = 25, species = "sal",     keep_inputs = TRUE): could not find function "sharma_pukkala_volume"
```
