% Generated manually to match the exported volume() interface
\name{volume}
\alias{volume}
\title{Estimate individual-tree or forest-inventory volume}
\usage{
volume(
  input,
  output = NULL,
  sheet = 1,
  methods = c("sharma_pukkala", "frtc"),
  dbh_breaks = c(0, 10, 20, 30, 40, 50, Inf)
)
}
\arguments{
\item{input}{A data frame or path to an existing \code{.csv} or \code{.xlsx} file.}
\item{output}{Optional \code{.xlsx} path for exporting results. For file inputs, an output workbook is created automatically when this is omitted.}
\item{sheet}{Worksheet to read when \code{input} is an \code{.xlsx} file. Defaults to 1.}
\item{methods}{One or both supported volume methods: \code{"sharma_pukkala"} and \code{"frtc"}. By default both are calculated.}
\item{dbh_breaks}{Breaks used for DBH-class summaries when plot information is supplied.}
}
\value{
An object of class \code{nepal_volume_result}. Individual-tree inputs contain
\code{tree_results} and \code{method_audit}. Forest-inventory inputs additionally
contain \code{forest_summary}, \code{plot_summary}, \code{species_summary}, and
\code{dbh_class_summary}.
}
\description{
Calculates tree volume using Sharma-Pukkala stem-volume equations combined
with Forest Regulation branch-volume ratios and/or FRTC (2025) stem-volume
equations. The function automatically distinguishes individual-tree inputs from
forest inventories according to whether both \code{plot_id} and
\code{plot_area_ha} are supplied.
}
\details{
The minimum columns for individual-tree volume estimation are \code{tree_id},
\code{species}, \code{dbh_cm}, and \code{height_m}. For forest-inventory
summaries, both \code{plot_id} and \code{plot_area_ha} must also be supplied.
Optional columns include \code{forest_id}, \code{forest_area_ha}, and
\code{branch_group}.

For Sharma-Pukkala + Forest Regulation, total volume is stem volume plus branch
volume. For species requiring a generic Forest Regulation branch category, the
user must explicitly enter \code{other_broadleaf} or \code{other_conifer}; the
package does not infer this category.

For FRTC (2025), the package returns total stem volume over bark, under-bark stem
volume to a 20-cm over-bark top diameter, and under-bark stem volume to a 10-cm
over-bark top diameter. FRTC volume outputs exclude the 30-cm stump and exclude
branches. Thus, the displayed FRTC total volume is total stem volume, not total
tree volume including branches.
}
\examples{
trees <- data.frame(
  tree_id = c("T1", "T2"),
  species = c("sal", "terminalia_alata"),
  dbh_cm = c(60, 45),
  height_m = c(25, 22),
  branch_group = c(NA, "other_broadleaf")
)
volume(trees)
volume(trees, methods = "frtc")
}
