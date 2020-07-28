# to do <- write network module logic using a string of onames as input
server <- function(input, output, session){
  selected <- searchModuleServer('searchModule')
  results <- networkModuleServer('networkModule', selected)
  downloadModuleServer('downloadModule', results)
  
}