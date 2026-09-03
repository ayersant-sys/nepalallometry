# Inspect sources used by nepalallometry

Returns the authoritative reference registry used in package
documentation and exported Excel workbooks. The registry distinguishes
original model and data sources from regulatory and conversion-factor
sources.

## Usage

``` r
allometry_references(source_id = NULL)
```

## Arguments

- source_id:

  Optional source identifier. If `NULL`, return all sources.

## Value

A data frame with the source identifier, short citation, role in the
package, and complete APA-style reference.

## Examples

``` r
allometry_references()
#>                 source_id                                   citation
#> 1          nepalallometry                                Ayer (2026)
#> 2               frtc_2025 Forest Research and Training Centre (2025)
#> 3     sharma_pukkala_1990                  Sharma and Pukkala (1990)
#> 4 forest_regulations_2079                 Government of Nepal (2022)
#> 5              chave_2014                        Chave et al. (2014)
#> 6       gwdd_article_2026                     Fischer et al. (2026a)
#> 7       gwdd_dataset_v2_2                     Fischer et al. (2026b)
#> 8               ipcc_2006                                IPCC (2006)
#>                                                                           source_role
#> 1                                                             Software implementation
#> 2    FRTC biomass equations, coefficients, density rules, and calibration information
#> 3 Original Sharma-Pukkala volume equations, biomass parameters, ratios, and densities
#> 4          Regulatory adoption of Sharma-Pukkala tree-volume parameters in Schedule 9
#> 5                           Height-inclusive pantropical aboveground-biomass equation
#> 6                           Scientific description of Global Wood Density Database v2
#> 7                           Bundled Global Wood Density Database v2.2 aggregated data
#> 8                                             Default biomass carbon fraction of 0.47
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          apa_reference
#> 1                                                                                                                                                                                                                                                                                                                                                          Ayer, S. (2026). nepalallometry: Allometric estimation for Nepal's forest trees [R package]. https://github.com/ayersant-sys/nepalallometry
#> 2                                                                                                                                                                                                                                                                                                                          Forest Research and Training Centre. (2025). Allometric equations for seven major tree species of Nepal (Vol. I). Ministry of Forests and Environment, Government of Nepal.
#> 3                                                                                                                                                                                                                                                                                        Sharma, E. R., & Pukkala, T. (1990). Volume equations and biomass prediction of forest trees of Nepal (Publication No. 47). Forest Survey and Statistics Division, Ministry of Forests and Soil Conservation.
#> 4                                                                                                                                                                                                                                                                                                                                                Government of Nepal. (2022). Forest Regulations, 2079. Nepal Law Commission. https://lawcommission.gov.np/content/12938/12938-forest-regulation-2079/
#> 5 Chave, J., Rejou-Mechain, M., Burquez, A., Chidumayo, E., Colgan, M. S., Delitti, W. B. C., Duque, A., Eid, T., Fearnside, P. M., Goodman, R. C., Henry, M., Martinez-Yrizar, A., Mugasha, W. A., Muller-Landau, H. C., Mencuccini, M., Nelson, B. W., Ngomanda, A., Nogueira, E. M., Ortiz-Malavassi, E., ... Vieilledent, G. (2014). Improved allometric models to estimate the aboveground biomass of tropical trees. Global Change Biology, 20(10), 3177-3190. https://doi.org/10.1111/gcb.12629
#> 6                          Fischer, F. J., Chave, J., Zanne, A., Jucker, T., Fajardo, A., Fayolle, A., Ferreira de Lima, R. A., Vieilledent, G., Beeckman, H., Hubau, W., De Mil, T., Wallenus, D., Aldana, A. M., Alvarez-Davila, E., Alves, L. F., Apgaua, D. M. G., Arcanjo, F., Bastin, J.-F., Bilous, A., ... Zieminska, K. (2026a). Beyond species means: The intraspecific contribution to global wood density variation. New Phytologist, 249(6), 2630-2651. https://doi.org/10.1111/nph.70860
#> 7                                                                                         Fischer, F. J., Chave, J., Zanne, A., Jucker, T., Fajardo, A., Fayolle, A., Ferreira de Lima, R. A., Vieilledent, G., Beeckman, H., Hubau, W., De Mil, T., Wallenus, D., Aldana, A. M., Alvarez-Davila, E., Alves, L. F., Apgaua, D. M. G., Arcanjo, F., Bastin, J.-F., Bilous, A., ... Zieminska, K. (2026b). Global Wood Density Database v2.2 [Data set]. Zenodo. https://doi.org/10.5281/zenodo.18262736
#> 8                                                                                                                                                    Intergovernmental Panel on Climate Change. (2006). 2006 IPCC guidelines for national greenhouse gas inventories: Volume 4. Agriculture, forestry and other land use (H. S. Eggleston, L. Buendia, K. Miwa, T. Ngara, & K. Tanabe, Eds.). Institute for Global Environmental Strategies. https://www.ipcc-nggip.iges.or.jp/public/2006gl/vol4.html
allometry_references("sharma_pukkala_1990")
#>             source_id                  citation
#> 3 sharma_pukkala_1990 Sharma and Pukkala (1990)
#>                                                                           source_role
#> 3 Original Sharma-Pukkala volume equations, biomass parameters, ratios, and densities
#>                                                                                                                                                                                                   apa_reference
#> 3 Sharma, E. R., & Pukkala, T. (1990). Volume equations and biomass prediction of forest trees of Nepal (Publication No. 47). Forest Survey and Statistics Division, Ministry of Forests and Soil Conservation.
```
