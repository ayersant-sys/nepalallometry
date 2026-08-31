library(nepalallometry)

# Hand calculations from the published functional forms and coefficients.
stopifnot(isTRUE(all.equal(
  frtc_total_biomass(30, 20, "Sr"),
  0.054968 * (30^2 * 20 * 0.5573)^0.980885
)))

stopifnot(isTRUE(all.equal(
  frtc_total_biomass(30, 20, "Pr"),
  0.031693 * 30^2.329281 * 20^0.519366
)))

# Scientific names and codes must give identical results.
stopifnot(isTRUE(all.equal(
  frtc_total_biomass(25, 18, "Alnus nepalensis"),
  frtc_total_biomass(25, 18, "An")
)))

mixed <- suppressWarnings(frtc_total_biomass(
  c(30, 20), c(20, 15), c("sal", "acacia_catechu"), keep_inputs = TRUE
))
stopifnot(mixed$estimation_status[1] == "estimated")
stopifnot(mixed$estimation_status[2] == "unsupported_species")
stopifnot(is.na(mixed$frtc_total_biomass_kg[2]))
