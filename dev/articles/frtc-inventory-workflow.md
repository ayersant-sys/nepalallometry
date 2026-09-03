# Estimating FRTC Biomass and Carbon from a Forest Inventory

## Purpose

This vignette demonstrates the complete `nepalallometry` workflow:
preparing tree inventory data, estimating FRTC-supported biomass and
carbon, summarizing results, handling unsupported species, and exporting
one Excel workbook.

The implemented response is total aboveground biomass **above 0.30 m**.
The 0-0.30 m stump is excluded.

## 1. Check supported species

``` r

frtc_species()
#>                 species_id nepali_name species_code          scientific_name
#> 1         alnus_nepalensis        utis           An         Alnus nepalensis
#> 2          castanopsis_spp       katus           Cs         Castanopsis spp.
#> 3 lagerstroemia_parviflora  botdhayero           Lp Lagerstroemia parviflora
#> 4         pinus_roxburghii  khotesallo           Pr         Pinus roxburghii
#> 5           shorea_robusta         sal           Sr           Shorea robusta
#> 6         schima_wallichii    chilaune           Sw         Schima wallichii
#> 7         terminalia_alata        asna           Ta         Terminalia alata
```

Use the standardized lowercase identifier (for example,
`schima_wallichii`) or the supported Nepali name (for example,
`chilaune`). An unsupported species remains in the output but receives
`NA` biomass.

## 2. Prepare inventory data

Each row represents one tree. The following columns are required:

- `tree_id`: unique tree identifier;
- `plot_id`: plot identifier;
- `plot_area_ha`: sampled plot area in hectares;
- `species`: standardized scientific identifier or supported Nepali
  name;
- `dbh_cm`: diameter at breast height in centimetres;
- `height_m`: total tree height in metres.

``` r

inventory <- data.frame(
  tree_id = 1:4,
  plot_id = c("p01", "p01", "p02", "p02"),
  plot_area_ha = c(0.05, 0.05, 0.10, 0.10),
  species = c("sal", "chilaune", "pinus_roxburghii", "acacia_catechu"),
  dbh_cm = c(30, 25, 30, 20),
  height_m = c(20, 18, 20, 15)
)

inventory
#>   tree_id plot_id plot_area_ha          species dbh_cm height_m
#> 1       1     p01         0.05              sal     30       20
#> 2       2     p01         0.05         chilaune     25       18
#> 3       3     p02         0.10 pinus_roxburghii     30       20
#> 4       4     p02         0.10   acacia_catechu     20       15
```

Plot area must be positive and constant within each plot. Tree
identifiers must be present and unique.

## 3. Estimate tree biomass and carbon

``` r

tree_results <- estimate_frtc_biomass(inventory)
#> Warning: FRTC total-biomass models are unavailable for 1 tree(s). Unsupported
#> species: acacia_catechu. Biomass was returned as NA for these trees.
tree_results
#>   tree_id plot_id plot_area_ha          species dbh_cm height_m
#> 1       1     p01         0.05              sal     30       20
#> 2       2     p01         0.05         chilaune     25       18
#> 3       3     p02         0.10 pinus_roxburghii     30       20
#> 4       4     p02         0.10   acacia_catechu     20       15
#>   species_standardized  scientific_name wood_density_g_cm3       density_source
#> 1       shorea_robusta   Shorea robusta             0.5573       frtc_dbh_class
#> 2     schima_wallichii Schima wallichii             0.4869 frtc_species_average
#> 3     pinus_roxburghii Pinus roxburghii                 NA         not_required
#> 4                 <NA>             <NA>                 NA        not_available
#>   frtc_total_biomass_kg carbon_fraction frtc_carbon_kg basal_area_m2
#> 1              462.3655            0.47       217.3118    0.07068583
#> 2              256.5608            0.47       120.5836    0.04908739
#> 3              414.2901            0.47       194.7164    0.07068583
#> 4                    NA            0.47             NA    0.03141593
#>     estimation_status calibration_dbh_min_cm calibration_dbh_max_cm
#> 1           estimated                    6.7                  102.4
#> 2           estimated                    5.5                   67.5
#> 3           estimated                    6.7                   91.2
#> 4 unsupported_species                     NA                     NA
#>   calibration_height_min_m calibration_height_max_m within_calibration_range
#> 1                      4.9                     42.0                     TRUE
#> 2                      5.0                     32.8                     TRUE
#> 3                      2.5                     36.4                     TRUE
#> 4                       NA                       NA                       NA
#>      calibration_status             biomass_boundary      model_source
#> 1 within_observed_range above 0.30 m; stump excluded FRTC 2025 Table 9
#> 2 within_observed_range above 0.30 m; stump excluded FRTC 2025 Table 9
#> 3 within_observed_range above 0.30 m; stump excluded FRTC 2025 Table 9
#> 4         not_available                         <NA>              <NA>
```

The result includes standardized species names, FRTC density provenance,
biomass in kg/tree, carbon in kg/tree, basal area, model source, and
estimation status. Carbon is calculated using the IPCC (2006) default
fraction of 0.47.

The fourth tree is unsupported. A warning is expected, its biomass is
`NA`, and its status is `unsupported_species`. The package does not
substitute a model from another species.

For supported trees, inspect `within_calibration_range` and
`calibration_status`. The package compares each DBH and height with the
observed species-specific limits in the FRTC model-development dataset.
A prediction outside either limit is returned but identified as an
extrapolation.

``` r

frtc_models()[, c(
  "species_id", "sample_size",
  "dbh_min_cm", "dbh_max_cm",
  "height_min_m", "height_max_m"
)]
#>                 species_id sample_size dbh_min_cm dbh_max_cm height_min_m
#> 1         alnus_nepalensis          52        7.4       83.4         4.50
#> 2          castanopsis_spp          52        5.4       76.4         4.55
#> 3 lagerstroemia_parviflora          46        7.1       58.1         5.50
#> 4         pinus_roxburghii          96        6.7       91.2         2.50
#> 5           shorea_robusta         122        6.7      102.4         4.90
#> 6         schima_wallichii          47        5.5       67.5         5.00
#> 7         terminalia_alata          61        5.4      103.2         4.80
#>   height_max_m
#> 1         36.6
#> 2         29.4
#> 3         29.3
#> 4         36.4
#> 5         42.0
#> 6         32.8
#> 7         38.4
```

## 4. Produce plot and forest summaries

``` r

plot_results <- frtc_plot_summary(tree_results)
species_results <- frtc_species_summary(tree_results)
dbh_results <- frtc_dbh_summary(tree_results)
forest_results <- frtc_forest_summary(plot_results)

plot_results
#>   plot_id plot_area_ha total_trees estimated_trees unsupported_or_missing_trees
#> 1     p01         0.05           2               2                            0
#> 2     p02         0.10           2               1                            1
#>   within_calibration_trees extrapolated_trees calibration_not_assessed_trees
#> 1                        2                  0                              0
#> 2                        1                  0                              0
#>   extrapolated_tree_pct_of_estimated stem_coverage_pct basal_area_coverage_pct
#> 1                                  0               100               100.00000
#> 2                                  0                50                69.23077
#>   frtc_supported_agb_kg frtc_supported_agb_Mg_ha carbon_fraction
#> 1              718.9263                14.378526            0.47
#> 2              414.2901                 4.142901            0.47
#>   frtc_supported_carbon_Mg_ha         summary_status
#> 1                    6.757907 complete_frtc_estimate
#> 2                    1.947164  partial_frtc_estimate
#>         calibration_summary_status             biomass_boundary
#> 1 all_supported_trees_within_range above 0.30 m; stump excluded
#> 2 all_supported_trees_within_range above 0.30 m; stump excluded
forest_results
#>   total_plots plots_with_estimates plots_without_estimates complete_plots
#> 1           2                    2                       0              1
#>   partial_plots mean_frtc_supported_agb_Mg_ha sd_frtc_supported_agb_Mg_ha
#> 1             1                      9.260714                     7.23768
#>   se_frtc_supported_agb_Mg_ha min_frtc_supported_agb_Mg_ha
#> 1                    5.117812                     4.142901
#>   max_frtc_supported_agb_Mg_ha carbon_fraction mean_frtc_supported_carbon_Mg_ha
#> 1                     14.37853            0.47                         4.352535
#>   sd_frtc_supported_carbon_Mg_ha se_frtc_supported_carbon_Mg_ha
#> 1                        3.40171                       2.405372
#>   min_frtc_supported_carbon_Mg_ha max_frtc_supported_carbon_Mg_ha
#> 1                        1.947164                        6.757907
#>                   forest_summary_status             biomass_boundary
#> 1 contains_partial_or_unestimated_plots above 0.30 m; stump excluded
```

Biomass is expressed in Mg/ha, which is numerically equal to metric
tonnes per hectare. Carbon is expressed in Mg C/ha.

Plot `p01` is a complete FRTC estimate because both trees are supported.
Plot `p02` is a partial estimate because one tree is unsupported. Its
biomass and carbon totals represent only the supported portion of that
plot.

Before interpretation, inspect:

- `summary_status`;
- `unsupported_or_missing_trees`;
- `stem_coverage_pct`;
- `basal_area_coverage_pct`.

A partial estimate must not be described as whole-plot biomass.

## 5. Work from a CSV file

A blank CSV template can be created with:

``` r

frtc_inventory_template("frtc_inventory.csv", rows = 100)
```

After filling the template, run:

``` r

results <- frtc_biomass_from_csv(
  input = "frtc_inventory.csv",
  output_format = "excel"
)

results$tree_results
results$plot_summary
results$species_summary
results$dbh_class_summary
results$forest_summary
results$files
```

The Excel workbook contains an interpretation sheet, all result tables,
the model registry, and the density rules. Use `output_format = "csv"`
for separate CSV files or `output_format = "both"` for both formats.

## 6. Inspect model information

``` r

frtc_equation("sal")
#> Species: Shorea robusta (sal)
#> Response: Total aboveground biomass above 0.30 m; stump excluded
#> Equation: B = 0.054968 * (DBH^2 * H * rho)^0.980885
#> Units: DBH cm; H m; rho g/cm3; B kg/tree
#> Density basis: FRTC DBH class
#> Sample size: 122
#> Fit RMSE: 384.1 kg
#> Operational RMSE: 354.007 kg
#> Observed DBH range: 6.7-102.4 cm
#> Observed height range: 4.9-42 m
#> Source: FRTC 2025, Tables 9 and 11; calibration ranges from the FRTC dataset
frtc_density("sal", dbh = 30)
#>       species_id dbh_cm density_g_cm3 density_source             source
#> 1 shorea_robusta     30        0.5573 frtc_dbh_class FRTC 2025 Table 11
```

Use
[`frtc_models()`](https://ayersant-sys.github.io/nepalallometry/dev/reference/frtc_models.md)
and
[`frtc_density()`](https://ayersant-sys.github.io/nepalallometry/dev/reference/frtc_density.md)
to inspect all equations and recommended densities.

## Interpretation limits

The current package does not:

- estimate biomass for species outside the seven FRTC models;
- predict missing tree heights;
- estimate the excluded stump, roots, dead wood, litter, or soil carbon;
- provide formal prediction intervals or uncertainty propagation;
- convert a partial supported-species estimate into total plot biomass.

Calibration flags describe whether a prediction is inside the observed
DBH and height domain. They do not quantify prediction uncertainty or
guarantee that an in-range prediction is accurate.

Users should cite `nepalallometry`, the original FRTC (2025) report, and
IPCC (2006) when using the default carbon fraction. Run
[`allometry_references()`](https://ayersant-sys.github.io/nepalallometry/dev/reference/allometry_references.md)
for the complete APA-style package reference registry.

## References

Forest Research and Training Centre. (2025). *Allometric equations for
seven major tree species of Nepal* (Vol. I). Ministry of Forests and
Environment, Government of Nepal.

Intergovernmental Panel on Climate Change. (2006). *2006 IPCC guidelines
for national greenhouse gas inventories: Volume 4. Agriculture, forestry
and other land use* (H. S. Eggleston, L. Buendia, K. Miwa, T. Ngara, &
K. Tanabe, Eds.). Institute for Global Environmental Strategies.
<https://www.ipcc-nggip.iges.or.jp/public/2006gl/vol4.html>
