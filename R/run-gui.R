#' Launch the nepalallometry graphical user interface
#'
#' Opens an interactive Shiny application for biomass, carbon, and tree-volume
#' estimation using the methods implemented in `nepalallometry`.
#'
#' @return No return value. Opens a Shiny application.
#' @export
run_gui <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop(
      "The 'shiny' package is required to use the GUI.\n",
      "Install it with install.packages('shiny').",
      call. = FALSE
    )
  }

  app_dir <- system.file("shiny", "nepalallometry", package = "nepalallometry")
  if (!nzchar(app_dir)) {
    stop("Could not find the nepalallometry Shiny application.", call. = FALSE)
  }

  shiny::runApp(app_dir, display.mode = "normal")
}
