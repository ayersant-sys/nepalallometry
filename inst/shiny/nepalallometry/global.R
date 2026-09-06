# Display-only helpers for the Shiny interface.
# These functions do not alter package result objects or downloaded workbooks.

clean_gui_name <- function(x) {
  exact <- c(
    tree_id = "Tree ID",
    plot_id = "Plot ID",
    forest_id = "Forest ID",
    species = "Species",
    species_code = "Species code",
    scientific_name = "Scientific name",
    common_name = "Common name",
    plot_area_ha = "Plot area (ha)",
    forest_area_ha = "Forest area (ha)",
    dbh_cm = "DBH (cm)",
    height_m = "Height (m)",
    dbh_class = "DBH class",
    dbh_class_cm = "DBH class (cm)",
    method = "Method",
    status = "Status",
    reason = "Reason",
    note = "Note",
    volume_type = "Volume type",
    volume_definition = "Volume definition",
    volume_m3 = "Volume (m³)",
    stem_volume_m3 = "Stem volume (m³)",
    branch_volume_m3 = "Branch volume (m³)",
    total_volume_m3 = "Total volume (m³)",
    volume_m3_ha = "Volume (m³/ha)",
    biomass_kg = "Biomass (kg)",
    biomass_mg = "Biomass (Mg)",
    biomass_mg_ha = "Biomass (Mg/ha)",
    carbon_kg = "Carbon (kg)",
    carbon_mg = "Carbon (Mg)",
    carbon_mg_ha = "Carbon (Mg/ha)",
    wood_density = "Wood density (g/cm³)",
    wood_density_g_cm3 = "Wood density (g/cm³)",
    tree_coverage_pct = "Tree coverage (%)",
    stem_coverage_pct = "Stem coverage (%)",
    species_coverage_pct = "Species coverage (%)",
    basal_area_coverage_pct = "Basal-area coverage (%)",
    n_trees = "Trees (n)",
    n_plots = "Plots (n)",
    n_species = "Species (n)",
    mean = "Mean",
    sd = "SD",
    se = "SE",
    ci_lower = "Lower 95% CI",
    ci_upper = "Upper 95% CI",
    lower_ci = "Lower 95% CI",
    upper_ci = "Upper 95% CI"
  )

  out <- unname(exact[x])
  missing <- is.na(out)
  if (!any(missing)) return(out)

  fallback <- x[missing]

  # Recognize common suffixes before applying generic title formatting.
  fallback <- sub("_pct$", " (%)", fallback)
  fallback <- sub("_mg_ha$", " (Mg/ha)", fallback)
  fallback <- sub("_m3_ha$", " (m³/ha)", fallback)
  fallback <- sub("_kg_ha$", " (kg/ha)", fallback)
  fallback <- sub("_m3$", " (m³)", fallback)
  fallback <- sub("_kg$", " (kg)", fallback)
  fallback <- sub("_cm$", " (cm)", fallback)
  fallback <- sub("_ha$", " (ha)", fallback)
  fallback <- sub("_m$", " (m)", fallback)
  fallback <- gsub("_", " ", fallback, fixed = TRUE)

  # Sentence-style labels are easier to scan than raw snake_case names.
  fallback <- vapply(fallback, function(z) {
    if (!nzchar(z)) return(z)
    paste0(toupper(substr(z, 1, 1)), substr(z, 2, nchar(z)))
  }, character(1))

  # Restore forestry/statistical abbreviations.
  fallback <- gsub("\\bDbh\\b", "DBH", fallback)
  fallback <- gsub("\\bId\\b", "ID", fallback)
  fallback <- gsub("\\bSd\\b", "SD", fallback)
  fallback <- gsub("\\bSe\\b", "SE", fallback)
  fallback <- gsub("\\bCi\\b", "CI", fallback)
  fallback <- gsub("\\bFrtc\\b", "FRTC", fallback)

  out[missing] <- fallback
  out
}

clean_gui_labels <- function(x) {
  if (!is.data.frame(x)) return(x)
  names(x) <- clean_gui_name(names(x))
  x
}

# app.R uses renderTable() throughout. Wrapping it here keeps the cleanup
# strictly in the GUI presentation layer while leaving package objects and
# Excel downloads unchanged.
renderTable <- function(expr, ..., env = parent.frame(), quoted = FALSE) {
  if (!quoted) expr <- substitute(expr)
  wrapped <- substitute(clean_gui_labels(EXPR), list(EXPR = expr))
  shiny::renderTable(wrapped, ..., env = env, quoted = TRUE)
}
