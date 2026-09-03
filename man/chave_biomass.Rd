\name{chave_biomass}
\alias{chave_biomass}
\title{Estimate aboveground biomass using Chave et al. (2014)}
\usage{
chave_biomass(
  dbh,
  height,
  species,
  wood_density = NULL,
  carbon_fraction = 0.47,
  keep_inputs = FALSE
)
}
\arguments{
\item{dbh}{Diameter at breast height in centimetres.}

\item{height}{Total tree height in metres.}

\item{species}{Scientific name or a supported FRTC code or Nepali name.
Scientific binomials are required for species-level GWDD matching.}

\item{wood_density}{Optional user-supplied basic wood density in g/cm3,
defined as oven-dry mass divided by fresh volume. When supplied, it
overrides automatic FRTC/GWDD lookup.}

\item{carbon_fraction}{Carbon fraction applied to oven-dry AGB. Defaults to
0.47 following IPCC (2006).}

\item{keep_inputs}{If \code{TRUE}, return inputs, density provenance, biomass,
carbon, and calibration status. If \code{FALSE}, return AGB in kg/tree.}
}
\value{
Oven-dry aboveground biomass in kg/tree, or a data frame when
\code{keep_inputs = TRUE}.
}
\description{
Applies the height-inclusive pantropical equation
\code{AGB = 0.0673 * (rho * D^2 * H)^0.976}. Basic wood density is selected
automatically from FRTC (2025) for the five FRTC species whose recommended
biomass equations use density, then from GWDD v2.2 at exact infraspecific,
binomial, or genus level. GWDD model-derived trunk density
(\code{wsg_est_trunk}) is used rather than the raw mean.
}
\references{
Chave, J., et al. (2014). Improved allometric models to estimate the
aboveground biomass of tropical trees. \emph{Global Change Biology, 20}(10),
3177-3190. \doi{10.1111/gcb.12629}

Fischer, F. J., et al. (2026a). Beyond species means: The intraspecific
contribution to global wood density variation. \emph{New Phytologist, 249}(6),
2630-2651. \doi{10.1111/nph.70860}

Fischer, F. J., et al. (2026b). \emph{Global Wood Density Database v2.2}
[Data set]. Zenodo. \doi{10.5281/zenodo.18262736}

Intergovernmental Panel on Climate Change. (2006). \emph{2006 IPCC guidelines
for national greenhouse gas inventories: Volume 4. Agriculture, forestry and
other land use}. IGES.
}
\examples{
chave_biomass(30, 20, "sal")
chave_biomass(30, 20, "Dalbergia sissoo", keep_inputs = TRUE)
}
