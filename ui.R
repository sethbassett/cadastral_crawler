library(shiny)

navbarPage(
  "Cadastral Crawler v0.21",
  theme = shinytheme("darkly"),
    tabPanel("Crawl!",
      column(4,
        searchWidget('mod1')
        ),
      column(4,
        verbatimTextOutput('debug')
        ),
      column(4,
             h4('Placeholder'))
    )
  )

