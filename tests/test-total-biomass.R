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


within <- frtc_total_biomass(
  30, 20, "sal", keep_inputs = TRUE
)
stopifnot(isTRUE(within$within_calibration_range))
stopifnot(within$calibration_status == "within_observed_range")
stopifnot(within$calibration_dbh_min_cm == 6.7)
stopifnot(within$calibration_dbh_max_cm == 102.4)

outside <- suppressWarnings(frtc_total_biomass(
  110, 45, "sal", keep_inputs = TRUE
))
stopifnot(identical(outside$within_calibration_range, FALSE))
stopifnot(outside$calibration_status ==
            "multiple_dimensions_outside_range")

unsupported <- suppressWarnings(frtc_total_biomass(
  20, 15, "acacia_catechu", keep_inputs = TRUE
))
stopifnot(is.na(unsupported$within_calibration_range))
stopifnot(unsupported$calibration_status == "not_available")
