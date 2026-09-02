.validate_biomass_inventory <- function(data) {
  .require_inventory_columns(data, c("tree_id", "plot_id", "plot_area_ha",
                                     "species", "dbh_cm", "height_m"))
  if (!nrow(data)) stop("The inventory must contain at least one tree.", call. = FALSE)
  for (nm in c("tree_id", "plot_id", "species")) if (
    anyNA(data[[nm]]) || any(!nzchar(trimws(as.character(data[[nm]])))))
    stop(sprintf("`%s` cannot be missing or blank.", nm), call. = FALSE)
  if (anyDuplicated(data$tree_id)) stop("`tree_id` must be unique.", call. = FALSE)
  if (any(!is.finite(data$dbh_cm) | data$dbh_cm <= 0))
    stop("`dbh_cm` must contain positive finite values.", call. = FALSE)
  if (any(!is.finite(data$height_m) | data$height_m <= 0))
    stop("`height_m` must contain positive finite values.", call. = FALSE)
  check <- data
  check$plot_id <- paste(data$forest_id, data$plot_id, sep = "::")
  .validate_plot_areas(check); invisible(TRUE)
}

.biomass_calculation_notes <- function(result) data.frame(
  Topic = c("Package", "Calculation date", "Input", "Methods", "Units",
            "Carbon fraction", "Wood density", "FRTC", "Sharma & Pukkala",
            "Chave", "Coverage", "Forest totals", "Confidence intervals",
            "Method comparison", "Stump adjustment", "Citations"),
  Description = c(
    paste0("nepalallometry ", tryCatch(
      as.character(utils::packageVersion("nepalallometry")),
      error = function(e) "development version")),
    as.character(Sys.Date()), attr(result, "input_source"),
    paste(vapply(attr(result, "methods"), .method_label, character(1)), collapse = ", "),
    "Tree biomass/carbon: kg/tree. Plot and mean forest values: Mg/ha. Estimated forest stocks: Mg.",
    as.character(attr(result, "carbon_fraction")),
    "Handled automatically where required. FRTC uses specified density rules; Sharma & Pukkala uses fixed species/group air-dry densities; Chave uses applicable FRTC basic density then GWDD v2.2 binomial or genus matches.",
    "FRTC (2025): oven-dry biomass above 0.30 m; stump excluded; seven supported taxa.",
    "Sharma and Pukkala (1990): air-dry stem + branch + foliage biomass; stump boundary not specified.",
    "Chave et al. (2014): height-inclusive pantropical oven-dry aboveground biomass equation.",
    "Coverage describes model coverage of inventoried trees, not geographic sampling coverage. Partial estimates sum supported trees only.",
    "Calculated only when forest_area_ha is supplied. Otherwise total forest stock is NA.",
    "Plot-to-plot t intervals are reported for equal-area plots with at least two estimates. For unequal plot areas, a sampled-area-weighted mean is reported and uncertainty is NA.",
    "Methods remain separate. Differences between methods are not formal model uncertainty; do not add or average method totals.",
    "No stump biomass adjustment is applied.",
    "Forest Research and Training Centre (2025); Sharma and Pukkala (1990); Chave et al. (2014); Global Wood Density Database v2.2."),
  stringsAsFactors = FALSE)

.write_biomass_workbook <- function(result, path) {
  if (length(path) != 1L || is.na(path) || !grepl("\\.xlsx$", path, ignore.case = TRUE))
    stop("`output` must be one .xlsx file path.", call. = FALSE)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  tables <- list(Calculation_Notes = result$calculation_notes,
                 Forest_Summary = result$forest_summary,
                 Plot_Summary = result$plot_summary,
                 Species_Summary = result$species_summary,
                 DBH_Class_Summary = result$dbh_class_summary,
                 Tree_Results = result$tree_results)
  wb <- openxlsx::createWorkbook(creator = "Santosh Ayer")
  header <- openxlsx::createStyle(fontColour = "#FFFFFF", fgFill = "#176B3A",
                                  textDecoration = "bold", halign = "center",
                                  valign = "center", wrapText = TRUE)
  note <- openxlsx::createStyle(wrapText = TRUE, valign = "top")
  for (sheet in names(tables)) {
    dat <- tables[[sheet]]
    openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeDataTable(wb, sheet, dat, tableStyle = "TableStyleMedium4",
                             withFilter = TRUE)
    openxlsx::addStyle(wb, sheet, header, rows = 1, cols = seq_len(ncol(dat)),
                       gridExpand = TRUE)
    openxlsx::freezePane(wb, sheet, firstRow = TRUE)
    openxlsx::setColWidths(wb, sheet, cols = seq_len(ncol(dat)), widths = "auto")
    wide <- which(nchar(names(dat)) > 22)
    if (length(wide)) openxlsx::setColWidths(wb, sheet, cols = wide, widths = 22)
  }
  openxlsx::setColWidths(wb, "Calculation_Notes", 1, 24)
  openxlsx::setColWidths(wb, "Calculation_Notes", 2, 90)
  openxlsx::addStyle(wb, "Calculation_Notes", note,
                     rows = 2:(nrow(result$calculation_notes) + 1), cols = 1:2,
                     gridExpand = TRUE)
  openxlsx::saveWorkbook(wb, path, overwrite = TRUE); invisible(path)
}

#' Compatibility wrapper for CSV biomass inventories
#' @param input Existing CSV path.
#' @param output Optional output `.xlsx` path.
#' @param ... Additional arguments passed to [biomass()].
#' @return A `nepal_biomass_result` object, invisibly.
#' @export
biomass_from_csv <- function(input, output = NULL, ...) {
  if (!is.character(input) || length(input) != 1L ||
      tolower(tools::file_ext(input)) != "csv") stop(
    "`input` must identify one existing CSV file.", call. = FALSE)
  biomass(input, output = output, ...)
}
