#' Estimate individual-tree or inventory volume
#'
#' Applies supported tree-volume methods to either individual trees or a forest
#' inventory. When plot information is supplied, tree-, plot-, species-,
#' DBH-class-, and forest-level summaries are produced. When plot information is
#' absent, only individual-tree results and the method audit are produced. The
#' current implementation supports the Sharma-Pukkala stem-volume equations
#' combined with branch-volume ratios from Schedule 9 of Nepal's Forest
#' Regulations 2079.
#'
#' @param input A data frame or path to an existing `.csv` or `.xlsx` file.
#' @param output Optional `.xlsx` path for exporting results. When `input` is a
#'   `.csv` or `.xlsx` file and `output` is not supplied, an Excel workbook named
#'   `<input>_volume_results.xlsx` is created automatically beside the input file.
#'   Data-frame inputs are not written automatically.
#' @param sheet Worksheet to read when `input` is an `.xlsx` file. Defaults to 1.
#' @param methods Volume method(s). Currently only `"sharma_pukkala"` is
#'   supported.
#' @param dbh_breaks Breaks used for DBH-class summaries when plot information
#'   is supplied.
#'
#' @details
#' The minimum columns for individual-tree estimation are `tree_id`, `species`,
#' `dbh_cm`, and `height_m`. `branch_group` is optional and is required only for
#' supported species that must use a generic Forest Regulation branch category.
#'
#' For inventory-level summaries, both `plot_id` and `plot_area_ha` must also be
#' supplied. If either one is supplied without the other, the function stops
#' with an informative error. Optional inventory columns are `forest_id` and
#' `forest_area_ha`.
#'
#' For species with a species-specific branch-volume row in the Forest
#' Regulations, `branch_group` may be left blank. For other supported
#' Sharma-Pukkala species, users must explicitly enter `other_broadleaf` or
#' `other_conifer` where appropriate. The package does not infer this category.
#'
#' @return An object of class `nepal_volume_result`. Tree-only inputs contain
#' `tree_results` and `method_audit`; inventory inputs additionally contain
#' `forest_summary`, `plot_summary`, `species_summary`, and `dbh_class_summary`.
#' @export
#'
#' @examples
#' trees <- data.frame(
#'   tree_id = c("T1", "T2"),
#'   species = c("sal", "terminalia_alata"),
#'   dbh_cm = c(60, 45),
#'   height_m = c(25, 22),
#'   branch_group = c(NA, "other_broadleaf")
#' )
#' volume(trees)
volume <- function(input, output = NULL, sheet = 1,
                   methods = "sharma_pukkala",
                   dbh_breaks = c(0, 10, 20, 30, 40, 50, Inf)) {
  methods <- .volume_methods(methods)
  read <- .read_volume_input(input, sheet = sheet)
  inventory <- .prepare_volume_inventory(read$data)
  analysis_level <- attr(inventory, "analysis_level")

  method_tables <- lapply(methods, function(method) {
    .calculate_volume_method(inventory, method)
  })
  names(method_tables) <- methods

  tree_results <- .volume_tree_results_table(
    inventory, methods, method_tables,
    tree_only = identical(analysis_level, "tree")
  )
  audit <- .volume_method_audit(method_tables)

  if (identical(analysis_level, "inventory")) {
    plot_summary <- .volume_plot_summary_table(method_tables)
    forest_summary <- .volume_forest_summary_table(plot_summary, inventory)
    species_summary <- .volume_category_summary(
      method_tables, inventory, category = "species", label = "species"
    )

    inventory$dbh_class_cm <- cut(
      inventory$dbh_cm, breaks = dbh_breaks, right = FALSE,
      include.lowest = TRUE
    )
    dbh_class_summary <- .volume_category_summary(
      method_tables, inventory, category = "dbh_class_cm", label = "dbh_class_cm"
    )
  } else {
    forest_summary <- NULL
    plot_summary <- NULL
    species_summary <- NULL
    dbh_class_summary <- NULL
  }

  result <- list(
    forest_summary = forest_summary,
    dbh_class_summary = dbh_class_summary,
    species_summary = species_summary,
    plot_summary = plot_summary,
    tree_results = tree_results,
    method_audit = audit
  )
  class(result) <- "nepal_volume_result"
  attr(result, "input_source") <- read$source
  attr(result, "methods") <- methods
  attr(result, "analysis_level") <- analysis_level

  if (is.null(output)) output <- read$default_output
  if (!is.null(output)) {
    .write_volume_workbook(result, output)
    output_path <- normalizePath(output, mustWork = FALSE)
    attr(result, "output_file") <- output_path
    message("Volume results written to: ", output_path)
  }

  result
}

.volume_methods <- function(methods) {
  aliases <- c(
    sharma_pukkala = "sharma_pukkala",
    sharma = "sharma_pukkala",
    sharma_pukkala_forest_regulation = "sharma_pukkala"
  )
  methods <- tolower(gsub("[ &-]+", "_", methods))
  out <- unname(aliases[methods])
  if (!length(out) || anyNA(out)) stop(
    "`methods` currently supports only 'sharma_pukkala'.",
    call. = FALSE
  )
  unique(out)
}

.volume_method_label <- function(method) {
  unname(c(sharma_pukkala = "Sharma & Pukkala + Forest Regulation")[method])
}

.read_volume_input <- function(input, sheet = 1) {
  if (is.data.frame(input)) return(list(
    data = input,
    source = "R data frame",
    default_output = NULL
  ))
  if (length(input) != 1L || is.na(input) || !file.exists(input)) stop(
    "`input` must be a data frame or one existing .csv or .xlsx file.",
    call. = FALSE
  )
  ext <- tolower(tools::file_ext(input))
  if (!ext %in% c("csv", "xlsx")) stop(
    "`input` must be a .csv or .xlsx file. Save legacy .xls files as .xlsx first.",
    call. = FALSE
  )
  dat <- if (ext == "csv") {
    utils::read.csv(input, stringsAsFactors = FALSE, check.names = FALSE)
  } else {
    openxlsx::read.xlsx(input, sheet = sheet, check.names = FALSE)
  }
  stem <- tools::file_path_sans_ext(basename(input))
  list(
    data = dat,
    source = normalizePath(input, mustWork = FALSE),
    default_output = file.path(dirname(input), paste0(stem, "_volume_results.xlsx"))
  )
}

.prepare_volume_inventory <- function(data) {
  .require_inventory_columns(data, c(
    "tree_id", "species", "dbh_cm", "height_m"
  ))

  has_plot_id <- "plot_id" %in% names(data)
  has_plot_area <- "plot_area_ha" %in% names(data)
  if (xor(has_plot_id, has_plot_area)) stop(
    "For inventory-level volume summaries, `plot_id` and `plot_area_ha` must be supplied together. For individual-tree volume, omit both columns.",
    call. = FALSE
  )
  analysis_level <- if (has_plot_id && has_plot_area) "inventory" else "tree"

  for (nm in c("plot_area_ha", "dbh_cm", "height_m", "forest_area_ha")) {
    if (nm %in% names(data)) data[[nm]] <- suppressWarnings(as.numeric(data[[nm]]))
  }

  if (!"branch_group" %in% names(data)) data$branch_group <- NA_character_
  data$branch_group <- trimws(as.character(data$branch_group))
  data$branch_group[is.na(data$branch_group) | !nzchar(data$branch_group)] <- NA_character_

  if (!nrow(data)) stop("The input must contain at least one tree.", call. = FALSE)
  for (nm in c("tree_id", "species")) {
    if (anyNA(data[[nm]]) || any(!nzchar(trimws(as.character(data[[nm]]))))) stop(
      sprintf("`%s` cannot be missing or blank.", nm), call. = FALSE
    )
  }
  if (anyDuplicated(data$tree_id)) stop("`tree_id` must be unique.", call. = FALSE)
  if (any(!is.finite(data$dbh_cm) | data$dbh_cm <= 0)) stop(
    "`dbh_cm` must contain positive finite values.", call. = FALSE
  )
  if (any(!is.finite(data$height_m) | data$height_m <= 0)) stop(
    "`height_m` must contain positive finite values.", call. = FALSE
  )

  if (identical(analysis_level, "inventory")) {
    if (!"forest_id" %in% names(data)) data$forest_id <- "Forest_1"
    data$forest_id <- trimws(as.character(data$forest_id))
    if (anyNA(data$forest_id) || any(!nzchar(data$forest_id))) stop(
      "`forest_id` cannot contain missing or blank values.", call. = FALSE
    )

    if (!"forest_area_ha" %in% names(data)) data$forest_area_ha <- NA_real_
    if (any(!is.na(data$forest_area_ha) &
            (!is.finite(data$forest_area_ha) | data$forest_area_ha <= 0))) stop(
      "`forest_area_ha` must be positive when supplied.", call. = FALSE
    )

    if (anyNA(data$plot_id) || any(!nzchar(trimws(as.character(data$plot_id))))) stop(
      "`plot_id` cannot be missing or blank.", call. = FALSE
    )

    check <- data
    check$plot_id <- paste(data$forest_id, data$plot_id, sep = "::")
    .validate_plot_areas(check)

    for (id in unique(data$forest_id)) {
      area <- unique(stats::na.omit(data$forest_area_ha[data$forest_id == id]))
      if (length(area) > 1L) stop(
        "`forest_area_ha` must be constant within each `forest_id`.", call. = FALSE
      )
    }

    data$.plot_key <- paste(data$forest_id, data$plot_id, sep = "\r")
  } else {
    data$plot_id <- NA_character_
    data$plot_area_ha <- NA_real_
    data$forest_id <- NA_character_
    data$forest_area_ha <- NA_real_
    data$.plot_key <- NA_character_
  }

  data$basal_area_m2 <- pi * (data$dbh_cm / 200)^2
  attr(data, "analysis_level") <- analysis_level
  data
}

.calculate_volume_method <- function(inventory, method) {
  if (method != "sharma_pukkala") stop("Unsupported volume method.", call. = FALSE)

  raw <- sharma_pukkala_volume(
    dbh = inventory$dbh_cm,
    height = inventory$height_m,
    species = inventory$species,
    branch_group = inventory$branch_group,
    keep_inputs = TRUE
  )

  data.frame(
    forest_id = inventory$forest_id,
    plot_id = inventory$plot_id,
    plot_key = inventory$.plot_key,
    plot_area_ha = inventory$plot_area_ha,
    tree_id = inventory$tree_id,
    species = inventory$species,
    dbh_cm = inventory$dbh_cm,
    basal_area_m2 = inventory$basal_area_m2,
    method_id = method,
    method = .volume_method_label(method),
    stem_volume_m3 = raw$stem_volume_m3,
    branch_volume_m3 = raw$branch_volume_m3,
    total_tree_volume_m3 = raw$total_tree_volume_m3,
    branch_group_used = raw$branch_group,
    estimation_status = raw$estimation_status,
    calibration_status = raw$calibration_status,
    stringsAsFactors = FALSE
  )
}

.volume_estimated <- function(z) {
  z$estimation_status %in% c("estimated", "estimated_no_branches") &
    is.finite(z$total_tree_volume_m3)
}

.volume_coverage_status <- function(n, estimated) {
  if (!estimated) "no_tree_estimates" else if (estimated == n)
    "complete_tree_coverage" else "partial_tree_coverage"
}

.volume_plot_method_summary <- function(x) {
  groups <- split(x, x$plot_key, drop = TRUE)
  do.call(rbind, lapply(groups, function(z) {
    ok <- .volume_estimated(z)
    n_est <- sum(ok)
    total_ba <- sum(z$basal_area_m2, na.rm = TRUE)
    total_volume <- if (n_est) sum(z$total_tree_volume_m3[ok]) else NA_real_
    extrap <- ok & grepl("below|above|outside", z$calibration_status)
    data.frame(
      forest_id = z$forest_id[1],
      plot_id = z$plot_id[1],
      plot_area_ha = z$plot_area_ha[1],
      method_id = z$method_id[1],
      method = z$method[1],
      total_trees = nrow(z),
      estimated_trees = n_est,
      unestimated_trees = nrow(z) - n_est,
      extrapolated_trees = sum(extrap, na.rm = TRUE),
      tree_coverage_pct = 100 * n_est / nrow(z),
      basal_area_coverage_pct = if (total_ba > 0)
        100 * sum(z$basal_area_m2[ok], na.rm = TRUE) / total_ba else NA_real_,
      volume_m3_ha = total_volume / z$plot_area_ha[1],
      coverage_status = .volume_coverage_status(nrow(z), n_est),
      stringsAsFactors = FALSE
    )
  }))
}

.volume_plot_summary_table <- function(method_tables) {
  out <- do.call(rbind, lapply(method_tables, .volume_plot_method_summary))
  out <- out[order(out$forest_id, out$plot_id, out$method), ]
  out$method_id <- NULL
  rownames(out) <- NULL
  out
}

.volume_forest_summary_table <- function(plot_long, inventory) {
  groups <- split(plot_long, interaction(plot_long$forest_id, plot_long$method, drop = TRUE))
  out <- lapply(groups, function(z) {
    forest <- z$forest_id[1]
    area <- unique(stats::na.omit(inventory$forest_area_ha[inventory$forest_id == forest]))
    area <- if (length(area)) area[1] else NA_real_
    equal_plots <- length(unique(z$plot_area_ha)) == 1L
    s <- .mean_stats(z$volume_m3_ha)
    if (!equal_plots) {
      ok <- is.finite(z$volume_m3_ha)
      if (any(ok)) s["mean"] <- stats::weighted.mean(
        z$volume_m3_ha[ok], z$plot_area_ha[ok]
      )
      s[c("sd", "se", "lower", "upper")] <- NA_real_
    }
    data.frame(
      forest_id = forest,
      forest_area_ha = area,
      method = z$method[1],
      total_plots = nrow(z),
      plots_with_estimates = sum(is.finite(z$volume_m3_ha)),
      total_trees = sum(z$total_trees),
      estimated_trees = sum(z$estimated_trees),
      tree_coverage_pct = 100 * sum(z$estimated_trees) / sum(z$total_trees),
      basal_area_coverage_pct = if (any(is.finite(z$basal_area_coverage_pct)))
        stats::weighted.mean(z$basal_area_coverage_pct, z$total_trees, na.rm = TRUE)
      else NA_real_,
      mean_volume_m3_ha = s["mean"],
      sd_volume_m3_ha = s["sd"],
      se_volume_m3_ha = s["se"],
      ci95_lower_volume_m3_ha = s["lower"],
      ci95_upper_volume_m3_ha = s["upper"],
      total_forest_volume_m3 = s["mean"] * area,
      plot_area_design = if (equal_plots) "equal_plot_area" else "unequal_plot_area_weighted_mean",
      uncertainty_status = if (!equal_plots) "unequal_plot_area_uncertainty_not_estimated"
      else if (sum(is.finite(z$volume_m3_ha)) < 3) "insufficient_plots"
      else "estimated_from_plots",
      summary_status = if (all(z$coverage_status == "no_tree_estimates")) "no_tree_estimates"
      else if (any(z$coverage_status != "complete_tree_coverage")) "partial_tree_coverage"
      else "complete_tree_coverage",
      stringsAsFactors = FALSE
    )
  })
  ans <- do.call(rbind, out)
  rownames(ans) <- NULL
  ans
}

.volume_category_summary <- function(method_tables, inventory, category, label) {
  result <- list()
  k <- 1L
  for (forest in unique(inventory$forest_id)) {
    cats <- unique(as.character(inventory[[category]][inventory$forest_id == forest]))
    plot_keys <- unique(inventory$.plot_key[inventory$forest_id == forest])
    for (cat in cats) for (id in names(method_tables)) {
      x <- method_tables[[id]]
      ids <- inventory$tree_id[
        inventory$forest_id == forest & as.character(inventory[[category]]) == cat
      ]
      z <- x[x$tree_id %in% ids, ]
      ok <- .volume_estimated(z)
      plot_areas <- vapply(plot_keys, function(key) {
        unique(inventory$plot_area_ha[inventory$.plot_key == key])[1]
      }, numeric(1))
      pv <- vapply(plot_keys, function(key) {
        q <- z$plot_key == key & ok
        area <- unique(inventory$plot_area_ha[inventory$.plot_key == key])[1]
        sum(z$total_tree_volume_m3[q], na.rm = TRUE) / area
      }, numeric(1))
      s <- .mean_stats(pv)
      equal_plots <- length(unique(plot_areas)) == 1L
      if (!equal_plots) {
        s["mean"] <- stats::weighted.mean(pv, plot_areas)
        s[c("sd", "se", "lower", "upper")] <- NA_real_
      }
      result[[k]] <- data.frame(
        forest_id = forest,
        category_value = cat,
        method = .volume_method_label(id),
        total_trees = nrow(z),
        estimated_trees = sum(ok),
        tree_coverage_pct = if (nrow(z)) 100 * sum(ok) / nrow(z) else NA_real_,
        mean_tree_volume_m3 = if (any(ok)) mean(z$total_tree_volume_m3[ok]) else NA_real_,
        mean_plot_volume_m3_ha = s["mean"],
        se_plot_volume_m3_ha = s["se"],
        ci95_lower_plot_volume_m3_ha = s["lower"],
        ci95_upper_plot_volume_m3_ha = s["upper"],
        uncertainty_status = if (!equal_plots) "unequal_plot_area_uncertainty_not_estimated"
        else if (length(pv) < 3) "insufficient_plots" else "estimated_from_plots",
        stringsAsFactors = FALSE
      )
      names(result[[k]])[2] <- label
      k <- k + 1L
    }
  }
  ans <- do.call(rbind, result)
  rownames(ans) <- NULL
  ans
}

.volume_tree_results_table <- function(inventory, methods, method_tables,
                                       tree_only = FALSE) {
  internal <- c(".plot_key")
  if (tree_only) {
    internal <- c(
      internal, "plot_id", "plot_area_ha", "forest_id", "forest_area_ha"
    )
  }
  out <- inventory[setdiff(names(inventory), internal)]
  for (id in methods) {
    cols <- method_tables[[id]][c(
      "stem_volume_m3", "branch_volume_m3", "total_tree_volume_m3",
      "branch_group_used", "estimation_status", "calibration_status"
    )]
    names(cols) <- paste0(id, "_", names(cols))
    out <- cbind(out, cols)
  }
  out
}

.volume_method_audit <- function(method_tables) {
  x <- method_tables[["sharma_pukkala"]]
  data.frame(
    method = "Sharma & Pukkala + Forest Regulation",
    stem_volume_source = "Sharma and Pukkala (1990)",
    branch_volume_source = "Nepal Forest Regulations 2079, Schedule 9",
    total_trees = nrow(x),
    estimated_trees = sum(.volume_estimated(x)),
    branch_group_required = sum(
      x$estimation_status == "stem_only_branch_category_required", na.rm = TRUE
    ),
    unsupported_species = sum(
      x$estimation_status == "unsupported_species", na.rm = TRUE
    ),
    stringsAsFactors = FALSE
  )
}

.volume_read_me <- function(result) {
  level <- attr(result, "analysis_level")
  if (identical(level, "tree")) {
    purpose <- "Individual-tree volume estimation for operational uses such as marked or harvesting trees. Plot information is not required."
    required <- "tree_id, species, dbh_cm, height_m"
    outputs <- "Tree_Results and Method_Audit"
    scaling <- "No plot- or forest-level scaling is performed because plot_id and plot_area_ha were not supplied."
  } else {
    purpose <- "Forest-inventory volume estimation with tree, plot, species, DBH-class, and forest summaries."
    required <- "tree_id, plot_id, plot_area_ha, species, dbh_cm, height_m"
    outputs <- "Forest_Summary, Plot_Summary, Species_Summary, DBH_Summary, Tree_Results, and Method_Audit"
    scaling <- "volume_m3_ha and mean_volume_m3_ha are m3/ha; total_forest_volume_m3 is m3 when forest_area_ha is supplied."
  }

  data.frame(
    item = c(
      "Purpose",
      "Detected workflow",
      "Current volume method",
      "Stem volume",
      "Branch volume",
      "Total tree volume",
      "Required columns",
      "Optional columns",
      "branch_group rule",
      "Generic branch groups",
      "Missing branch group",
      "Tree-level units",
      "Scaling",
      "Output sheets",
      "Coverage",
      "Calibration status",
      "Uncertainty",
      "Method audit"
    ),
    guidance = c(
      purpose,
      if (identical(level, "tree")) "Individual-tree workflow" else "Forest-inventory workflow",
      "Sharma & Pukkala stem-volume equations combined with Nepal Forest Regulations 2079 Schedule 9 branch-volume ratios.",
      "Calculated from the Sharma & Pukkala (1990) logarithmic stem-volume equation and reported in m3/tree.",
      "Calculated as the Forest Regulation branch ratio multiplied by stem volume.",
      "Calculated as stem volume plus branch volume. Foliage is not included as volume.",
      required,
      if (identical(level, "tree")) "branch_group" else "forest_id, forest_area_ha, branch_group",
      "Leave branch_group blank for species with direct Forest Regulation branch parameters. For other supported species, the user must assign the appropriate generic group.",
      "Use only other_broadleaf or other_conifer when a generic Forest Regulation branch category is required.",
      "If a required generic branch group is missing, stem volume is retained but branch and total tree volume are NA; the package does not guess the category.",
      "stem_volume_m3, branch_volume_m3, and total_tree_volume_m3 are m3/tree.",
      scaling,
      outputs,
      if (identical(level, "tree")) "Not applicable to individual-tree workflow." else "Tree and basal-area coverage show how much of the inventory received complete total-tree volume estimates. Partial coverage should be interpreted explicitly.",
      "DBH calibration status indicates whether a prediction is within or outside the observed Sharma-Pukkala model-development DBH range.",
      if (identical(level, "tree")) "No sampling-based plot uncertainty is calculated for individual-tree inputs." else "SD, SE, and 95% CI in forest summaries describe variation among sampled plots where estimable; they do not represent allometric model uncertainty.",
      "See Method_Audit for sources and counts of estimated, unsupported, or branch-group-required trees."
    ),
    stringsAsFactors = FALSE
  )
}

.write_volume_workbook <- function(result, path) {
  if (length(path) != 1L || is.na(path) || !grepl("\\.xlsx$", path, ignore.case = TRUE)) stop(
    "`output` must be one .xlsx file path.", call. = FALSE
  )
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)

  if (identical(attr(result, "analysis_level"), "tree")) {
    tables <- list(
      Read_Me = .volume_read_me(result),
      Tree_Results = result$tree_results,
      Method_Audit = result$method_audit
    )
  } else {
    tables <- list(
      Read_Me = .volume_read_me(result),
      Forest_Summary = result$forest_summary,
      Plot_Summary = result$plot_summary,
      Species_Summary = result$species_summary,
      DBH_Summary = result$dbh_class_summary,
      Tree_Results = result$tree_results,
      Method_Audit = result$method_audit
    )
  }

  wb <- openxlsx::createWorkbook(creator = "Santosh Ayer")
  header <- openxlsx::createStyle(
    fgFill = "#E7E6E6", textDecoration = "bold",
    halign = "center", valign = "center", wrapText = TRUE
  )
  wrap <- openxlsx::createStyle(valign = "top", wrapText = TRUE)
  for (sheet_name in names(tables)) {
    dat <- tables[[sheet_name]]
    openxlsx::addWorksheet(wb, sheet_name)
    openxlsx::writeData(
      wb, sheet_name, dat,
      withFilter = sheet_name != "Read_Me"
    )
    openxlsx::addStyle(
      wb, sheet_name, header, rows = 1, cols = seq_len(ncol(dat)),
      gridExpand = TRUE
    )
    openxlsx::freezePane(wb, sheet_name, firstRow = TRUE)
    if (sheet_name == "Read_Me") {
      openxlsx::addStyle(
        wb, sheet_name, wrap,
        rows = 2:(nrow(dat) + 1), cols = seq_len(ncol(dat)),
        gridExpand = TRUE
      )
      openxlsx::setColWidths(wb, sheet_name, cols = 1, widths = 28)
      openxlsx::setColWidths(wb, sheet_name, cols = 2, widths = 95)
    } else {
      openxlsx::setColWidths(
        wb, sheet_name, cols = seq_len(ncol(dat)), widths = "auto"
      )
    }
  }
  openxlsx::saveWorkbook(wb, path, overwrite = TRUE)
  invisible(path)
}
