# shiny::runApp(display.mode="normal",launch.browser=FALSE)

message(paste(as.character(Sys.time()),"shiny server starting",sep=": "))
global.at <- proc.time()
started.at <- proc.time()
options(scipen=100)
options(encoding = "UTF-8") # options(encoding = "native.enc")
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(markdown))
suppressPackageStartupMessages(library(ggplot2))
timetaken <- function(started.at, units = "secs", num = FALSE, precision = 3){
  secs <- as.numeric(as.difftime(tim = proc.time()[[3]]-started.at[[3]], units = "secs"))
  target_num <- as.numeric(as.difftime(tim = secs, format = "%S", units = units))
  r <- if(num) target_num else paste0(format(target_num, nsmall = precision, scientific=FALSE),substring(units, 1, 1))
  return(r)
}
message(paste(as.character(Sys.time()),"loading packages and sources",timetaken(started.at),sep=": "))

if(!exists("DT")) DT <- NULL
if(!is.data.table(DT)){
  message(paste(as.character(Sys.time()),"no data.table 'DT' object prepared, loading example data",sep=": "))
  started.at <- proc.time()
  
  DT <- readRDS(paste(system.file("data",package="shinyBI"),"cran_logs.rds",sep="/"))[,`:=`(weekday=weekdays(date),
                                                                                            week=strftime(as.POSIXlt(date),format="%Y-%W"))
                                                                                      ][date >= as.Date("2013-11-17")
                                                                                        ][,setkeyv(.SD,c("package","date","week"))
                                                                                          ]
  message(paste(as.character(Sys.time()),"example data loaded to memory",timetaken(started.at),sep=": "))
}

started.at <- proc.time()
count <- length
count_distinct <- function(x) length(unique(x))
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
funs <- c("sum","mean","count","count_distinct","Mode","min","max") #dictionary
# provide values, produce names from values, format names to non underscore and capital letters of first word
translation <- function(x){
  if(is.null(x)) return(character())
  x <- setNames(x,gsub("_", " ", x, fixed = T))
  names(x) <- gsub(pattern = "\\b([a-z])", replacement = "\\U\\1", names(x), perl = TRUE)
  x
}
message(paste(as.character(Sys.time()),"defining global functions",timetaken(started.at),sep=": "))

message(paste(as.character(Sys.time()),"global.R started",timetaken(global.at),sep=": "))
