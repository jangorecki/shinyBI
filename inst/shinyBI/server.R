# generic function to apply vector of functions (funs) on list of measures (sd) while performing pivot, NA will be omitted
xapply <- function(sd, funs, na.rm, ...){
  if(length(sd) > 1 & length(funs)==1) funs <- rep(funs,length(sd)) #repeat one aggreate function for all measures
  if(length(sd)!=length(funs)) stop("you should provide as much functions as values provided or only one function to apply on all measures")
  nms <- names(sd)
  r <- lapply(1:length(sd), FUN = function(i, ...){
    tryCatch({
      fun <- match.fun(funs[[i]])
      if("na.rm" %in% names(as.list(args(fun)))){
        fun(sd[[i]], na.rm = na.rm)
      } else if(!("na.rm" %in% names(as.list(args(fun))))){
        fun(sd[[i]])
      } else{
        stop(paste("error on 'na.rm' argument check in target function",funs[[i]]))
      }
    }, error = function(e){
      paste(c(as.character(e$call,e$message), collapse=": "))
    })
  }, sd = sd, funs = funs, na.rm = na.rm)
  names(r) <- paste(nms,funs,sep=".")
  r
}

shinyServer(function(input, output, session) {
  # source
  output$rTailDT <- renderDataTable(tail(DT))
  
  # pivot
  fPivot <- reactive({
    input$iPivot
    if(input$iPivot == 0) return()
    isolate({
      # input check
      started.at <- proc.time()
      row.subset <- if(input$iRowSubset=="") expression(TRUE) else parse(text = input$iRowSubset)
      
      # dcast
      #input$iSelectCols
      
      # aggregate
      rDT <- DT[tryCatch(expr = eval(row.subset),
                         error = function(e) stop(paste0("Provided filter expression results error: ",paste(as.character(c(e$call,e$message)),collapse=": ")))),
                xapply(sd = .SD, funs = eval(input$iSelectFuns), na.rm = eval(input$iNAomit)),
                keyby = eval(input$iSelectRows),
                .SDcols = eval(input$iSelectVals)]
      
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
  output$rPivotProcTime <- renderText(sprintf("Seconds elapsed: %1.3f",attr(fPivot(), "rPivotProcTime", exact=T)))
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
    if(input$iPlot == 0) return()
    isolate({
      started.at <- proc.time()
      rgg <- ggplot(data = fPivot(), environment=environment())
      rgg <- rgg + ggtitle(paste0("shinyBI plot: ",eval(input$iYaxis)," by ",eval(input$iXaxis)))
      if(is(fPivot()[[eval(input$iYaxis)]],"Date") | is.character(fPivot()[[eval(input$iYaxis)]]) | is.factor(fPivot()[[eval(input$iYaxis)]])){
        #message(paste("plot Y as frequency",paste("x",input$iXaxis,sep="="),paste("y",input$iYaxis,sep="="),paste("group",input$iGroups,sep="="),sep=", "))
        if(input$iGroups=="") rgg <- rgg + geom_bar(aes_string(x = eval(input$iXaxis), y = eval(input$iYaxis), group = 1), stat="identity")
        else rgg <- rgg + geom_bar(aes_string(x = eval(input$iXaxis), y = eval(input$iYaxis), colour = eval(input$iGroups), group = eval(input$iGroups)), stat="identity")
      }
      else if(is.numeric(fPivot()[[eval(input$iYaxis)]])){
        #message(paste("plot Y as value",paste("x",input$iXaxis,sep="="),paste("y",input$iYaxis,sep="="),paste("group",input$iGroups,sep="="),sep=", "))
        if(input$iGroups=="") rgg <- rgg + geom_line(aes_string(x = eval(input$iXaxis), y = eval(input$iYaxis), group = 1))
        else rgg <- rgg + geom_line(aes_string(x = eval(input$iXaxis), y = eval(input$iYaxis), colour = eval(input$iGroups), group = eval(input$iGroups)))
      }
      else stop(paste0("X axis data type unsupported on plot"))
      if(eval(input$iPlotLogY)){
        rgg <- rgg + scale_y_log10()
      }
      rgg <- rgg + theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
      
      # describe
      setattr(rgg,"rPlotInRows",nrow(fPivot()))
      setattr(rgg,"rPlotProcTime",timetaken(started.at, num=TRUE))      
      rgg
    })
  }) # fPlot
  output$rPlotInRows <- renderText(sprintf("Input rows: %1.0f", attr(fPlot(), "rPlotInRows", exact=T)))
  output$rPlotProcTime <- renderText(sprintf("Seconds elapsed: %1.3f",attr(fPlot(), "rPlotProcTime", exact=T)))
  output$rPlot <- renderPlot(print(fPlot()))
  
  # report
  #output$rPDF <- downloadHandler(filename = paste("shinyBI_report.pdf", content = function() render("input.Rmd", "pdf_document"), contentType = "application/pdf")
  
})

# runApp()