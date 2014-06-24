suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(rCharts))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(markdown))

timetaken <- function(started.at, units = "secs", num = FALSE, precision = 3){
  #return(proc.time()[[3]]-started.at[[3]])
  secs <- as.numeric(as.difftime(tim = proc.time()[[3]]-started.at[[3]], units = "secs"))
  target_num <- as.numeric(as.difftime(tim = secs, format = "%S", units = units))
  r <- if(num) target_num else paste0(format(target_num, nsmall = precision, scientific=FALSE),substring(units, 1, 1))
  return(r)
}
count <- length
count_distinct <- function(x) length(unique(x))
count_NA <- function(x) sum(is.na(x))
percent_NA <- function(x) sum(is.na(x))/length(x)
mean <- function(x, na.rm=FALSE, ...) base::mean(x, ...)
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
#dictionary
fPivotDict <- c("sum","mean","count","count_distinct","count_NA","percent_NA","Mode","min","max")
fNAs <- c("sum" = TRUE,"mean" = TRUE,"count" = FALSE,"count_distinct" = FALSE, "count_NA" = FALSE, "percent_NA" = FALSE,"Mode" = FALSE,"min" = TRUE,"max" = TRUE)
# fNUMs <- c("sum" = TRUE,"mean" = TRUE,"count" = FALSE,"count_distinct" = FALSE, "count_NA" = FALSE, "percent_NA" = FALSE,"Mode" = FALSE,"min" = FALSE,"max" = FALSE)
# fPlotDict <- c("cumsum","runmean","runmin","runmax")

# provide values, produce names from values, format names to non underscore and capital letters of first word
translation <- function(x){
  if(is.null(x)) return(character())
  x <- setNames(x,gsub("_", " ", x, fixed = T))
  names(x) <- gsub(pattern = "\\b([a-z])", replacement = "\\U\\1", names(x), perl = TRUE)
  x
}

# load cran logs data
exampleDT <- function(){
  DT <- readRDS(paste(system.file("data",package="shinyBI"),"cran_logs.rds",sep="/"))
  #DT <- readRDS("../../data/cran_logs.rds")
  #DT <- readRDS("data/cran_logs.rds")
  datelt <- as.POSIXlt(DT[,unique(date)])
  time_dim <- data.table(
    date = as.Date(datelt),
    week = format(datelt,"%W"), month = format(datelt,"%B"), year = format(datelt,"%Y"),
    week_day = format(datelt,"%A"), year_month = format(datelt,"%Y-%m"), year_week = format(datelt,"%Y-%W"),
    key = "date"
  )
  DT <- time_dim[setkeyv(DT,"date")]
  rm(datelt,time_dim)
  setkeyv(DT,c("package","date"))
  gc()
  DT
}

if(!exists("DT")){
  DT <- exampleDT()
} else if(is.null(DT)){
  DT <- exampleDT()
} else if(!is.data.table(DT)){
  stop("shinyBI DT argument must be a data.table object")
}

