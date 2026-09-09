# Estimate individual-tree or forest-inventory volume

Calculates tree volume using Sharma-Pukkala stem-volume equations
combined with Forest Regulation branch-volume ratios and/or FRTC (2025)
stem-volume equations. The function automatically distinguishes
individual-tree inputs from forest inventories according to whether both
`plot_id` and `plot_area_ha` are supplied.

## Usage

``` r
volume(
  input,
  output = NULL,
  sheet = 1,
  methods = c("sharma_pukkala", "frtc"),
  dbh_breaks = c(0, 10, 20, 30, 40, 50, Inf)
)
```

## Arguments

- input:

  A data frame or path to an existing `.csv` or `.xlsx` file.

- output:

  Optional `.xlsx` path for exporting results. For file inputs, an
  output workbook is created automatically when this is omitted.

- sheet:

  Worksheet to read when `input` is an `.xlsx` file. Defaults to 1.

- methods:

  One or both supported volume methods: `"sharma_pukkala"` and `"frtc"`.
  By default both are calculated.

- dbh_breaks:

  Breaks used for DBH-class summaries when plot information is supplied.

## Value

An object of class `nepal_volume_result`. Individual-tree inputs contain
`tree_results` and `method_audit`. Forest-inventory inputs additionally
contain `forest_summary`, `plot_summary`, `species_summary`, and
`dbh_class_summary`.

## Details

The minimum columns for individual-tree volume estimation are `tree_id`,
`species`, `dbh_cm`, and `height_m`. For forest-inventory summaries,
both `plot_id` and `plot_area_ha` must also be supplied. Optional
columns include `forest_id`, `forest_area_ha`, and `branch_group`.

For Sharma-Pukkala + Forest Regulation, total volume is stem volume plus
branch volume. For species requiring a generic Forest Regulation branch
category, the user must explicitly enter `other_broadleaf` or
`other_conifer`; the package does not infer this category.

For FRTC (2025), the package returns total stem volume over bark,
under-bark stem volume to a 20-cm over-bark top diameter, and under-bark
stem volume to a 10-cm over-bark top diameter. FRTC volume outputs
exclude the 30-cm stump and exclude branches. Thus, the displayed FRTC
total volume is total stem volume, not total tree volume including
branches.

## Examples

``` r
trees <- data.frame(
  tree_id = c("T1", "T2"),
  species = c("sal", "terminalia_alata"),
  dbh_cm = c(60, 45),
  height_m = c(25, 22),
  branch_group = c(NA, "other_broadleaf")
)
volume(trees)
#> $forest_summary
#> NULL
#> 
#> $dbh_class_summary
#> NULL
#> 
#> $species_summary
#> NULL
#> 
#> $plot_summary
#> NULL
#> 
#> $tree_results
#>   tree_id          species dbh_cm height_m    branch_group basal_area_m2
#> 1      T1              sal     60       25            <NA>     0.2827433
#> 2      T2 terminalia_alata     45       22 other_broadleaf     0.1590431
#>   frtc_total_volume_m3 frtc_volume_ub_20cm_m3 frtc_volume_ub_10cm_m3
#> 1             2.952055              2.2897561               2.274572
#> 2             1.448508              0.9849217               1.079244
#>   frtc_estimation_status frtc_top20_status frtc_top10_status
#> 1              estimated         estimated         estimated
#> 2              estimated         estimated         estimated
#>   frtc_calibration_status sharma_pukkala_stem_volume_m3
#> 1   within_observed_range                      3.050025
#> 2   within_observed_range                      1.479857
#>   sharma_pukkala_branch_volume_m3 sharma_pukkala_total_tree_volume_m3
#> 1                        1.072592                            4.122617
#> 2                        0.805289                            2.285146
#>   sharma_pukkala_branch_group_used sharma_pukkala_estimation_status
#> 1                   shorea_robusta                        estimated
#> 2                  other_broadleaf                        estimated
#>   sharma_pukkala_calibration_status
#> 1         within_observed_dbh_range
#> 2         within_observed_dbh_range
#> 
#> $method_audit
#>                                 method volume_type
#> 1                                 FRTC    total_ob
#> 2                                 FRTC     ub_20cm
#> 3                                 FRTC     ub_10cm
#> 4 Sharma & Pukkala + Forest Regulation  total_tree
#>                                        volume_definition
#> 1                            Total over-bark stem volume
#> 2 Under-bark stem volume to 20-cm over-bark top diameter
#> 3 Under-bark stem volume to 10-cm over-bark top diameter
#> 4    Total tree volume (stem + regulatory branch volume)
#>                           stem_volume_source
#> 1 Forest Research and Training Centre (2025)
#> 2 Forest Research and Training Centre (2025)
#> 3 Forest Research and Training Centre (2025)
#> 4                  Sharma and Pukkala (1990)
#>                        branch_volume_source total_trees estimated_trees
#> 1                                      <NA>           2               2
#> 2                                      <NA>           2               2
#> 3                                      <NA>           2               2
#> 4 Nepal Forest Regulations 2079, Schedule 9           2               2
#>   branch_group_required unsupported_species
#> 1                     0                   0
#> 2                     0                   0
#> 3                     0                   0
#> 4                     0                   0
#> 
#> attr(,"class")
#> [1] "nepal_volume_result"
#> attr(,"input_source")
#> [1] "R data frame"
#> attr(,"methods")
#> [1] "frtc"           "sharma_pukkala"
#> attr(,"analysis_level")
#> [1] "tree"
volume(trees, methods = "frtc")
#> $forest_summary
#> NULL
#> 
#> $dbh_class_summary
#> NULL
#> 
#> $species_summary
#> NULL
#> 
#> $plot_summary
#> NULL
#> 
#> $tree_results
#>   tree_id          species dbh_cm height_m    branch_group basal_area_m2
#> 1      T1              sal     60       25            <NA>     0.2827433
#> 2      T2 terminalia_alata     45       22 other_broadleaf     0.1590431
#>   frtc_total_volume_m3 frtc_volume_ub_20cm_m3 frtc_volume_ub_10cm_m3
#> 1             2.952055              2.2897561               2.274572
#> 2             1.448508              0.9849217               1.079244
#>   frtc_estimation_status frtc_top20_status frtc_top10_status
#> 1              estimated         estimated         estimated
#> 2              estimated         estimated         estimated
#>   frtc_calibration_status
#> 1   within_observed_range
#> 2   within_observed_range
#> 
#> $method_audit
#>   method volume_type                                      volume_definition
#> 1   FRTC    total_ob                            Total over-bark stem volume
#> 2   FRTC     ub_20cm Under-bark stem volume to 20-cm over-bark top diameter
#> 3   FRTC     ub_10cm Under-bark stem volume to 10-cm over-bark top diameter
#>                           stem_volume_source branch_volume_source total_trees
#> 1 Forest Research and Training Centre (2025)                 <NA>           2
#> 2 Forest Research and Training Centre (2025)                 <NA>           2
#> 3 Forest Research and Training Centre (2025)                 <NA>           2
#>   estimated_trees branch_group_required unsupported_species
#> 1               2                     0                   0
#> 2               2                     0                   0
#> 3               2                     0                   0
#> 
#> attr(,"class")
#> [1] "nepal_volume_result"
#> attr(,"input_source")
#> [1] "R data frame"
#> attr(,"methods")
#> [1] "frtc"
#> attr(,"analysis_level")
#> [1] "tree"
```
