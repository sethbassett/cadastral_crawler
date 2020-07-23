# Shiny Packages
library(shiny)
#library(shinydashboard)
library(shinyWidgets)
library(shinythemes)
library(DT)

# Spatial Packages
library(sp)
library(leaflet)
library(leaflet.extras)

# Database Packages
library(pool)
library(rpostgis)
library(RPostgres)
library(DBI)

# Network Packages
library(igraph)
library(visNetwork)

# Data Manipulation Packages  
library(scales)
library(dplyr)

# Aesthetics
library(wesanderson)

credentials <- read.csv('./credentials.env', stringsAsFactors = F, header = F)
connectionArgs <- sapply(credentials[,2],list)
names(connectionArgs) <- credentials[,1]
pool <- do.call(dbPool, connectionArgs)


# modules -----------------------------------------------------------------

source("./modules/search.R")



# Global Functions --------------------------------------------------------

oname_query <- function(input, wildcard = T){
  conn <- poolCheckout(pool)
  if(wildcard == T){
    input <- paste("%", toupper(input), "%", sep = '')  
  }
  cleanQuery <- sqlInterpolate(conn, "SELECT objectid, parcelid, jv, phyaddr1, phycity, phyzip, oname, oaddr1, oaddr2, ocity, ostate, ozipcd, ocat, saleyr1, saleprc1, saleyr2, saleprc2, googlemap, nocat from parcels_2018 WHERE UPPER(oname) ILIKE ?oname;",
                               oname = input)
  results <- dbGetQuery(conn, cleanQuery)
  results$nocat <- gsub(' ', '', results$ocat)
  poolReturn(conn)
  return(results)
}

oname_exact_query <- function(input){
  conn <- poolCheckout(pool)
  #input <- toupper(input)
  cleanQuery <- sqlInterpolate(conn, "SELECT objectid, parcelid, jv, phyaddr1, phycity, phyzip, oname, oaddr1, oaddr2, ocity, ostate, ozipcd, ocat, saleyr1, saleprc1, saleyr2, saleprc2, googlemap, nocat from parcels_2018 WHERE oname = ?oname;",
                               oname = input)
  results <- dbGetQuery(conn, cleanQuery)
  results$nocat <- gsub(' ', '', results$ocat)
  poolReturn(conn)
  return(results)
}





nocat_query <- function(input){
  conn <- poolCheckout(pool)
  cleanQuery <- sqlInterpolate(conn, 
                               "SELECT objectid, parcelid, jv, phyaddr1, phycity, phyzip, oname, oaddr1, oaddr2, ocity, ostate, ozipcd, ocat, saleyr1, saleprc1, saleyr2, saleprc2, googlemap, nocat from parcels_2018 WHERE nocat = ?nocat;",
                               nocat = input)
  results <- dbGetQuery(conn, cleanQuery)
  poolReturn(conn)
  return(results)
}

build_in <- function(character.vector, w = "both"){
  character.vector <- paste("'",trimws(unique(character.vector), which = w),"'", collapse=',', sep ='')
  return(character.vector)
}

get_parcel_props_from_ids <- function(parcelids){
  conn <- poolCheckout(pool)
  cleanQuery <- sqlInterpolate(conn,
                               "SELECT count(parcelid) as n, sum(lndsqfoot) as area, sum(jv) as jv_sum, avg(jv) as jv_avg FROM parcels_2018 WHERE parcelid IN (?parcels)", 
                               parcels = SQL(build_in(parcelids)))
  results <- dbGetQuery(conn, cleanQuery)
  poolReturn(conn)
  return(results)
}


