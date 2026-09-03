# Compatibility wrapper for CSV biomass inventories

Retains the earlier CSV entry point. New code should use
[`biomass()`](https://ayersant-sys.github.io/nepalallometry/dev/reference/biomass.md),
which also accepts R data frames and Excel files.

## Usage

``` r
biomass_from_csv(input, output = NULL, ...)
```

## Arguments

- input:

  Existing CSV path.

- output:

  Optional output `.xlsx` path.

- ...:

  Additional arguments passed to
  [`biomass()`](https://ayersant-sys.github.io/nepalallometry/dev/reference/biomass.md).

## Value

A `nepal_biomass_result` object, invisibly.
