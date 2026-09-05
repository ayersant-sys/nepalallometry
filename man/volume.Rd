% Generated manually to match the exported volume() interface
\name{volume}
\alias{volume}
\title{Estimate tree and inventory volume}
\usage{
volume(
  input,
  output = NULL,
  sheet = 1,
  methods = "sharma_pukkala",
  dbh_breaks = c(0, 10, 20, 30, 40, 50, Inf)
)
}
\arguments{
\item{input}{A data frame or path to an existing \code{.csv} or \code{.xlsx} inventory.}
\item{output}{Optional \code{.xlsx} path for exporting results.}
\item{sheet}{Worksheet to read when \code{input} is an \code{.xlsx} file. Defaults to 1.}
\item{methods}{Volume method(s). Currently only \code{"sharma_pukkala"} is supported.}
\item{dbh_breaks}{Breaks used for DBH-class summaries.}
}
\value{
An object of class \code{nepal_volume_result} containing \code{forest_summary},
\code{plot_summary}, \code{species_summary}, \code{dbh_class_summary},
\code{tree_results}, and \code{method_audit}.
}
\description{
Applies supported tree-volume methods to a forest inventory and returns tree-,
plot-, species-, DBH-class-, and forest-level summaries. The current
implementation supports the Sharma-Pukkala stem-volume equations combined
with branch-volume ratios from Schedule 9 of Nepal's Forest Regulations 2079.
}
\details{
Required inventory columns are \code{tree_id}, \code{plot_id},
\code{plot_area_ha}, \code{species}, \code{dbh_cm}, and \code{height_m}.
Optional columns are \code{forest_id}, \code{forest_area_ha}, and
\code{branch_group}.

For species with a species-specific branch-volume row in the Forest
Regulations, \code{branch_group} may be left blank. For other supported
Sharma-Pukkala species, users must explicitly enter \code{other_broadleaf} or
\code{other_conifer} where appropriate. The package does not infer this category.
}
\examples{
inventory <- data.frame(
  tree_id = c("T1", "T2"),
  plot_id = c("P1", "P1"),
  plot_area_ha = c(0.05, 0.05),
  species = c("sal", "terminalia_alata"),
  dbh_cm = c(60, 45),
  height_m = c(25, 22),
  branch_group = c(NA, "other_broadleaf")
)
volume(inventory)
}
