# Estimate aboveground biomass using Chave et al. (2014)

Applies the height-inclusive pantropical equation
`AGB = 0.0673 * (rho * D^2 * H)^0.976`. Basic wood density is selected
automatically from FRTC (2025) for the five FRTC species whose
recommended biomass equations use density, then from GWDD v2.2 at exact
infraspecific, binomial, or genus level. GWDD model-derived trunk
density (`wsg_est_trunk`) is used rather than the raw mean.

## Usage

``` r
chave_biomass(
  dbh,
  height,
  species,
  wood_density = NULL,
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

  Scientific name or a supported FRTC code or Nepali name. Scientific
  binomials are required for species-level GWDD matching.

- wood_density:

  Optional user-supplied basic wood density in g/cm3, defined as
  oven-dry mass divided by fresh volume. When supplied, it overrides
  automatic FRTC/GWDD lookup.

- carbon_fraction:

  Carbon fraction applied to oven-dry AGB. Defaults to 0.47 following
  IPCC (2006).

- keep_inputs:

  If `TRUE`, return inputs, density provenance, biomass, carbon, and
  calibration status. If `FALSE`, return AGB in kg/tree.

## Value

Oven-dry aboveground biomass in kg/tree, or a data frame when
`keep_inputs = TRUE`.

## References

Chave, J., et al. (2014). Improved allometric models to estimate the
aboveground biomass of tropical trees. *Global Change Biology, 20*(10),
3177-3190. [doi:10.1111/gcb.12629](https://doi.org/10.1111/gcb.12629)

Fischer, F. J., et al. (2026a). Beyond species means: The intraspecific
contribution to global wood density variation. *New Phytologist,
249*(6), 2630-2651.
[doi:10.1111/nph.70860](https://doi.org/10.1111/nph.70860)

Fischer, F. J., et al. (2026b). *Global Wood Density Database v2.2*
\[Data set\]. Zenodo.
[doi:10.5281/zenodo.18262736](https://doi.org/10.5281/zenodo.18262736)

Intergovernmental Panel on Climate Change. (2006). *2006 IPCC guidelines
for national greenhouse gas inventories: Volume 4. Agriculture, forestry
and other land use*. IGES.

## Examples

``` r
chave_biomass(30, 20, "sal")
#> [1] 541.1827
chave_biomass(30, 20, "Dalbergia sissoo", keep_inputs = TRUE)
#>   dbh_cm height_m    species_input wood_density_g_cm3 density_source
#> 1     30       20 Dalbergia sissoo               0.62      GWDD_v2.2
#>   density_match_level density_taxon_matched density_value_field
#> 1            binomial      Dalbergia sissoo       wsg_est_trunk
#>             density_definition density_database_version chave_agb_kg
#> 1 oven-dry mass / fresh volume                GWDD v2.2     600.5308
#>   carbon_fraction chave_carbon_kg within_chave_dbh_range     calibration_status
#> 1            0.47        282.2495                   TRUE within_chave_dbh_range
#>   estimation_status biomass_moisture_basis
#> 1         estimated               oven_dry
#>                                        biomass_boundary        model_source
#> 1 aboveground biomass as defined by Chave et al. (2014) Chave et al. (2014)
```
