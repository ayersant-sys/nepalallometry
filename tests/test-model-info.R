library(nepalallometry)

models <- frtc_models()
stopifnot(nrow(models) == 7L)
stopifnot(models$a[models$species_id == "shorea_robusta"] == 0.054968)
stopifnot(models$operational_rmse_kg[
  models$species_id == "shorea_robusta"
] == 354.007)

density <- frtc_density("sal", dbh = 30)
stopifnot(density$density_g_cm3 == 0.5573)
stopifnot(density$density_source == "frtc_dbh_class")

pinus_density <- frtc_density("pinus_roxburghii", dbh = 30)
stopifnot(is.na(pinus_density$density_g_cm3))
stopifnot(pinus_density$density_source == "not_required")

equation <- capture.output(info <- frtc_equation("chilaune"))
stopifnot(any(grepl("Schima wallichii", equation, fixed = TRUE)))
stopifnot(info$species_id == "schima_wallichii")
