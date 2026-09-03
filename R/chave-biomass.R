.chave_frtc_codes <- c("An", "Lp", "Sr", "Sw", "Ta")

.gwdd_cache <- new.env(parent = emptyenv())

.gwdd_read <- function(level) {
  if (exists(level, envir = .gwdd_cache, inherits = FALSE)) {
    return(get(level, envir = .gwdd_cache, inherits = FALSE))
  }
  filename <- paste0("gwddagg_v2.2_", level, ".csv.gz")
  path <- system.file("extdata", filename, package = "nepalallometry")
  if (!nzchar(path)) {
    stop("Bundled GWDD v2.2 file is unavailable: ", filename, call. = FALSE)
  }
  x <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  assign(level, x, envir = .gwdd_cache)
  x
}

.chave_clean_taxon <- function(x) {
  x <- trimws(gsub("_", " ", as.character(x), fixed = TRUE))
  gsub("\\s+", " ", x)
}

.chave_density_lookup <- function(species, dbh) {
  n <- length(species)
  density <- rep(NA_real_, n)
  source <- rep(NA_character_, n)
  level <- rep(NA_character_, n)
  matched <- rep(NA_character_, n)
  value_field <- rep(NA_character_, n)

  frtc_code <- .normalize_frtc_species(species)
  use_frtc <- !is.na(frtc_code) & frtc_code %in% .chave_frtc_codes
  if (any(use_frtc)) {
    density[use_frtc] <- .frtc_total_density(
      frtc_code[use_frtc], dbh[use_frtc]
    )
    frtc_names <- stats::setNames(
      frtc_species()$scientific_name, frtc_species()$species_code
    )
    source[use_frtc] <- "FRTC_2025_basic_density"
    level[use_frtc] <- ifelse(
      frtc_code[use_frtc] %in% c("Sr", "Ta"),
      "dbh_class", "species_average"
    )
    matched[use_frtc] <- unname(frtc_names[frtc_code[use_frtc]])
    value_field[use_frtc] <- "FRTC_recommended_density"
  }

  unresolved <- which(is.na(density))
  if (!length(unresolved)) {
    return(data.frame(density, source, level, matched, value_field))
  }

  frtc_names <- stats::setNames(
    frtc_species()$scientific_name, frtc_species()$species_code
  )
  taxon <- .chave_clean_taxon(species)
  mapped <- !is.na(frtc_code)
  taxon[mapped] <- unname(frtc_names[frtc_code[mapped]])
  taxon_key <- tolower(taxon)
  words <- strsplit(taxon_key, "\\s+")

  species_table <- .gwdd_read("species")
  accepted <- is.na(species_table$status_taxonomic) |
    species_table$status_taxonomic == "accepted"
  species_keys <- tolower(species_table$species)

  for (i in unresolved) {
    wi <- words[[i]]
    if (!length(wi) || !nzchar(wi[1]) || is.na(taxon_key[i])) next

    has_infraspecific_name <- length(wi) >= 3L &&
      !wi[2] %in% c("sp", "sp.", "spp", "spp.")
    if (has_infraspecific_name) {
      j <- match(taxon_key[i], species_keys)
      if (!is.na(j) && accepted[j] && is.finite(species_table$wsg_est_trunk[j])) {
        density[i] <- species_table$wsg_est_trunk[j]
        source[i] <- "GWDD_v2.2"
        level[i] <- "species_infraspecific"
        matched[i] <- species_table$species[j]
        value_field[i] <- "wsg_est_trunk"
        next
      }
    }

    is_binomial <- length(wi) >= 2L &&
      !wi[2] %in% c("sp", "sp.", "spp", "spp.")
    if (is_binomial) {
      binomial_table <- .gwdd_read("binomial")
      binomial_key <- paste(wi[1:2], collapse = " ")
      j <- match(binomial_key, tolower(binomial_table$binomial))
      if (!is.na(j) && is.finite(binomial_table$wsg_est_trunk[j])) {
        density[i] <- binomial_table$wsg_est_trunk[j]
        source[i] <- "GWDD_v2.2"
        level[i] <- "binomial"
        matched[i] <- binomial_table$binomial[j]
        value_field[i] <- "wsg_est_trunk"
        next
      }
    }

    genus_table <- .gwdd_read("genus")
    j <- match(wi[1], tolower(genus_table$genus))
    if (!is.na(j) && is.finite(genus_table$wsg_est_trunk[j])) {
      density[i] <- genus_table$wsg_est_trunk[j]
      source[i] <- "GWDD_v2.2"
      level[i] <- "genus"
      matched[i] <- genus_table$genus[j]
      value_field[i] <- "wsg_est_trunk"
    }
  }

  data.frame(density, source, level, matched, value_field)
}

#' Estimate aboveground biomass using Chave et al. (2014)
#'
#' Applies the height-inclusive pantropical equation
#' `AGB = 0.0673 * (rho * D^2 * H)^0.976`. Basic wood density is selected
#' automatically from FRTC (2025) for the five FRTC species whose recommended
#' biomass equations use density, then from GWDD v2.2 at exact infraspecific,
#' binomial, or genus level. GWDD model-derived trunk density
#' (`wsg_est_trunk`) is used rather than the raw mean.
#'
#' @param dbh Diameter at breast height in centimetres.
#' @param height Total tree height in metres.
#' @param species Scientific name or a supported FRTC code or Nepali name.
#'   Scientific binomials are required for species-level GWDD matching.
#' @param wood_density Optional user-supplied basic wood density in g/cm3,
#'   defined as oven-dry mass divided by fresh volume. When supplied, it
#'   overrides automatic FRTC/GWDD lookup.
#' @param carbon_fraction Carbon fraction applied to oven-dry AGB. Defaults to
#'   0.47 following IPCC (2006).
#' @param keep_inputs If `TRUE`, return inputs, density provenance, biomass,
#'   carbon, and calibration status. If `FALSE`, return AGB in kg/tree.
#'
#' @return Oven-dry aboveground biomass in kg/tree, or a data frame when
#'   `keep_inputs = TRUE`.
#' @export
#' @references
#' Chave, J., et al. (2014). Improved allometric models to estimate the
#' aboveground biomass of tropical trees. *Global Change Biology, 20*(10),
#' 3177-3190. \doi{10.1111/gcb.12629}
#'
#' Fischer, F. J., et al. (2026a). Beyond species means: The intraspecific
#' contribution to global wood density variation. *New Phytologist, 249*,
#' 2630-2651. \doi{10.1111/nph.70860}
#'
#' Fischer, F. J., et al. (2026b). *Global Wood Density Database v2.2*
#' [Data set]. Zenodo. \doi{10.5281/zenodo.18262736}
#'
#' Intergovernmental Panel on Climate Change. (2006). *2006 IPCC guidelines
#' for national greenhouse gas inventories: Volume 4. Agriculture, forestry
#' and other land use*. IGES.
#'
#' @examples
#' chave_biomass(30, 20, "sal")
#' chave_biomass(30, 20, "Dalbergia sissoo", keep_inputs = TRUE)
chave_biomass <- function(dbh, height, species, wood_density = NULL,
                          carbon_fraction = 0.47, keep_inputs = FALSE) {
  n <- max(length(dbh), length(height), length(species))
  supplied_lengths <- c(length(dbh), length(height), length(species))
  if (any(!supplied_lengths %in% c(1L, n))) {
    stop("Inputs must have length 1 or a common length.", call. = FALSE)
  }
  if (length(carbon_fraction) != 1L || !is.finite(carbon_fraction) ||
      carbon_fraction < 0 || carbon_fraction > 1) {
    stop("`carbon_fraction` must be one finite value between 0 and 1.",
         call. = FALSE)
  }

  dbh <- rep(as.numeric(dbh), length.out = n)
  height <- rep(as.numeric(height), length.out = n)
  species_input <- rep(species, length.out = n)
  if (any(!is.finite(dbh) | dbh <= 0, na.rm = TRUE)) {
    stop("`dbh` must contain positive finite values in centimetres.",
         call. = FALSE)
  }
  if (any(!is.finite(height) | height <= 0, na.rm = TRUE)) {
    stop("`height` must contain positive finite values in metres.",
         call. = FALSE)
  }

  lookup <- .chave_density_lookup(species_input, dbh)
  if (!is.null(wood_density)) {
    if (!length(wood_density) %in% c(1L, n)) {
      stop("`wood_density` must have length 1 or the common input length.",
           call. = FALSE)
    }
    supplied <- rep(as.numeric(wood_density), length.out = n)
    invalid_density <- !is.na(supplied) &
      (!is.finite(supplied) | supplied <= 0 | supplied > 1.5)
    if (any(invalid_density)) {
      stop(paste0(
        "`wood_density` must contain positive finite basic-density values ",
        "in g/cm3 (normally less than 1.5)."
      ), call. = FALSE)
    }
    use <- !is.na(supplied)
    lookup$density[use] <- supplied[use]
    lookup$source[use] <- "user_supplied"
    lookup$level[use] <- "user_supplied"
    lookup$matched[use] <- as.character(species_input[use])
    lookup$value_field[use] <- "wood_density"
  }

  missing_density <- is.na(lookup$density)
  if (any(missing_density)) {
    warning(
      "Basic wood density was unavailable for ", sum(missing_density),
      " tree(s). Chave biomass was returned as NA. Unmatched taxa: ",
      paste(unique(as.character(species_input[missing_density])),
            collapse = ", "), ".",
      call. = FALSE
    )
  }
  genus_match <- lookup$level == "genus"
  genus_match[is.na(genus_match)] <- FALSE
  if (any(genus_match)) {
    warning(
      sum(genus_match), " tree(s) used a GWDD v2.2 genus-level density. ",
      "Inspect `density_taxon_matched` and `density_match_level`.",
      call. = FALSE
    )
  }

  agb <- 0.0673 * (lookup$density * dbh^2 * height)^0.976
  carbon <- agb * carbon_fraction
  within_dbh <- dbh >= 5 & dbh <= 212
  if (any(!within_dbh)) {
    warning(
      sum(!within_dbh), " tree(s) are outside the 5-212 cm DBH range of ",
      "the Chave et al. (2014) calibration data. Predictions were returned ",
      "but are extrapolations.", call. = FALSE
    )
  }

  if (!keep_inputs) return(agb)

  data.frame(
    dbh_cm = dbh,
    height_m = height,
    species_input = as.character(species_input),
    wood_density_g_cm3 = lookup$density,
    density_source = lookup$source,
    density_match_level = lookup$level,
    density_taxon_matched = lookup$matched,
    density_value_field = lookup$value_field,
    density_definition = ifelse(
      !missing_density, "oven-dry mass / fresh volume", NA_character_
    ),
    density_database_version = ifelse(
      lookup$source == "GWDD_v2.2", "GWDD v2.2", NA_character_
    ),
    chave_agb_kg = agb,
    carbon_fraction = carbon_fraction,
    chave_carbon_kg = carbon,
    within_chave_dbh_range = within_dbh,
    calibration_status = ifelse(
      dbh < 5, "below_chave_dbh_range",
      ifelse(dbh > 212, "above_chave_dbh_range", "within_chave_dbh_range")
    ),
    estimation_status = ifelse(missing_density, "density_unavailable",
                               "estimated"),
    biomass_moisture_basis = "oven_dry",
    biomass_boundary = "aboveground biomass as defined by Chave et al. (2014)",
    model_source = "Chave et al. (2014)",
    stringsAsFactors = FALSE
  )
}
