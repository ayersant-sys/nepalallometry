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
Defaults to 0.47 following IPCC (2006).}
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
Schedule 9 of Nepal's Forest Regulations, 2079 provides the regulatory basis
for operational use of the Sharma-Pukkala tree-volume parameters.
}
\details{
The output is air-dry biomass. Observed model-development limits are assessed
for DBH only because species-specific height ranges were not reported.
The miscellaneous Terai and Hills groups must be selected explicitly.
}
\references{
Sharma, E. R., and Pukkala, T. (1990). \emph{Volume equations and biomass
prediction of forest trees of Nepal} (Publication No. 47). Forest Survey and
Statistics Division, Ministry of Forests and Soil Conservation.

Government of Nepal. (2022). \emph{Forest Regulations, 2079}, Schedule 9.
Nepal Law Commission.

Intergovernmental Panel on Climate Change. (2006). \emph{2006 IPCC guidelines
for national greenhouse gas inventories: Volume 4. Agriculture, forestry and
other land use}. IGES.
}
\examples{
sharma_pukkala_biomass(30, 20, "sal")
sharma_pukkala_biomass(30, 20, "chilaune", keep_inputs = TRUE)
}
