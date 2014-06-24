shinyUI(
  navbarPage(
    "shinyBI",
    tabPanel("about",
             includeMarkdown("about.md")),
    tabPanel("source",
             includeMarkdown("source.md"),
             wellPanel(dataTableOutput("rTailDT"))),
    tabPanel("pivot",
             includeMarkdown("pivot.md"),
             fluidPage(
               sidebarLayout(
                 sidebarPanel(width=3,
                   textInput("iRowSubset", label = "filters", value = ""),
                   selectizeInput("iSelectRows", label = "rows", choices = translation(names(DT)), multiple = TRUE),
                   #selectizeInput("iSelectCols", label = "columns", choices = translation(names(DT)), multiple = TRUE),
                   selectizeInput("iSelectVals", label = "measures", choices = translation(names(DT)), multiple = TRUE),
                   selectizeInput("iSelectFuns", label = "functions", choices = translation(fPivotDict), multiple = TRUE),
                   actionButton("iPivot", "pivot"),br(),
                   br(),
                   checkboxInput("iNAomit", label = "NA omit", value = TRUE), 
                   checkboxInput("iUnique", label = "distinct", value = FALSE),
                   br(),
                   verbatimTextOutput("rPivotInRows"),
                   verbatimTextOutput("rPivotOutRows"),
                   verbatimTextOutput("rPivotProcTime")
                 ),
                 mainPanel(dataTableOutput("rPivot"))
               )
             )),
    tabPanel("plot",
             includeMarkdown("plot.md"),
             fluidPage(
               sidebarLayout(
                 sidebarPanel(width=3,
                   selectizeInput("iXaxis", label = "X axis", choices = NULL, multiple = F),
                   selectizeInput("iYaxis", label = "Y axis", choices = NULL, multiple = F),
                   selectizeInput("iGroups", label = "groups", choices = NULL, multiple = F),
                   #br(),
                   #selectizeInput("iYfun", label = "non-aggr FUN(Y)", choices = translation(fPlotDict), multiple = F),
                   #checkboxInput("iYkeep", label = "keep Y values", value = FALSE), 
                   #checkboxInput("iPlotLogY", label = "log Y", value = FALSE), 
                   br(),
                   actionButton("iPlot", "plot"),br(),
                   br(),
                   verbatimTextOutput("rPlotInRows"),
                   verbatimTextOutput("rPlotProcTime")
                 ),
                 mainPanel(
                   chartOutput("rPlot", "nvd3")
                   )
               )
             ))
  )
)
