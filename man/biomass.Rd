\name{biomass}
\alias{biomass}
\title{Estimate biomass and produce complete inventory summaries}
\usage{biomass(input, output = NULL, sheet = 1,
  methods = c("frtc", "sharma_pukkala", "chave"),
  carbon_fraction = 0.47,
  dbh_breaks = c(0, 10, 20, 30, 40, 50, Inf))}
\arguments{
\item{input}{A data frame or path to a \code{.csv} or \code{.xlsx} inventory.}
\item{output}{Optional output \code{.xlsx} path. Use \code{FALSE} to skip writing.}
\item{sheet}{Excel sheet name or number for an Excel input.}
\item{methods}{Any of \code{"frtc"}, \code{"sharma_pukkala"}, and \code{"chave"}.}
\item{carbon_fraction}{Biomass carbon fraction; default 0.47.}
\item{dbh_breaks}{DBH class boundaries in centimetres.}}
\value{A \code{nepal_biomass_result} containing calculation notes and forest,
plot, species, DBH-class, and tree tables.}
\description{Runs selected published biomass methods without combining their
totals. Required columns are \code{tree_id}, \code{plot_id},
\code{plot_area_ha}, \code{species}, \code{dbh_cm}, and \code{height_m}.
Optional \code{forest_id} and \code{forest_area_ha} enable grouped forest
summaries and estimated total forest stocks.}
\examples{\dontrun{result <- biomass(forest_inventory)}}
