# generic function to apply vector of functions (funs) on list of measures (sd) while performing pivot
mxapply <- function(SDcols,funs,na.rm){
  if(length(SDcols) > 1 & length(funs)==1) funs <- rep(funs,length(SDcols)) #repeat one aggreate function for all measures
  if(length(SDcols)!=length(funs)) stop("you should provide as much functions as values provided or only one function to apply on all measures")
  optNA <- ifelse(fNAs[funs],paste0(", na.rm=",na.rm),"")
  ffuns <- paste0(funs,"(",SDcols,optNA,")")
  listBody <- paste(SDcols,ffuns,sep="=")
  jjText <- sprintf('list(%s)', paste(listBody, collapse = ', ')) 
  # lapply and mapply was not scalling as well as expression
  jj <- as.quoted(jjText)[[1]]
  jj
}

# character to factor to plot on X axis - this will be useful if: https://github.com/ramnathv/rCharts/issues/452
# fCharX <- function(DT, colX, typeX){
#   if(!("character" %in% typeX)) return(DT) 
#   DT[,.SD][, eval(colX) := lapply(.SD, as.factor), .SDcols = colX]
# }

fPlotXchar <- function(DT, colX, typeX){
  if("character" %in% typeX){
    return(DT[,.SD
              ][order(eval(as.quoted(colX)[[1]]))
                ][, eval(colX) := lapply(.SD, function(x) as.integer(as.factor(x))), .SDcols = colX
                  ])
  }
  return(DT)
}
# fPlotXcharLab <- function(DT, colX, typeX){
#   if("character" %in% typeX){
#     return(DT[,.SD,,.SDcols=colX
#               ][order(eval(as.quoted(colX)[[1]]))
#                 ][[eval(colX)]])
#   }
#   return(DT[,eval(colX),with=FALSE])
# }

shinyServer(function(input, output, session) {
  # source
  output$rTailDT <- renderDataTable(tail(DT))
  
  # pivot
  fPivot <- reactive({
    input$iPivot
    if(input$iPivot == 0) return(NULL)
    isolate({
      # input check
      started.at <- proc.time()
      row.subset <- if(input$iRowSubset=="") expression(TRUE) else parse(text = input$iRowSubset)
      
      # dcast
      #input$iSelectCols
      
      # aggregate
      jj <- mxapply(SDcols = eval(input$iSelectVals),funs = eval(input$iSelectFuns),na.rm = eval(input$iNAomit))
      rDT <- DT[tryCatch(expr = eval(row.subset),
                         error = function(e) stop(paste0("Provided filter expression results error: ",paste(as.character(c(e$call,e$message)),collapse=": ")), call.=FALSE)),
                eval(jj),
                keyby = eval(input$iSelectRows)]
      
      # deduplicate
      if(input$iUnique) rDT <- unique(rDT)
      
      # describe
      setattr(rDT,"rPivotInRows",nrow(DT))
      setattr(rDT,"rPivotOutRows",nrow(rDT))
      setattr(rDT,"rPivotProcTime",timetaken(started.at, num=TRUE))
      
      # return
      rDT
    })
  }) # fPivot
  output$rPivotInRows <- renderText(sprintf("Input rows: %1.0f", attr(fPivot(), "rPivotInRows", exact=T)))
  output$rPivotOutRows <- renderText(sprintf("Output rows: %1.0f", attr(fPivot(), "rPivotOutRows", exact=T)))
  output$rPivotProcTime <- renderText(sprintf("Elapsed secs: %1.3f",attr(fPivot(), "rPivotProcTime", exact=T)))
  output$rPivot <- renderDataTable({fPivot()}, options = list(aLengthMenu = list(c(15, 25, 50, 100, -1), c('15', '25', '50', '100', 'All')), iDisplayLength = 15))
  
  # plot
  observe({
    vars <- translation(names(fPivot()))
    updateSelectizeInput(session, "iXaxis", choices = vars, selected=NULL)
    updateSelectizeInput(session, "iYaxis", choices = vars, selected=NULL)
    updateSelectizeInput(session, "iGroups", choices = c("", vars), selected="")
  }) # updateSelectizeInput
  fPlot <- reactive({
    input$iPlot
    validate(
      need(input$iPlot > 0, "Define the plot")
    )
    isolate({
      # input check
      started.at <- proc.time()
      grp <- if(input$iGroups == "") NULL else eval(input$iGroups)
      # lowest granularity check
      inGranularityCheck <- nrow(fPivot()[,unique(.SD), .SDcols=c(eval(input$iXaxis),grp)])
      if(nrow(fPivot()) > inGranularityCheck) stop(paste0("Plot is possible only on lowest granularity data from pivot results, go back to pivot and remove any 'rows' fields not used in plotting X axis or groups"))
      
      typeX <- class(fPivot()[0][[input$iXaxis]])
      typeY <- class(fPivot()[0][[input$iYaxis]])
      
      # non-aggr funs
      # runmean(1:1000,k=30,endrule="NA",align="right"),
      #fNonAggrApply <- function(DT){ DT }
      
      # def vars
      #browser()
      p <- nPlot(x = input$iXaxis, y = input$iYaxis, group = grp, data = fPlotXchar(DT = fPivot(), colX = input$iXaxis, typeX = typeX),
                 type = "lineChart")

      # X axis format
      if("Date" %in% typeX){
        p$xAxis(tickFormat="#!function(d) {return d3.time.format.utc('%b %Y')(new Date( d * 86400000 ));}!#")
      } else if("character" %in% typeX){
        # not read, waiting for: https://github.com/ramnathv/rCharts/issues/452
        invisible()
        #p$xAxis(tickValues=fPlotXcharLab(DT = fPivot(), colX = input$iXaxis, typeX = typeX))
        #p$xAxis(tickLabels=fPlotXcharLab(DT = fPivot(), colX = input$iXaxis, typeX = typeX))
      }
      # "#!function(d) { var dataset = ['Build Array from data']; return dataset; }!#"
      
      # axis labels
      p$xAxis(axisLabel = names(translation(input$iXaxis)))
      p$yAxis(axisLabel = names(translation(input$iYaxis)))
      
      # p$chart(useInteractiveGuideline=TRUE) # laggy on small dt?
      p$addParams(dom = "rPlot")
      
      # description
      setattr(p,"rPlotInRows",nrow(fPivot()))
      setattr(p,"rPlotProcTime",timetaken(started.at, num=TRUE))      
      p
    }) # end isolation
  }) # fPlot
  output$rPlotInRows <- renderText(sprintf("Input rows: %1.0f", attr(fPlot(), "rPlotInRows", exact=T)))
  output$rPlotProcTime <- renderText(sprintf("Elapsed secs: %1.3f",attr(fPlot(), "rPlotProcTime", exact=T)))
  output$rPlot <- renderChart(fPlot())
  
})
