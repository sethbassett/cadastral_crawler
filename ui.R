library(shiny)

navbarPage(
  "Cadastral Crawler v0.22",
  theme = shinytheme("readable"),
    tabPanel("Crawl!",
      fluidPage(
      column(2,
        networkModuleUI('networkModule'),
        searchWidget('mod1')
        ),
      column(5,
        networkModuleGraph('networkModule')
      ),
      column(5,
        networkModuleMap('networkModule'))
  )
    )
)

