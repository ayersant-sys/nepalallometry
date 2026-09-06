library(shiny)

read_inventory_file <- function(fileinfo, sheet = 1) {
  req(fileinfo)
  ext <- tolower(tools::file_ext(fileinfo$name))
  if (ext == "csv") {
    utils::read.csv(fileinfo$datapath, stringsAsFactors = FALSE, check.names = FALSE)
  } else if (ext == "xlsx") {
    openxlsx::read.xlsx(fileinfo$datapath, sheet = sheet, check.names = FALSE)
  } else {
    stop("Please upload a .csv or .xlsx file.", call. = FALSE)
  }
}

fmt_num <- function(x, digits = 2) {
  ifelse(is.finite(x), format(round(x, digits), nsmall = digits, big.mark = ","), "NA")
}

status_box <- function(title, value, note = NULL, class = "status-card") {
  div(class = class,
      div(class = "status-value", value),
      div(class = "status-title", title),
      if (!is.null(note)) div(class = "status-note", note))
}

ui <- navbarPage(
  title = div(span(class = "brand-name", "nepalallometry"),
              span(class = "brand-subtitle", "Forest allometry for Nepal")),
  id = "main_nav",
  header = tags$head(
    tags$style(HTML("
      body { background: #f7f8f7; color: #1f2a24; }
      .navbar { background: #163f31 !important; border: 0; }
      .navbar-default .navbar-brand, .navbar-default .navbar-nav > li > a { color: #ffffff !important; }
      .navbar-default .navbar-nav > .active > a,
      .navbar-default .navbar-nav > .active > a:hover { background: #0f3025 !important; color: #ffffff !important; }
      .brand-name { font-style: italic; font-weight: 700; margin-right: 10px; }
      .brand-subtitle { font-size: 12px; opacity: 0.85; }
      .app-wrap { max-width: 1280px; margin: 0 auto; padding: 20px 14px 32px; }
      .panel-card { background: white; border: 1px solid #dde4df; border-radius: 8px; padding: 18px; margin-bottom: 18px; box-shadow: 0 1px 2px rgba(0,0,0,0.03); }
      .panel-card h3 { margin-top: 0; color: #163f31; font-size: 20px; }
      .panel-card h4 { color: #294f41; }
      .help-note { color: #5f6f66; font-size: 13px; line-height: 1.45; }
      .action-row { margin-top: 14px; }
      .btn-primary { background: #1d6b4f; border-color: #1d6b4f; }
      .btn-primary:hover, .btn-primary:focus { background: #15543d; border-color: #15543d; }
      .status-grid { display: flex; flex-wrap: wrap; gap: 12px; margin: 8px 0 18px; }
      .status-card { background: #ffffff; border: 1px solid #d9e2dc; border-left: 4px solid #1d6b4f; border-radius: 6px; padding: 12px 15px; min-width: 155px; flex: 1; }
      .status-value { font-size: 24px; font-weight: 700; color: #163f31; }
      .status-title { font-size: 13px; font-weight: 600; }
      .status-note { font-size: 11px; color: #6d7c74; margin-top: 3px; }
      .warning-box { background: #fff9e8; border: 1px solid #efd992; border-left: 4px solid #c99a19; border-radius: 6px; padding: 12px 15px; margin-bottom: 14px; }
      .success-box { background: #eef8f2; border: 1px solid #c8dfd0; border-left: 4px solid #1d6b4f; border-radius: 6px; padding: 12px 15px; margin-bottom: 14px; }
      .error-box { background: #fff1f1; border: 1px solid #e8c1c1; border-left: 4px solid #a83b3b; border-radius: 6px; padding: 12px 15px; margin-bottom: 14px; }
      table { font-size: 12px; }
      .table > thead > tr > th { background: #eef3ef; color: #20352b; border-bottom: 2px solid #cbd8d0; }
      .section-lead { margin: -5px 0 16px; color: #647269; }
      .workflow-note { background: #edf4f0; border-radius: 6px; padding: 10px 12px; margin-top: 12px; font-size: 12px; color: #3c5649; }
      .tab-content { padding-top: 10px; }
      .footer-note { text-align: center; color: #6d7b73; font-size: 12px; margin-top: 25px; }
    "))
  ),

  tabPanel(
    "Biomass & Carbon",
    div(class = "app-wrap",
        fluidRow(
          column(4,
                 div(class = "panel-card",
                     h3("1. Input inventory"),
                     fileInput("bio_file", "CSV or Excel file", accept = c(".csv", ".xlsx")),
                     numericInput("bio_sheet", "Excel sheet number", value = 1, min = 1, step = 1),
                     p(class = "help-note",
                       "Required columns: tree_id, plot_id, plot_area_ha, species, dbh_cm, height_m. forest_id and forest_area_ha are optional."),
                     tags$hr(),
                     h4("Methods"),
                     checkboxGroupInput(
                       "bio_methods", NULL,
                       choices = c("FRTC 2025" = "frtc",
                                   "Sharma & Pukkala 1990" = "sharma_pukkala",
                                   "Chave et al. 2014" = "chave"),
                       selected = c("frtc", "sharma_pukkala", "chave")
                     ),
                     numericInput("carbon_fraction", "Carbon fraction", value = 0.47, min = 0, max = 1, step = 0.01),
                     div(class = "action-row",
                         actionButton("run_biomass", "Calculate biomass & carbon", class = "btn-primary", width = "100%")),
                     div(class = "workflow-note",
                         "The GUI calls the existing nepalallometry functions; equations are not duplicated in the interface."))) ,
          column(8,
                 div(class = "panel-card",
                     h3("2. Input preview"),
                     p(class = "section-lead", "Check the uploaded inventory before running the calculation."),
                     uiOutput("bio_input_status"),
                     tableOutput("bio_preview")),
                 div(class = "panel-card",
                     h3("3. Results"),
                     uiOutput("bio_run_status"),
                     uiOutput("bio_status_cards"),
                     conditionalPanel(
                       condition = "output.bio_has_results",
                       tabsetPanel(
                         tabPanel("Forest", tableOutput("bio_forest")),
                         tabPanel("Plot", tableOutput("bio_plot")),
                         tabPanel("Species", tableOutput("bio_species")),
                         tabPanel("DBH class", tableOutput("bio_dbh")),
                         tabPanel("Trees", tableOutput("bio_trees")),
                         tabPanel("Audit", tableOutput("bio_audit"))
                       ),
                       br(),
                       downloadButton("download_biomass", "Download complete Excel results", class = "btn-primary")
                     )))
        ),
        div(class = "footer-note", "Published methods retained • calculations standardized • assumptions and status preserved")
    )
  ),

  tabPanel(
    "Tree Volume",
    div(class = "app-wrap",
        fluidRow(
          column(4,
                 div(class = "panel-card",
                     h3("1. Input data"),
                     fileInput("vol_file", "CSV or Excel file", accept = c(".csv", ".xlsx")),
                     numericInput("vol_sheet", "Excel sheet number", value = 1, min = 1, step = 1),
                     p(class = "help-note",
                       "Minimum tree-level columns: tree_id, species, dbh_cm, height_m. Add plot_id and plot_area_ha together for inventory summaries. branch_group is optional where applicable."),
                     tags$hr(),
                     h4("Methods"),
                     checkboxGroupInput(
                       "vol_methods", NULL,
                       choices = c("FRTC 2025" = "frtc",
                                   "Sharma & Pukkala + Forest Regulations 2079" = "sharma_pukkala"),
                       selected = c("frtc", "sharma_pukkala")
                     ),
                     div(class = "action-row",
                         actionButton("run_volume", "Calculate tree volume", class = "btn-primary", width = "100%")),
                     div(class = "workflow-note",
                         "FRTC outputs retain total over-bark stem volume and under-bark stem volumes to 10-cm and 20-cm top diameters as separate volume definitions. Sharma–Pukkala stem volume and Forest Regulations branch/total volume are also retained separately."))),
          column(8,
                 div(class = "panel-card",
                     h3("2. Input preview"),
                     uiOutput("vol_input_status"),
                     tableOutput("vol_preview")),
                 div(class = "panel-card",
                     h3("3. Results"),
                     uiOutput("vol_run_status"),
                     uiOutput("vol_status_cards"),
                     conditionalPanel(
                       condition = "output.vol_has_results",
                       tabsetPanel(
                         tabPanel("Forest", tableOutput("vol_forest")),
                         tabPanel("Plot", tableOutput("vol_plot")),
                         tabPanel("Species", tableOutput("vol_species")),
                         tabPanel("DBH class", tableOutput("vol_dbh")),
                         tabPanel("Trees", tableOutput("vol_trees")),
                         tabPanel("Audit", tableOutput("vol_audit"))
                       ),
                       br(),
                       downloadButton("download_volume", "Download complete Excel results", class = "btn-primary")
                     )))
        ),
        div(class = "footer-note", "Different volume definitions are preserved rather than combined • tree-only and inventory workflows supported")
    )
  ),

  tabPanel(
    "About",
    div(class = "app-wrap",
        div(class = "panel-card",
            h3("About nepalallometry"),
            p("nepalallometry provides standardized access to established forest allometric methods relevant to Nepal."),
            p("The graphical interface is a front end to the package functions. It does not replace or duplicate the equations implemented in the R package."),
            tags$hr(),
            h4("GUI workflow"),
            tags$ol(
              tags$li("Upload a standard inventory file."),
              tags$li("Choose the supported estimation method(s)."),
              tags$li("Run the calculation."),
              tags$li("Review forest, plot, species, DBH-class, tree-level, and audit outputs."),
              tags$li("Download the complete Excel workbook." )
            ),
            h4("Interpretation"),
            p("Summary SD, SE, and confidence intervals describe variation among sampled plots where estimable. They do not represent uncertainty in the underlying allometric equations."),
            p("Unsupported species or out-of-calibration predictions are retained in status and audit information rather than silently substituted.")))
  )
)

server <- function(input, output, session) {
  bio_data <- reactiveVal(NULL)
  bio_result <- reactiveVal(NULL)
  bio_error <- reactiveVal(NULL)

  observeEvent(list(input$bio_file, input$bio_sheet), {
    bio_result(NULL)
    bio_error(NULL)
    if (is.null(input$bio_file)) {
      bio_data(NULL)
      return()
    }
    dat <- tryCatch(read_inventory_file(input$bio_file, input$bio_sheet), error = function(e) e)
    if (inherits(dat, "error")) {
      bio_data(NULL)
      bio_error(conditionMessage(dat))
    } else {
      bio_data(dat)
    }
  }, ignoreInit = FALSE)

  output$bio_input_status <- renderUI({
    if (!is.null(bio_error())) return(div(class = "error-box", bio_error()))
    dat <- bio_data()
    if (is.null(dat)) return(div(class = "help-note", "Upload a .csv or .xlsx inventory file to begin."))
    div(class = "success-box", paste(nrow(dat), "trees loaded across", length(unique(dat$species)), "species entries."))
  })

  output$bio_preview <- renderTable({
    dat <- bio_data(); req(dat)
    utils::head(dat, 8)
  }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")

  observeEvent(input$run_biomass, {
    bio_error(NULL)
    dat <- bio_data()
    if (is.null(dat)) {
      bio_error("Upload an inventory file before running the calculation.")
      return()
    }
    if (!length(input$bio_methods)) {
      bio_error("Select at least one biomass method.")
      return()
    }
    res <- tryCatch(
      nepalallometry::biomass(
        dat,
        output = FALSE,
        methods = input$bio_methods,
        carbon_fraction = input$carbon_fraction
      ),
      error = function(e) e
    )
    if (inherits(res, "error")) {
      bio_result(NULL)
      bio_error(conditionMessage(res))
    } else {
      bio_result(res)
    }
  })

  output$bio_run_status <- renderUI({
    if (!is.null(bio_error())) return(div(class = "error-box", bio_error()))
    if (is.null(bio_result())) return(div(class = "help-note", "Run the calculation to generate summaries and audit information."))
    div(class = "success-box", "Calculation completed. Review the summaries below or download the full workbook.")
  })

  output$bio_status_cards <- renderUI({
    res <- bio_result(); req(res)
    fs <- res$forest_summary
    tr <- res$tree_results
    methods <- length(unique(fs$method))
    coverage <- if (nrow(fs)) mean(fs$stem_coverage_pct, na.rm = TRUE) else NA_real_
    div(class = "status-grid",
        status_box("Trees", format(nrow(tr), big.mark = ",")),
        status_box("Methods run", methods),
        status_box("Forests", length(unique(fs$forest_id))),
        status_box("Mean tree coverage", paste0(fmt_num(coverage, 1), "%")))
  })

  output$bio_has_results <- reactive(!is.null(bio_result()))
  outputOptions(output, "bio_has_results", suspendWhenHidden = FALSE)

  output$bio_forest <- renderTable({ req(bio_result()); bio_result()$forest_summary }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")
  output$bio_plot <- renderTable({ req(bio_result()); bio_result()$plot_summary }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")
  output$bio_species <- renderTable({ req(bio_result()); bio_result()$species_summary }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")
  output$bio_dbh <- renderTable({ req(bio_result()); bio_result()$dbh_class_summary }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")
  output$bio_trees <- renderTable({ req(bio_result()); utils::head(bio_result()$tree_results, 100) }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")
  output$bio_audit <- renderTable({ req(bio_result()); bio_result()$method_audit }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")

  output$download_biomass <- downloadHandler(
    filename = function() paste0("nepalallometry_biomass_results_", Sys.Date(), ".xlsx"),
    content = function(file) {
      req(bio_data())
      nepalallometry::biomass(
        bio_data(), output = file,
        methods = input$bio_methods,
        carbon_fraction = input$carbon_fraction
      )
    }
  )

  vol_data <- reactiveVal(NULL)
  vol_result <- reactiveVal(NULL)
  vol_error <- reactiveVal(NULL)

  observeEvent(list(input$vol_file, input$vol_sheet), {
    vol_result(NULL)
    vol_error(NULL)
    if (is.null(input$vol_file)) {
      vol_data(NULL)
      return()
    }
    dat <- tryCatch(read_inventory_file(input$vol_file, input$vol_sheet), error = function(e) e)
    if (inherits(dat, "error")) {
      vol_data(NULL)
      vol_error(conditionMessage(dat))
    } else {
      vol_data(dat)
    }
  }, ignoreInit = FALSE)

  output$vol_input_status <- renderUI({
    if (!is.null(vol_error())) return(div(class = "error-box", vol_error()))
    dat <- vol_data()
    if (is.null(dat)) return(div(class = "help-note", "Upload a .csv or .xlsx file to begin."))
    level <- if (all(c("plot_id", "plot_area_ha") %in% names(dat))) "inventory-level" else "tree-level"
    div(class = "success-box", paste(nrow(dat), "trees loaded;", level, "workflow detected."))
  })

  output$vol_preview <- renderTable({
    dat <- vol_data(); req(dat)
    utils::head(dat, 8)
  }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")

  observeEvent(input$run_volume, {
    vol_error(NULL)
    dat <- vol_data()
    if (is.null(dat)) {
      vol_error("Upload a file before running the calculation.")
      return()
    }
    if (!length(input$vol_methods)) {
      vol_error("Select at least one volume method.")
      return()
    }
    res <- tryCatch(
      nepalallometry::volume(dat, output = NULL, methods = input$vol_methods),
      error = function(e) e
    )
    if (inherits(res, "error")) {
      vol_result(NULL)
      vol_error(conditionMessage(res))
    } else {
      vol_result(res)
    }
  })

  output$vol_run_status <- renderUI({
    if (!is.null(vol_error())) return(div(class = "error-box", vol_error()))
    if (is.null(vol_result())) return(div(class = "help-note", "Run the calculation to generate volume results."))
    div(class = "success-box", "Volume calculation completed. Volume definitions remain separated in the result tables.")
  })

  output$vol_status_cards <- renderUI({
    res <- vol_result(); req(res)
    tr <- res$tree_results
    level <- attr(res, "analysis_level")
    methods_run <- if ("method" %in% names(tr)) length(unique(tr$method)) else length(input$vol_methods)
    if (identical(level, "inventory") && !is.null(res$forest_summary)) {
      coverage <- mean(res$forest_summary$tree_coverage_pct, na.rm = TRUE)
      forests <- length(unique(res$forest_summary$forest_id))
    } else {
      coverage <- NA_real_
      forests <- 0
    }
    div(class = "status-grid",
        status_box("Trees", format(nrow(tr), big.mark = ",")),
        status_box("Methods run", methods_run),
        status_box("Workflow", if (identical(level, "inventory")) "Inventory" else "Tree only"),
        status_box("Forests", forests),
        status_box("Mean tree coverage", if (is.finite(coverage)) paste0(fmt_num(coverage, 1), "%") else "—"))
  })

  output$vol_has_results <- reactive(!is.null(vol_result()))
  outputOptions(output, "vol_has_results", suspendWhenHidden = FALSE)

  output$vol_forest <- renderTable({
    res <- vol_result(); req(res)
    if (is.null(res$forest_summary)) return(data.frame(Note = "Forest summaries require plot_id and plot_area_ha."))
    res$forest_summary
  }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")
  output$vol_plot <- renderTable({
    res <- vol_result(); req(res)
    if (is.null(res$plot_summary)) return(data.frame(Note = "Plot summaries require plot_id and plot_area_ha."))
    res$plot_summary
  }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")
  output$vol_species <- renderTable({
    res <- vol_result(); req(res)
    if (is.null(res$species_summary)) return(data.frame(Note = "Species summaries require inventory-level input."))
    res$species_summary
  }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")
  output$vol_dbh <- renderTable({
    res <- vol_result(); req(res)
    if (is.null(res$dbh_class_summary)) return(data.frame(Note = "DBH-class summaries require inventory-level input."))
    res$dbh_class_summary
  }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")
  output$vol_trees <- renderTable({ req(vol_result()); utils::head(vol_result()$tree_results, 100) }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")
  output$vol_audit <- renderTable({ req(vol_result()); vol_result()$method_audit }, striped = TRUE, bordered = TRUE, spacing = "xs", na = "")

  output$download_volume <- downloadHandler(
    filename = function() paste0("nepalallometry_volume_results_", Sys.Date(), ".xlsx"),
    content = function(file) {
      req(vol_data())
      nepalallometry::volume(vol_data(), output = file, methods = input$vol_methods)
    }
  )
}

shinyApp(ui, server)
