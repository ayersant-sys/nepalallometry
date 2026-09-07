# Launch the nepalallometry graphical user interface

Launches the graphical user interface for nepalallometry. The interface
provides access to biomass, carbon, and tree-volume estimation workflows
using the methods implemented in the package.

## Usage

``` r
run_gui()
```

## Value

No return value. The function launches an interactive Shiny application.

## Details

The GUI requires the shiny package. If shiny is not installed,
`run_gui()` stops with an informative message explaining how to install
it. The calculations performed through the interface call the existing
nepalallometry functions rather than maintaining separate equation code.

## Examples

``` r
if (FALSE) { # \dontrun{
run_gui()
} # }
```
