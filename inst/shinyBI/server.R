shinyServer(function(input, output, session) {
  # source preview
  output$rTailDT <- renderDataTable(tail(DT))
  
  # pivot
  fPivot <- reactive({
    validate(need(input$iPivot > 0, "Define the pivot"))
    isolate({
      # input check
      started.at <- proc.time()
      if(any(eval(input$iSelectRows) %in% eval(input$iSelectVals))) stop(paste0("cannot use same column in both rows and measures fields"))
      row.subset <- if(input$iRowSubset=="") expression(TRUE) else parse(text = input$iRowSubset)
      
      # dcast
      #input$iSelectCols
      
      # aggregate or just list
      if(!is.null(eval(input$iSelectVals))){
        jj <- mxapply(SDcols = eval(input$iSelectVals),funs = eval(input$iSelectFuns),na.rm = eval(input$iNAomit))
        rDT <- DT[tryCatch(expr = eval(row.subset),
                           error = function(e) stop(paste0("Provided filter expression results error: ",paste(as.character(c(e$call,e$message)),collapse=": ")), call.=FALSE)),
                  eval(jj),
                  keyby = eval(input$iSelectRows)]
      }
      else if(is.null(eval(input$iSelectVals))){
        rDT <- DT[tryCatch(expr = eval(row.subset),
                           error = function(e) stop(paste0("Provided filter expression results error: ",paste(as.character(c(e$call,e$message)),collapse=": ")), call.=FALSE)),
                  .SD,
                  .SDcols = eval(input$iSelectRows)]
      }
      
      # deduplicate
      if(input$iUnique) rDT <- unique(rDT)
      
      # describe
      setattr(rDT,"rPivotInRows",nrow(DT))
      setattr(rDT,"rPivotOutRows",nrow(rDT))
      setattr(rDT,"rPivotProcTime",timetaken(started.at, num=TRUE))
      
      # update plot controls
      vars <- translation(names(rDT))
      updateSelectizeInput(session, "iXaxis", choices = vars, selected=NULL)
      updateSelectizeInput(session, "iYaxis", choices = vars, selected=NULL)
      updateSelectizeInput(session, "iGroups", choices = c("", vars), selected="")
      
      # return
      setorderv(rDT, cols = eval(input$iSelectRows), na.last=TRUE)
    }) # end isolation
  }) # fPivot
  output$rPivotInRows <- renderText(sprintf("Input rows: %1.0f", attr(fPivot(), "rPivotInRows", exact=T)))
  output$rPivotOutRows <- renderText(sprintf("Output rows: %1.0f", attr(fPivot(), "rPivotOutRows", exact=T)))
  output$rPivotProcTime <- renderText(sprintf("Elapsed secs: %1.3f",attr(fPivot(), "rPivotProcTime", exact=T)))
  output$rPivot <- renderDataTable({fPivot()}, options = list(aLengthMenu = list(c(15, 25, 50, 100, -1), c('15', '25', '50', '100', 'All')), iDisplayLength = 15))
  output$csvPivot <- downloadHandler(filename = function() paste('pivot_', format(Sys.time(),"%Y%m%d_%H%M%S"), '.csv', sep=''),content = function(con) write.csv2(fPivot(), con))
  
  # plot
  fPlot <- reactive({
    validate(need(input$iPlot > 0, "Define the plot"))
    isolate({
      # input check
      started.at <- proc.time()
      grp <- if(input$iGroups == "") NULL else eval(input$iGroups)
      # lowest granularity check
      inGranularityCheck <- nrow(fPivot()[,unique(.SD), .SDcols=c(eval(input$iXaxis),grp)])
      if(nrow(fPivot()) > inGranularityCheck) stop(paste0("Plot is possible only on lowest granularity data from pivot results, go back to pivot and remove any 'rows' fields not used in plotting X axis or groups"))
      # plot, including data type preparing
      p <- nxPlot(x = eval(input$iXaxis), y = eval(input$iYaxis), group = eval(grp), data = fPivot(), type = eval(input$iPlotType))
      # iInteractiveGuideline
      if(input$iInteractiveGuideline & eval(input$iPlotType) == "lineChart") p$chart(useInteractiveGuideline=TRUE)
      
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
