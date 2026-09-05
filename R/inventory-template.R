#' Create a simple FRTC inventory CSV template
#'
#' The template can also be used for Sharma-Pukkala volume estimation.
#' For species without a species-specific Forest Regulation branch category,
#' users may enter `other_conifer` or `other_broadleaf` in `branch_group`.
#' Leave `branch_group` blank when a species-specific branch category exists.
#'
#' @param path Output CSV path.
#' @param rows Number of blank data-entry rows.
#' @return The normalized path, invisibly.
#' @export
frtc_inventory_template <- function(path = "frtc_inventory_template.csv",
                                    rows = 20L) {
  rows <- as.integer(rows)
  if (length(rows) != 1L || is.na(rows) || rows < 1L) {
    stop("`rows` must be one positive whole number.", call. = FALSE)
  }
  template <- data.frame(
    tree_id = seq_len(rows),
    plot_id = rep("", rows),
    plot_area_ha = rep(NA_real_, rows),
    species = rep("", rows),
    dbh_cm = rep(NA_real_, rows),
    height_m = rep(NA_real_, rows),
    branch_group = rep("", rows),
    stringsAsFactors = FALSE
  )
  utils::write.csv(template, path, row.names = FALSE, na = "")
  invisible(normalizePath(path, mustWork = FALSE))
}
