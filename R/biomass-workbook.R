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
    "Plot-to-plot t intervals are reported for equal-area inventories with at least three plots. For unequal plot areas, a sampled-area-weighted mean is reported and uncertainty is NA.",
    "Methods remain separate. Differences between methods are not formal model uncertainty; do not add or average method totals.",
    "No stump biomass adjustment is applied.",
    "Forest Research and Training Centre (2025); Sharma and Pukkala (1990); Chave et al. (2014); Global Wood Density Database v2.2."),
  stringsAsFactors = FALSE)

.excel_column_labels <- function() c(
  forest_id = "Forest ID", forest_area_ha = "Forest area (ha)",
  plot_id = "Plot ID", plot_area_ha = "Plot area (ha)", method = "Method",
  total_plots = "Number of plots", plots_with_estimates = "Plots with estimates",
  total_trees = "Total trees", estimated_trees = "Estimated trees",
  unestimated_trees = "Unestimated trees", extrapolated_trees = "Extrapolated trees",
  stem_coverage_pct = "Tree coverage (%)",
  basal_area_coverage_pct = "Basal-area coverage (%)",
  biomass_Mg_ha = "Biomass (Mg/ha)", carbon_Mg_ha = "Carbon (Mg/ha)",
  coverage_status = "Coverage status", mean_biomass_Mg_ha = "Mean biomass (Mg/ha)",
  sd_biomass_Mg_ha = "Biomass SD (Mg/ha)", se_biomass_Mg_ha = "Biomass SE (Mg/ha)",
  ci95_lower_biomass_Mg_ha = "Biomass 95% CI lower (Mg/ha)",
  ci95_upper_biomass_Mg_ha = "Biomass 95% CI upper (Mg/ha)",
  mean_carbon_Mg_ha = "Mean carbon (Mg/ha)", sd_carbon_Mg_ha = "Carbon SD (Mg/ha)",
  se_carbon_Mg_ha = "Carbon SE (Mg/ha)",
  ci95_lower_carbon_Mg_ha = "Carbon 95% CI lower (Mg/ha)",
  ci95_upper_carbon_Mg_ha = "Carbon 95% CI upper (Mg/ha)",
  total_forest_biomass_Mg = "Total forest biomass (Mg)",
  total_forest_carbon_Mg = "Total forest carbon (Mg)",
  plot_area_design = "Plot-area design", summary_status = "Summary status",
  species = "Species", dbh_class_cm = "DBH class (cm)",
  tree_coverage_pct = "Tree coverage (%)",
  mean_tree_biomass_kg = "Mean tree biomass (kg/tree)",
  se_tree_biomass_kg = "Tree biomass SE (kg/tree)",
  mean_plot_biomass_Mg_ha = "Mean plot biomass (Mg/ha)",
  se_plot_biomass_Mg_ha = "Plot biomass SE (Mg/ha)",
  ci95_lower_plot_biomass_Mg_ha = "Plot biomass 95% CI lower (Mg/ha)",
  ci95_upper_plot_biomass_Mg_ha = "Plot biomass 95% CI upper (Mg/ha)",
  uncertainty_status = "Uncertainty status", tree_id = "Tree ID", dbh_cm = "DBH (cm)",
  height_m = "Height (m)", basal_area_m2 = "Basal area (m²)",
  frtc_biomass_kg = "FRTC biomass (kg/tree)", frtc_carbon_kg = "FRTC carbon (kg/tree)",
  frtc_estimation_status = "FRTC status",
  sharma_pukkala_biomass_kg = "Sharma & Pukkala biomass (kg/tree)",
  sharma_pukkala_carbon_kg = "Sharma & Pukkala carbon (kg/tree)",
  sharma_pukkala_estimation_status = "Sharma & Pukkala status",
  chave_biomass_kg = "Chave biomass (kg/tree)",
  chave_carbon_kg = "Chave carbon (kg/tree)", chave_estimation_status = "Chave status",
  carbon_fraction = "Carbon fraction", estimation_status = "Estimation status",
  calibration_status = "Calibration status",
  wood_density_g_cm3 = "Wood density (g/cm³)", density_source = "Density source",
  density_match_level = "Density match level", density_taxon_matched = "Matched taxon",
  biomass_moisture_basis = "Moisture basis", biomass_boundary = "Biomass boundary",
  model_citation = "Model citation")

.excel_table <- function(data) {
  labels <- .excel_column_labels()
  original <- names(data)
  matched <- labels[original]
  names(data) <- ifelse(is.na(matched), gsub("_", " ", original), matched)
  attr(data, "original_names") <- original
  data
}

.write_biomass_workbook <- function(result, path) {
  if (length(path) != 1L || is.na(path) || !grepl("\\.xlsx$", path, ignore.case = TRUE))
    stop("`output` must be one .xlsx file path.", call. = FALSE)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  tables <- list(Read_Me = result$calculation_notes,
                 Forest_Summary = result$forest_summary,
                 Plot_Summary = result$plot_summary,
                 Species_Summary = result$species_summary,
                 DBH_Summary = result$dbh_class_summary,
                 Tree_Results = result$tree_results,
                 Method_Audit = result$method_audit)
  wb <- openxlsx::createWorkbook(creator = "Santosh Ayer")
  header <- openxlsx::createStyle(fgFill = "#E7E6E6",
                                  textDecoration = "bold", halign = "center",
                                  valign = "center", wrapText = TRUE)
  note <- openxlsx::createStyle(wrapText = TRUE, valign = "top")
  four_decimal <- openxlsx::createStyle(numFmt = "0.0000")
  integer <- openxlsx::createStyle(numFmt = "0")
  for (sheet in names(tables)) {
    raw <- tables[[sheet]]
    dat <- .excel_table(raw)
    openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeData(wb, sheet, dat, withFilter = TRUE)
    openxlsx::addStyle(wb, sheet, header, rows = 1, cols = seq_len(ncol(dat)),
                       gridExpand = TRUE)
    openxlsx::freezePane(wb, sheet, firstRow = TRUE)
    openxlsx::setColWidths(wb, sheet, cols = seq_len(ncol(dat)), widths = "auto")
    wide <- which(nchar(names(dat)) > 24)
    if (length(wide)) openxlsx::setColWidths(wb, sheet, cols = wide, widths = 24)
    numeric_cols <- which(vapply(raw, is.numeric, logical(1)))
    count_cols <- which(grepl("(^|_)(plots|trees)$|^plots_with_estimates$",
                              names(raw)))
    decimal_cols <- setdiff(numeric_cols, count_cols)
    if (length(decimal_cols) && nrow(dat)) openxlsx::addStyle(
      wb, sheet, four_decimal, rows = 2:(nrow(dat) + 1), cols = decimal_cols,
      gridExpand = TRUE, stack = TRUE)
    if (length(count_cols) && nrow(dat)) openxlsx::addStyle(
      wb, sheet, integer, rows = 2:(nrow(dat) + 1), cols = count_cols,
      gridExpand = TRUE, stack = TRUE)
  }
  openxlsx::setColWidths(wb, "Read_Me", 1, 24)
  openxlsx::setColWidths(wb, "Read_Me", 2, 90)
  openxlsx::addStyle(wb, "Read_Me", note,
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
