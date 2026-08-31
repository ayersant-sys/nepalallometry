library(nepalallometry)

inventory <- data.frame(
  tree_id = 1:4,
  plot_id = c("p01", "p01", "p02", "p02"),
  plot_area_ha = c(0.05, 0.05, 0.10, 0.10),
  species = c("sal", "chilaune", "pinus_roxburghii", "acacia_catechu"),
  dbh_cm = c(30, 25, 30, 20),
  height_m = c(20, 18, 20, 15),
  stringsAsFactors = FALSE
)

trees <- suppressWarnings(estimate_frtc_biomass(inventory))
plots <- frtc_plot_summary(trees)
stopifnot(nrow(plots) == 2L)
stopifnot(plots$summary_status[plots$plot_id == "p01"] ==
            "complete_frtc_estimate")
stopifnot(plots$summary_status[plots$plot_id == "p02"] ==
            "partial_frtc_estimate")
stopifnot(isTRUE(all.equal(trees$frtc_carbon_kg,
                          trees$frtc_total_biomass_kg * 0.47)))
stopifnot(nrow(frtc_species_summary(trees)) == 4L)
stopifnot(nrow(frtc_dbh_summary(trees)) >= 2L)
species_out <- frtc_species_summary(trees)
stopifnot(is.na(species_out$frtc_supported_agb_kg[
  species_out$species == "acacia_catechu"
]))
forest <- frtc_forest_summary(plots)
stopifnot(forest$total_plots == 2L)
stopifnot(forest$complete_plots == 1L)
stopifnot(forest$partial_plots == 1L)
stopifnot(forest$forest_summary_status ==
            "contains_partial_or_unestimated_plots")

csv_dir <- tempfile("frtc_csv_test_")
dir.create(csv_dir)
input_csv <- file.path(csv_dir, "inventory.csv")
utils::write.csv(inventory, input_csv, row.names = FALSE)
csv_result <- suppressWarnings(frtc_biomass_from_csv(
  input_csv, output_format = "csv"
))
stopifnot(length(csv_result$files) == 5L)
stopifnot(all(file.exists(csv_result$files)))

excel_result <- suppressWarnings(frtc_biomass_from_csv(
  input_csv, output_format = "excel"
))
stopifnot(length(excel_result$files) == 1L)
stopifnot(file.exists(excel_result$files[[1]]))


stopifnot(all(plots$extrapolated_trees == 0L))
stopifnot(all(plots$calibration_summary_status[
  plots$estimated_trees > 0L
] == "all_supported_trees_within_range"))

extrapolation_inventory <- inventory[1, , drop = FALSE]
extrapolation_inventory$tree_id <- 100L
extrapolation_inventory$dbh_cm <- 110
extrapolation_inventory$height_m <- 45
extrapolation_tree <- suppressWarnings(
  estimate_frtc_biomass(extrapolation_inventory)
)
extrapolation_plot <- frtc_plot_summary(extrapolation_tree)
stopifnot(extrapolation_plot$extrapolated_trees == 1L)
stopifnot(extrapolation_plot$calibration_summary_status ==
            "contains_extrapolation")
