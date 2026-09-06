% Generated manually to document the exported GUI launcher
\name{run_gui}
\alias{run_gui}
\title{Launch the nepalallometry graphical user interface}
\usage{
run_gui()
}
\value{
No return value. The function launches an interactive Shiny application.
}
\description{
Launches the graphical user interface for \pkg{nepalallometry}. The interface
provides access to biomass, carbon, and tree-volume estimation workflows using
the methods implemented in the package.
}
\details{
The GUI requires the \pkg{shiny} package. If \pkg{shiny} is not installed,
\code{run_gui()} stops with an informative message explaining how to install it.
The calculations performed through the interface call the existing
\pkg{nepalallometry} functions rather than maintaining separate equation code.
}
\examples{
\dontrun{
run_gui()
}
}
