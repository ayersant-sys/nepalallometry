.frtc_total_biomass_models <- data.frame(
  species_code = c("An", "Cs", "Lp", "Pr", "Sr", "Sw", "Ta"),
  equation = c("density_power", "dbh_height", "density_power",
               "dbh_height", "density_power", "density_power",
               "density_power"),
  a = c(0.067139, 0.071253, 0.060964, 0.031693, 0.054968, 0.071359, 0.080156),
  b = c(0.956808, 2.318525, 0.971369, 2.329281, 0.980885, 0.951091, 0.943341),
  c = c(NA, 0.299393, NA, 0.519366, NA, NA, NA),
  recommended_density = c(0.4318, NA, 0.5651, NA, NA, 0.4869, NA),
  stringsAsFactors = FALSE
)

.frtc_total_density <- function(code, dbh) {
  out <- rep(NA_real_, length(code))
  out[code == "An"] <- 0.4318
  out[code == "Lp"] <- 0.5651
  out[code == "Sw"] <- 0.4869

  sr <- code == "Sr"
  out[sr & dbh <= 10] <- 0.5042
  out[sr & dbh > 10 & dbh <= 30] <- 0.5573
  out[sr & dbh > 30 & dbh <= 50] <- 0.6331
  out[sr & dbh > 50] <- 0.6551

  ta <- code == "Ta"
  out[ta & dbh <= 10] <- 0.4865
  out[ta & dbh > 10 & dbh <= 30] <- 0.5780
  out[ta & dbh > 30 & dbh <= 50] <- 0.6472
  out[ta & dbh > 50] <- 0.6819
  out
}

#' Estimate total aboveground biomass using FRTC 2025 models
#'
#' Estimates biomass above the FRTC felling height of 0.30 m. Consequently,
#' the result excludes stump biomass between ground level and 0.30 m.
#'
#' @param dbh Diameter at breast height in centimetres. Must be positive.
#' @param height Total tree height in metres. Must be positive.
#' @param species Species code, scientific name, or supported Nepali common
#'   name. Run [frtc_species()] for the canonical list.
#' @param keep_inputs If `TRUE`, return a data frame containing inputs,
#'   normalized species, density provenance, and biomass. If `FALSE`, return
#'   only the biomass vector.
#'
#' @return Biomass in kg/tree, excluding the 0-30 cm stump. A numeric vector
#'   when `keep_inputs = FALSE`; otherwise a data frame.
#' @export
#'
#' @examples
#' frtc_total_biomass(30, 20, "Shorea robusta")
#' frtc_total_biomass(c(20, 30), c(15, 20), c("An", "Pr"))
frtc_total_biomass <- function(dbh, height, species, keep_inputs = FALSE) {
  n <- max(length(dbh), length(height), length(species))
  valid_lengths <- c(1L, n)
  supplied_lengths <- c(length(dbh), length(height), length(species))
  if (any(!supplied_lengths %in% valid_lengths)) {
    stop("Inputs must have length 1 or a common length.", call. = FALSE)
  }

  dbh <- rep(as.numeric(dbh), length.out = n)
  height <- rep(as.numeric(height), length.out = n)
  species_input <- rep(species, length.out = n)
  code <- .normalize_frtc_species(species_input)
  missing_species <- is.na(species_input) |
    !nzchar(trimws(as.character(species_input)))
  unsupported <- is.na(code) & !missing_species
  if (any(unsupported)) {
    warning(
      "FRTC total-biomass models are unavailable for ", sum(unsupported),
      " tree(s). Unsupported species: ",
      paste(unique(as.character(species_input[unsupported])), collapse = ", "),
      ". Biomass was returned as NA for these trees.",
      call. = FALSE
    )
  }

  if (any(!is.finite(dbh) | dbh <= 0, na.rm = TRUE)) {
    stop("`dbh` must contain positive finite values in centimetres.", call. = FALSE)
  }
  if (any(!is.finite(height) | height <= 0, na.rm = TRUE)) {
    stop("`height` must contain positive finite values in metres.", call. = FALSE)
  }

  supported <- !is.na(code)
  required_density <- supported & code %in% c("An", "Lp", "Sr", "Sw", "Ta")
  recommended <- .frtc_total_density(code, dbh)
  density <- recommended
  density_source <- ifelse(
    !supported, "not_available",
    ifelse(!required_density, "not_required",
      ifelse(code %in% c("Sr", "Ta"), "frtc_dbh_class",
             "frtc_species_average")
    )
  )

  idx <- match(code, .frtc_total_biomass_models$species_code)
  model <- .frtc_total_biomass_models[idx, ]
  biomass <- rep(NA_real_, n)
  density_model <- supported & model$equation == "density_power"
  biomass[density_model] <- model$a[density_model] *
    (dbh[density_model]^2 * height[density_model] * density[density_model])^
      model$b[density_model]
  dbh_height_model <- supported & model$equation == "dbh_height"
  biomass[dbh_height_model] <- model$a[dbh_height_model] *
    dbh[dbh_height_model]^model$b[dbh_height_model] *
    height[dbh_height_model]^model$c[dbh_height_model]

  if (!keep_inputs) return(biomass)

  species_table <- frtc_species()
  names_lookup <- stats::setNames(species_table$scientific_name,
                                  species_table$species_code)
  ids_lookup <- stats::setNames(species_table$species_id,
                                species_table$species_code)
  data.frame(
    dbh_cm = dbh,
    height_m = height,
    species_input = as.character(species_input),
    species_standardized = unname(ids_lookup[code]),
    species_code = code,
    scientific_name = unname(names_lookup[code]),
    wood_density_g_cm3 = ifelse(required_density, density, NA_real_),
    density_source = density_source,
    frtc_total_biomass_kg = biomass,
    estimation_status = ifelse(
      supported, "estimated",
      ifelse(missing_species, "missing_species", "unsupported_species")
    ),
    biomass_boundary = ifelse(
      supported, "above 0.30 m; stump excluded", NA_character_
    ),
    stringsAsFactors = FALSE
  )
}
