# Why nepalallometry?

## Why does Nepal need an allometry package?

Forest inventories depend on allometric models to translate field
measurements such as diameter and height into quantities used for
management, research, and carbon accounting. In Nepal, those models are
distributed across reports, regulations, publications, spreadsheets, and
separate analytical traditions. Users must therefore identify the
appropriate equation, reproduce its parameters, apply the correct units
and wood density, interpret its calibration range, and understand
exactly which parts of the tree its response represents.

These decisions matter because Nepal’s established pathways do not
estimate an identical quantity. They differ in species coverage,
moisture basis, density treatment, calibration information, and biomass
boundary. Transferring an equation without its assumptions can produce a
numerical result that appears precise but is not fully comparable with
another estimate. Unsupported species, unmeasured height, unusual tree
form, and application outside the calibration domain create further
practical uncertainty.

***nepalallometry*** provides a common, reproducible implementation
while preserving those methodological differences. It records model and
density provenance, identifies unsupported or extrapolated trees,
reports model coverage, and keeps the outputs from different pathways
separate. The package is intended to grow into a broader platform for
allometric work in Nepal as additional models and inventory tools are
incorporated.

## First stable release: Biomass and Carbon Estimation

The first release focuses on tree-, plot-, species-, diameter-class-,
and forest-level biomass and carbon estimation. Its main workflow is
[`biomass()`](https://ayersant-sys.github.io/nepalallometry/reference/biomass.md),
which accepts a forest inventory data frame, CSV file, or Excel workbook
and returns auditable R summaries and a seven-sheet Excel report. It is
designed for researchers, students, and operational forest managers. Its
usefulness for operational decisions will increase as additional models,
species, and allometric modules are added.

The three pathways in this release are intentionally not averaged or
combined:

### FRTC

The Forest Research and Training Centre (2025) pathway implements recent
species-specific total-biomass equations for seven major tree taxa. The
estimates are oven-dry biomass above the 0.30 m felling height, so the
lower stump is excluded.

### Sharma & Pukkala

Sharma and Pukkala (1990) provides air-dry stem, branch, and foliage
biomass for named species and explicit miscellaneous groups. Schedule 9
of Nepal’s *Forest Regulations, 2079* provides the regulatory basis for
operational use of its tree-volume parameters (Government of Nepal,
2022).

### Chave

Chave et al. (2014) provides a height-inclusive pantropical oven-dry
aboveground-biomass equation. The package supplies traceable basic wood
density from the applicable FRTC source or Global Wood Density Database
v2.2 matches (Fischer et al., 2026a, 2026b).

Carbon is calculated with a default fraction of 0.47 following IPCC
(2006). Users may supply another documented fraction when appropriate.
The default is a reporting conversion and should not be interpreted as a
measured species-specific carbon concentration.

## Who can use it?

- **Researchers** can reproduce calculations and inspect the
  assumptions, calibration flags, and source attached to each pathway.
- **Students** can learn how measurements, equations, density, biomass
  boundaries, and aggregation are connected.
- **Operational managers** can create consistent summaries and retain an
  audit record, while recognizing the present limits of species and
  model coverage.

## Development perspective

The motivation for developing ***nepalallometry*** grew from my forestry
work in Nepal and subsequent research on forest biomass and carbon
estimation. While working on the preparation of operational plans for
community forests, and later conducting research involving biomass and
carbon estimation, I repeatedly encountered practical difficulties in
applying allometric methods. Relevant equations are distributed across
different sources, their species coverage and input requirements vary,
and calculations often require users to move between publications,
equations, spreadsheets, and separate analytical procedures.

These experiences motivated the development of ***nepalallometry*** as a
transparent and reproducible framework that brings established
allometric approaches together while preserving their original
assumptions, applicability, and limitations. The package is intended to
expand as additional authoritative equations and allometric tools
relevant to Nepal become available.

## Future updates

***nepalallometry*** is an umbrella package rather than a biomass-only
project. Future releases are expected to incorporate additional
Nepal-relevant equations and species, stem-volume estimation,
height-diameter relationships, and other allometric or inventory tools
where the underlying evidence supports a transparent implementation.
Each addition will retain the package’s emphasis on source attribution,
units, calibration domains, validation, and clearly stated limitations.
These are planned directions, not fixed release commitments.

## References

Complete APA-style references for every model, database, regulatory
source, and conversion factor used by the package are available with:

``` r
allometry_references()
```

They are also included in `citation("nepalallometry")` and in the
`Read_Me` sheet of each exported workbook.
