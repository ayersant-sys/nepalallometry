# Methods & Equations

This page summarizes the calculation pathways implemented in
*nepalallometry*. The package operationalizes published equations; it
does not replace the original methodological sources. Users should
consider species coverage, calibration domain, biomass boundary, and
volume definition when selecting and comparing methods.

## Biomass and carbon

### FRTC 2025

The FRTC pathway implements the published species-specific equations for
seven major tree species of Nepal. Depending on the species and
component, the implemented models use DBH ($`D`$), total tree height
($`H`$), and the FRTC-recommended wood-density information.

The package returns total aboveground biomass **above 0.30 m**. The
0–0.30 m stump is excluded. Use
[`frtc_equation()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_equation.md)
and
[`frtc_models()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_models.md)
to inspect the exact species-specific equations and model information
implemented in the package.

### Sharma & Pukkala 1990

The Sharma & Pukkala pathway applies the published species or
species-group equations implemented in the package. Where a species is
handled using a miscellaneous equation, the user must identify the
appropriate **Hill** or **Terai** miscellaneous group.

Use
[`sharma_pukkala_species()`](https://ayersant-sys.github.io/nepalallometry/reference/sharma_pukkala_species.md)
to inspect the supported species and groups.

### Chave et al. 2014

The Chave pathway implements the moist/tropical aboveground biomass
equation based on DBH, total tree height, and wood density:

``` math
AGB = 0.0673\left(\rho D^2H\right)^{0.976}
```

where $`AGB`$ is aboveground biomass (kg), $`\rho`$ is wood density (g
cm$`^{-3}`$), $`D`$ is DBH (cm), and $`H`$ is total tree height (m).

Wood density is handled internally where supported, using the package’s
documented density sources and rules. A user-supplied `wood_density` can
be used as an override where applicable.

### Carbon conversion

Carbon is derived from estimated biomass as:

``` math
C = AGB \times CF
```

where $`C`$ is aboveground carbon, $`AGB`$ is aboveground biomass, and
$`CF`$ is the carbon fraction. The default carbon fraction in
*nepalallometry* is 0.47.

## Tree volume

### FRTC 2025 volume

The FRTC pathway implements species-specific published equations in one
of the following mathematical forms:

``` math
V = aD^bH^c
```

``` math
V = a(D^2H)^b
```

or

``` math
V = a + b(D^2H)
```

where $`V`$ is tree volume, $`D`$ is DBH, $`H`$ is total tree height,
and $`a`$, $`b`$, and $`c`$ are published model coefficients.

FRTC provides three distinct volume definitions:

- **total over-bark stem volume**;
- **under-bark stem volume to a 20-cm over-bark top diameter**; and
- **under-bark stem volume to a 10-cm over-bark top diameter**.

These are different volume definitions, not replicate estimates of the
same quantity. They should **not be averaged or summed**. The FRTC
volume definitions exclude the 0.30-m stump and do not include branch
volume.

Use
[`frtc_volume()`](https://ayersant-sys.github.io/nepalallometry/reference/frtc_volume.md)
and the package model information to inspect the species-specific
implementation.

### Sharma & Pukkala stem volume

The implemented Sharma & Pukkala stem-volume pathway uses:

``` math
V_s = \frac{\exp\left(a+b\ln D+c\ln H\right)}{1000}
```

where $`V_s`$ is stem volume (m$`^3`$), $`D`$ is DBH (cm), $`H`$ is
total tree height (m), and $`a`$, $`b`$, and $`c`$ are species-specific
published coefficients.

### Forest Regulations 2079 branch volume

For the Sharma–Pukkala + Forest Regulations pathway, branch volume is
derived from the applicable branch ratio $`R(D)`$:

``` math
V_b = R(D)V_s
```

where $`V_b`$ is branch volume and $`V_s`$ is stem volume. The
applicable ratio depends on the branch group and DBH class defined by
the Forest Regulations 2079. Therefore, `branch_group` is required for
this calculation.

Total tree volume is then:

``` math
V_t = V_s + V_b
```

where $`V_t`$ is total tree volume.

The resulting total-tree volume includes branches and therefore is not
directly equivalent to the FRTC stem-volume definitions.

## Plot and forest summaries

For a plot of area $`A`$ hectares, a tree-level quantity $`Y_i`$ is
expanded to a per-hectare plot estimate as:

``` math
Y_{plot} = \frac{\sum_i Y_i}{A}
```

Forest-level summaries are calculated across plots where the required
plot information is available.

For $`n`$ plots, the standard error of the mean is:

``` math
SE = \frac{SD}{\sqrt{n}}
```

and a two-sided 95% confidence interval is based on the Student’s $`t`$
distribution:

``` math
\bar{Y} \pm t_{0.975,n-1}SE
```

These confidence intervals describe uncertainty in the estimated mean
across sampled plots. They are not individual-tree prediction intervals
and do not quantify allometric model uncertainty.

## Method boundaries and interpretation

Different methods should not automatically be treated as interchangeable
estimates of exactly the same biological quantity. In particular:

- FRTC biomass excludes the 0–0.30 m stump;
- biomass boundaries can differ among national and pantropical
  approaches;
- FRTC volume outputs represent separate stem-volume definitions;
- FRTC volume excludes branches;
- the Sharma–Pukkala + Forest Regulations total-volume pathway includes
  branch volume; and
- carbon is calculated from biomass rather than estimated independently.

Differences among methods can be useful for evaluating sensitivity to
methodological choice, but the spread among methods is **not a formal
estimate of uncertainty or accuracy**.

## Inspecting equations in R

The package provides functions for inspecting the implemented models and
sources. For example:

``` r

frtc_models()
frtc_equation("sal")
frtc_density("sal", dbh = 30)
sharma_pukkala_species()
allometry_references()
```

These functions should be used when exact species-specific coefficients,
density rules, or source information are required.

## References

Run:

``` r

allometry_references()
```

for the package’s reference registry covering the FRTC, Sharma &
Pukkala, Chave, Forest Regulations, wood-density, and carbon-conversion
sources used by the implemented workflows.
