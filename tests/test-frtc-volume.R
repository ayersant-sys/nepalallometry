library(nepalallometry)

# FRTC 2025 reference table: selected volume equations reported in Tables 6-8.
# These tests protect source fidelity. nepalallometry should reproduce the
# published model forms, coefficients, and sample sizes without alteration.
expected_models <- data.frame(
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
actual_models <- getFromNamespace(".frtc_volume_models", "nepalallometry")
stopifnot(isTRUE(all.equal(actual_models, expected_models, check.attributes = FALSE)))

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
stopifnot(grepl("30-cm stump excluded", sal$volume_boundary, fixed = TRUE))
stopifnot(grepl("branches excluded", sal$volume_boundary, fixed = TRUE))
stopifnot(grepl("under-bark stem", sal$volume_boundary, fixed = TRUE))

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
