# FRTC 2025 tree-volume equations for seven major tree species.
#
# Source fidelity is intentional: model forms, coefficients, sample sizes, and
# volume definitions below reproduce the selected equations reported by FRTC
# (2025), Tables 6-8. No coefficients are re-fitted, adjusted, harmonized, or
# constrained by nepalallometry.
#
# FRTC definitions reproduced here:
#   total_ob = total stem volume over-bark;
#   ub_20cm  = under-bark stem volume up to a 20-cm over-bark top diameter;
#   ub_10cm  = under-bark stem volume up to a 10-cm over-bark top diameter.
# All three stem-volume definitions exclude the 0.30-m stump. Branch volume is
# not included in these three fitted stem-volume equations.

.frtc_volume_models <- data.frame(
  species_code = rep(c("An", "Cs", "Lp", "Pr", "Sr", "Sw", "Ta"), 3),
  volume_type = rep(c("total_ob", "ub_20cm", "ub_10cm"), each = 7),
  form = c(
    "a_db_hc", "a_d2h_b", "a_d2h_b", "a_d2h_b", "a_d2h_b", "a_db_hc", "a_d2h_b",
    "a_d2h_b", "a_d2h_b", "linear_d2h", "a_d2h_b", "a_d2h_b", "a_db_hc", "a_d2h_b",
    "a_db_hc", "a_d2h_b", "a_d2h_b", "a_d2h_b", "a_db_hc", "a_db_hc", "a_d2h_b"
  ),
  a = c(
    0.000048, 0.000064, 0.000064, 0.000058, 0.000059, 0.000047, 0.000070,
    0.000023, 0.000009, -0.147542, 0.000007, 0.000007, 0.000003, 0.000010,
    0.000018, 0.000031, 0.000014, 0.000014, 0.000011, 0.000010, 0.000021
  ),
  b = c(
    1.769901, 0.936534, 0.936459, 0.957300, 0.948535, 1.677002, 0.928364,
    1.016204, 1.089575, 0.000031, 1.121720, 1.113125, 1.994043, 1.074116,
    1.785698, 0.987658, 1.068129, 1.064049, 1.960877, 1.765752, 1.013348
  ),
  c = c(
    1.165658, NA, NA, NA, NA, 1.254950, NA,
    NA, NA, NA, NA, NA, 1.644049, NA,
    1.403011, NA, NA, NA, 1.308190, 1.523197, NA
  ),
  sample_size = c(
    52L, 52L, 46L, 96L, 122L, 47L, 61L,
    43L, 42L, 31L, 82L, 107L, 39L, 53L,
    51L, 49L, 44L, 94L, 119L, 46L, 59L
  ),
  stringsAsFactors = FALSE
)

.frtc_volume_predict <- function(code, dbh, height, volume_type) {
  idx <- match(paste(code, volume_type),
               paste(.frtc_volume_models$species_code,
                     .frtc_volume_models$volume_type))
  m <- .frtc_volume_models[idx, , drop = FALSE]
  out <- rep(NA_real_, length(code))
  ok <- !is.na(idx) & is.finite(dbh) & dbh > 0 & is.finite(height) & height > 0
  f1 <- ok & m$form == "a_db_hc"
  f2 <- ok & m$form == "a_d2h_b"
  f3 <- ok & m$form == "linear_d2h"
  out[f1] <- m$a[f1] * dbh[f1]^m$b[f1] * height[f1]^m$c[f1]
  out[f2] <- m$a[f2] * (dbh[f2]^2 * height[f2])^m$b[f2]
  out[f3] <- m$a[f3] + m$b[f3] * (dbh[f3]^2 * height[f3])
  out
}

#' Estimate FRTC 2025 stem volumes
#'
#' Reproduces the selected FRTC (2025) equations for three reported stem-volume
#' definitions for the seven supported species: total stem volume over-bark,
#' under-bark stem volume up to a 20-cm over-bark top diameter, and under-bark
#' stem volume up to a 10-cm over-bark top diameter. The equations, model forms,
#' and coefficients are used as published; they are not re-fitted or modified by
#' the package. All three definitions exclude the 30-cm stump. These fitted
#' equations estimate stem volume; branch volume is not included.
#'
#' @param dbh Diameter at breast height in cm.
#' @param height Total tree height in m.
#' @param species Species name, code, or accepted alias.
#' @param keep_inputs Logical; retain inputs and status fields.
#'
#' @return A data frame with FRTC stem-volume estimates in m3/tree.
#' @export
frtc_volume <- function(dbh, height, species, keep_inputs = FALSE) {
  n <- max(length(dbh), length(height), length(species))
  dbh <- rep_len(as.numeric(dbh), n)
  height <- rep_len(as.numeric(height), n)
  species <- rep_len(species, n)
  code <- .normalize_frtc_species(species)

  total <- .frtc_volume_predict(code, dbh, height, "total_ob")
  top20 <- .frtc_volume_predict(code, dbh, height, "ub_20cm")
  top10 <- .frtc_volume_predict(code, dbh, height, "ub_10cm")

  # The fitted 10-cm and 20-cm equations apply to stems that reach the stated
  # top-diameter definition. A tree whose DBH itself is below that top diameter
  # cannot meet that definition, so no estimate is returned for that output.
  # This does not alter the published equations or their coefficients.
  top20[is.finite(dbh) & dbh < 20] <- NA_real_
  top10[is.finite(dbh) & dbh < 10] <- NA_real_

  cal <- .frtc_calibration_info(code, dbh, height)
  status <- ifelse(is.na(code), "unsupported_species",
                   ifelse(!is.finite(dbh) | dbh <= 0 | !is.finite(height) | height <= 0,
                          "invalid_measurement", "estimated"))

  ans <- data.frame(
    frtc_total_volume_m3 = total,
    frtc_volume_ub_20cm_m3 = top20,
    frtc_volume_ub_10cm_m3 = top10,
    stringsAsFactors = FALSE
  )

  if (isTRUE(keep_inputs)) {
    ans <- data.frame(
      species = species,
      species_code = code,
      dbh_cm = dbh,
      height_m = height,
      ans,
      top20_status = ifelse(is.na(code), "unsupported_species",
                            ifelse(dbh < 20, "dbh_below_20cm_top_limit", "estimated")),
      top10_status = ifelse(is.na(code), "unsupported_species",
                            ifelse(dbh < 10, "dbh_below_10cm_top_limit", "estimated")),
      estimation_status = status,
      cal,
      volume_source = "FRTC (2025)",
      volume_boundary = paste(
        "Stem only; 30-cm stump excluded;",
        "total = over-bark stem to tip;",
        "20-cm and 10-cm outputs = under-bark stem to the stated over-bark top diameter;",
        "branches excluded"
      ),
      stringsAsFactors = FALSE
    )
  }
  ans
}
