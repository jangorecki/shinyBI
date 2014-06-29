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
                   selectizeInput("iSelectFuns", label = "functions", choices = translation(fPivotFunDict), multiple = TRUE),
                   actionButton("iPivot", "pivot"),br(),
                   br(),
                   checkboxInput("iNAomit", label = "NA omit", value = TRUE), 
                   checkboxInput("iUnique", label = "distinct", value = FALSE),
                   br(),
                   verbatimTextOutput("rPivotInRows"),
                   verbatimTextOutput("rPivotOutRows"),
                   verbatimTextOutput("rPivotProcTime"),
                   br(),
                   downloadButton("csvPivot", label = "Download .csv")
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
                   selectizeInput("iPlotType", label = "type", choices = translation(fPlotTypeDict), multiple = F),
                   checkboxInput("iInteractiveGuideline", label = "interactive guideline", value = FALSE), 
                   actionButton("iPlot", "plot"),br(),
                   br(),
                   verbatimTextOutput("rPlotInRows"),
                   verbatimTextOutput("rPlotProcTime")
                 ),
                 mainPanel(
                   showOutput("rPlot", "nvd3")
                   )
               )
             ))
  )
)
