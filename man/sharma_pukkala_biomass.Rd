\name{sharma_pukkala_biomass}
\alias{sharma_pukkala_biomass}
\title{Estimate biomass using Sharma and Pukkala (1990)}
\usage{
sharma_pukkala_biomass(
  dbh,
  height,
  species,
  carbon_fraction = 0.47,
  keep_inputs = FALSE
)
}
\arguments{
\item{dbh}{Diameter at breast height in centimetres.}
\item{height}{Total tree height in metres.}
\item{species}{Supported standardized scientific identifier or Nepali/common
name. Use \code{sharma_pukkala_species()} to inspect supported species.}
\item{carbon_fraction}{Carbon fraction applied to air-dry total biomass.
Defaults to 0.47.}
\item{keep_inputs}{If \code{TRUE}, return inputs, biomass components,
provenance, and calibration status. If \code{FALSE}, return total biomass
in kg/tree.}
}
\value{
Air-dry total biomass in kg/tree, or a data frame when
\code{keep_inputs = TRUE}.
}
\description{
Estimates air-dry stem, branch, foliage, and total aboveground biomass.
The stem-volume equation is used internally. Branch and foliage ratios are
interpolated independently by DBH using the Sharma-Pukkala procedure.
}
\details{
The output is air-dry biomass. Observed model-development limits are assessed
for DBH only because species-specific height ranges were not reported.
The miscellaneous Terai and Hills groups must be selected explicitly.
}
\examples{
sharma_pukkala_biomass(30, 20, "sal")
sharma_pukkala_biomass(30, 20, "chilaune", keep_inputs = TRUE)
}
