suppressPackageStartupMessages(library(plyr)) # as.quoted FUN
suppressPackageStartupMessages(library(rCharts))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(markdown)) #rmarkdown

# misc --------------------------------------------------------------------

# pivot function dictionary
fPivotFunDict <- c("sum","mean","count","count_distinct","count_NA","percent_NA","Mode","min","max")

# pivot functions
count <- length
count_distinct <- function(x) length(unique(x))
count_NA <- function(x) sum(is.na(x))
percent_NA <- function(x) sum(is.na(x))/length(x)
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# funs na.rm dictionary
fNAs <- c("sum" = TRUE,"mean" = TRUE,"count" = FALSE,"count_distinct" = FALSE, "count_NA" = FALSE, "percent_NA" = FALSE,"Mode" = FALSE,"min" = TRUE,"max" = TRUE)

# plot type dictionary
fPlotTypeDict <- c("lineChart","scatterChart","multiBarChart","lineWithFocusChart","multiBarHorizontalChart")

# load sample DT if not provided
if(!exists("DT")){
  message("Loading shinyBI built-in example dataset")
  DT <- makeDim(readRDS(system.file("extdata","cran_logs.rds",package="shinyBI")))
} else if(is.null(DT)){
  message("Loading shinyBI built-in example dataset")
  DT <- makeDim(readRDS(system.file("extdata","cran_logs.rds",package="shinyBI")))
} else if(!is.data.table(DT)){
  stop("prepared DT argument must be a data.table object")
}

# shinyBI funs ------------------------------------------------------------

#' @title mxapply
#' @description Build quoted expression to apply provided aggregate functions on provided columns. Created this way due to lapply and mapply were not scalling as well as direct evaluated expression.
#' @keywords internal
mxapply <- function(SDcols,funs,na.rm){
  if(length(SDcols) > 1 & length(funs)==1) funs <- rep(funs,length(SDcols)) #repeat one aggreate function for all measures
  if(length(SDcols)!=length(funs)) stop("you should provide as much functions as values provided or only one function to apply on all measures")
  optNA <- ifelse(fNAs[funs],paste0(", na.rm=",na.rm),"")
  ffuns <- paste0(funs,"(",SDcols,optNA,")")
  listBody <- paste(SDcols,ffuns,sep="=")
  jjText <- sprintf('list(%s)', paste(listBody, collapse = ', ')) 
  # lapply and mapply were not scalling as well as direct evaluated expression
  jj <- as.quoted(jjText)[[1]]
  jj
}

#' @title timetaken
#' @description Slightly different than data.table::timetaken, not yet finished for other units than seconds.
#' @keywords internal
timetaken <- function(started.at, units = "secs", num = FALSE, precision = 3){
  secs <- as.numeric(as.difftime(tim = proc.time()[[3]]-started.at[[3]], units = "secs"))
  target_num <- as.numeric(as.difftime(tim = secs, format = "%S", units = units))
  r <- if(num) target_num else paste0(format(target_num, nsmall = precision, scientific=FALSE),substring(units, 1, 1))
  return(r)
}

#' @title nxPlot
#' @description Run nPlot with already prepared data types of x, y, grp and format axis after plotting.
#' @keywords internal
nxPlot <- function(x, y, group, data, type){
  typeX <- class(data[0][[x]])
  typeY <- class(data[0][[y]])
  if(!is.null(group)) typeGRP <- class(data[0][[group]])
  
  # order, clean X na
  colX <- x
  data <- setorderv(x = data[!is.na(get(colX)),.SD], cols = colX)
  
  # data types: pre plot
  
  if("character" %in% typeX){
    if(type %in% c("lineChart","scatterChart","lineWithFocusChart")){
      tickLabels <- unique(data[[x]])
      data[, eval(colX) := lapply(.SD, FUN = function(x) as.integer(as.factor(x))), .SDcols = colX]
    }
  }
  
  # plot
  p <- nPlot(x = x, y = y, group = group, data = data, type = type)
  
  # data types: post plot
  if("character" %in% typeX){
    if(type %in% c("lineChart","scatterChart","lineWithFocusChart")){
      p$xAxis(tickFormat = sprintf(
        "#! function(d){return [%s'][d-1]} !#",
        paste("'",tickLabels,sep="",collapse="',")
      ))
      p$xAxis(tickValues = data[[colX]])
    }
  }
  else if("Date" %in% typeX){
    p$xAxis(tickFormat="#!function(d) {return d3.time.format.utc('%b %Y')(new Date( d * 86400000 ));}!#")
  }
  p$xAxis(staggerLabels = TRUE)
  # axis labels
  p$xAxis(axisLabel = names(translation(x)))
  p$yAxis(axisLabel = names(translation(y)))
  return(p)
}
