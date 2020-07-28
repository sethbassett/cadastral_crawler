validExtensions <- c('ESRI Shapefile',
                   'KML',
                   'CSV',
                   'GeoJSON',
                   'GPKG',
                   'SQLite',
                   'XLSX')

get_sf_by_objectid <- function(objectid) {
  conn <- poolCheckout(pool)
  #ST_Simplify(geom,0.001) as 
  cleanQuery <- sqlInterpolate(conn, "SELECT * FROM parcels_2018 WHERE objectid IN (?input)", input = SQL(build_in(objectid)))
  results <- st_read(conn, query = cleanQuery, stringsAsFactors = F)
  poolReturn(conn)
  return(results)
}

downloadModuleUI <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(ns('downloadType')),
    uiOutput(ns('downloadBttn'))
  )
}

downloadModuleServer <- function(id, cadgraph) {
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      
      output$downloadBttn <- renderUI({
        req(cadgraph(), input$filetype)
        tagList(
          br(),
          downloadBttn(ns('downloadData'), 
                       label = "Download", 
                       color = 'danger', 
                       style = 'material-flat',
                       block = T)
        )
        
      })
      
      output$downloadType <- renderUI({
        req(cadgraph())
        tagList(
          hr(),
          br(),
          pickerInput(
            inputId = ns("filetype"),
            label = "Download as", 
            choices = validExtensions,
            selected = 'shp',
            options = list(
              style = "btn-danger"),
            width = '100%'
          )
        )
      })
      
      baseFileName <- reactive({
        paste('cadcrawler',format(Sys.time(), '%Y%d%m%M%S'), sep = "_")
      })
      output$downloadData <- downloadHandler(
        filename = function(){
          paste0(baseFileName(), '.zip')
        },
        content = function(file) {
          baseWildCard <- paste(baseFileName(), '.*', sep='')
          baseDSN <- paste(baseFileName(), input$filetype, sep = '.')
          baseDriver <- names(input$filetype)[1]
          
          print(baseWildCard)
          print(baseDSN)
          print(baseDriver)
          
          owd <- setwd(tempdir())
          on.exit(setwd(owd))
          
          parcels <- get_sf_by_objectid(cadgraph()$sf$objectid)
          st_write(parcels, dsn = baseDSN)
          
          zipr(zipfile = file, files = Sys.glob(baseWildCard))
          
          if (length(Sys.glob(baseWildCard))>0){
            file.remove(Sys.glob(baseWildCard))
          }
        },

        contentType = "application/zip"
      )
      
    })
}
  