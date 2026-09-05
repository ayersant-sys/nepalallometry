# Estimate tree and inventory volume

Applies supported tree-volume methods to a forest inventory and returns
tree-, plot-, species-, DBH-class-, and forest-level summaries. The
current implementation supports the Sharma-Pukkala stem-volume equations
combined with branch-volume ratios from Schedule 9 of Nepal's Forest
Regulations 2079.

## Usage

``` r
volume(
  input,
  output = NULL,
  sheet = 1,
  methods = "sharma_pukkala",
  dbh_breaks = c(0, 10, 20, 30, 40, 50, Inf)
)
```

## Arguments

- input:

  A data frame or path to an existing `.csv` or `.xlsx` inventory.

- output:

  Optional `.xlsx` path for exporting results.

- sheet:

  Worksheet to read when `input` is an `.xlsx` file. Defaults to 1.

- methods:

  Volume method(s). Currently only `"sharma_pukkala"` is supported.

- dbh_breaks:

  Breaks used for DBH-class summaries.

## Value

An object of class `nepal_volume_result` containing `forest_summary`,
`plot_summary`, `species_summary`, `dbh_class_summary`, `tree_results`,
and `method_audit`.

## Details

Required inventory columns are `tree_id`, `plot_id`, `plot_area_ha`,
`species`, `dbh_cm`, and `height_m`. Optional columns are `forest_id`,
`forest_area_ha`, and `branch_group`.

For species with a species-specific branch-volume row in the Forest
Regulations, `branch_group` may be left blank. For other supported
Sharma-Pukkala species, users must explicitly enter `other_broadleaf` or
`other_conifer` where appropriate. The package does not infer this
category.

## Examples

``` r
inventory <- data.frame(
  tree_id = c("T1", "T2"),
  plot_id = c("P1", "P1"),
  plot_area_ha = c(0.05, 0.05),
  species = c("sal", "terminalia_alata"),
  dbh_cm = c(60, 45),
  height_m = c(25, 22),
  branch_group = c(NA, "other_broadleaf")
)
volume(inventory)
#> $forest_summary
#>   forest_id forest_area_ha                               method total_plots
#> 1  Forest_1             NA Sharma & Pukkala + Forest Regulation           1
#>   plots_with_estimates total_trees estimated_trees tree_coverage_pct
#> 1                    1           2               2               100
#>   basal_area_coverage_pct mean_volume_m3_ha sd_volume_m3_ha se_volume_m3_ha
#> 1                     100          128.1553              NA              NA
#>   ci95_lower_volume_m3_ha ci95_upper_volume_m3_ha total_forest_volume_m3
#> 1                      NA                      NA                     NA
#>   plot_area_design uncertainty_status         summary_status
#> 1  equal_plot_area insufficient_plots complete_tree_coverage
#> 
#> $dbh_class_summary
#>   forest_id dbh_class_cm                               method total_trees
#> 1  Forest_1     [50,Inf] Sharma & Pukkala + Forest Regulation           1
#> 2  Forest_1      [40,50) Sharma & Pukkala + Forest Regulation           1
#>   estimated_trees tree_coverage_pct mean_tree_volume_m3 mean_plot_volume_m3_ha
#> 1               1               100            4.122617               82.45234
#> 2               1               100            2.285146               45.70293
#>   se_plot_volume_m3_ha ci95_lower_plot_volume_m3_ha
#> 1                   NA                           NA
#> 2                   NA                           NA
#>   ci95_upper_plot_volume_m3_ha uncertainty_status
#> 1                           NA insufficient_plots
#> 2                           NA insufficient_plots
#> 
#> $species_summary
#>   forest_id          species                               method total_trees
#> 1  Forest_1              sal Sharma & Pukkala + Forest Regulation           1
#> 2  Forest_1 terminalia_alata Sharma & Pukkala + Forest Regulation           1
#>   estimated_trees tree_coverage_pct mean_tree_volume_m3 mean_plot_volume_m3_ha
#> 1               1               100            4.122617               82.45234
#> 2               1               100            2.285146               45.70293
#>   se_plot_volume_m3_ha ci95_lower_plot_volume_m3_ha
#> 1                   NA                           NA
#> 2                   NA                           NA
#>   ci95_upper_plot_volume_m3_ha uncertainty_status
#> 1                           NA insufficient_plots
#> 2                           NA insufficient_plots
#> 
#> $plot_summary
#>   forest_id plot_id plot_area_ha                               method
#> 1  Forest_1      P1         0.05 Sharma & Pukkala + Forest Regulation
#>   total_trees estimated_trees unestimated_trees extrapolated_trees
#> 1           2               2                 0                  0
#>   tree_coverage_pct basal_area_coverage_pct volume_m3_ha        coverage_status
#> 1               100                     100     128.1553 complete_tree_coverage
#> 
#> $tree_results
#>   tree_id plot_id plot_area_ha          species dbh_cm height_m    branch_group
#> 1      T1      P1         0.05              sal     60       25            <NA>
#> 2      T2      P1         0.05 terminalia_alata     45       22 other_broadleaf
#>   forest_id forest_area_ha basal_area_m2 sharma_pukkala_stem_volume_m3
#> 1  Forest_1             NA     0.2827433                      3.050025
#> 2  Forest_1             NA     0.1590431                      1.479857
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
#>                                 method        stem_volume_source
#> 1 Sharma & Pukkala + Forest Regulation Sharma and Pukkala (1990)
#>                        branch_volume_source total_trees estimated_trees
#> 1 Nepal Forest Regulations 2079, Schedule 9           2               2
#>   branch_group_required unsupported_species
#> 1                     0                   0
#> 
#> attr(,"class")
#> [1] "nepal_volume_result"
#> attr(,"input_source")
#> [1] "R data frame"
#> attr(,"methods")
#> [1] "sharma_pukkala"
#> attr(,"analysis_level")
#> [1] "inventory"
```
