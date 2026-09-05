# Estimate biomass using Sharma and Pukkala (1990)

Estimates air-dry stem, branch, foliage, and total aboveground biomass.
The stem-volume equation is used internally. Branch and foliage ratios
are interpolated independently by DBH using the Sharma-Pukkala
procedure. Schedule 9 of Nepal's Forest Regulations, 2079 provides the
regulatory basis for operational use of the Sharma-Pukkala tree-volume
parameters.

## Usage

``` r
sharma_pukkala_biomass(
  dbh,
  height,
  species,
  carbon_fraction = 0.47,
  keep_inputs = FALSE
)
```

## Arguments

- dbh:

  Diameter at breast height in centimetres.

- height:

  Total tree height in metres.

- species:

  Supported standardized scientific identifier or Nepali/common name.
  Use
  [`sharma_pukkala_species()`](https://ayersant-sys.github.io/nepalallometry/reference/sharma_pukkala_species.md)
  to inspect supported species.

- carbon_fraction:

  Carbon fraction applied to air-dry total biomass. Defaults to 0.47
  following IPCC (2006).

- keep_inputs:

  If `TRUE`, return inputs, biomass components, provenance, and
  calibration status. If `FALSE`, return total biomass in kg/tree.

## Value

Air-dry total biomass in kg/tree, or a data frame when
`keep_inputs = TRUE`.

## Details

The output is air-dry biomass. Observed model-development limits are
assessed for DBH only because species-specific height ranges were not
reported. The miscellaneous Terai and Hills groups must be selected
explicitly.

## References

Sharma, E. R., and Pukkala, T. (1990). *Volume equations and biomass
prediction of forest trees of Nepal* (Publication No. 47). Forest Survey
and Statistics Division, Ministry of Forests and Soil Conservation.

Government of Nepal. (2022). *Forest Regulations, 2079*, Schedule 9.
Nepal Law Commission.

Intergovernmental Panel on Climate Change. (2006). *2006 IPCC guidelines
for national greenhouse gas inventories: Volume 4. Agriculture, forestry
and other land use*. IGES.

## Examples

``` r
sharma_pukkala_biomass(30, 20, "sal")
#> [1] 782.496
sharma_pukkala_biomass(30, 20, "chilaune", keep_inputs = TRUE)
#>   dbh_cm height_m species_input species_standardized  scientific_name
#> 1     30       20      chilaune     schima_wallichii Schima wallichii
#>   nepali_name density_kg_m3 branch_ratio foliage_ratio sp_stem_biomass_kg
#> 1    chilaune           689          0.3    0.04666667            437.537
#>   sp_branch_biomass_kg sp_foliage_biomass_kg sp_total_biomass_kg
#> 1             131.2611               20.4184            589.2166
#>   carbon_fraction sp_carbon_kg calibration_dbh_min_cm calibration_dbh_max_cm
#> 1            0.47     276.9318                   18.3                   77.5
#>   within_calibration_dbh_range        calibration_status
#> 1                         TRUE within_observed_dbh_range
#>   height_calibration_status estimation_status biomass_moisture_basis
#> 1 not_assessed_not_reported         estimated                air_dry
#>                                          biomass_boundary
#> 1 stem + branches + foliage; stump boundary not specified
#>                model_source
#> 1 Sharma and Pukkala (1990)
#>                                                  parameter_source
#> 1 Sharma and Pukkala (1990); Forest Regulations, 2079, Schedule 9
```
