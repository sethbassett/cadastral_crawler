#####################
# Passes a parameterized string input to the database
# 
# Returns: 
#   selected (char*) : character vector of matching onames
#
#   * denotes a reactive
#####################




# UI Logic ----------------------------------------------------------------
searchDT <- function(id, label = "Search Output"){
  # Using DT::dataTableOutput
  ns <- NS(id) 
  tagList(
    hr(),
    textInput(ns("oname"), label = h3('Search by Owner Name')),
    actionButton(ns('action'), label = "Search"),
    hr(),
    DT::dataTableOutput(ns("dt"),
                        width = NULL
    )
  )
}

# using shinyWidgets
searchWidget <- function(id, label = "Results"){
  ns <- NS(id)
  tagList(        
    textInput(ns("oname"), label = h5('Search Owner Records by Name')),
    actionBttn(ns('action'), label = "Send Query!", color = 'primary', style = 'material-flat', icon = icon('table', lib = 'glyphicon')),
    hr(),
    uiOutput(ns('widget'))
  )
}

# Server Logic ------------------------------------------------------------
searchModuleServer <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      results <- eventReactive(input$action, {
        withProgress(message = 'Querying Database, this might take a moment...', value = 0.5, {
          results <- get_onames_fuzzy(input$oname)
          results <- data.frame(unique(results$oname), stringsAsFactors = F)
          if(nrow(results) == 0){
            return(NULL)
          }
          names(results) <- "Owner"
        })
        return(results)
      })
      
      selected <- reactive({
        req(results(), input$picker)
        results()[results()[,1] %in% input$picker,1]
      })
      
      # Server UI Logic ---------------------------------------------------------
      output$widget <- renderUI({
        req(results())
        pickerInput(
          inputId = session$ns('picker'),
          label = "Select Results: ", 
          choices = results(),
          options = list(
            `live-search` = TRUE,
            `actions-box` = TRUE), 
          multiple = TRUE
        )
      })
      return(selected)
    })
}