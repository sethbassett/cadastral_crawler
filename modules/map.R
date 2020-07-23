# Parcel Map --------------------------------------------------------------
get_parcels_by_oname <- function(onames, geom = T) {
  conn <- poolCheckout(pool)
  if(geom==TRUE){
    cleanQuery <- sqlInterpolate(conn, "SELECT * FROM parcels_2018 WHERE oname IN (?input)", input = SQL(build_in(onames)))
    print(cleanQuery)
    results <- pgGetGeom(conn, geom = 'geom', query = cleanQuery)  
  } else{
    cleanQuery <- sqlInterpolate(conn, "SELECT parcelid, oname, oaddr1, oaddr2, ocity, ostate, ozipcd, ocat, saleyr1, saleprc1, saleyr2, saleprc2, googlemap FROM parcels_2018 WHERE parcelid IN (?parcels)", parcels = SQL(build_in(parcelids)))
    results <- dbGetQuery(conn, cleanQuery)
  }
  poolReturn(conn)
  return(results)
}

bbox_query <- function(input){
  conn <- poolCheckout(pool)
  baseQuery <- "
  WITH
  dump_envelope AS (
  SELECT 
  (ST_DumpPoints(ST_Envelope(geom))).* 
  FROM 
  parcels_2018 
  WHERE 
  parcelid IN (?pids)
  )
  SELECT MIN(ST_X(geom)) minx,  MIN(ST_Y(geom)) miny, MAX(ST_X(geom)) maxx, MAX(ST_Y(geom)) maxy FROM dump_envelope;
  "
  cleanQuery <- sqlInterpolate(conn, baseQuery,
                               pids= SQL(build_in(input$parcelid)))
  results <- dbGetQuery(conn, cleanQuery)
  poolReturn(conn)
  return(results)
}

build_map_labels <- function(spatial.df){
  labels <- sprintf(
    "<strong>Owner Name:</strong>%s<br/><strong>Parcel ID: </strong>%s<br/><strong>Sale 1: </strong>%g (%g)<br/>, <strong>Sale 2: </strong>%g (%g)<br/><a href=%s>Google Maps</a>",
    spatial.df$oname, spatial.df$parcelid, spatial.df$saleprc1, spatial.df$saleyr1, spatial.df$saleprc2, spatial.df$saleyr2, spatial.df$googlemap) %>% 
    lapply(htmltools::HTML)
}

basic_map <- function(cadgraph){
  parcels <- cadgraph$parcels
  bbox <- bbox_query(parcels)
  labels <- build_map_labels(parcels)
  factpal <- colorFactor(cadgraph$pal, parcels$oname)
  leaflet(parcels) %>% 
    fitBounds(bbox$minx, bbox$miny, bbox$maxx, bbox$maxy) %>%
    addProviderTiles(providers$Esri.WorldGrayCanvas) %>% 
    addPolygons(data = parcels, 
                fillColor = ~factpal(oname),
                color = 'burlywood',
                dashArray = "3",
                fillOpacity = 0.7,
                weight = 1.5,
                group = 'parcels',
                popup = labels,
                label = ~oname,
                highlight = highlightOptions(
                  weight = 5,
                  color = "cyan",
                  dashArray = "",
                  fillOpacity = 0.7,
                  bringToFront = TRUE))
}

