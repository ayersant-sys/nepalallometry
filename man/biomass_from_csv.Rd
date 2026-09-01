\name{biomass_from_csv}
\alias{biomass_from_csv}
\title{Calculate inventory biomass with three methods and write one workbook}
\usage{
biomass_from_csv(input, output = NULL)
}
\arguments{
\item{input}{Path to a CSV containing \code{tree_id}, \code{plot_id},
\code{plot_area_ha}, \code{species}, \code{dbh_cm}, and \code{height_m}.
Additional columns are preserved.}

\item{output}{Path for the resulting \code{.xlsx} workbook. By default, it is
saved beside \code{input} using the suffix \code{_biomass_results.xlsx}.}
}
\value{
Invisibly, a list containing the workbook path and the three result data
frames.
}
\description{
Reads one tree-inventory CSV and writes an Excel workbook containing a
disclaimer plus separate FRTC 2025, Sharma-Pukkala, and Chave 2014 result
sheets. Each method sheet retains every input row and repeats its plot-level
biomass, carbon, coverage, and status values on the corresponding tree rows.
The three methods are never combined.
}
\examples{
\dontrun{
biomass_from_csv("forest_inventory.csv")
}
}
