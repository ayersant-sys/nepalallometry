.sp_models <- data.frame(
  species_id = c(
    "abies_spp", "acacia_catechu", "adina_cordifolia", "albizia_spp",
    "alnus_nepalensis", "anogeissus_latifolia", "bombax_ceiba",
    "cedrela_toona", "dalbergia_sissoo", "eugenia_jambolana",
    "hymenodictyon_excelsum", "lagerstroemia_parviflora",
    "michelia_champaca", "pinus_roxburghii", "pinus_wallichiana",
    "quercus_spp", "schima_wallichii", "shorea_robusta",
    "terminalia_alata", "trewia_nudiflora", "tsuga_spp",
    "miscellaneous_terai", "miscellaneous_hills"
  ),
  scientific_name = c(
    "Abies spp.", "Acacia catechu", "Adina cordifolia", "Albizia spp.",
    "Alnus nepalensis", "Anogeissus latifolia", "Bombax ceiba",
    "Cedrela toona", "Dalbergia sissoo", "Eugenia jambolana",
    "Hymenodictyon excelsum", "Lagerstroemia parviflora",
    "Michelia champaca", "Pinus roxburghii", "Pinus wallichiana",
    "Quercus spp.", "Schima wallichii", "Shorea robusta",
    "Terminalia alata", "Trewia nudiflora", "Tsuga spp.",
    "Miscellaneous species in Terai", "Miscellaneous species in Hills"
  ),
  nepali_name = c(
    "thingre_salla", "khair", "haldu_karma", "siris", "uttis", "dhauti",
    "simal", "tuni", "sisau", "jamun", "kuda", "botdhayero", "champ",
    "khote_salla", "gobre_salla", "khasru", "chilaune", "sal", "asna",
    "gutel", "hemlock", NA, NA
  ),
  a = c(
    -2.4453, -2.3256, -2.5626, -2.4284, -2.7761, -2.2720, -2.3865,
    -2.1832, -2.1959, -2.5693, -2.5850, -2.3411, -2.0152, -2.9770,
    -2.8195, -2.3600, -2.7385, -2.4554, -2.4616, -2.4585, -2.5293,
    -2.3993, -2.3204
  ),
  b = c(
    1.7220, 1.6476, 1.8598, 1.7609, 1.9006, 1.7499, 1.7414, 1.8679,
    1.6567, 1.8816, 1.9437, 1.7246, 1.8555, 1.9235, 1.7250, 1.9680,
    1.8155, 1.9026, 1.8497, 1.8043, 1.7815, 1.7836, 1.8507
  ),
  c = c(
    1.0757, 1.0552, 0.8783, 0.9662, 0.9428, 0.9174, 1.0063, 0.7569,
    0.9899, 0.8498, 0.7902, 0.9702, 0.7630, 1.0019, 1.1623, 0.7469,
    1.0072, 0.8352, 0.8800, 0.9220, 1.0369, 0.9546, 0.8223
  ),
  branch_s = c(.44,.40,.40,.40,.80,.40,.40,.40,.68,.40,.40,.40,.40,.19,.68,.75,.52,.06,.40,.40,.44,.40,.40),
  branch_m = c(.37,.40,.40,.40,1.23,.40,.40,.40,.68,.40,.40,.40,.40,.26,.49,.96,.19,.34,.40,.40,.37,.40,.40),
  branch_l = c(.36,.40,.40,.40,1.51,.40,.40,.40,.68,.40,.40,.40,.40,.30,.41,1.06,.17,.36,.40,.40,.36,.40,.40),
  foliage_s = c(.25,.07,.07,.07,.17,.07,.07,.07,.01,.07,.07,.07,.07,.10,.40,.23,.06,.06,.07,.07,.25,.07,.07),
  foliage_m = c(.14,.05,.05,.05,.09,.05,.05,.05,.01,.05,.05,.05,.05,.05,.24,.22,.04,.07,.05,.05,.14,.05,.05),
  foliage_l = c(.11,.04,.04,.04,.06,.04,.04,.04,.01,.04,.04,.04,.04,.03,.18,.20,.03,.07,.04,.04,.11,.04,.04),
  density_kg_m3 = c(
    480,960,670,673,390,880,368,480,780,770,513,850,497,650,400,860,
    689,880,950,352,450,674,674
  ),
  sample_size = c(
    148,270,229,112,163,123,221,139,266,142,125,192,113,612,340,152,
    47,895,492,98,94,109,138
  ),
  dbh_min_cm = c(
    13.0,13.2,13.2,15.5,12.7,14.5,14.5,13.0,14.0,14.5,13.5,13.2,
    16.3,12.7,13.0,13.0,18.3,12.7,12.7,15.7,13.7,14.5,14.7
  ),
  dbh_max_cm = c(
    77.2,53.3,121.4,119.4,83.6,82.6,137.4,91.2,78.0,108.7,95.5,80.0,
    136.4,100.3,92.7,113.0,77.5,144.5,131.1,70.1,117.9,114.8,94.0
  ),
  stringsAsFactors = FALSE
)

.sp_key <- function(x) {
  x <- tolower(trimws(as.character(x)))
  x <- gsub("[^a-z0-9]+", "_", x)
  gsub("^_+|_+$", "", x)
}

.sp_aliases <- local({
  aliases <- list(
    abies_spp=c("abies_spp","abies","fir","thingre_salla"),
    acacia_catechu=c("acacia_catechu","khair"),
    adina_cordifolia=c("adina_cordifolia","haldu","karma"),
    albizia_spp=c("albizia_spp","albizia","siris"),
    alnus_nepalensis=c("alnus_nepalensis","uttis","utis"),
    anogeissus_latifolia=c("anogeissus_latifolia","banjhi","dhauti"),
    bombax_ceiba=c("bombax_ceiba","bombax_malabaricum","simal"),
    cedrela_toona=c("cedrela_toona","toona_ciliata","tuni"),
    dalbergia_sissoo=c("dalbergia_sissoo","sissoo","sisau"),
    eugenia_jambolana=c("eugenia_jambolana","syzygium_cumini","jamun"),
    hymenodictyon_excelsum=c("hymenodictyon_excelsum","bhurkul","kuda"),
    lagerstroemia_parviflora=c("lagerstroemia_parviflora","botdhayero"),
    michelia_champaca=c("michelia_champaca","magnolia_champaca","champ"),
    pinus_roxburghii=c("pinus_roxburghii","khote_salla","khotesallo"),
    pinus_wallichiana=c("pinus_wallichiana","blue_pine","gobre_salla","ranisallo"),
    quercus_spp=c("quercus_spp","quercus","oak","khasru","banjh"),
    schima_wallichii=c("schima_wallichii","chilaune"),
    shorea_robusta=c("shorea_robusta","sal"),
    terminalia_alata=c("terminalia_alata","terminalia_tomentosa","asna","saaj"),
    trewia_nudiflora=c("trewia_nudiflora","gutel"),
    tsuga_spp=c("tsuga_spp","tsuga","hemlock"),
    miscellaneous_terai=c("miscellaneous_terai","miscellaneous_in_terai"),
    miscellaneous_hills=c("miscellaneous_hills","miscellaneous_in_hills","miscellaneous_hill")
  )
  out <- unlist(lapply(names(aliases), function(id) {
    stats::setNames(rep(id, length(aliases[[id]])), .sp_key(aliases[[id]]))
  }))
  out[!duplicated(names(out))]
})

.normalize_sp_species <- function(species) {
  key <- .sp_key(species)
  out <- unname(.sp_aliases[key])
  out[is.na(species) | !nzchar(trimws(as.character(species)))] <- NA_character_
  out
}

.sp_ratio <- function(dbh, small, medium, large) {
  ifelse(
    dbh < 10, small,
    ifelse(
      dbh <= 40,
      ((dbh - 10) * medium + (40 - dbh) * small) / 30,
      ifelse(
        dbh <= 70,
        ((dbh - 40) * large + (70 - dbh) * medium) / 30,
        large
      )
    )
  )
}

#' List Sharma-Pukkala biomass species and parameters
#'
#' @return A data frame containing supported species, biomass parameters,
#'   air-dry density, sample size, and observed DBH calibration range.
#' @export
sharma_pukkala_species <- function() {
  .sp_models
}

#' Estimate biomass using Sharma and Pukkala (1990)
#'
#' Estimates air-dry stem, branch, foliage, and total aboveground biomass.
#' The stem-volume equation is used internally and is not returned as a
#' user-facing volume product. Branch and foliage ratios are interpolated
#' independently by DBH using the Sharma-Pukkala procedure.
#' Schedule 9 of Nepal's Forest Regulations, 2079 provides the regulatory
#' basis for operational use of the Sharma-Pukkala tree-volume parameters.
#'
#' @param dbh Diameter at breast height in centimetres.
#' @param height Total tree height in metres.
#' @param species Supported standardized scientific identifier or Nepali/common
#'   name. Use [sharma_pukkala_species()] to inspect supported species.
#' @param carbon_fraction Carbon fraction applied to air-dry total biomass.
#'   Defaults to 0.47 following IPCC (2006).
#' @param keep_inputs If `TRUE`, return inputs, biomass components, provenance,
#'   and calibration status. If `FALSE`, return total biomass in kg/tree.
#'
#' @return Air-dry total biomass in kg/tree, or a data frame when
#'   `keep_inputs = TRUE`.
#' @export
#' @references
#' Sharma, E. R., & Pukkala, T. (1990). *Volume equations and biomass
#' prediction of forest trees of Nepal* (Publication No. 47). Forest Survey
#' and Statistics Division, Ministry of Forests and Soil Conservation.
#'
#' Government of Nepal. (2022). *Forest Regulations, 2079*, Schedule 9.
#' Nepal Law Commission.
#'
#' Intergovernmental Panel on Climate Change. (2006). *2006 IPCC guidelines
#' for national greenhouse gas inventories: Volume 4. Agriculture, forestry
#' and other land use*. IGES.
#'
#' @examples
#' sharma_pukkala_biomass(30, 20, "sal")
#' sharma_pukkala_biomass(30, 20, "chilaune", keep_inputs = TRUE)
sharma_pukkala_biomass <- function(dbh, height, species,
                                   carbon_fraction = 0.47,
                                   keep_inputs = FALSE) {
  n <- max(length(dbh), length(height), length(species))
  lengths <- c(length(dbh), length(height), length(species))
  if (any(!lengths %in% c(1L, n))) {
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

  species_id <- .normalize_sp_species(species_input)
  unsupported <- is.na(species_id) &
    !is.na(species_input) & nzchar(trimws(as.character(species_input)))
  if (any(unsupported)) {
    warning(
      "Sharma-Pukkala biomass parameters are unavailable for ",
      sum(unsupported), " tree(s). Unsupported species: ",
      paste(unique(as.character(species_input[unsupported])), collapse = ", "),
      ". Biomass was returned as NA for these trees.",
      call. = FALSE
    )
  }

  idx <- match(species_id, .sp_models$species_id)
  model <- .sp_models[idx, , drop = FALSE]
  supported <- !is.na(idx)
  branch_ratio <- .sp_ratio(
    dbh, model$branch_s, model$branch_m, model$branch_l
  )
  foliage_ratio <- .sp_ratio(
    dbh, model$foliage_s, model$foliage_m, model$foliage_l
  )

  stem_volume_internal_m3 <- rep(NA_real_, n)
  stem_volume_internal_m3[supported] <- exp(
    model$a[supported] +
      model$b[supported] * log(dbh[supported]) +
      model$c[supported] * log(height[supported])
  ) / 1000

  stem_biomass <- stem_volume_internal_m3 * model$density_kg_m3
  branch_biomass <- stem_biomass * branch_ratio
  foliage_biomass <- stem_biomass * foliage_ratio
  total_biomass <- stem_biomass + branch_biomass + foliage_biomass
  carbon <- total_biomass * carbon_fraction

  within <- supported & dbh >= model$dbh_min_cm & dbh <= model$dbh_max_cm
  within[!supported] <- NA
  calibration_status <- ifelse(
    !supported, "not_available",
    ifelse(
      dbh < model$dbh_min_cm, "below_observed_dbh_range",
      ifelse(dbh > model$dbh_max_cm, "above_observed_dbh_range",
             "within_observed_dbh_range")
    )
  )
  extrapolated <- supported & !within
  if (any(extrapolated)) {
    warning(
      sum(extrapolated),
      " supported tree(s) are outside the observed Sharma-Pukkala ",
      "model-development DBH range. Predictions were returned but are ",
      "extrapolations. Height extrapolation could not be assessed because ",
      "species-specific height ranges were not reported.",
      call. = FALSE
    )
  }

  if (!keep_inputs) return(total_biomass)

  data.frame(
    dbh_cm = dbh,
    height_m = height,
    species_input = as.character(species_input),
    species_standardized = species_id,
    scientific_name = model$scientific_name,
    nepali_name = model$nepali_name,
    density_kg_m3 = model$density_kg_m3,
    branch_ratio = branch_ratio,
    foliage_ratio = foliage_ratio,
    sp_stem_biomass_kg = stem_biomass,
    sp_branch_biomass_kg = branch_biomass,
    sp_foliage_biomass_kg = foliage_biomass,
    sp_total_biomass_kg = total_biomass,
    carbon_fraction = carbon_fraction,
    sp_carbon_kg = carbon,
    calibration_dbh_min_cm = model$dbh_min_cm,
    calibration_dbh_max_cm = model$dbh_max_cm,
    within_calibration_dbh_range = within,
    calibration_status = calibration_status,
    height_calibration_status = ifelse(
      supported, "not_assessed_not_reported", "not_available"
    ),
    estimation_status = ifelse(supported, "estimated", "unsupported_species"),
    biomass_moisture_basis = ifelse(supported, "air_dry", NA_character_),
    biomass_boundary = ifelse(
      supported, "stem + branches + foliage; stump boundary not specified",
      NA_character_
    ),
    model_source = ifelse(
      supported, "Sharma and Pukkala (1990)", NA_character_
    ),
    parameter_source = ifelse(
      supported,
      "Sharma and Pukkala (1990); Forest Regulations, 2079, Schedule 9",
      NA_character_
    ),
    stringsAsFactors = FALSE
  )
}
