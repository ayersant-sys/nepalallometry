.frtc_calibration_ranges <- data.frame(
  species_code = c("An", "Cs", "Lp", "Pr", "Sr", "Sw", "Ta"),
  sample_size = c(52L, 52L, 46L, 96L, 122L, 47L, 61L),
  dbh_min_cm = c(7.4, 5.4, 7.1, 6.7, 6.7, 5.5, 5.4),
  dbh_max_cm = c(83.4, 76.4, 58.1, 91.2, 102.4, 67.5, 103.2),
  height_min_m = c(4.5, 4.55, 5.5, 2.5, 4.9, 5.0, 4.8),
  height_max_m = c(36.6, 29.4, 29.3, 36.4, 42.0, 32.8, 38.4),
  stringsAsFactors = FALSE
)

.frtc_calibration_info <- function(code, dbh, height) {
  idx <- match(code, .frtc_calibration_ranges$species_code)
  limits <- .frtc_calibration_ranges[idx, , drop = FALSE]

  assessed <- !is.na(code) & is.finite(dbh) & is.finite(height)
  below_dbh <- assessed & dbh < limits$dbh_min_cm
  above_dbh <- assessed & dbh > limits$dbh_max_cm
  below_height <- assessed & height < limits$height_min_m
  above_height <- assessed & height > limits$height_max_m
  outside_count <- below_dbh + above_dbh + below_height + above_height

  status <- rep("not_available", length(code))
  status[!is.na(code) & !assessed] <- "not_assessed_missing_measurement"
  status[assessed & outside_count == 0L] <- "within_observed_range"
  status[below_dbh & outside_count == 1L] <- "below_dbh_range"
  status[above_dbh & outside_count == 1L] <- "above_dbh_range"
  status[below_height & outside_count == 1L] <- "below_height_range"
  status[above_height & outside_count == 1L] <- "above_height_range"
  status[assessed & outside_count > 1L] <- "multiple_dimensions_outside_range"

  within <- rep(NA, length(code))
  within[assessed] <- outside_count[assessed] == 0L

  data.frame(
    calibration_dbh_min_cm = limits$dbh_min_cm,
    calibration_dbh_max_cm = limits$dbh_max_cm,
    calibration_height_min_m = limits$height_min_m,
    calibration_height_max_m = limits$height_max_m,
    within_calibration_range = within,
    calibration_status = status,
    stringsAsFactors = FALSE
  )
}
