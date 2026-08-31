#' Species supported by the FRTC 2025 equations
#'
#' Returns the accepted species codes and scientific names used by
#' [frtc_total_biomass()].
#'
#' @return A data frame with `species_code` and `scientific_name`.
#' @export
frtc_species <- function() {
  data.frame(
    species_id = c(
      "alnus_nepalensis", "castanopsis_spp", "lagerstroemia_parviflora",
      "pinus_roxburghii", "shorea_robusta", "schima_wallichii",
      "terminalia_alata"
    ),
    nepali_name = c("utis", "katus", "botdhayero", "khotesallo", "sal",
                    "chilaune", "asna"),
    species_code = c("An", "Cs", "Lp", "Pr", "Sr", "Sw", "Ta"),
    scientific_name = c(
      "Alnus nepalensis",
      "Castanopsis spp.",
      "Lagerstroemia parviflora",
      "Pinus roxburghii",
      "Shorea robusta",
      "Schima wallichii",
      "Terminalia alata"
    ),
    stringsAsFactors = FALSE
  )
}

.normalize_frtc_species <- function(species) {
  x <- trimws(tolower(as.character(species)))
  x <- gsub("[ -]+", "_", x)
  aliases <- c(
    "an" = "An", "alnus_nepalensis" = "An", "utis" = "An",
    "uttis" = "An",
    "cs" = "Cs", "castanopsis_spp." = "Cs", "castanopsis_spp" = "Cs",
    "castanopsis_spps." = "Cs", "castanopsis_spps" = "Cs",
    "castanopsis" = "Cs", "katus" = "Cs", "katush" = "Cs",
    "lp" = "Lp", "lagerstroemia_parviflora" = "Lp", "botdhayero" = "Lp",
    "pr" = "Pr", "pinus_roxburghii" = "Pr", "khotesallo" = "Pr",
    "khote_sallo" = "Pr",
    "sr" = "Sr", "shorea_robusta" = "Sr", "sal" = "Sr",
    "sw" = "Sw", "schima_wallichii" = "Sw", "schima_wallichi" = "Sw",
    "chilaune" = "Sw",
    "ta" = "Ta", "terminalia_alata" = "Ta", "asna" = "Ta", "saj" = "Ta"
  )
  out <- unname(aliases[x])
  out
}
