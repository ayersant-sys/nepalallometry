# Volume method integration loaded after volume.R.
# Keeps biomass behavior unchanged while supporting two volume methods.

volume <- function(input, output = NULL, sheet = 1,
                   methods = c("sharma_pukkala", "frtc"),
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
    sharma_pukkala_forest_regulation = "sharma_pukkala",
    frtc = "frtc",
    frtc_2025 = "frtc"
  )
  methods <- tolower(gsub("[ &-]+", "_", methods))
  out <- unname(aliases[methods])
  if (!length(out) || anyNA(out)) stop(
    "`methods` supports 'sharma_pukkala' and/or 'frtc'.",
    call. = FALSE
  )
  unique(out)
}

.volume_method_label <- function(method) {
  unname(c(
    sharma_pukkala = "Sharma & Pukkala + Forest Regulation",
    frtc = "FRTC 2025"
  )[method])
}

.calculate_volume_method <- function(inventory, method) {
  if (method == "sharma_pukkala") {
    raw <- sharma_pukkala_volume(
      dbh = inventory$dbh_cm,
      height = inventory$height_m,
      species = inventory$species,
      branch_group = inventory$branch_group,
      keep_inputs = TRUE
    )

    return(data.frame(
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
      frtc_volume_ub_20cm_m3 = NA_real_,
      frtc_volume_ub_10cm_m3 = NA_real_,
      top20_status = NA_character_,
      top10_status = NA_character_,
      estimation_status = raw$estimation_status,
      calibration_status = raw$calibration_status,
      stringsAsFactors = FALSE
    ))
  }

  if (method == "frtc") {
    raw <- frtc_volume(
      dbh = inventory$dbh_cm,
      height = inventory$height_m,
      species = inventory$species,
      keep_inputs = TRUE
    )

    return(data.frame(
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
      stem_volume_m3 = raw$frtc_total_volume_m3,
      branch_volume_m3 = NA_real_,
      total_tree_volume_m3 = raw$frtc_total_volume_m3,
      branch_group_used = NA_character_,
      frtc_volume_ub_20cm_m3 = raw$frtc_volume_ub_20cm_m3,
      frtc_volume_ub_10cm_m3 = raw$frtc_volume_ub_10cm_m3,
      top20_status = raw$top20_status,
      top10_status = raw$top10_status,
      estimation_status = raw$estimation_status,
      calibration_status = raw$calibration_status,
      stringsAsFactors = FALSE
    ))
  }

  stop("Unsupported volume method.", call. = FALSE)
}

.volume_tree_results_table <- function(inventory, methods, method_tables,
                                       tree_only = FALSE) {
  internal <- ".plot_key"
  if (tree_only) {
    internal <- c(internal, "plot_id", "plot_area_ha", "forest_id", "forest_area_ha")
  }
  out <- inventory[setdiff(names(inventory), internal)]

  for (id in methods) {
    x <- method_tables[[id]]
    if (id == "sharma_pukkala") {
      cols <- x[c(
        "stem_volume_m3", "branch_volume_m3", "total_tree_volume_m3",
        "branch_group_used", "estimation_status", "calibration_status"
      )]
      names(cols) <- paste0("sharma_pukkala_", names(cols))
    } else {
      cols <- x[c(
        "total_tree_volume_m3", "frtc_volume_ub_20cm_m3",
        "frtc_volume_ub_10cm_m3", "top20_status", "top10_status",
        "estimation_status", "calibration_status"
      )]
      names(cols) <- c(
        "frtc_total_volume_m3",
        "frtc_volume_ub_20cm_m3",
        "frtc_volume_ub_10cm_m3",
        "frtc_top20_status",
        "frtc_top10_status",
        "frtc_estimation_status",
        "frtc_calibration_status"
      )
    }
    out <- cbind(out, cols)
  }
  out
}

.volume_method_audit <- function(method_tables) {
  rows <- list()
  k <- 1L

  if ("sharma_pukkala" %in% names(method_tables)) {
    x <- method_tables[["sharma_pukkala"]]
    rows[[k]] <- data.frame(
      method = "Sharma & Pukkala + Forest Regulation",
      total_volume_definition = "Stem volume plus branch volume",
      stem_volume_source = "Sharma and Pukkala (1990)",
      branch_volume_source = "Nepal Forest Regulations 2079, Schedule 9",
      stump_boundary = "As defined by the underlying Sharma-Pukkala stem-volume equations",
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
    k <- k + 1L
  }

  if ("frtc" %in% names(method_tables)) {
    x <- method_tables[["frtc"]]
    rows[[k]] <- data.frame(
      method = "FRTC 2025",
      total_volume_definition = "Total stem volume over bark; branches excluded",
      stem_volume_source = "FRTC (2025), Allometric Equations of Major Tree Species of Nepal, Volume I",
      branch_volume_source = "Not applicable; FRTC volume equations are stem-only",
      stump_boundary = "30-cm stump excluded",
      total_trees = nrow(x),
      estimated_trees = sum(.volume_estimated(x)),
      branch_group_required = 0L,
      unsupported_species = sum(
        x$estimation_status == "unsupported_species", na.rm = TRUE
      ),
      stringsAsFactors = FALSE
    )
  }

  ans <- do.call(rbind, rows)
  rownames(ans) <- NULL
  ans
}

.volume_read_me <- function(result) {
  level <- attr(result, "analysis_level")
  methods <- attr(result, "methods")

  purpose <- if (identical(level, "tree")) {
    "Individual-tree volume estimation for operational uses such as marked or harvesting trees. Plot information is not required."
  } else {
    "Forest-inventory volume estimation with tree, plot, species, DBH-class, and forest summaries."
  }
  required <- if (identical(level, "tree")) {
    "tree_id, species, dbh_cm, height_m"
  } else {
    "tree_id, plot_id, plot_area_ha, species, dbh_cm, height_m"
  }
  outputs <- if (identical(level, "tree")) {
    "Tree_Results and Method_Audit"
  } else {
    "Forest_Summary, Plot_Summary, Species_Summary, DBH_Summary, Tree_Results, and Method_Audit"
  }

  method_text <- paste(.volume_method_label(methods), collapse = "; ")

  data.frame(
    item = c(
      "Purpose", "Detected workflow", "Methods calculated",
      "Sharma-Pukkala stem volume", "Sharma-Pukkala branch volume",
      "Sharma-Pukkala total volume", "FRTC total volume",
      "FRTC 20-cm top volume", "FRTC 10-cm top volume",
      "FRTC volume boundary", "Important total-volume distinction",
      "Required columns", "Optional columns", "branch_group rule",
      "Tree-level units", "Scaling", "Output sheets", "Coverage",
      "Calibration status", "Uncertainty", "Method audit"
    ),
    guidance = c(
      purpose,
      if (identical(level, "tree")) "Individual-tree workflow" else "Forest-inventory workflow",
      method_text,
      "Stem volume from Sharma & Pukkala (1990).",
      "Branch volume from Nepal Forest Regulations 2079 Schedule 9; a generic branch_group may be required for some species.",
      "Stem volume plus branch volume.",
      "FRTC total stem volume over bark. It is labelled total volume for operational simplicity, but it is stem-only and does not include branches.",
      "FRTC under-bark stem volume up to a 20-cm over-bark top diameter. Values are not calculated when DBH is below 20 cm.",
      "FRTC under-bark stem volume up to a 10-cm over-bark top diameter. Values are not calculated when DBH is below 10 cm.",
      "All FRTC volume outputs exclude the 30-cm stump and exclude branch volume.",
      "Total volume is method-specific: Sharma-Pukkala + Forest Regulation total includes stem + branches; FRTC total means total stem volume over bark only.",
      required,
      if (identical(level, "tree")) "branch_group" else "forest_id, forest_area_ha, branch_group",
      "branch_group applies only to Sharma-Pukkala + Forest Regulation. Leave it blank for direct Schedule 9 species; otherwise use other_broadleaf or other_conifer as appropriate. The package does not guess.",
      "All tree-volume outputs are m3/tree.",
      if (identical(level, "tree")) "No plot- or forest-level scaling is performed." else "Summary volume is reported in m3/ha; total forest volume is m3 when forest_area_ha is supplied.",
      outputs,
      if (identical(level, "tree")) "Not applicable to individual-tree workflow." else "Coverage reports the proportion of inventory trees represented by each method's total-volume estimate.",
      "Calibration status indicates whether DBH and height are within the observed model-development range where available.",
      if (identical(level, "tree")) "No sampling-based plot uncertainty is calculated for individual-tree inputs." else "SD, SE, and 95% CI describe variation among sampled plots where estimable; they do not represent allometric model uncertainty.",
      "Method_Audit documents method-specific volume definitions, sources, boundary assumptions, coverage, and unsupported species."
    ),
    stringsAsFactors = FALSE
  )
}
