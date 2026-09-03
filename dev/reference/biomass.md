# Estimate biomass and produce complete inventory summaries

Runs selected published biomass methods without combining their totals.
Required columns are `tree_id`, `plot_id`, `plot_area_ha`, `species`,
`dbh_cm`, and `height_m`. Optional `forest_id` and `forest_area_ha`
enable grouped forest summaries and estimated total forest stocks.

## Usage

``` r
biomass(input, output = NULL, sheet = 1,
  methods = c("frtc", "sharma_pukkala", "chave"),
  carbon_fraction = 0.47,
  dbh_breaks = c(0, 10, 20, 30, 40, 50, Inf))
```

## Arguments

- input:

  A data frame or path to a `.csv` or `.xlsx` inventory.

- output:

  Optional output `.xlsx` path. Use `FALSE` to skip writing.

- sheet:

  Excel sheet name or number for an Excel input.

- methods:

  Any of `"frtc"`, `"sharma_pukkala"`, and `"chave"`.

- carbon_fraction:

  Biomass carbon fraction; default 0.47 following IPCC (2006). Users may
  provide a different documented value appropriate to their application.

- dbh_breaks:

  DBH class boundaries in centimetres.

## Value

A `nepal_biomass_result` containing calculation notes, forest, plot,
species, DBH-class, tree, and method-audit tables.

## References

Run
[`allometry_references()`](https://ayersant-sys.github.io/nepalallometry/dev/reference/allometry_references.md)
for the complete APA-style references for the package, model pathways,
wood-density sources, default carbon fraction, and the regulatory use of
Sharma-Pukkala tree-volume parameters.

## Examples

``` r
if (FALSE) result <- biomass(forest_inventory) # \dontrun{}
```
