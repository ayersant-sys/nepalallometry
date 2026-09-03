# Run the FRTC biomass workflow from a CSV file

Run the FRTC biomass workflow from a CSV file

## Usage

``` r
frtc_biomass_from_csv(
  input,
  output_dir = dirname(input),
  prefix = NULL,
  output_format = c("excel", "csv", "both")
)
```

## Arguments

- input:

  Path to an inventory CSV containing \`tree_id\`, \`plot_id\`,
  \`plot_area_ha\`, \`species\`, \`dbh_cm\`, and \`height_m\`.

- output_dir:

  Directory in which result CSV files are saved. Defaults to the
  directory containing \`input\`.

- prefix:

  Filename prefix. Defaults to the input filename without its \`.csv\`
  extension.

- output_format:

  Output as one formatted Excel workbook (\`"excel"\`), five CSV files
  (\`"csv"\`), or both (\`"both"\`).

## Value

A list containing all result tables and their saved file paths.
