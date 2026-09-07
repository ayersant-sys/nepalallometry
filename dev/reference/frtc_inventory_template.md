# Create a simple FRTC inventory CSV template

The template can also be used for Sharma-Pukkala volume estimation. For
species without a species-specific Forest Regulation branch category,
users may enter \`other_conifer\` or \`other_broadleaf\` in
\`branch_group\`. Leave \`branch_group\` blank when a species-specific
branch category exists.

## Usage

``` r
frtc_inventory_template(path = "frtc_inventory_template.csv", rows = 20L)
```

## Arguments

- path:

  Output CSV path.

- rows:

  Number of blank data-entry rows.

## Value

The normalized path, invisibly.
