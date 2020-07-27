# Database Query Functions ------------------------------------------------

get_parcel_props_from_onames <- function(oname){
  ### Fetch summary of parcel properties for each owner name ###
  conn <- poolCheckout(pool)
  cleanQuery <- sqlInterpolate(conn,
                               "SELECT count(parcelid) as n, sum(lndsqfoot)/27878400.0 as area, sum(jv) as jv_sum, avg(jv) as jv_avg FROM parcels_2018 WHERE oname = ?input", 
                               input = oname)
  results <- dbGetQuery(conn, cleanQuery)
  poolReturn(conn)
  return(results)
}

get_parcel_props_from_nocat <- function(nocat){
  ### Fetch summary of parcel properties for each owner name ###
  conn <- poolCheckout(pool)
  cleanQuery <- sqlInterpolate(conn,
                               "SELECT count(parcelid) as n, sum(lndsqfoot)/27878400.0 as area, sum(jv) as jv_sum, avg(jv) as jv_avg FROM parcels_2018 WHERE nocat = ?input", 
                               input = nocat)
  results <- dbGetQuery(conn, cleanQuery)
  poolReturn(conn)
  return(results)
}

get_nocats <- function(oname){
  ### Get nocats values for a single oname
  conn <- poolCheckout(pool)
  cleanQuery <- sqlInterpolate(conn, 
                               "SELECT nocat FROM parcels_2018 WHERE oname = ?input;",
                               input = oname)
  nocats <- dbGetQuery(conn, cleanQuery)
  poolReturn(conn)
  if(nrow(nocats) > 0){
    nocats <- unique(nocats[1])
    nocats <- data.frame(oname = rep(oname, length(nocats)),
                         nocat = nocats,
                         stringsAsFactors = F)
  } else {
    nocats <- data.frame(oname = character(),
                         nocat = character(),
                         stringsAsFactors = F)
  }
  return(nocats)
}

get_onames <- function(nocat){
  ### Fetch onames based on a single nocat value
  conn <- poolCheckout(pool)
  cleanQuery <- sqlInterpolate(conn, 
                               "SELECT oname FROM parcels_2018 WHERE nocat = ?input;",
                               input = nocat)
  onames <- dbGetQuery(conn, cleanQuery)
  poolReturn(conn)
  if(nrow(onames) > 0){
    onames <- unique(onames[1])
    onames <- data.frame(oname = onames,
                         nocat = rep(nocat, length(onames)),
                         stringsAsFactors = F)
  } else {
    onames <- data.frame(oname = character(),
                         nocat = character(),
                         stringsAsFactors = F)
  }
  return(onames)
}


# Network Graph Functions -------------------------------------------------

init_nodes <- function(onames, currentDepth, pal) {
  ### Initialize a node data frame ###
  
  # Scrub
  onames <- unique(onames)
  
  # Query Size Data  
  sizes <- do.call(rbind, lapply(onames, get_parcel_props_from_onames))
  sizes$id <- onames
  nodes <- data.frame(id = onames,
                      label = onames,
                      title = onames,
                      visited = rep(FALSE, length(onames)),
                      size = rep(25, length(onames)),
                      shape = rep('star', length(onames)),
                      color = rep(pal[currentDepth], length(onames)),
                      group = rep(paste("Search Depth", currentDepth), length(onames)),
                      stringsAsFactors = F)
  nodes <- merge(nodes, sizes, by = 'id')
  return(nodes)
}


init_nocat_nodes <- function(nocat, currentDepth, pal) {
  ### Initialize a node data frame ###
  
  # Scrub
  nocat <- unique(nocat)
  
  # Query Size Data  
  sizes <- do.call(rbind, lapply(nocat, get_parcel_props_from_nocat))
  sizes$id <- nocat
  nodes <- data.frame(id = nocat,
                      label = nocat,
                      title = nocat,
                      visited = rep(TRUE, length(nocat)),
                      size = rep(25, length(nocat)),
                      shape = rep('ellipse', length(nocat)),
                      color = rep(pal[currentDepth], length(nocat)),
                      group = rep(paste("Search Depth", currentDepth), length(nocat)),
                      stringsAsFactors = F)
  nodes <- merge(nodes, sizes, by = 'id')
  return(nodes)
}

init_graph <- function(onames, 
                       maxDepth = 5, maxNodes = 1000, 
                       pal = rev(wes_palette('FantasticFox1', 5)),
                       discoveryOrder = F) {
  ### Initialize a new network graph ###
  
  shapes <- c("star","square", "triangle", "box", "circle", "dot",
              "ellipse","diamond")
  
  # clean 
  onames <- unique(onames)
  
  # init node data frame
  nodes <- init_nodes(onames, 1, pal)
  
  # init edges data frame
  edges <- data.frame(from = character(),
                      to = character(),
                      #title = character(),
                      stringsAsFactors = F
                      # length = c(100,500),
                      # width = c(4,1),
                      # arrows = c("to", "from", "middle", "middle;to"),
                      # dashes = c(TRUE, FALSE),
                      # title = paste("Edge", 1:8),
                      # smooth = c(FALSE, TRUE),
                      #shadow = c(FALSE, TRUE, FALSE, TRUE)
                      
  ) 
  return(list(nodes = nodes, edges = edges, current_depth = 1, max_depth = maxDepth, max_nodes = maxNodes, pal = pal, discoveryOrder = discoveryOrder))
}

graph_step <- function(cadgraph){
  ### Next step in a breadth-first search ###
  
  # Pull list items for convenience and clarity
  nodes <- cadgraph$nodes
  edges <- cadgraph$edges
  currentDepth <- cadgraph$current_depth + 1
  maxDepth <- cadgraph$max_depth
  maxNodes <- cadgraph$max_nodes
  pal = cadgraph$pal
  discoveryOrder = cadgraph$discoveryOrder
  
  # establish a queue
  queue <- nodes$id[nodes$visited == FALSE]
  
  ### Build links table
  # query next links
  nocats <- do.call(rbind, lapply(queue, get_nocats))
  onames <- do.call(rbind, lapply(nocats$nocat, get_onames))
  
  # mark queue items as visited
  nodes$visited[nodes$id %in% queue] <- TRUE
  
  # Scrub NA from links
  nocats <- na.omit(nocats)
  onames <- na.omit(onames)
  
  # join lists for links table
  links <- full_join(nocats, onames, by = "nocat")
  
  # remove non-unique links
  links <- unique(links)
  
  # remove self-links 
  links <- links[!(links$oname.x == links$oname.y),]
  
  # remove back-links to already visited nodes
  links <- links[!(links$oname.y %in% nodes$id[nodes$visited == T]),]
  #links <- links[!(links$nocat %in% nodes$id[nodes$visited == T]),]
  
  newLinks1 <- links[,c(1,2)]
  names(newLinks1) <- c("from","to")
  
  if(discoveryOrder == T){
     # build in order of discover
     newLinks2 <- links[,c(2,3)]
  } else {
    # Natural Order
    newLinks2 <- links[,c(3,2)]
  }
  
  names(newLinks2) <- c("from","to")
  newLinks <- rbind(newLinks1, newLinks2)
  newLinks$title <- rep(NULL, nrow(newLinks))
  
  newNodes <- rbind(init_nocat_nodes(links$nocat, currentDepth, pal), init_nodes(links$oname.y, currentDepth, pal))
  
  nodes <- unique(rbind(nodes, newNodes))
  edges <- unique(rbind(edges, newLinks))
  
  if(nrow(nodes) > maxNodes){
    cadgraph$current_depth <- maxDepth + 1
    return(cadgraph)
  } else {
    # update graph
    
    cadgraph <- list(nodes = nodes,
                     edges = edges,
                     max_depth = maxDepth,
                     current_depth = currentDepth,
                     max_nodes = maxNodes,
                     pal = pal,
                     discoveryOrder = discoveryOrder)
    return(cadgraph)
  }
  
}

graph_props <- function(cadgraph){
  onames <- unique(cadgraph$edges$from)
  
  # generate properties table for owners
  props <- do.call(rbind, lapply(onames, get_parcel_props_from_onames))
  props$oname <- onames
  
  # create popup title for nodes table
  props$title <- paste(paste('Owner: ', props$oname), 
                       paste('N-Parcels: ', formatC(props$n, format = 'f', big.mark = ',', digits = 0)), 
                       paste('Total Area: ', formatC(props$area, format = 'f', big.mark = ',', digits = 0), ' mi<sup>2</sup>'),
                       paste('Total Just Value: ', dollar(props$jv_sum)),
                       paste('Avg Just Value: ', dollar(props$jv_avg)),
                       sep = "<br/>")
  
  # merge poup title to nodes table
  cadgraph$nodes <- merge(cadgraph$nodes[,!grepl("title", colnames(cadgraph$nodes))], props[,c('oname','title')], by.x = "id", by.y = "oname", all.x = T)
  
  # add props table to cadgraph
  cadgraph$props <- props
  
  # generate summary table for all parcels
  cadgraph$summary <- props %>% 
    summarise(n_owners = n(), 
              n_nodes = nrow(cadgraph$nodes),
              n_edges = nrow(cadgraph$edges),
              area = sum(area, na.rm = T), 
              jv = sum(jv_sum, na.rm=T))
  
  # generate a title for the network graph
  cadgraph$title <- paste(paste('N-Owners: ', formatC(cadgraph$summary$n_owners[1], format = 'f', big.mark = ',', digits = 0)), 
                          paste('Total Area: ', formatC(cadgraph$summary$area[1], format = 'f', big.mark = ',', digits = 0),  'mi<sup>2</sup>'),
                          paste('Total Just Value: ', dollar(cadgraph$summary$jv[1])),
                          sep = "<br/>")
  
  # add parcel data
  #cadgraph$parcels <- get_parcels_by_oname(onames)
  cadgraph$sf <- get_sf_by_oname(onames)
  cadgraph$edges$smooth <- rep(TRUE, nrow(cadgraph$edges))
  
  return(cadgraph)
}

prune_graph <- function(cadgraph, prune){
  ### Prune a graph based on an oname value (prune)
  cadgraph$edges <- cadgraph$edges[cadgraph$edges$from != prune & cadgraph$edges$to != prune,]
  cadgraph$nodes <- cadgraph$nodes[cadgraph$nodes$id != prune,]
  return(cadgraph)
}

build_graph <- function(cadgraph){
  while(nrow(cadgraph$nodes) < cadgraph$max_nodes & cadgraph$current_depth <= cadgraph$max_depth & !all(cadgraph$nodes$visited)){
    cadgraph <- graph_step(cadgraph)
  }
  cadgraph <- graph_props(cadgraph)
  return(cadgraph)
}


# mapping Functions ------------------------------------------------------
get_sf_by_oname <- function(onames) {
  conn <- poolCheckout(pool)
  #ST_Simplify(geom,0.001) as 
  cleanQuery <- sqlInterpolate(conn, "SELECT objectid, parcelid, parusedesc, jv, oname, ocat, nocat, lndsqfoot, googlemap, geom FROM parcels_2018 WHERE oname IN (?input) AND ST_IsValid(geom) = TRUE", input = SQL(build_in(onames)))
  results <- st_read(conn, query = cleanQuery, stringsAsFactors = F)
  poolReturn(conn)
  return(results)
}

build_map_labels <- function(spatial.df){
  labels <- sprintf(
    "<strong>Owner Name:</strong>%s<br/><strong>Parcel ID: </strong>%s<br/><a href=%s>Google Maps</a>",
    spatial.df$oname, spatial.df$parcelid, spatial.df$googlemap) %>% 
    lapply(htmltools::HTML)
}



# Shiny UI Logic ----------------------------------------------------------
networkModuleUI <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(ns('widget'))
  )
}

networkModuleGraph <- function(id, ...){
  ns <- NS(id)
  tagList(
      visNetworkOutput(ns('network'), ...)
  )
}

networkModuleMap <- function(id, ...){
  ns <- NS(id)
  tagList(
      leafletOutput(ns('map'), ...)
  )
}

# Shiny Server Logic ------------------------------------------------------

networkModuleServer <- function(id, onames) {
  moduleServer(
    id,
    function(input, output, session) {
      results <- eventReactive(input$crawl, {
        # build graph
        withProgress(message = 'Building graph...', value = 0.25, {
          cadgraph <- init_graph(onames(), maxDepth = 5, maxNodes = 150, discoveryOrder = input$discoveryOrder)
          
          #print(cadgraph)
          cadgraph <- build_graph(cadgraph)
        })
        return(cadgraph)
      })
      
      
      # Server UI ---------------------------------------------------------
      output$widget <- renderUI({
        req(onames())
        ns <- session$ns
        tagList(
          hr(),
          br(),
          materialSwitch(ns("discoveryOrder"), 
                         label = 'Use Order Discovered',
                         value = F,
                         right = T,
                         status = 'success'),
          br(),
          actionBttn(inputId = ns('crawl'), 
                     label = "Crawl Data", 
                     color = 'success', 
                     style = 'material-flat',
                     icon = icon('diagram-2', lib = 'glyphicon'),
                     block = T)

        )
      })
      

# visGraph ----------------------------------------------------------------
      selectedParcels <- reactive({
        req(results(), input$click_node_id)
        nodeType <- results()$nodes[results()$nodes$id == input$click_node_id, 'shape']
        parcels <- results()$sf
        if(nodeType == 'star'){
          parcels <- parcels[parcels$oname == input$click_node_id,]
        } else if(nodeType == 'ellipse'){
          parcels <- parcels[parcels$nocat == input$click_node_id,]
        }
        return(parcels)
      })
      


      output$network <- renderVisNetwork({
        req(results())
        ns <- session$ns
        size.col = "n"
        newScale = c(10,200)
        cadgraph <- results()
        
        cadgraph$nodes$size <- rescale(cadgraph$nodes[,size.col], newScale)
        v <- visNetwork::visNetwork(
                cadgraph$nodes[,c("id","title","size", "color","shape", 'label')], 
                cadgraph$edges, 
                submain = cadgraph$title) %>%
          visNodes(shadow = list(enabled = TRUE, size = 10),
                   font = "18px arial white") %>%
          visEdges(arrows = "to", label = NULL) %>%
          #visHierarchicalLayout() %>%
          #visIgraphLayout(layout = layoutType) %>%
          visOptions(highlightNearest = TRUE, nodesIdSelection = F) %>%
          visLayout(randomSeed = 111282) %>%
          visEvents(click=paste0("function(ng_nodes){
                console.log('teste');
                Shiny.onInputChange('",ns('click_node_id'),"',ng_nodes.nodes[0]);
                             }"))
        
        if(cadgraph$discoveryOrder == F){
          v %>% visIgraphLayout(layout = 'layout_nicely')
        } else {
          #layoutType = 'layout_with_sugiyama'
          v %>% visIgraphLayout('layout_with_sugiyama', maxiter = 200)
        }
      })
      

# leaflet -----------------------------------------------------------------

      observeEvent(input$click_node_id, {
        print(input$click_node_id)
        parcels <- selectedParcels()
        bbox <- st_bbox(parcels)
        names(bbox) <- NULL
        labels <- build_map_labels(parcels)
        
        leafletProxy('map') %>%
          clearGroup('Selected Parcels') %>%
          #fitBounds(selectedParcels()@bbox[1,1], selectedParcels()@bbox[2,1], selectedParcels()@bbox[1,2], selectedParcels()@bbox[2,2]) %>%
          addPolygons(data = parcels, 
                      group = 'Selected Parcels',
                      fillColor = 'cyan',
                      color = 'cyan',
                      weight = 4,
                      fillOpacity = 0.33,
                      popup = labels) %>%
          fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
      })
      
      output$map <- renderLeaflet({
        req(results())
        ns <- session$ns
        cadgraph <- results()
        parcels <- cadgraph$sf
        labels <- build_map_labels(parcels)
        factpal <- colorFactor(cadgraph$pal, parcels$oname)
        leaflet() %>% 
          addProviderTiles(providers$Esri.WorldGrayCanvas, group = 'ESRI Grey Canvas') %>%
          addProviderTiles(providers$Esri.WorldImagery, group = 'ESRI Imagery') %>%
          addPolygons(data = parcels, 
                      layerId = ~objectid,
                      fillColor = 'red',
                      color = 'red',
                      dashArray = "3",
                      fillOpacity = 0.4,
                      weight = 1.5,
                      group = 'Base Parcels',
                      popup = labels,
                      label = ~oname,
                      highlight = highlightOptions(
                        weight = 5,
                        color = "yellow",
                        dashArray = "",
                        fillOpacity = 0.7,
                        bringToFront = TRUE)) %>%
          addLayersControl(baseGroups = c('ESRI Grey Canvas', 'ESRI Imagery'),
                           overlayGroups = c('Base Parcels', 'Selected Parcels'))
        
      })
      return(results)
    })
}









