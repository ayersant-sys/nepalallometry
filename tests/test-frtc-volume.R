library(nepalallometry)

# FRTC 2025 hand calculations for Shorea robusta.
sal <- frtc_volume(60, 25, "sal", keep_inputs = TRUE)
stopifnot(isTRUE(all.equal(
  sal$frtc_total_volume_m3,
  0.000059 * (60^2 * 25)^0.948535
)))
stopifnot(isTRUE(all.equal(
  sal$frtc_volume_ub_20cm_m3,
  0.000007 * (60^2 * 25)^1.113125
)))
stopifnot(isTRUE(all.equal(
  sal$frtc_volume_ub_10cm_m3,
  0.000011 * 60^1.960877 * 25^1.308190
)))
stopifnot(sal$volume_boundary ==
            "Stem only; 30-cm stump excluded; branches excluded")

# Linear FRTC 20-cm-top model for Lagerstroemia parviflora.
lp <- frtc_volume(40, 20, "lagerstroemia_parviflora")
stopifnot(isTRUE(all.equal(
  lp$frtc_volume_ub_20cm_m3,
  -0.147542 + 0.000031 * (40^2 * 20)
)))

# Top-diameter outputs are not used below their physical DBH threshold.
small <- frtc_volume(c(15, 8), c(12, 8), c("sal", "sal"), keep_inputs = TRUE)
stopifnot(is.na(small$frtc_volume_ub_20cm_m3[1]))
stopifnot(small$top20_status[1] == "dbh_below_20cm_top_limit")
stopifnot(is.na(small$frtc_volume_ub_10cm_m3[2]))
stopifnot(small$top10_status[2] == "dbh_below_10cm_top_limit")

# Tree-only high-level workflow calculates both supported methods by default.
trees <- data.frame(
  tree_id = c("H1", "H2"),
  species = c("sal", "pinus_roxburghii"),
  dbh_cm = c(60, 45),
  height_m = c(25, 22),
  stringsAsFactors = FALSE
)
res <- volume(trees)
stopifnot(attr(res, "analysis_level") == "tree")
stopifnot(all(c(
  "sharma_pukkala_total_tree_volume_m3",
  "frtc_total_volume_m3",
  "frtc_volume_ub_20cm_m3",
  "frtc_volume_ub_10cm_m3"
) %in% names(res$tree_results)))
stopifnot(nrow(res$method_audit) == 2L)

# FRTC-only workflow does not require branch_group.
frtc_only <- volume(trees, methods = "frtc")
stopifnot(nrow(frtc_only$method_audit) == 1L)
stopifnot(frtc_only$method_audit$method == "FRTC 2025")
