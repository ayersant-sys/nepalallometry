#' Inspect the FRTC 2025 total-biomass model registry
#'
#' @return A data frame containing equations, coefficients, fit statistics,
#'   observed model-development DBH and height ranges, units, biomass boundary,
#'   and source information.
#' @export
frtc_models <- function() {
  species <- frtc_species()
  model <- .frtc_total_biomass_models
  idx <- match(model$species_code, species$species_code)
  range_idx <- match(model$species_code,
                     .frtc_calibration_ranges$species_code)
  calibration <- .frtc_calibration_ranges[range_idx, , drop = FALSE]
  data.frame(
    species_id = species$species_id[idx],
    nepali_name = species$nepali_name[idx],
    scientific_name = species$scientific_name[idx],
    model_form = model$equation,
    equation = ifelse(
      model$equation == "density_power",
      "B = a * (DBH^2 * H * rho)^b",
      "B = a * DBH^b * H^c"
    ),
    a = model$a,
    b = model$b,
    c = model$c,
    sample_size = calibration$sample_size,
    dbh_min_cm = calibration$dbh_min_cm,
    dbh_max_cm = calibration$dbh_max_cm,
    height_min_m = calibration$height_min_m,
    height_max_m = calibration$height_max_m,
    calibration_range_basis = "observed model-development sample",
    calibration_range_source = "FRTC 2025 dataset",
    aic = c(572.91, 599.48, 455.63, 1110.16, 1522.86, 494.61, 736.85),
    fit_rmse_kg = c(148.1, 265.0, 80.4, 223.3, 384.1, 98.8, 433.2),
    mean_bias_kg = c(-6.34, -18.14, -2.10, 2.84, 13.57, 9.56, -71.49),
    adjusted_r2 = c(0.97, 0.90, 0.98, 0.97, 0.97, 0.98, 0.95),
    operational_rmse_kg = c(184.897, 265.0, 92.431, 223.3, 354.007,
                            117.852, 412.501),
    operational_rmse_source = c(
      "FRTC 2025 Table 11", "FRTC 2025 Table 9", "FRTC 2025 Table 11",
      "FRTC 2025 Table 9", "FRTC 2025 Table 11", "FRTC 2025 Table 11",
      "FRTC 2025 Table 11"
    ),
    operational_density_basis = c(
      "FRTC species average", "not required", "FRTC species average",
      "not required", "FRTC DBH class", "FRTC species average",
      "FRTC DBH class"
    ),
    dbh_unit = "cm",
    height_unit = "m",
    density_unit = "g/cm3",
    output_unit = "kg/tree",
    biomass_boundary = "above 0.30 m; stump excluded",
    coefficient_source = "FRTC 2025 Table 9",
    density_source = "FRTC 2025 Table 11",
    stringsAsFactors = FALSE
  )
}

#' Display one FRTC total-biomass equation
#'
#' @param species A supported standardized scientific identifier or Nepali
#'   name, such as `shorea_robusta` or `sal`.
#' @return The selected registry row, invisibly.
#' @export
frtc_equation <- function(species) {
  if (length(species) != 1L || is.na(species)) {
    stop("`species` must be one supported species name.", call. = FALSE)
  }
  code <- .normalize_frtc_species(species)
  if (is.na(code)) {
    stop("No FRTC 2025 total-biomass equation is available for `", species,
         "`.", call. = FALSE)
  }
  registry <- frtc_models()
  code_lookup <- stats::setNames(frtc_species()$species_id,
                                 frtc_species()$species_code)
  info <- registry[registry$species_id == unname(code_lookup[code]), , drop = FALSE]
  coefficient_text <- if (info$model_form == "density_power") {
    sprintf("B = %.6f * (DBH^2 * H * rho)^%.6f", info$a, info$b)
  } else {
    sprintf("B = %.6f * DBH^%.6f * H^%.6f", info$a, info$b, info$c)
  }
  cat(
    "Species: ", info$scientific_name, " (", info$nepali_name, ")\n",
    "Response: Total aboveground biomass above 0.30 m; stump excluded\n",
    "Equation: ", coefficient_text, "\n",
    "Units: DBH cm; H m; rho g/cm3; B kg/tree\n",
    "Density basis: ", info$operational_density_basis, "\n",
    "Sample size: ", info$sample_size, "\n",
    "Fit RMSE: ", info$fit_rmse_kg, " kg\n",
    "Operational RMSE: ", info$operational_rmse_kg, " kg\n",
    "Observed DBH range: ", info$dbh_min_cm, "-", info$dbh_max_cm, " cm\n",
    "Observed height range: ", info$height_min_m, "-", info$height_max_m, " m\n",
    "Source: FRTC 2025, Tables 9 and 11; calibration ranges from the FRTC dataset\n",
    sep = ""
  )
  invisible(info)
}

#' Inspect FRTC-recommended densities for total biomass
#'
#' @param species Optional supported species identifier or Nepali name.
#' @param dbh Optional DBH in cm. When supplied with `species`, return the
#'   density applied by the package for that tree.
#' @return A density-rule table, or a one-row applied-density result.
#' @export
frtc_density <- function(species = NULL, dbh = NULL) {
  rules <- data.frame(
    species_id = c(
      "alnus_nepalensis", "castanopsis_spp", "lagerstroemia_parviflora",
      "pinus_roxburghii", rep("shorea_robusta", 4), "schima_wallichii",
      rep("terminalia_alata", 4)
    ),
    dbh_class_cm = c(
      "all", "not required", "all", "not required",
      "5-10", ">10-30", ">30-50", ">50", "all",
      "5-10", ">10-30", ">30-50", ">50"
    ),
    density_g_cm3 = c(
      0.4318, NA, 0.5651, NA,
      0.5042, 0.5573, 0.6331, 0.6551, 0.4869,
      0.4865, 0.5780, 0.6472, 0.6819
    ),
    density_basis = c(
      "species_average", "not_required", "species_average", "not_required",
      rep("dbh_class", 4), "species_average", rep("dbh_class", 4)
    ),
    source = "FRTC 2025 Table 11",
    stringsAsFactors = FALSE
  )
  if (is.null(species)) return(rules)
  if (length(species) != 1L || is.na(species)) {
    stop("`species` must be one supported species name.", call. = FALSE)
  }
  code <- .normalize_frtc_species(species)
  if (is.na(code)) {
    stop("No FRTC 2025 density rule is available for `", species, "`.",
         call. = FALSE)
  }
  id <- stats::setNames(frtc_species()$species_id,
                        frtc_species()$species_code)[code]
  selected <- rules[rules$species_id == id, , drop = FALSE]
  if (is.null(dbh)) return(selected)
  if (length(dbh) != 1L || !is.finite(dbh) || dbh <= 0) {
    stop("`dbh` must be one positive finite value in cm.", call. = FALSE)
  }
  density <- .frtc_total_density(code, dbh)
  basis <- if (code %in% c("Cs", "Pr")) "not_required" else
    if (code %in% c("Sr", "Ta")) "frtc_dbh_class" else
      "frtc_species_average"
  data.frame(
    species_id = unname(id),
    dbh_cm = dbh,
    density_g_cm3 = density,
    density_source = basis,
    source = "FRTC 2025 Table 11",
    stringsAsFactors = FALSE
  )
}
