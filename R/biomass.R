.biomass_methods <- function(methods) {
  aliases <- c(frtc = "frtc", sharma_pukkala = "sharma_pukkala",
               sharma = "sharma_pukkala", chave = "chave")
  methods <- tolower(gsub("[ &-]+", "_", methods))
  out <- unname(aliases[methods])
  if (!length(out) || anyNA(out)) stop(
    "`methods` must contain only 'frtc', 'sharma_pukkala', or 'chave'.",
    call. = FALSE)
  unique(out)
}

.method_label <- function(method) unname(c(
  frtc = "FRTC", sharma_pukkala = "Sharma & Pukkala", chave = "Chave"
)[method])

.read_biomass_input <- function(input, sheet = 1) {
  if (is.data.frame(input)) return(list(
    data = input, source = "R data frame",
    output = file.path(getwd(), "biomass_results.xlsx")
  ))
  if (length(input) != 1L || is.na(input) || !file.exists(input)) stop(
    "`input` must be a data frame or one existing .csv or .xlsx file.",
    call. = FALSE)
  ext <- tolower(tools::file_ext(input))
  if (!ext %in% c("csv", "xlsx")) stop(
    "`input` must be a .csv or .xlsx file. Save legacy .xls files as .xlsx first.",
    call. = FALSE)
  dat <- if (ext == "csv") {
    utils::read.csv(input, stringsAsFactors = FALSE, check.names = FALSE)
  } else openxlsx::read.xlsx(input, sheet = sheet, check.names = FALSE)
  stem <- tools::file_path_sans_ext(basename(input))
  list(data = dat, source = normalizePath(input, mustWork = FALSE),
       output = file.path(dirname(input), paste0(stem, "_biomass_results.xlsx")))
}

.prepare_biomass_inventory <- function(data) {
  .require_inventory_columns(data, c("tree_id", "plot_id", "plot_area_ha",
                                     "species", "dbh_cm", "height_m"))
  for (nm in c("plot_area_ha", "dbh_cm", "height_m", "forest_area_ha"))
    if (nm %in% names(data)) data[[nm]] <- suppressWarnings(as.numeric(data[[nm]]))
  if (!"forest_id" %in% names(data)) data$forest_id <- "Forest_1"
  data$forest_id <- trimws(as.character(data$forest_id))
  if (anyNA(data$forest_id) || any(!nzchar(data$forest_id))) stop(
    "`forest_id` cannot contain missing or blank values.", call. = FALSE)
  if (!"forest_area_ha" %in% names(data)) data$forest_area_ha <- NA_real_
  if (any(!is.na(data$forest_area_ha) &
          (!is.finite(data$forest_area_ha) | data$forest_area_ha <= 0))) stop(
    "`forest_area_ha` must be positive when supplied.", call. = FALSE)
  for (id in unique(data$forest_id)) {
    area <- unique(stats::na.omit(data$forest_area_ha[data$forest_id == id]))
    if (length(area) > 1L) stop(
      "`forest_area_ha` must be constant within each `forest_id`.", call. = FALSE)
  }
  .validate_biomass_inventory(data)
  data$.plot_key <- paste(data$forest_id, data$plot_id, sep = "\r")
  data$basal_area_m2 <- pi * (data$dbh_cm / 200)^2
  data
}

.calculate_method <- function(inventory, method, carbon_fraction) {
  raw <- switch(method,
    frtc = frtc_total_biomass(inventory$dbh_cm, inventory$height_m,
                              inventory$species, keep_inputs = TRUE),
    sharma_pukkala = sharma_pukkala_biomass(
      inventory$dbh_cm, inventory$height_m, inventory$species,
      carbon_fraction = carbon_fraction, keep_inputs = TRUE),
    chave = chave_biomass(inventory$dbh_cm, inventory$height_m,
                          inventory$species, carbon_fraction = carbon_fraction,
                          keep_inputs = TRUE))
  biomass_kg <- switch(method, frtc = raw$frtc_total_biomass_kg,
                       sharma_pukkala = raw$sp_total_biomass_kg,
                       chave = raw$chave_agb_kg)
  carbon_kg <- if (method == "frtc") biomass_kg * carbon_fraction else
    switch(method, sharma_pukkala = raw$sp_carbon_kg,
           chave = raw$chave_carbon_kg)
  density <- if ("wood_density_g_cm3" %in% names(raw)) raw$wood_density_g_cm3
    else if ("density_kg_m3" %in% names(raw)) raw$density_kg_m3 / 1000 else NA_real_
  density_source <- if ("density_source" %in% names(raw)) raw$density_source
    else if (method == "sharma_pukkala") "Sharma_Pukkala_fixed_density" else NA_character_
  match_level <- if ("density_match_level" %in% names(raw)) raw$density_match_level
    else NA_character_
  matched_taxon <- if ("density_taxon_matched" %in% names(raw))
    raw$density_taxon_matched else NA_character_
  boundary <- if ("biomass_boundary" %in% names(raw)) raw$biomass_boundary else NA_character_
  moisture <- if ("biomass_moisture_basis" %in% names(raw))
    raw$biomass_moisture_basis else ifelse(method == "frtc" & raw$estimation_status == "estimated",
                                           "oven_dry", NA_character_)
  data.frame(
    forest_id = inventory$forest_id, plot_id = inventory$plot_id,
    plot_key = inventory$.plot_key, plot_area_ha = inventory$plot_area_ha,
    tree_id = inventory$tree_id, species = inventory$species,
    dbh_cm = inventory$dbh_cm, basal_area_m2 = inventory$basal_area_m2,
    method_id = method, method = .method_label(method), biomass_kg = biomass_kg,
    carbon_kg = carbon_kg, wood_density_g_cm3 = density,
    density_source = density_source, density_match_level = match_level,
    density_taxon_matched = matched_taxon,
    biomass_moisture_basis = moisture, biomass_boundary = boundary,
    estimation_status = raw$estimation_status,
    calibration_status = raw$calibration_status, stringsAsFactors = FALSE)
}

.coverage_status <- function(n, estimated) {
  if (!estimated) "no_tree_estimates" else if (estimated == n)
    "complete_tree_coverage" else "partial_tree_coverage"
}

.plot_method_summary <- function(x) {
  groups <- split(x, x$plot_key, drop = TRUE)
  do.call(rbind, lapply(groups, function(z) {
    ok <- z$estimation_status == "estimated" & is.finite(z$biomass_kg)
    nb <- sum(ok); total_ba <- sum(z$basal_area_m2, na.rm = TRUE)
    biomass <- if (nb) sum(z$biomass_kg[ok]) else NA_real_
    carbon <- if (nb) sum(z$carbon_kg[ok]) else NA_real_
    extrap <- ok & grepl("below|above|outside|multiple_dimensions",
                         z$calibration_status)
    data.frame(
      forest_id = z$forest_id[1], plot_id = z$plot_id[1],
      plot_area_ha = z$plot_area_ha[1], method_id = z$method_id[1],
      method = z$method[1], total_trees = nrow(z), estimated_trees = nb,
      unestimated_trees = nrow(z) - nb,
      extrapolated_trees = sum(extrap, na.rm = TRUE),
      stem_coverage_pct = 100 * nb / nrow(z),
      basal_area_coverage_pct = if (total_ba > 0)
        100 * sum(z$basal_area_m2[ok], na.rm = TRUE) / total_ba else NA_real_,
      biomass_Mg_ha = biomass / (1000 * z$plot_area_ha[1]),
      carbon_Mg_ha = carbon / (1000 * z$plot_area_ha[1]),
      coverage_status = .coverage_status(nrow(z), nb), stringsAsFactors = FALSE)
  }))
}

.plot_summary_table <- function(method_tables) {
  out <- do.call(rbind, lapply(method_tables, .plot_method_summary))
  out <- out[order(out$forest_id, out$plot_id, out$method), ]
  out$method_id <- NULL
  rownames(out) <- NULL
  out
}

.mean_stats <- function(values) {
  values <- values[is.finite(values)]; n <- length(values)
  avg <- if (n) mean(values) else NA_real_
  sd <- if (n > 1) stats::sd(values) else NA_real_
  se <- if (n > 1) sd / sqrt(n) else NA_real_
  margin <- if (n >= 3) stats::qt(0.975, n - 1) * se else NA_real_
  c(n = n, mean = avg, sd = sd, se = se,
    lower = avg - margin, upper = avg + margin)
}

.forest_summary_table <- function(plot_long, inventory) {
  groups <- split(plot_long, interaction(plot_long$forest_id,
                                         plot_long$method, drop = TRUE))
  out <- lapply(groups, function(z) {
    forest <- z$forest_id[1]
    area <- unique(stats::na.omit(inventory$forest_area_ha[
      inventory$forest_id == forest])); area <- if (length(area)) area[1] else NA_real_
    equal_plots <- length(unique(z$plot_area_ha)) == 1L
    b <- .mean_stats(z$biomass_Mg_ha); c <- .mean_stats(z$carbon_Mg_ha)
    if (!equal_plots) {
      ok <- is.finite(z$biomass_Mg_ha)
      if (any(ok)) b["mean"] <- stats::weighted.mean(z$biomass_Mg_ha[ok], z$plot_area_ha[ok])
      ok <- is.finite(z$carbon_Mg_ha)
      if (any(ok)) c["mean"] <- stats::weighted.mean(z$carbon_Mg_ha[ok], z$plot_area_ha[ok])
      b[c("sd", "se", "lower", "upper")] <- NA_real_
      c[c("sd", "se", "lower", "upper")] <- NA_real_
    }
    data.frame(
      forest_id = forest, forest_area_ha = area, method = z$method[1],
      total_plots = nrow(z), plots_with_estimates = sum(is.finite(z$biomass_Mg_ha)),
      total_trees = sum(z$total_trees), estimated_trees = sum(z$estimated_trees),
      stem_coverage_pct = 100 * sum(z$estimated_trees) / sum(z$total_trees),
      basal_area_coverage_pct = if (any(is.finite(z$basal_area_coverage_pct)))
        stats::weighted.mean(z$basal_area_coverage_pct, z$total_trees,
                             na.rm = TRUE) else NA_real_,
      mean_biomass_Mg_ha = b["mean"], sd_biomass_Mg_ha = b["sd"],
      se_biomass_Mg_ha = b["se"], ci95_lower_biomass_Mg_ha = b["lower"],
      ci95_upper_biomass_Mg_ha = b["upper"], mean_carbon_Mg_ha = c["mean"],
      sd_carbon_Mg_ha = c["sd"], se_carbon_Mg_ha = c["se"],
      ci95_lower_carbon_Mg_ha = c["lower"], ci95_upper_carbon_Mg_ha = c["upper"],
      total_forest_biomass_Mg = b["mean"] * area,
      total_forest_carbon_Mg = c["mean"] * area,
      plot_area_design = if (equal_plots) "equal_plot_area" else "unequal_plot_area_weighted_mean",
      uncertainty_status = if (!equal_plots) "unequal_plot_area_uncertainty_not_estimated"
      else if (sum(is.finite(z$biomass_Mg_ha)) < 3) "insufficient_plots"
      else "estimated_from_plots",
      summary_status = if (all(z$coverage_status == "no_tree_estimates")) "no_tree_estimates"
      else if (any(z$coverage_status != "complete_tree_coverage")) "partial_tree_coverage"
      else "complete_tree_coverage", stringsAsFactors = FALSE)
  })
  ans <- do.call(rbind, out); rownames(ans) <- NULL; ans
}

.category_summary <- function(method_tables, inventory, category, label) {
  result <- list(); k <- 1L
  for (forest in unique(inventory$forest_id)) {
    cats <- unique(as.character(inventory[[category]][inventory$forest_id == forest]))
    plot_keys <- unique(inventory$.plot_key[inventory$forest_id == forest])
    for (cat in cats) for (id in names(method_tables)) {
      x <- method_tables[[id]]
      ids <- inventory$tree_id[inventory$forest_id == forest &
                                as.character(inventory[[category]]) == cat]
      z <- x[x$tree_id %in% ids, ]
      ok <- z$estimation_status == "estimated" & is.finite(z$biomass_kg)
      plot_areas <- vapply(plot_keys, function(key)
        unique(inventory$plot_area_ha[inventory$.plot_key == key])[1], numeric(1))
      pv <- vapply(plot_keys, function(key) {
        q <- z$plot_key == key & ok
        area <- unique(inventory$plot_area_ha[inventory$.plot_key == key])[1]
        sum(z$biomass_kg[q], na.rm = TRUE) / (1000 * area)
      }, numeric(1)); s <- .mean_stats(pv)
      equal_plots <- length(unique(plot_areas)) == 1L
      if (!equal_plots) {
        s["mean"] <- stats::weighted.mean(pv, plot_areas)
        s[c("sd", "se", "lower", "upper")] <- NA_real_
      }
      result[[k]] <- data.frame(
        forest_id = forest, category = cat, method = .method_label(id),
        total_trees = nrow(z), estimated_trees = sum(ok),
        tree_coverage_pct = 100 * sum(ok) / nrow(z),
        mean_tree_biomass_kg = if (any(ok)) mean(z$biomass_kg[ok]) else NA_real_,
        se_tree_biomass_kg = if (sum(ok) > 1) stats::sd(z$biomass_kg[ok]) / sqrt(sum(ok)) else NA_real_,
        mean_plot_biomass_Mg_ha = s["mean"], se_plot_biomass_Mg_ha = s["se"],
        ci95_lower_plot_biomass_Mg_ha = s["lower"],
        ci95_upper_plot_biomass_Mg_ha = s["upper"],
        uncertainty_status = if (equal_plots) {
          if (length(pv) >= 3) "estimated_from_plots" else "insufficient_plots"
        } else "unequal_plot_area_uncertainty_not_estimated",
        stringsAsFactors = FALSE)
      names(result[[k]])[2] <- label; k <- k + 1L
    }
  }
  ans <- do.call(rbind, result); rownames(ans) <- NULL; ans
}

.tree_results_table <- function(inventory, methods, method_tables, carbon_fraction) {
  out <- inventory[setdiff(names(inventory), ".plot_key")]
  for (id in methods) {
    common <- method_tables[[id]][c(
      "biomass_kg", "carbon_kg", "estimation_status")]
    names(common) <- paste0(id, "_", names(common)); out <- cbind(out, common)
  }
  out$carbon_fraction <- carbon_fraction; out
}

.method_audit_table <- function(method_tables) {
  citations <- c(frtc = "Forest Research and Training Centre (2025)",
                 sharma_pukkala = "Sharma and Pukkala (1990)",
                 chave = "Chave et al. (2014)")
  out <- do.call(rbind, lapply(names(method_tables), function(id) {
    x <- method_tables[[id]][c(
      "tree_id", "method", "estimation_status", "calibration_status",
      "wood_density_g_cm3", "density_source", "density_match_level",
      "density_taxon_matched", "biomass_moisture_basis", "biomass_boundary")]
    x$model_citation <- citations[id]
    x
  }))
  out <- out[order(out$tree_id, out$method), ]
  rownames(out) <- NULL
  out
}

#' Estimate biomass and produce complete inventory summaries
#' @param input A data frame or path to a `.csv` or `.xlsx` inventory file.
#' @param output Optional output `.xlsx` path. Set to `FALSE` to skip writing.
#' @param sheet Excel sheet name or number when `input` is `.xlsx`.
#' @param methods Any of `"frtc"`, `"sharma_pukkala"`, and `"chave"`.
#' @param carbon_fraction Biomass carbon fraction, default 0.47.
#' @param dbh_breaks DBH class boundaries in cm.
#' @return A `nepal_biomass_result` object.
#' @export
biomass <- function(input, output = NULL, sheet = 1,
                    methods = c("frtc", "sharma_pukkala", "chave"),
                    carbon_fraction = 0.47,
                    dbh_breaks = c(0, 10, 20, 30, 40, 50, Inf)) {
  if (length(carbon_fraction) != 1L || !is.finite(carbon_fraction) ||
      carbon_fraction < 0 || carbon_fraction > 1) stop(
    "`carbon_fraction` must be one finite value between 0 and 1.", call. = FALSE)
  methods <- .biomass_methods(methods); source <- .read_biomass_input(input, sheet)
  inventory <- .prepare_biomass_inventory(source$data)
  inventory$dbh_class_cm <- cut(inventory$dbh_cm, breaks = dbh_breaks,
                                include.lowest = TRUE, right = FALSE)
  tables <- stats::setNames(lapply(methods, function(id)
    .calculate_method(inventory, id, carbon_fraction)), methods)
  plot <- .plot_summary_table(tables)
  result <- list(
    calculation_notes = NULL,
    forest_summary = .forest_summary_table(plot, inventory),
    plot_summary = plot,
    species_summary = .category_summary(tables, inventory, "species", "species"),
    dbh_class_summary = .category_summary(tables, inventory, "dbh_class_cm", "dbh_class_cm"),
    tree_results = .tree_results_table(inventory, methods, tables, carbon_fraction),
    method_audit = .method_audit_table(tables))
  class(result) <- c("nepal_biomass_result", "nepalallometry_result")
  attr(result, "methods") <- methods; attr(result, "input_source") <- source$source
  attr(result, "carbon_fraction") <- carbon_fraction
  result$calculation_notes <- .biomass_calculation_notes(result)
  if (!identical(output, FALSE)) {
    if (is.null(output)) output <- source$output
    .write_biomass_workbook(result, output)
    attr(result, "workbook") <- normalizePath(output, mustWork = FALSE)
  }
  invisible(result)
}

#' Extract biomass summaries
#' @param x A result returned by [biomass()].
#' @param ... Reserved for future use.
#' @export
forest_summary <- function(x, ...) UseMethod("forest_summary")
#' @export
forest_summary.nepal_biomass_result <- function(x, ...) x$forest_summary
#' @rdname forest_summary
#' @export
plot_summary <- function(x, ...) UseMethod("plot_summary")
#' @export
plot_summary.nepal_biomass_result <- function(x, ...) x$plot_summary
#' @rdname forest_summary
#' @export
species_summary <- function(x, ...) UseMethod("species_summary")
#' @export
species_summary.nepal_biomass_result <- function(x, ...) x$species_summary
#' @rdname forest_summary
#' @export
dbh_summary <- function(x, ...) UseMethod("dbh_summary")
#' @export
dbh_summary.nepal_biomass_result <- function(x, ...) x$dbh_class_summary
#' @rdname forest_summary
#' @export
tree_results <- function(x, ...) UseMethod("tree_results")
#' @export
tree_results.nepal_biomass_result <- function(x, ...) x$tree_results
#' @rdname forest_summary
#' @export
method_audit <- function(x, ...) UseMethod("method_audit")
#' @export
method_audit.nepal_biomass_result <- function(x, ...) x$method_audit

#' @export
summary.nepal_biomass_result <- function(object, ...) structure(
  object$forest_summary, class = c("nepal_biomass_summary", "data.frame"),
  workbook = attr(object, "workbook"))

#' @export
print.nepal_biomass_summary <- function(x, ...) {
  print.data.frame(x[c("forest_id", "method", "mean_biomass_Mg_ha",
                       "mean_carbon_Mg_ha", "summary_status")], row.names = FALSE)
  path <- attr(x, "workbook")
  if (!is.null(path)) cat("\nWorkbook:", path, "\n")
  invisible(x)
}
