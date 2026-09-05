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
#>   sharma_pukkala_stem_volume_m3 sharma_pukkala_branch_volume_m3
#> 1                      3.050025                        1.072592
#> 2                      1.479857                        0.805289
#>   sharma_pukkala_total_tree_volume_m3 sharma_pukkala_branch_group_used
#> 1                            4.122617                   shorea_robusta
#> 2                            2.285146                  other_broadleaf
#>   sharma_pukkala_estimation_status sharma_pukkala_calibration_status
#> 1                        estimated         within_observed_dbh_range
#> 2                        estimated         within_observed_dbh_range
#>   frtc_total_volume_m3 frtc_volume_ub_20cm_m3 frtc_volume_ub_10cm_m3
#> 1             2.952055              2.2897561               2.274572
#> 2             1.448508              0.9849217               1.079244
#>   frtc_top20_status frtc_top10_status frtc_estimation_status
#> 1         estimated         estimated              estimated
#> 2         estimated         estimated              estimated
#>   frtc_calibration_status
#> 1   within_observed_range
#> 2   within_observed_range
#> 
#> $method_audit
#>                                 method
#> 1 Sharma & Pukkala + Forest Regulation
#> 2                            FRTC 2025
#>                          total_volume_definition
#> 1                 Stem volume plus branch volume
#> 2 Total stem volume over bark; branches excluded
#>                                                           stem_volume_source
#> 1                                                  Sharma and Pukkala (1990)
#> 2 FRTC (2025), Allometric Equations of Major Tree Species of Nepal, Volume I
#>                                  branch_volume_source
#> 1           Nepal Forest Regulations 2079, Schedule 9
#> 2 Not applicable; FRTC volume equations are stem-only
#>                                                      stump_boundary total_trees
#> 1 As defined by the underlying Sharma-Pukkala stem-volume equations           2
#> 2                                              30-cm stump excluded           2
#>   estimated_trees branch_group_required unsupported_species
#> 1               2                     0                   0
#> 2               2                     0                   0
#> 
#> attr(,"class")
#> [1] "nepal_volume_result"
#> attr(,"input_source")
#> [1] "R data frame"
#> attr(,"methods")
#> [1] "sharma_pukkala" "frtc"          
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
#>   frtc_top20_status frtc_top10_status frtc_estimation_status
#> 1         estimated         estimated              estimated
#> 2         estimated         estimated              estimated
#>   frtc_calibration_status
#> 1   within_observed_range
#> 2   within_observed_range
#> 
#> $method_audit
#>      method                        total_volume_definition
#> 1 FRTC 2025 Total stem volume over bark; branches excluded
#>                                                           stem_volume_source
#> 1 FRTC (2025), Allometric Equations of Major Tree Species of Nepal, Volume I
#>                                  branch_volume_source       stump_boundary
#> 1 Not applicable; FRTC volume equations are stem-only 30-cm stump excluded
#>   total_trees estimated_trees branch_group_required unsupported_species
#> 1           2               2                     0                   0
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
