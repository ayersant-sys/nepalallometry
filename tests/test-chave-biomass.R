library(nepalallometry)

sal <- chave_biomass(50, 35, "sal", keep_inputs = TRUE)
expected_sal <- 0.0673 * (0.6331 * 50^2 * 35)^0.976
stopifnot(abs(sal$chave_agb_kg - expected_sal) < 1e-8)
stopifnot(sal$density_source == "FRTC_2025_basic_density")
stopifnot(sal$density_match_level == "dbh_class")
stopifnot(sal$biomass_moisture_basis == "oven_dry")

alnus <- chave_biomass(30, 20, "Alnus nepalensis", keep_inputs = TRUE)
stopifnot(alnus$wood_density_g_cm3 == 0.4318)
stopifnot(alnus$density_match_level == "species_average")

pine <- chave_biomass(30, 20, "Pinus roxburghii", keep_inputs = TRUE)
stopifnot(pine$wood_density_g_cm3 == 0.46)
stopifnot(pine$density_source == "GWDD_v2.2")
stopifnot(pine$density_match_level == "binomial")
stopifnot(pine$density_taxon_matched == "Pinus roxburghii")

castanopsis <- suppressWarnings(chave_biomass(
  30, 20, "Castanopsis spp.", keep_inputs = TRUE
))
stopifnot(castanopsis$density_source == "GWDD_v2.2")
stopifnot(castanopsis$density_match_level == "genus")
stopifnot(castanopsis$density_taxon_matched == "Castanopsis")

infraspecific <- chave_biomass(
  20, 15, "Pinus nigra subsp. laricio", keep_inputs = TRUE
)
stopifnot(infraspecific$density_source == "GWDD_v2.2")
stopifnot(infraspecific$density_match_level %in%
            c("species_infraspecific", "binomial"))

override <- chave_biomass(
  30, 20, "unknown tree", wood_density = 0.55, keep_inputs = TRUE
)
stopifnot(override$wood_density_g_cm3 == 0.55)
stopifnot(override$density_source == "user_supplied")

missing <- suppressWarnings(chave_biomass(
  30, 20, "not_a_real_taxon", keep_inputs = TRUE
))
stopifnot(is.na(missing$chave_agb_kg))
stopifnot(missing$estimation_status == "density_unavailable")

outside <- suppressWarnings(chave_biomass(
  220, 45, "sal", keep_inputs = TRUE
))
stopifnot(!outside$within_chave_dbh_range)
stopifnot(outside$calibration_status == "above_chave_dbh_range")
