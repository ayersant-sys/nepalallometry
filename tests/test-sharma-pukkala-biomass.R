models <- sharma_pukkala_species()
stopifnot(nrow(models) == 23L)
stopifnot(all(c(
  "species_id", "a", "b", "c", "branch_s", "branch_m", "branch_l",
  "foliage_s", "foliage_m", "foliage_l", "density_kg_m3",
  "dbh_min_cm", "dbh_max_cm"
) %in% names(models)))

sal <- sharma_pukkala_biomass(
  50, 35, "sal", keep_inputs = TRUE
)
stopifnot(sal$species_standardized == "shorea_robusta")
stopifnot(abs(sal$branch_ratio - 0.3466666667) < 1e-8)
stopifnot(abs(sal$foliage_ratio - 0.07) < 1e-8)
stopifnot(abs(sal$sp_total_biomass_kg - 3559.997045) < 0.01)
stopifnot(sal$biomass_moisture_basis == "air_dry")
stopifnot(sal$calibration_status == "within_observed_dbh_range")
stopifnot(sal$height_calibration_status == "not_assessed_not_reported")

small <- sharma_pukkala_biomass(
  8, 10, "pinus_roxburghii", keep_inputs = TRUE
)
stopifnot(small$branch_ratio == 0.19)
stopifnot(small$foliage_ratio == 0.10)

medium <- sharma_pukkala_biomass(
  25, 15, "uttis", keep_inputs = TRUE
)
stopifnot(abs(medium$branch_ratio - mean(c(0.80, 1.23))) < 1e-12)

large <- sharma_pukkala_biomass(
  80, 30, "chilaune", keep_inputs = TRUE
)
stopifnot(large$branch_ratio == 0.17)
stopifnot(large$foliage_ratio == 0.03)

outside <- suppressWarnings(sharma_pukkala_biomass(
  160, 35, "sal", keep_inputs = TRUE
))
stopifnot(identical(outside$within_calibration_dbh_range, FALSE))
stopifnot(outside$calibration_status == "above_observed_dbh_range")

mixed <- suppressWarnings(sharma_pukkala_biomass(
  c(30, 20), c(20, 15), c("khair", "unknown_tree"),
  keep_inputs = TRUE
))
stopifnot(mixed$estimation_status[1] == "estimated")
stopifnot(mixed$estimation_status[2] == "unsupported_species")
stopifnot(is.na(mixed$sp_total_biomass_kg[2]))

misc <- sharma_pukkala_biomass(
  30, 20, "miscellaneous_terai", keep_inputs = TRUE
)
stopifnot(misc$species_standardized == "miscellaneous_terai")
