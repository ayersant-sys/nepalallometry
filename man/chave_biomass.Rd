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
0.47.}

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
\examples{
chave_biomass(30, 20, "sal")
chave_biomass(30, 20, "Dalbergia sissoo", keep_inputs = TRUE)
}
