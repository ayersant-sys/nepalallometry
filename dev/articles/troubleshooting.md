# Help & Troubleshooting

This page summarizes common input problems, method-specific
requirements, and interpretation issues that may occur when using
*nepalallometry*.

## Input requirements

Input data can be supplied as a data frame or, through supported
workflows, as a `.csv` or `.xlsx` file. Column names must follow the
names expected by *nepalallometry*.

| Analysis | Required columns | Additional or method-specific requirements |
|----|----|----|
| **Biomass & Carbon** | `tree_id`, `plot_id`, `plot_area_ha`, `species`, `dbh_cm`, `height_m` | `forest_id` and `forest_area_ha` are optional. For **Sharma & Pukkala**, miscellaneous species must be identified as **Hill** or **Terai**, as appropriate. |
| **FRTC tree volume** | `tree_id`, `species`, `dbh_cm`, `height_m` | Add `plot_id` and `plot_area_ha` for plot and forest summaries. |
| **Sharma–Pukkala + Forest Regulations volume** | `tree_id`, `species`, `dbh_cm`, `height_m`, `branch_group` | Add `plot_id` and `plot_area_ha` for plot and forest summaries. |

For methods requiring wood density, *nepalallometry* handles density
internally where supported. A user-supplied `wood_density` value can be
used as an override where applicable.

## Common problems and solutions

| Problem | Possible cause | What to do |
|----|----|----|
| **File cannot be read** | Unsupported file type, incorrect Excel sheet number, or invalid workbook | Use `.csv` or `.xlsx` and verify the selected sheet number. |
| **Required column is missing** | One or more required variables are absent or incorrectly named | Compare your data with the input requirements above. Column names must match the expected names. |
| **`branch_group` is missing** | Sharma–Pukkala + Forest Regulations volume was selected without branch-group information | Add the required `branch_group` column or deselect this method. |
| **Miscellaneous group is not specified** | Sharma & Pukkala biomass requires the appropriate miscellaneous equation but the group has not been identified | Specify the miscellaneous species as **Hill** or **Terai**, as appropriate. |
| **Species is unsupported** | The selected method does not provide an equation for that species | Check the method audit. Unsupported estimates are returned as `NA`; the package does not silently substitute another method. |
| **Some trees return `NA`** | Missing measurements, unsupported species, or method-specific applicability requirements | Inspect the tree results and method audit to identify the affected records and reason. |
| **Plot or forest summaries are unavailable** | The data contain only tree-level information | Include both `plot_id` and `plot_area_ha`. |
| **Results differ among methods** | Methods use different equations, predictors, species groupings, biomass boundaries, or volume definitions | This is not necessarily an error. Interpret estimates according to the definition and assumptions of each method. |
| **Several FRTC volume estimates appear for one tree** | FRTC provides different volume definitions | Keep the volume definitions separate. They should not be summed or averaged. |
| **An unexpected calculation error appears** | Input structure or an unanticipated software issue | Check the required columns, missing values, method-specific requirements, and audit information first. If the problem persists, report the error. |

## Before reporting an error

Check that:

1.  Column names exactly match those required by the package.
2.  DBH, height, species, plot area, and other required measurements are
    present.
3.  Method-specific information such as `branch_group` or **Hill/Terai
    miscellaneous classification** is supplied when required.
4.  The selected method supports the species being analysed.
5.  The method audit has been checked for unsupported or excluded
    records.
6.  Different biomass or volume definitions are not being interpreted as
    directly equivalent estimates.

## Still having a problem?

If the problem cannot be resolved using the checks above, report it
through the *nepalallometry* GitHub repository. Please include the
**error message, selected method(s), package version, and a small
reproducible example** where possible.

> **Note:** Differences among supported allometric methods are not, by
> themselves, software errors. Methods may differ in species coverage,
> model structure, predictors, biomass boundaries, and volume
> definitions.
