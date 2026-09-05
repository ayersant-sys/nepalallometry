# ============================================================
# Sharma-Pukkala (1990) + Nepal Forest Regulations 2079
# Tree volume estimation
#
# Stem volume:
#   Sharma & Pukkala (1990)
#
# Branch volume:
#   Forest Regulations 2079, Schedule 9
#
# IMPORTANT:
# This file reuses:
#   .sp_models
#   .normalize_sp_species()
#
# already defined in sharma-pukkala-biomass.R
# ============================================================


# ------------------------------------------------------------
# 1. Forest Regulations 2079 branch-volume parameters
#    Schedule 9, Table 2
#
# s = small-tree branch ratio
# m = medium-tree branch ratio
# b = large-tree branch ratio
# ------------------------------------------------------------

.forest_reg_branch_models <- data.frame(
  branch_id = c(
    "abies_spp",
    "alnus_nepalensis",
    "dalbergia_sissoo",
    "pinus_roxburghii",
    "pinus_wallichiana",
    "quercus_spp",
    "schima_wallichii",
    "shorea_robusta",
    "other_conifer",
    "other_broadleaf"
  ),
  
  scientific_name = c(
    "Abies spp.",
    "Alnus nepalensis",
    "Dalbergia sissoo",
    "Pinus roxburghii",
    "Pinus wallichiana",
    "Quercus spp.",
    "Schima wallichii",
    "Shorea robusta",
    "Other conifer species",
    "Other broadleaf species"
  ),
  
  nepali_name = c(
    "Thingre salla",
    "Uttis",
    "Sissoo",
    "Khote salla",
    "Gobre salla",
    "Khasru",
    "Chilaune",
    "Sal",
    "Other conifers",
    "Other broadleaves"
  ),
  
  branch_s = c(
    0.436,
    0.803,
    0.684,
    0.189,
    0.683,
    0.747,
    0.520,
    0.055,
    0.436,
    0.443
  ),
  
  branch_m = c(
    0.372,
    1.226,
    0.684,
    0.256,
    0.488,
    0.960,
    0.186,
    0.341,
    0.372,
    0.511
  ),
  
  branch_b = c(
    0.355,
    1.510,
    0.684,
    0.300,
    0.410,
    1.060,
    0.168,
    0.357,
    0.355,
    0.710
  ),
  
  stringsAsFactors = FALSE
)


# ------------------------------------------------------------
# 2. Internal function:
#    Calculate branch-volume ratio according to DBH
#
# Forest Regulations 2079, Schedule 9, Table 3
#
# d < 10:
#   R = s
#
# 10 <= d <= 40:
#   R = ((d - 10)m + (40 - d)s) / 30
#
# 40 < d <= 70:
#   R = ((d - 40)b + (70 - d)m) / 30
#
# d > 70:
#   R = b
# ------------------------------------------------------------

.forest_reg_branch_ratio <- function(dbh, s, m, b) {
  
  ifelse(
    dbh < 10,
    s,
    
    ifelse(
      dbh <= 40,
      
      ((dbh - 10) * m +
         (40 - dbh) * s) / 30,
      
      ifelse(
        dbh <= 70,
        
        ((dbh - 40) * b +
           (70 - dbh) * m) / 30,
        
        b
      )
    )
  )
}


# ------------------------------------------------------------
# 3. Function to inspect Forest Regulation branch parameters
# ------------------------------------------------------------

#' Forest Regulation branch-volume parameters
#'
#' Returns the branch-volume ratio parameters prescribed in
#' Schedule 9 of Nepal's Forest Regulations 2079.
#'
#' @return A data frame containing branch-volume parameters.
#'
#' @export
forest_regulation_branch_parameters <- function() {
  
  .forest_reg_branch_models
}


# ------------------------------------------------------------
# 4. Main Sharma-Pukkala tree-volume function
# ------------------------------------------------------------

#' Estimate tree volume using Sharma-Pukkala and Forest Regulations
#'
#' Estimates stem volume using the species-specific equations of
#' Sharma and Pukkala (1990). Stem volume is calculated in dm3 by
#' the original equation and divided by 1000 to obtain m3.
#'
#' Branch volume is estimated using the species- and DBH-dependent
#' branch-volume ratios prescribed in Schedule 9 of Nepal's
#' Forest Regulations 2079.
#'
#' Total tree volume is:
#'
#' total tree volume = stem volume + branch volume
#'
#' @param dbh Diameter at breast height in centimetres.
#' @param height Total tree height in metres.
#' @param species Supported Sharma-Pukkala species name or alias.
#' @param branch_group Optional branch category for species without
#'   a species-specific Forest Regulation branch equation.
#'   Accepted values are `"other_conifer"` and `"other_broadleaf"`.
#'   The package does not automatically classify an unlisted species
#'   as conifer or broadleaf.
#' @param has_branches Logical. Whether the tree has branches.
#'   Defaults to TRUE. If FALSE, branch volume is zero and total
#'   tree volume equals stem volume.
#' @param keep_inputs If TRUE, returns detailed calculation
#'   components. If FALSE, returns total tree volume in m3/tree.
#'
#' @return Total tree volume in m3/tree, or a data frame when
#'   `keep_inputs = TRUE`.
#'
#' @references
#' Sharma, E. R., and Pukkala, T. (1990). Volume equations and
#' biomass prediction of forest trees of Nepal. Publication No. 47.
#' Forest Survey and Statistics Division, Ministry of Forests and
#' Soil Conservation, Kathmandu, Nepal.
#'
#' Government of Nepal. Forest Regulations, 2079. Schedule 9.
#'
#' @examples
#' sharma_pukkala_volume(
#'   dbh = 60,
#'   height = 25,
#'   species = "sal"
#' )
#'
#' sharma_pukkala_volume(
#'   dbh = 60,
#'   height = 25,
#'   species = "sal",
#'   keep_inputs = TRUE
#' )
#'
#' @export
sharma_pukkala_volume <- function(
    dbh,
    height,
    species,
    branch_group = NULL,
    has_branches = TRUE,
    keep_inputs = FALSE) {
  
  
  # ----------------------------------------------------------
  # Determine required vector length
  # ----------------------------------------------------------
  
  n <- max(
    length(dbh),
    length(height),
    length(species),
    length(has_branches)
  )
  
  
  # ----------------------------------------------------------
  # Check compatible input lengths
  # ----------------------------------------------------------
  
  lengths <- c(
    length(dbh),
    length(height),
    length(species),
    length(has_branches)
  )
  
  if (any(!lengths %in% c(1L, n))) {
    stop(
      "`dbh`, `height`, `species`, and `has_branches` must have ",
      "length 1 or a common length.",
      call. = FALSE
    )
  }
  
  
  # ----------------------------------------------------------
  # Recycle inputs
  # ----------------------------------------------------------
  
  dbh <- rep(
    as.numeric(dbh),
    length.out = n
  )
  
  height <- rep(
    as.numeric(height),
    length.out = n
  )
  
  species_input <- rep(
    species,
    length.out = n
  )
  
  has_branches <- rep(
    as.logical(has_branches),
    length.out = n
  )
  
  
  # ----------------------------------------------------------
  # Validate DBH
  # ----------------------------------------------------------
  
  if (any(
    !is.finite(dbh) | dbh <= 0,
    na.rm = TRUE
  )) {
    
    stop(
      "`dbh` must contain positive finite values in centimetres.",
      call. = FALSE
    )
  }
  
  
  # ----------------------------------------------------------
  # Validate height
  # ----------------------------------------------------------
  
  if (any(
    !is.finite(height) | height <= 0,
    na.rm = TRUE
  )) {
    
    stop(
      "`height` must contain positive finite values in metres.",
      call. = FALSE
    )
  }
  
  
  # ----------------------------------------------------------
  # Validate has_branches
  # ----------------------------------------------------------
  
  if (any(is.na(has_branches))) {
    
    stop(
      "`has_branches` must contain TRUE or FALSE.",
      call. = FALSE
    )
  }
  
  
  # ----------------------------------------------------------
  # Handle optional branch group
  # ----------------------------------------------------------
  
  if (is.null(branch_group)) {
    
    branch_group <- rep(
      NA_character_,
      n
    )
    
  } else {
    
    if (!length(branch_group) %in% c(1L, n)) {
      
      stop(
        "`branch_group` must have length 1 or the same length ",
        "as the tree inputs.",
        call. = FALSE
      )
    }
    
    branch_group <- rep(
      as.character(branch_group),
      length.out = n
    )
    
    valid_branch_groups <- c(
      "other_conifer",
      "other_broadleaf"
    )
    
    invalid_group <-
      !is.na(branch_group) &
      !branch_group %in% valid_branch_groups
    
    if (any(invalid_group)) {
      
      stop(
        "`branch_group` must be either ",
        "'other_conifer' or 'other_broadleaf'.",
        call. = FALSE
      )
    }
  }
  
  
  # ----------------------------------------------------------
  # Standardize Sharma-Pukkala species
  #
  # Uses existing normalization from
  # sharma-pukkala-biomass.R
  # ----------------------------------------------------------
  
  species_id <-
    .normalize_sp_species(
      species_input
    )
  
  
  # ----------------------------------------------------------
  # Match Sharma-Pukkala stem model
  #
  # Uses existing .sp_models table.
  # ----------------------------------------------------------
  
  idx <- match(
    species_id,
    .sp_models$species_id
  )
  
  model <-
    .sp_models[
      idx,
      ,
      drop = FALSE
    ]
  
  supported <- !is.na(idx)
  
  
  # ----------------------------------------------------------
  # Warn about unsupported Sharma-Pukkala species
  # ----------------------------------------------------------
  
  unsupported <-
    !supported &
    !is.na(species_input) &
    nzchar(
      trimws(
        as.character(species_input)
      )
    )
  
  if (any(unsupported)) {
    
    warning(
      "Sharma-Pukkala stem-volume parameters are unavailable for ",
      sum(unsupported),
      " tree(s). Unsupported species: ",
      paste(
        unique(
          as.character(
            species_input[unsupported]
          )
        ),
        collapse = ", "
      ),
      ". Volume was returned as NA for these trees.",
      call. = FALSE
    )
  }
  
  
  # ==========================================================
  # 5. STEM VOLUME
  #
  # ln(V) = a + b ln(d) + c ln(h)
  #
  # V from equation = dm3
  #
  # divide by 1000 to obtain m3
  # ==========================================================
  
  stem_volume_m3 <-
    rep(
      NA_real_,
      n
    )
  
  stem_volume_m3[supported] <-
    exp(
      model$a[supported] +
        model$b[supported] *
        log(dbh[supported]) +
        model$c[supported] *
        log(height[supported])
    ) / 1000
  
  
  # ----------------------------------------------------------
  # 6. Identify direct Forest Regulation branch categories
  # ----------------------------------------------------------
  
  direct_branch_species <- c(
    "abies_spp",
    "alnus_nepalensis",
    "dalbergia_sissoo",
    "pinus_roxburghii",
    "pinus_wallichiana",
    "quercus_spp",
    "schima_wallichii",
    "shorea_robusta"
  )
  
  
  # ----------------------------------------------------------
  # Default branch identifier
  # ----------------------------------------------------------
  
  branch_id <- rep(
    NA_character_,
    n
  )
  
  
  # ----------------------------------------------------------
  # Direct species-specific regulatory category
  # ----------------------------------------------------------
  
  direct_match <-
    species_id %in%
    direct_branch_species
  
  branch_id[direct_match] <-
    species_id[direct_match]
  
  
  # ----------------------------------------------------------
  # For remaining species, use explicit user classification
  #
  # We do NOT automatically decide whether an unlisted
  # species is conifer or broadleaf.
  # ----------------------------------------------------------
  
  use_generic <-
    is.na(branch_id) &
    !is.na(branch_group)
  
  branch_id[use_generic] <-
    branch_group[use_generic]
  
  
  # ----------------------------------------------------------
  # Match branch parameter table
  # ----------------------------------------------------------
  
  branch_idx <- match(
    branch_id,
    .forest_reg_branch_models$branch_id
  )
  
  branch_model <-
    .forest_reg_branch_models[
      branch_idx,
      ,
      drop = FALSE
    ]
  
  
  # ==========================================================
  # 7. BRANCH RATIO
  # ==========================================================
  
  branch_ratio <-
    rep(
      NA_real_,
      n
    )
  
  
  # ----------------------------------------------------------
  # Trees explicitly recorded as having no branches
  #
  # Regulation says branch volume does not need to be
  # calculated for trees without branches.
  # ----------------------------------------------------------
  
  branch_ratio[
    supported &
      !has_branches
  ] <- 0
  
  
  # ----------------------------------------------------------
  # Trees that have branches and have regulatory parameters
  # ----------------------------------------------------------
  
  has_branch_model <-
    has_branches &
    !is.na(branch_idx) &
    supported
  
  branch_ratio[has_branch_model] <-
    .forest_reg_branch_ratio(
      
      dbh =
        dbh[has_branch_model],
      
      s =
        branch_model$branch_s[
          has_branch_model
        ],
      
      m =
        branch_model$branch_m[
          has_branch_model
        ],
      
      b =
        branch_model$branch_b[
          has_branch_model
        ]
    )
  
  
  # ----------------------------------------------------------
  # Warn when stem volume exists but branch category is absent
  # ----------------------------------------------------------
  
  missing_branch_category <-
    supported &
    has_branches &
    is.na(branch_idx)
  
  if (any(missing_branch_category)) {
    
    warning(
      sum(missing_branch_category),
      " tree(s) have a Sharma-Pukkala stem-volume equation but ",
      "no Forest Regulation branch category was specified. ",
      "Stem volume was calculated, but branch and total tree ",
      "volume were returned as NA. ",
      "For appropriate species, use branch_group = ",
      "'other_conifer' or 'other_broadleaf'.",
      call. = FALSE
    )
  }
  
  
  # ==========================================================
  # 8. BRANCH VOLUME
  #
  # Branch volume =
  # branch ratio x stem volume
  # ==========================================================
  
  branch_volume_m3 <-
    stem_volume_m3 *
    branch_ratio
  
  
  # ==========================================================
  # 9. TOTAL TREE VOLUME
  #
  # Tree volume =
  # stem volume + branch volume
  # ==========================================================
  
  total_volume_m3 <-
    stem_volume_m3 +
    branch_volume_m3
  
  
  # ----------------------------------------------------------
  # 10. Calibration status based on original
  #     Sharma-Pukkala DBH ranges
  # ----------------------------------------------------------
  
  within_calibration <-
    supported &
    dbh >= model$dbh_min_cm &
    dbh <= model$dbh_max_cm
  
  within_calibration[
    !supported
  ] <- NA
  
  
  calibration_status <-
    ifelse(
      
      !supported,
      
      "not_available",
      
      ifelse(
        
        dbh < model$dbh_min_cm,
        
        "below_observed_dbh_range",
        
        ifelse(
          
          dbh > model$dbh_max_cm,
          
          "above_observed_dbh_range",
          
          "within_observed_dbh_range"
        )
      )
    )
  
  
  # ----------------------------------------------------------
  # Warn for DBH extrapolation
  # ----------------------------------------------------------
  
  extrapolated <-
    supported &
    !within_calibration
  
  if (any(
    extrapolated,
    na.rm = TRUE
  )) {
    
    warning(
      sum(
        extrapolated,
        na.rm = TRUE
      ),
      " supported tree(s) are outside the observed ",
      "Sharma-Pukkala model-development DBH range. ",
      "Predictions were returned but are extrapolations.",
      call. = FALSE
    )
  }
  
  
  # ----------------------------------------------------------
  # 11. Estimation status
  # ----------------------------------------------------------
  
  estimation_status <-
    ifelse(
      
      !supported,
      
      "unsupported_species",
      
      ifelse(
        
        !has_branches,
        
        "estimated_no_branches",
        
        ifelse(
          
          is.na(branch_idx),
          
          "stem_only_branch_category_required",
          
          "estimated"
        )
      )
    )
  
  
  # ----------------------------------------------------------
  # 12. Simple output
  # ----------------------------------------------------------
  
  if (!keep_inputs) {
    
    return(
      total_volume_m3
    )
  }
  
  
  # ----------------------------------------------------------
  # 13. Detailed output
  # ----------------------------------------------------------
  
  data.frame(
    
    dbh_cm =
      dbh,
    
    height_m =
      height,
    
    species_input =
      as.character(
        species_input
      ),
    
    species_standardized =
      species_id,
    
    scientific_name =
      model$scientific_name,
    
    nepali_name =
      model$nepali_name,
    
    # Sharma-Pukkala coefficients
    coefficient_a =
      model$a,
    
    coefficient_b =
      model$b,
    
    coefficient_c =
      model$c,
    
    # Stem volume
    stem_volume_m3 =
      stem_volume_m3,
    
    # Branch information
    has_branches =
      has_branches,
    
    branch_group =
      branch_id,
    
    branch_s =
      branch_model$branch_s,
    
    branch_m =
      branch_model$branch_m,
    
    branch_b =
      branch_model$branch_b,
    
    branch_ratio =
      branch_ratio,
    
    branch_volume_m3 =
      branch_volume_m3,
    
    # Total volume
    total_tree_volume_m3 =
      total_volume_m3,
    
    # Calibration information
    calibration_dbh_min_cm =
      model$dbh_min_cm,
    
    calibration_dbh_max_cm =
      model$dbh_max_cm,
    
    within_calibration_dbh_range =
      within_calibration,
    
    calibration_status =
      calibration_status,
    
    height_calibration_status =
      ifelse(
        supported,
        "not_assessed_not_reported",
        "not_available"
      ),
    
    # Status
    estimation_status =
      estimation_status,
    
    # Provenance
    stem_volume_source =
      ifelse(
        supported,
        "Sharma and Pukkala (1990)",
        NA_character_
      ),
    
    branch_volume_source =
      ifelse(
        !is.na(branch_idx),
        "Nepal Forest Regulations 2079, Schedule 9",
        NA_character_
      ),
    
    stem_volume_unit =
      ifelse(
        supported,
        "m3/tree",
        NA_character_
      ),
    
    branch_volume_unit =
      ifelse(
        !is.na(branch_ratio),
        "m3/tree",
        NA_character_
      ),
    
    total_volume_unit =
      ifelse(
        !is.na(total_volume_m3),
        "m3/tree",
        NA_character_
      ),
    
    stringsAsFactors = FALSE
  )
}