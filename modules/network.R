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
  shapes <- c("star","square", "triangle", "box", "circle", "dot",
              "ellipse","diamond")
  
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
  shapes <- c("star","square", "triangle", "box", "circle", "dot",
              "ellipse","diamond")
  
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

init_graph <- function(onames, maxDepth = 5, maxNodes = 1000, wespal = 'Cavalcanti1') {
  ### Initialize a new network graph ###
  # standard vectors
  pal <- rev(wes_palette(wespal, 5))
  shapes <- c("star","square", "triangle", "box", "circle", "dot",
              "ellipse","diamond")
  
  # clean 
  onames <- unique(onames)
  
  # init node data frame
  nodes <- init_nodes(onames, 1, pal)
  
  # init edges data frame
  edges <- data.frame(from = character(),
                      to = character(),
                      title = character(),
                      stringsAsFactors = F
                      # length = c(100,500),
                      # width = c(4,1),
                      # arrows = c("to", "from", "middle", "middle;to"),
                      # dashes = c(TRUE, FALSE),
                      # title = paste("Edge", 1:8),
                      # smooth = c(FALSE, TRUE),
                      #shadow = c(FALSE, TRUE, FALSE, TRUE)
                      
  ) 
  return(list(nodes = nodes, edges = edges, current_depth = 1, max_depth = maxDepth, max_nodes = maxNodes, pal = pal))
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
  
  # Natural Order
  newLinks2 <- links[,c(3,2)]
  
  # Depth Order
  #newLinks2 <- links[,c(3,2)]
  
  names(newLinks2) <- c("from","to")
  newLinks <- rbind(newLinks1, newLinks2)
  newLinks$title <- rep('a title', nrow(newLinks))
  
  newNodes <- rbind(init_nocat_nodes(links$nocat, currentDepth, pal), init_nodes(links$oname.y, currentDepth, pal))

  nodes <- rbind(nodes, newNodes)
  edges <- rbind(edges, newLinks)
  
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
                   pal = pal)
  }
  return(cadgraph)
}

graph_props <- function(cadgraph){
  onames <- unique(cadgraph$edges$from)
  
  # generate properties table for owners
  props <- do.call(rbind, lapply(onames, get_parcel_props_from_onames))
  props$oname <- onames
  
  # create popup title for nodes table
  props$title <- paste(paste('N-Parcels: ', formatC(props$n, format = 'f', big.mark = ',', digits = 0)), 
                       paste('Total Area (mi^2): ', formatC(props$area, format = 'f', big.mark = ',', digits = 0)),
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
  cadgraph$title <- paste(paste('N-Owners: ', formatC(cadgraph$summary$n[1], format = 'f', big.mark = ',', digits = 0)), 
                          paste('Total Area (mi^2): ', formatC(cadgraph$summary$area[1], format = 'f', big.mark = ',', digits = 0)),
                          paste('Total Just Value: ', dollar(cadgraph$summary$jv[1])),
                          sep = "<br/>")
  
  # add parcel data
  cadgraph$parcels <- get_parcels_by_oname(onames)
  
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


# visGraph Functions ------------------------------------------------------

create_vizgraph <- function(cadgraph, size.col = "n", newScale = c(10,100), layoutType = 'layout_nicely', ...){
  cadgraph$nodes$size <- rescale(cadgraph$nodes[,size.col], newScale)
  g <- visNetwork::visNetwork(cadgraph$nodes[,c("id","title","size", "color","shape", 'label')], 
                              cadgraph$edges, 
                              submain = cadgraph$title) %>%
    visNodes(shadow = list(enabled = TRUE, size = 10),
             font = "9px arial black") %>%
    visEdges(arrows = "to") %>%
    #visHierarchicalLayout() %>%
    visIgraphLayout(layout = layoutType, ...) %>%
    visOptions(highlightNearest = TRUE, nodesIdSelection = F) %>%
    visLayout(randomSeed = 111282)
  return(g)
}

test2 <- oname_query("deseret")
graph2 <- init_graph(test2$oname, maxDepth = 5, maxNodes = 100)
graph2 <- build_graph(graph2)
g2 <- create_vizgraph(graph2, size.col = "area", newScale = c(10,150), layoutType = 'layout_nicely')
g2


m2 <- basic_map(graph2)
m2








