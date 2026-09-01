library(nepalallometry)

inventory <- data.frame(
  tree_id = c("P01_T01", "P01_T02", "P02_T01", "P02_T02"),
  plot_id = c("P01", "P01", "P02", "P02"),
  plot_area_ha = c(0.05, 0.05, 0.10, 0.10),
  species = c("Shorea robusta", "Schima wallichii",
              "Pinus roxburghii", "Dalbergia sissoo"),
  dbh_cm = c(50, 32, 30, 25),
  height_m = c(35, 22, 20, 18),
  forest_name = "Test Forest",
  stringsAsFactors = FALSE
)
input <- tempfile(fileext = ".csv")
output <- tempfile(fileext = ".xlsx")
utils::write.csv(inventory, input, row.names = FALSE)

result <- suppressWarnings(biomass_from_csv(input, output))
stopifnot(file.exists(output))
stopifnot(identical(
  openxlsx::getSheetNames(output),
  c("Disclaimer", "FRTC_2025", "Sharma_Pukkala", "Chave_2014")
))

for (nm in c("FRTC_2025", "Sharma_Pukkala", "Chave_2014")) {
  x <- result[[nm]]
  stopifnot(nrow(x) == nrow(inventory))
  stopifnot(all(c(
    "forest_name", "tree_biomass_kg", "tree_carbon_kg",
    "plot_biomass_Mg_ha", "plot_carbon_Mg_ha",
    "plot_stem_coverage_pct", "plot_basal_area_coverage_pct",
    "plot_extrapolated_trees", "plot_summary_status",
    "calibration_status", "model_source"
  ) %in% names(x)))
  p01 <- x[x$plot_id == "P01", ]
  expected <- sum(p01$tree_biomass_kg, na.rm = TRUE) / (1000 * 0.05)
  stopifnot(all(abs(p01$plot_biomass_Mg_ha - expected) < 1e-8))
}

frtc_p02 <- result$FRTC_2025[result$FRTC_2025$plot_id == "P02", ]
stopifnot(all(frtc_p02$plot_summary_status == "partial_estimate"))
stopifnot(all(frtc_p02$plot_estimated_trees == 1L))

sp_p02 <- result$Sharma_Pukkala[result$Sharma_Pukkala$plot_id == "P02", ]
stopifnot(all(sp_p02$plot_summary_status == "complete_estimate"))

chave_p02 <- result$Chave_2014[result$Chave_2014$plot_id == "P02", ]
stopifnot(all(chave_p02$plot_summary_status == "complete_estimate"))

bad <- inventory
bad$plot_area_ha[2] <- 0.10
bad_input <- tempfile(fileext = ".csv")
utils::write.csv(bad, bad_input, row.names = FALSE)
stopifnot(inherits(
  try(biomass_from_csv(bad_input, tempfile(fileext = ".xlsx")), silent = TRUE),
  "try-error"
))
