# to do <- write network module logic using a string of onames as input
server <- function(input, output, session){
  selected <- searchModuleServer('mod1')
  networkModuleServer('networkModule', selected)
  
  output$debug <- renderPrint({
    req(selected())
    selected()
  })
}








