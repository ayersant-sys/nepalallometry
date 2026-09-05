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
#> Error in volume(trees): could not find function "volume"
volume(trees, methods = "frtc")
#> Error in volume(trees, methods = "frtc"): could not find function "volume"
```
