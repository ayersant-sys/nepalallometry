\name{forest_summary}
\alias{forest_summary}\alias{forest_summary.nepal_biomass_result}
\alias{plot_summary}\alias{plot_summary.nepal_biomass_result}
\alias{species_summary}\alias{species_summary.nepal_biomass_result}
\alias{dbh_summary}\alias{dbh_summary.nepal_biomass_result}
\alias{tree_results}\alias{tree_results.nepal_biomass_result}
\title{Extract biomass result tables}
\usage{forest_summary(x, ...)\cr plot_summary(x, ...)\cr
species_summary(x, ...)\cr dbh_summary(x, ...)\cr tree_results(x, ...)}
\arguments{\item{x}{A result returned by \code{biomass()}.}
\item{...}{Reserved for future use.}}
\value{The requested data frame.}
\description{Generic accessors for the analysis levels stored in a biomass
result. Their generic names support future allometry result classes.}
