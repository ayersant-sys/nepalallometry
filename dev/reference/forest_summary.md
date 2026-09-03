# Extract biomass result tables

Generic accessors for the analysis levels stored in a biomass result.
Their generic names support future allometry result classes.

## Usage

``` r
forest_summary(x, ...)

plot_summary(x, ...)

species_summary(x, ...)

dbh_summary(x, ...)

tree_results(x, ...)

method_audit(x, ...)
```

## Arguments

- x:

  A result returned by
  [`biomass()`](https://ayersant-sys.github.io/nepalallometry/dev/reference/biomass.md).

- ...:

  Reserved for future use.

## Value

The requested data frame.
