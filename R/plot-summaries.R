.require_inventory_columns <- function(data, columns) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  missing <- setdiff(columns, names(data))
  if (length(missing)) {
    stop("Missing required column(s): ", paste(missing, collapse = ", "),
         ".", call. = FALSE)
  }
}

.validate_plot_areas <- function(data) {
  if (any(!is.finite(data$plot_area_ha) | data$plot_area_ha <= 0,
          na.rm = TRUE)) {
    stop("`plot_area_ha` must contain positive finite values.", call. = FALSE)
  }
  if (anyNA(data$plot_area_ha)) {
    stop("`plot_area_ha` cannot be missing.", call. = FALSE)
  }
  areas <- split(data$plot_area_ha, data$plot_id, drop = TRUE)
  inconsistent <- names(areas)[vapply(areas, function(x) {
    length(unique(x)) != 1L
  }, logical(1))]
  if (length(inconsistent)) {
    stop("Plot area is inconsistent within plot(s): ",
         paste(inconsistent, collapse = ", "), ".", call. = FALSE)
  }
  invisible(TRUE)
}

#' Estimate FRTC biomass and carbon for an inventory data frame
#'
#' @param data A data frame containing `tree_id`, `plot_id`, `plot_area_ha`,
#'   `species`, `dbh_cm`, and `height_m`.
#' @return The original rows with FRTC model metadata, biomass, carbon, basal
#'   area, and estimation status appended.
#' @export
estimate_frtc_biomass <- function(data) {
  required <- c("tree_id", "plot_id", "plot_area_ha", "species", "dbh_cm",
                "height_m")
  .require_inventory_columns(data, required)
  if (anyNA(data$tree_id) || any(!nzchar(trimws(as.character(data$tree_id))))) {
    stop("`tree_id` cannot be missing or blank.", call. = FALSE)
  }
  if (anyDuplicated(data$tree_id)) {
    stop("`tree_id` must be unique.", call. = FALSE)
  }
  if (anyNA(data$plot_id) || any(!nzchar(trimws(as.character(data$plot_id))))) {
    stop("`plot_id` cannot be missing or blank.", call. = FALSE)
  }
  .validate_plot_areas(data)

  estimates <- frtc_total_biomass(
    dbh = data$dbh_cm,
    height = data$height_m,
    species = data$species,
    keep_inputs = TRUE
  )
  result <- data
  result$species_standardized <- estimates$species_standardized
  result$scientific_name <- estimates$scientific_name
  result$wood_density_g_cm3 <- estimates$wood_density_g_cm3
  result$density_source <- estimates$density_source
  result$frtc_total_biomass_kg <- estimates$frtc_total_biomass_kg
  result$carbon_fraction <- 0.47
  result$frtc_carbon_kg <- result$frtc_total_biomass_kg * 0.47
  result$basal_area_m2 <- pi * (as.numeric(result$dbh_cm) / 200)^2
  result$estimation_status <- estimates$estimation_status
  result$calibration_dbh_min_cm <- estimates$calibration_dbh_min_cm
  result$calibration_dbh_max_cm <- estimates$calibration_dbh_max_cm
  result$calibration_height_min_m <- estimates$calibration_height_min_m
  result$calibration_height_max_m <- estimates$calibration_height_max_m
  result$within_calibration_range <- estimates$within_calibration_range
  result$calibration_status <- estimates$calibration_status
  result$biomass_boundary <- estimates$biomass_boundary
  result$model_source <- ifelse(
    result$estimation_status == "estimated", "FRTC 2025 Table 9", NA_character_
  )
  result
}

.summarize_group <- function(x, group_values) {
  estimated <- x$estimation_status == "estimated"
  area <- unique(x$plot_area_ha)
  n_estimated <- sum(estimated)
  extrapolated <- estimated & !is.na(x$within_calibration_range) &
    !x$within_calibration_range
  within_range <- estimated & !is.na(x$within_calibration_range) &
    x$within_calibration_range
  calibration_unassessed <- estimated & is.na(x$within_calibration_range)
  n_extrapolated <- sum(extrapolated)
  n_within_range <- sum(within_range)
  n_calibration_unassessed <- sum(calibration_unassessed)
  agb_kg <- if (n_estimated > 0) {
    sum(x$frtc_total_biomass_kg[estimated], na.rm = TRUE)
  } else {
    NA_real_
  }
  carbon_kg <- if (n_estimated > 0) {
    sum(x$frtc_carbon_kg[estimated], na.rm = TRUE)
  } else {
    NA_real_
  }
  total_ba <- sum(x$basal_area_m2, na.rm = TRUE)
  supported_ba <- sum(x$basal_area_m2[estimated], na.rm = TRUE)
  cbind(
    group_values,
    data.frame(
      plot_area_ha = area,
      total_trees = nrow(x),
      estimated_trees = n_estimated,
      unsupported_or_missing_trees = sum(!estimated),
      within_calibration_trees = n_within_range,
      extrapolated_trees = n_extrapolated,
      calibration_not_assessed_trees = n_calibration_unassessed,
      extrapolated_tree_pct_of_estimated = if (n_estimated > 0) {
        100 * n_extrapolated / n_estimated
      } else {
        NA_real_
      },
      stem_coverage_pct = 100 * n_estimated / nrow(x),
      basal_area_coverage_pct = if (total_ba > 0) 100 * supported_ba / total_ba else NA_real_,
      frtc_supported_agb_kg = agb_kg,
      frtc_supported_agb_Mg_ha = agb_kg / (1000 * area),
      carbon_fraction = 0.47,
      frtc_supported_carbon_Mg_ha = carbon_kg / (1000 * area),
      summary_status = if (all(estimated)) "complete_frtc_estimate" else
        "partial_frtc_estimate",
      calibration_summary_status = if (n_estimated == 0L) {
        "not_applicable"
      } else if (n_extrapolated > 0L) {
        "contains_extrapolation"
      } else if (n_calibration_unassessed > 0L) {
        "contains_unassessed_measurements"
      } else {
        "all_supported_trees_within_range"
      },
      biomass_boundary = "above 0.30 m; stump excluded",
      stringsAsFactors = FALSE
    )
  )
}

#' Summarize FRTC-supported biomass and carbon by plot
#'
#' @param data Output from [estimate_frtc_biomass()].
#' @return One row per plot, with biomass and carbon in Mg/ha and coverage.
#' @export
frtc_plot_summary <- function(data) {
  required <- c("plot_id", "plot_area_ha", "estimation_status",
                "frtc_total_biomass_kg", "frtc_carbon_kg", "basal_area_m2",
                "within_calibration_range")
  .require_inventory_columns(data, required)
  .validate_plot_areas(data)
  groups <- split(data, data$plot_id, drop = TRUE)
  out <- lapply(names(groups), function(id) {
    .summarize_group(groups[[id]], data.frame(plot_id = id))
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result
}

#' Summarize FRTC-supported biomass and carbon by plot and species
#'
#' @param data Output from [estimate_frtc_biomass()].
#' @return One row per plot and entered species.
#' @export
frtc_species_summary <- function(data) {
  required <- c("plot_id", "plot_area_ha", "species", "species_standardized",
                "estimation_status", "frtc_total_biomass_kg",
                "frtc_carbon_kg", "basal_area_m2",
                "within_calibration_range")
  .require_inventory_columns(data, required)
  .validate_plot_areas(data)
  species_label <- ifelse(is.na(data$species_standardized),
                          as.character(data$species), data$species_standardized)
  key <- interaction(data$plot_id, species_label, drop = TRUE, lex.order = TRUE)
  groups <- split(data, key, drop = TRUE)
  out <- lapply(groups, function(x) {
    label <- ifelse(is.na(x$species_standardized[1]),
                    as.character(x$species[1]), x$species_standardized[1])
    .summarize_group(x, data.frame(plot_id = as.character(x$plot_id[1]),
                                   species = label))
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result
}

#' Summarize FRTC-supported biomass and carbon by plot and DBH class
#'
#' @param data Output from [estimate_frtc_biomass()].
#' @return One row per plot and DBH class.
#' @export
frtc_dbh_summary <- function(data) {
  required <- c("plot_id", "plot_area_ha", "dbh_cm", "estimation_status",
                "frtc_total_biomass_kg", "frtc_carbon_kg", "basal_area_m2",
                "within_calibration_range")
  .require_inventory_columns(data, required)
  .validate_plot_areas(data)
  classes <- cut(
    data$dbh_cm,
    breaks = c(0, 10, 20, 30, 40, 50, Inf),
    labels = c("<=10", ">10-20", ">20-30", ">30-40", ">40-50", ">50"),
    right = TRUE
  )
  if (anyNA(classes)) {
    stop("All DBH values must be positive to form DBH classes.", call. = FALSE)
  }
  key <- interaction(data$plot_id, classes, drop = TRUE, lex.order = TRUE)
  groups <- split(data, key, drop = TRUE)
  class_values <- split(as.character(classes), key, drop = TRUE)
  out <- lapply(names(groups), function(k) {
    x <- groups[[k]]
    .summarize_group(x, data.frame(plot_id = as.character(x$plot_id[1]),
                                   dbh_class_cm = class_values[[k]][1]))
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result
}

#' Summarize biomass and carbon across inventory plots
#'
#' @param data Output from [frtc_plot_summary()].
#' @return A one-row data frame containing the mean, standard deviation,
#'   standard error, minimum, and maximum across plots.
#' @export
frtc_forest_summary <- function(data) {
  required <- c("plot_id", "frtc_supported_agb_Mg_ha",
                "frtc_supported_carbon_Mg_ha", "summary_status")
  .require_inventory_columns(data, required)
  if (anyDuplicated(data$plot_id)) {
    stop("`data` must contain only one row per plot.", call. = FALSE)
  }
  usable <- is.finite(data$frtc_supported_agb_Mg_ha)
  agb <- data$frtc_supported_agb_Mg_ha[usable]
  carbon <- data$frtc_supported_carbon_Mg_ha[usable]
  n <- length(agb)
  stat_sd <- function(x) if (length(x) > 1L) stats::sd(x) else NA_real_
  stat_se <- function(x) if (length(x) > 1L) stats::sd(x) / sqrt(length(x)) else NA_real_
  safe_min <- function(x) if (length(x)) min(x) else NA_real_
  safe_max <- function(x) if (length(x)) max(x) else NA_real_
  safe_mean <- function(x) if (length(x)) mean(x) else NA_real_

  data.frame(
    total_plots = nrow(data),
    plots_with_estimates = n,
    plots_without_estimates = nrow(data) - n,
    complete_plots = sum(data$summary_status == "complete_frtc_estimate"),
    partial_plots = sum(data$summary_status == "partial_frtc_estimate"),
    mean_frtc_supported_agb_Mg_ha = safe_mean(agb),
    sd_frtc_supported_agb_Mg_ha = stat_sd(agb),
    se_frtc_supported_agb_Mg_ha = stat_se(agb),
    min_frtc_supported_agb_Mg_ha = safe_min(agb),
    max_frtc_supported_agb_Mg_ha = safe_max(agb),
    carbon_fraction = 0.47,
    mean_frtc_supported_carbon_Mg_ha = safe_mean(carbon),
    sd_frtc_supported_carbon_Mg_ha = stat_sd(carbon),
    se_frtc_supported_carbon_Mg_ha = stat_se(carbon),
    min_frtc_supported_carbon_Mg_ha = safe_min(carbon),
    max_frtc_supported_carbon_Mg_ha = safe_max(carbon),
    forest_summary_status = if (
      any(data$summary_status == "partial_frtc_estimate") || any(!usable)
    ) "contains_partial_or_unestimated_plots" else "all_plots_complete",
    biomass_boundary = "above 0.30 m; stump excluded",
    stringsAsFactors = FALSE
  )
}

#' Run the FRTC biomass workflow from a CSV file
#'
#' @param input Path to an inventory CSV containing `tree_id`, `plot_id`,
#'   `plot_area_ha`, `species`, `dbh_cm`, and `height_m`.
#' @param output_dir Directory in which result CSV files are saved. Defaults
#'   to the directory containing `input`.
#' @param prefix Filename prefix. Defaults to the input filename without its
#'   `.csv` extension.
#' @param output_format Output as one formatted Excel workbook (`"excel"`),
#'   five CSV files (`"csv"`), or both (`"both"`).
#' @return A list containing all result tables and their saved file paths.
#' @export
frtc_biomass_from_csv <- function(input, output_dir = dirname(input),
                                  prefix = NULL,
                                  output_format = c("excel", "csv", "both")) {
  output_format <- match.arg(output_format)
  if (length(input) != 1L || !file.exists(input)) {
    stop("`input` must identify one existing CSV file.", call. = FALSE)
  }
  if (is.null(prefix)) {
    prefix <- tools::file_path_sans_ext(basename(input))
  }
  if (length(prefix) != 1L || is.na(prefix) || !nzchar(trimws(prefix))) {
    stop("`prefix` must be one non-empty filename prefix.", call. = FALSE)
  }
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(output_dir)) {
    stop("Could not create `output_dir`.", call. = FALSE)
  }

  inventory <- utils::read.csv(input, stringsAsFactors = FALSE,
                               check.names = FALSE)
  trees <- estimate_frtc_biomass(inventory)
  plots <- frtc_plot_summary(trees)
  species <- frtc_species_summary(trees)
  dbh_classes <- frtc_dbh_summary(trees)
  forest <- frtc_forest_summary(plots)

  tables <- list(
    tree_results = trees,
    plot_summary = plots,
    species_summary = species,
    dbh_class_summary = dbh_classes,
    forest_summary = forest
  )
  saved_files <- character()

  if (output_format %in% c("csv", "both")) {
    suffixes <- c("tree_results", "plot_summary", "species_summary",
                  "dbh_class_summary", "forest_summary")
    csv_paths <- file.path(output_dir, paste0(prefix, "_", suffixes, ".csv"))
    for (i in seq_along(tables)) {
      utils::write.csv(tables[[i]], csv_paths[i], row.names = FALSE, na = "")
    }
    saved_files <- c(saved_files,
                     stats::setNames(csv_paths, paste0("csv_", suffixes)))
  }

  if (output_format %in% c("excel", "both")) {
    excel_path <- file.path(output_dir, paste0(prefix, "_frtc_results.xlsx"))
    .write_frtc_excel(tables, excel_path, input)
    saved_files <- c(saved_files, excel_workbook = excel_path)
  }

  tables$files <- normalizePath(saved_files, mustWork = FALSE)
  tables
}

.write_frtc_excel <- function(tables, path, input) {
  wb <- openxlsx::createWorkbook(creator = "nepalallometry")
  green <- "#176B3A"
  header_style <- openxlsx::createStyle(
    fontColour = "#FFFFFF", fgFill = green, textDecoration = "bold",
    halign = "center", valign = "center", wrapText = TRUE,
    border = "Bottom", borderColour = "#FFFFFF"
  )
  title_style <- openxlsx::createStyle(
    fontSize = 16, textDecoration = "bold", fontColour = green
  )
  note_style <- openxlsx::createStyle(wrapText = TRUE, valign = "top")

  openxlsx::addWorksheet(wb, "About")
  openxlsx::writeData(wb, "About", "Nepal Allometry: FRTC Biomass Results",
                      startRow = 1, startCol = 1)
  openxlsx::addStyle(wb, "About", title_style, rows = 1, cols = 1)
  about <- data.frame(
    Item = c(
      "Input file", "Model source", "Response", "Biomass boundary",
      "Carbon fraction", "Biomass unit", "Carbon unit",
      "Important interpretation"
    ),
    Description = c(
      normalizePath(input, mustWork = FALSE),
      "FRTC (2025), Allometric Equations for Seven Major Tree Species of Nepal, Volume I",
      "Total aboveground biomass",
      "Biomass above 0.30 m; stump excluded",
      "0.47",
      "Mg/ha (numerically equal to metric tonnes per hectare)",
      "Mg C/ha (metric tonnes of carbon per hectare)",
      paste(
        "Partial estimates include only species supported by FRTC models.",
        "Check coverage and summary-status columns before interpretation."
      )
    ),
    stringsAsFactors = FALSE
  )
  openxlsx::writeDataTable(wb, "About", about, startRow = 3,
                           tableStyle = "TableStyleMedium4")
  openxlsx::addStyle(wb, "About", note_style, rows = 4:(nrow(about) + 3),
                     cols = 1:2, gridExpand = TRUE)
  openxlsx::setColWidths(wb, "About", cols = 1, widths = 24)
  openxlsx::setColWidths(wb, "About", cols = 2, widths = 85)
  openxlsx::setRowHeights(wb, "About", rows = 3:(nrow(about) + 3),
                          heights = 32)

  workbook_tables <- c(
    tables,
    list(model_registry = frtc_models(), density_rules = frtc_density())
  )
  sheet_names <- c(
    tree_results = "Tree Results",
    plot_summary = "Plot Summary",
    species_summary = "Species Summary",
    dbh_class_summary = "DBH Class Summary",
    forest_summary = "Forest Summary",
    model_registry = "Model Registry",
    density_rules = "Density Rules"
  )
  for (nm in names(workbook_tables)) {
    sheet <- unname(sheet_names[nm])
    dat <- workbook_tables[[nm]]
    openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeDataTable(wb, sheet, dat, tableStyle = "TableStyleMedium4",
                             withFilter = TRUE)
    openxlsx::addStyle(wb, sheet, header_style, rows = 1,
                       cols = seq_len(ncol(dat)), gridExpand = TRUE)
    openxlsx::freezePane(wb, sheet, firstRow = TRUE)
    openxlsx::setColWidths(wb, sheet, cols = seq_len(ncol(dat)),
                           widths = "auto")
    wide <- which(nchar(names(dat)) > 24)
    if (length(wide)) {
      openxlsx::setColWidths(wb, sheet, cols = wide, widths = 24)
    }
  }
  openxlsx::saveWorkbook(wb, path, overwrite = TRUE)
  invisible(path)
}
