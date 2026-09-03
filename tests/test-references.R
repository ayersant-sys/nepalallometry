library(nepalallometry)

refs <- allometry_references()
expected <- c(
  "nepalallometry", "frtc_2025", "sharma_pukkala_1990",
  "forest_regulations_2079", "chave_2014", "gwdd_article_2026",
  "gwdd_dataset_v2_2", "ipcc_2006"
)

stopifnot(
  identical(refs$source_id, expected),
  !anyDuplicated(refs$source_id),
  all(nzchar(refs$citation)),
  all(nzchar(refs$source_role)),
  all(nzchar(refs$apa_reference))
)

regulation <- allometry_references("forest_regulations_2079")
stopifnot(
  nrow(regulation) == 1L,
  grepl("regulatory", regulation$source_role, ignore.case = TRUE),
  grepl("Schedule 9", regulation$source_role, fixed = TRUE)
)

stopifnot(inherits(
  try(allometry_references("not_a_source"), silent = TRUE),
  "try-error"
))

notes <- getFromNamespace(".biomass_calculation_notes", "nepalallometry")(
  structure(
    list(),
    carbon_fraction = 0.47,
    input_source = "test inventory",
    methods = "frtc"
  )
)
stopifnot(
  all(paste0("Reference: ", refs$citation) %in% notes$Topic),
  all(refs$apa_reference %in% notes$Description)
)
