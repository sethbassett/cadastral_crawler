tagList(
  tags$head(includeScript("navAppend.js")),
  navbarPage(
      "Cadastral Crawler v0.23",
      theme = shinytheme("slate"),
        tabPanel("Main App",
          fluidPage(
              column(2,
                     searchInput('searchModule'),
                     searchWidget('searchModule'),
                     networkModuleUI('networkModule'),
                     downloadModuleUI('downloadModule')),
              column(5,
                     networkModuleGraph('networkModule')
              ),
              column(5,
                     networkModuleMap('networkModule')
              )
        )
      ),
      tabPanel('Tutorial', 
               includeMarkdown('docs/Tutorial.Rmd'))
      )
)
