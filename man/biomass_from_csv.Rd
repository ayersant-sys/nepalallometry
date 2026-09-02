\name{biomass_from_csv}
\alias{biomass_from_csv}
\title{Compatibility wrapper for CSV biomass inventories}
\usage{biomass_from_csv(input, output = NULL, ...)}
\arguments{\item{input}{Existing CSV path.}\item{output}{Optional output
\code{.xlsx} path.}\item{...}{Additional arguments passed to \code{biomass()}.}}
\value{A \code{nepal_biomass_result} object, invisibly.}
\description{Retains the earlier CSV entry point. New code should use
\code{biomass()}, which also accepts R data frames and Excel files.}
