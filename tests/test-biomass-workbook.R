library(nepalallometry)

inventory <- data.frame(
  tree_id = c("P01_T01", "P01_T02", "P02_T01", "P02_T02"),
  plot_id = c("P01", "P01", "P02", "P02"), plot_area_ha = 0.05,
  forest_id = "Community_Forest_1", forest_area_ha = 125,
  species = c("Shorea robusta", "Schima wallichii",
              "Pinus roxburghii", "Dalbergia sissoo"),
  dbh_cm = c(50, 32, 30, 25), height_m = c(35, 22, 20, 18),
  stringsAsFactors = FALSE)

output <- tempfile(fileext = ".xlsx")
result <- suppressWarnings(biomass(inventory, output = output))
stopifnot(inherits(result, "nepal_biomass_result"), file.exists(output))
stopifnot(identical(openxlsx::getSheetNames(output), c(
  "Calculation_Notes", "Forest_Summary", "Plot_Summary", "Species_Summary",
  "DBH_Class_Summary", "Tree_Results")))
stopifnot(nrow(tree_results(result)) == nrow(inventory))
stopifnot(nrow(plot_summary(result)) == 2L)
stopifnot(nrow(forest_summary(result)) == 3L)
stopifnot(all(c("FRTC", "Sharma & Pukkala", "Chave") %in%
              forest_summary(result)$method))
stopifnot(all(is.finite(forest_summary(result)$estimated_total_forest_carbon_Mg[
  forest_summary(result)$plots_with_estimates > 0])))
stopifnot(any(plot_summary(result)$frtc_coverage_status ==
              "partial_tree_coverage"))

no_area <- inventory; no_area$forest_area_ha <- NULL
x <- suppressWarnings(biomass(no_area, output = FALSE))
stopifnot(all(is.na(forest_summary(x)$estimated_total_forest_carbon_Mg)))

csv <- tempfile(fileext = ".csv")
utils::write.csv(inventory, csv, row.names = FALSE)
legacy <- suppressWarnings(biomass_from_csv(csv, tempfile(fileext = ".xlsx")))
stopifnot(inherits(legacy, "nepal_biomass_result"))

xlsx <- tempfile(fileext = ".xlsx")
openxlsx::write.xlsx(inventory, xlsx)
from_excel <- suppressWarnings(biomass(xlsx, output = FALSE))
stopifnot(nrow(tree_results(from_excel)) == nrow(inventory))

bad <- inventory; bad$forest_area_ha[2] <- 130
stopifnot(inherits(try(biomass(bad, output = FALSE), silent = TRUE), "try-error"))
