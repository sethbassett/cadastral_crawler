#####################
# Passes a parameterized string input to the database
# 
# Returns: 
#   selected (char*) : character vector of matching onames
#
#   * denotes a reactive
#####################


# using shinyWidgets
searchInput <- function(id, label = "Results"){
  ns <- NS(id)
  tagList(        
    textInput(ns("oname"), 
              label = h5('Search Owner Records by Name'),
              value = "Deseret",
              width = '100%'
    ),
    actionBttn(ns('action'), 
               label = "Query Data", 
               color = 'primary', 
               style = 'material-flat', 
               icon = icon('table', lib = 'glyphicon'),
               block = TRUE)
  )
}

searchWidget <- function(id, label = "Results"){
  ns <- NS(id)
  tagList(
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
          #results <- get_nonames_fuzzy(input$oname)
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
          label = h5("Select Results: "), 
          choices = results(),
          options = list(
            `live-search` = TRUE,
            `actions-box` = TRUE), 
          multiple = TRUE,
          width = '100%')
      })
      return(selected)
    })
}