.validate_biomass_inventory <- function(data) {
  required <- c("tree_id", "plot_id", "plot_area_ha", "species", "dbh_cm",
                "height_m")
  .require_inventory_columns(data, required)
  if (!nrow(data)) {
    stop("The inventory must contain at least one tree.", call. = FALSE)
  }
  if (anyNA(data$tree_id) || any(!nzchar(trimws(as.character(data$tree_id))))) {
    stop("`tree_id` cannot be missing or blank.", call. = FALSE)
  }
  if (anyDuplicated(data$tree_id)) {
    stop("`tree_id` must be unique.", call. = FALSE)
  }
  if (anyNA(data$plot_id) || any(!nzchar(trimws(as.character(data$plot_id))))) {
    stop("`plot_id` cannot be missing or blank.", call. = FALSE)
  }
  if (anyNA(data$species) || any(!nzchar(trimws(as.character(data$species))))) {
    stop("`species` cannot be missing or blank.", call. = FALSE)
  }
  if (any(!is.finite(data$dbh_cm) | data$dbh_cm <= 0)) {
    stop("`dbh_cm` must contain positive finite values.", call. = FALSE)
  }
  if (any(!is.finite(data$height_m) | data$height_m <= 0)) {
    stop("`height_m` must contain positive finite values.", call. = FALSE)
  }
  .validate_plot_areas(data)
  invisible(TRUE)
}

.inventory_plot_results <- function(data) {
  groups <- split(data, data$plot_id, drop = TRUE)
  rows <- lapply(names(groups), function(id) {
    x <- groups[[id]]
    estimated <- x$estimation_status == "estimated" &
      is.finite(x$tree_biomass_kg)
    n_estimated <- sum(estimated)
    area <- unique(x$plot_area_ha)
    biomass_kg <- if (n_estimated) {
      sum(x$tree_biomass_kg[estimated], na.rm = TRUE)
    } else NA_real_
    carbon_kg <- if (n_estimated) {
      sum(x$tree_carbon_kg[estimated], na.rm = TRUE)
    } else NA_real_
    total_ba <- sum(x$basal_area_m2, na.rm = TRUE)
    estimated_ba <- sum(x$basal_area_m2[estimated], na.rm = TRUE)
    extrapolated <- estimated & grepl(
      "below|above|outside|multiple_dimensions", x$calibration_status
    )
    data.frame(
      plot_id = id,
      plot_total_trees = nrow(x),
      plot_estimated_trees = n_estimated,
      plot_unestimated_trees = nrow(x) - n_estimated,
      plot_extrapolated_trees = sum(extrapolated, na.rm = TRUE),
      plot_stem_coverage_pct = 100 * n_estimated / nrow(x),
      plot_basal_area_coverage_pct = if (total_ba > 0) {
        100 * estimated_ba / total_ba
      } else NA_real_,
      plot_biomass_kg = biomass_kg,
      plot_biomass_Mg_ha = biomass_kg / (1000 * area),
      plot_carbon_kg = carbon_kg,
      plot_carbon_Mg_ha = carbon_kg / (1000 * area),
      plot_summary_status = if (!n_estimated) {
        "no_estimate"
      } else if (all(estimated)) {
        "complete_estimate"
      } else {
        "partial_estimate"
      },
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

.append_plot_results <- function(data) {
  plot_results <- .inventory_plot_results(data)
  idx <- match(as.character(data$plot_id), plot_results$plot_id)
  added <- setdiff(names(plot_results), "plot_id")
  for (nm in added) data[[nm]] <- plot_results[[nm]][idx]
  data
}

.frtc_inventory_results <- function(inventory) {
  raw <- frtc_total_biomass(
    dbh = inventory$dbh_cm, height = inventory$height_m,
    species = inventory$species, keep_inputs = TRUE
  )
  out <- inventory
  details <- setdiff(names(raw), c("dbh_cm", "height_m", "species_input"))
  for (nm in details) out[[nm]] <- raw[[nm]]
  out$tree_biomass_kg <- raw$frtc_total_biomass_kg
  out$carbon_fraction <- 0.47
  out$tree_carbon_kg <- out$tree_biomass_kg * out$carbon_fraction
  out$basal_area_m2 <- pi * (as.numeric(out$dbh_cm) / 200)^2
  out$biomass_moisture_basis <- ifelse(
    out$estimation_status == "estimated", "oven_dry", NA_character_
  )
  out$model_source <- ifelse(
    out$estimation_status == "estimated", "FRTC (2025)", NA_character_
  )
  .append_plot_results(out)
}

.sp_inventory_results <- function(inventory) {
  raw <- sharma_pukkala_biomass(
    dbh = inventory$dbh_cm, height = inventory$height_m,
    species = inventory$species, keep_inputs = TRUE
  )
  out <- inventory
  details <- setdiff(names(raw), c("dbh_cm", "height_m", "species_input"))
  for (nm in details) out[[nm]] <- raw[[nm]]
  out$tree_biomass_kg <- raw$sp_total_biomass_kg
  out$tree_carbon_kg <- raw$sp_carbon_kg
  out$basal_area_m2 <- pi * (as.numeric(out$dbh_cm) / 200)^2
  .append_plot_results(out)
}

.chave_inventory_results <- function(inventory) {
  raw <- chave_biomass(
    dbh = inventory$dbh_cm, height = inventory$height_m,
    species = inventory$species, keep_inputs = TRUE
  )
  out <- inventory
  details <- setdiff(names(raw), c("dbh_cm", "height_m", "species_input"))
  for (nm in details) out[[nm]] <- raw[[nm]]
  out$tree_biomass_kg <- raw$chave_agb_kg
  out$tree_carbon_kg <- raw$chave_carbon_kg
  out$basal_area_m2 <- pi * (as.numeric(out$dbh_cm) / 200)^2
  .append_plot_results(out)
}

.biomass_disclaimer <- function(input) {
  data.frame(
    Topic = c(
      "Purpose", "Input file", "Required units", "Carbon fraction",
      "Plot calculation", "FRTC 2025", "Sharma-Pukkala",
      "Chave 2014", "Chave density lookup", "Partial estimates",
      "Extrapolation", "Method comparison", "Stump adjustment",
      "User responsibility"
    ),
    Description = c(
      "Separate biomass and carbon estimates from three published methods; this workbook does not create a hybrid estimate.",
      normalizePath(input, mustWork = FALSE),
      "DBH in cm, total height in m, plot area in ha; tree biomass and carbon in kg/tree; plot results in Mg/ha (metric tonnes/ha).",
      "Tree carbon is calculated as biomass multiplied by 0.47.",
      "Plot Mg/ha equals the sum of estimated tree kg divided by 1,000 and by plot area in hectares.",
      "FRTC (2025) species equations; oven-dry biomass above 0.30 m; stump excluded; only seven supported species.",
      "Sharma and Pukkala (1990); air-dry stem + branch + foliage biomass; stump boundary not specified.",
      "Chave et al. (2014) height-inclusive pantropical aboveground biomass equation; oven-dry basis.",
      "Automatic only: applicable FRTC basic density first, then GWDD v2.2 binomial, then GWDD v2.2 genus. Genus matches are flagged.",
      "A partial plot estimate sums only estimated trees. Always inspect plot coverage and plot_summary_status before use.",
      "Predictions outside reported model-development ranges are retained but flagged in calibration_status.",
      "Do not add, average, or merge totals across method sheets. Moisture basis, biomass boundary, model scope, and density assumptions differ.",
      "No stump biomass adjustment is applied in this version.",
      "Users must verify species identification, measurements, plot area, model suitability, density match, coverage, and calibration status before reporting results."
    ),
    stringsAsFactors = FALSE
  )
}

.write_biomass_workbook <- function(tables, disclaimer, path) {
  wb <- openxlsx::createWorkbook(creator = "nepalallometry")
  green <- "#176B3A"
  header <- openxlsx::createStyle(
    fontColour = "#FFFFFF", fgFill = green, textDecoration = "bold",
    halign = "center", valign = "center", wrapText = TRUE
  )
  title <- openxlsx::createStyle(
    fontSize = 16, textDecoration = "bold", fontColour = green
  )
  note <- openxlsx::createStyle(wrapText = TRUE, valign = "top")

  openxlsx::addWorksheet(wb, "Disclaimer")
  openxlsx::writeData(wb, "Disclaimer",
                      "Nepal Allometry: Method Notes and Disclaimer",
                      startRow = 1, startCol = 1)
  openxlsx::addStyle(wb, "Disclaimer", title, rows = 1, cols = 1)
  openxlsx::writeDataTable(wb, "Disclaimer", disclaimer, startRow = 3,
                           tableStyle = "TableStyleMedium4")
  openxlsx::addStyle(wb, "Disclaimer", note,
                     rows = 4:(nrow(disclaimer) + 3), cols = 1:2,
                     gridExpand = TRUE)
  openxlsx::setColWidths(wb, "Disclaimer", cols = 1, widths = 24)
  openxlsx::setColWidths(wb, "Disclaimer", cols = 2, widths = 90)
  openxlsx::setRowHeights(wb, "Disclaimer",
                          rows = 3:(nrow(disclaimer) + 3), heights = 34)
  openxlsx::freezePane(wb, "Disclaimer", firstActiveRow = 4)

  for (sheet in names(tables)) {
    dat <- tables[[sheet]]
    openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeDataTable(wb, sheet, dat,
                             tableStyle = "TableStyleMedium4",
                             withFilter = TRUE)
    openxlsx::addStyle(wb, sheet, header, rows = 1,
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

#' Calculate inventory biomass with three methods and write one workbook
#'
#' Reads one tree-inventory CSV and writes an Excel workbook containing a
#' disclaimer plus separate FRTC 2025, Sharma-Pukkala, and Chave 2014 result
#' sheets. Each method sheet retains every input row and repeats its plot-level
#' biomass, carbon, coverage, and status values on the corresponding tree rows.
#' The three methods are never combined.
#'
#' @param input Path to a CSV containing `tree_id`, `plot_id`, `plot_area_ha`,
#'   `species`, `dbh_cm`, and `height_m`. Additional columns are preserved.
#' @param output Path for the resulting `.xlsx` workbook. By default, it is
#'   saved beside `input` using the suffix `_biomass_results.xlsx`.
#' @return Invisibly, a list containing the workbook path and the three result
#'   data frames.
#' @export
#'
#' @examples
#' \dontrun{
#' biomass_from_csv("forest_inventory.csv")
#' }
biomass_from_csv <- function(input, output = NULL) {
  if (length(input) != 1L || !file.exists(input)) {
    stop("`input` must identify one existing CSV file.", call. = FALSE)
  }
  if (is.null(output)) {
    stem <- tools::file_path_sans_ext(basename(input))
    output <- file.path(dirname(input), paste0(stem, "_biomass_results.xlsx"))
  }
  if (length(output) != 1L || is.na(output) ||
      !nzchar(trimws(output)) || !grepl("\\.xlsx$", output, ignore.case = TRUE)) {
    stop("`output` must be one `.xlsx` file path.", call. = FALSE)
  }
  output_dir <- dirname(output)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(output_dir)) {
    stop("Could not create the output directory.", call. = FALSE)
  }

  inventory <- utils::read.csv(input, stringsAsFactors = FALSE,
                               check.names = FALSE)
  for (nm in c("plot_area_ha", "dbh_cm", "height_m")) {
    if (nm %in% names(inventory)) {
      inventory[[nm]] <- suppressWarnings(as.numeric(inventory[[nm]]))
    }
  }
  .validate_biomass_inventory(inventory)
  tables <- list(
    FRTC_2025 = .frtc_inventory_results(inventory),
    Sharma_Pukkala = .sp_inventory_results(inventory),
    Chave_2014 = .chave_inventory_results(inventory)
  )
  .write_biomass_workbook(
    tables, .biomass_disclaimer(input), output
  )
  result <- c(list(workbook = normalizePath(output, mustWork = FALSE)), tables)
  invisible(result)
}
