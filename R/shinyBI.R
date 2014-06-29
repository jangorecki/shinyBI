#' @title shinyBI package
#' @references \url{https://github.com/jangorecki/shinyBI}
#' @import plyr markdown shiny rCharts data.table
#' @docType package
#' @name shinyBI-package
NULL

#' @title Run shinyBI app
#' @description Run shinyBI app. App can perform simple Business Intelligence processes on provided denormalized data \code{DT} object.
#' @param ... params to be passed to \code{\link{runApp}}. Excluding \code{appDir} argument.
#' @param appDir param will be omitted and not passed to \code{runApp}.
#' @note In case of no DT object provided the example data will be loaded. Example data are CRAN rstudio mirror logs from 2013-11-17 to 2014-06-15 (1.6mln rows). See references for details.
#' @references \url{http://cran-logs.rstudio.com/}
#' @export
#' @examples
#' \dontrun{
#'   DT <- fread("source.csv")
#'   shinyBI()
#' }
shinyBI <- function(..., appDir = NULL){
  if(!is.null(appDir)) warning("shinyBI function do not allow to pass the appDir argument to runApp function, it will be omitted", immediate. = TRUE)
  runApp(appDir = system.file("shinyBI", package="shinyBI"), ...)
}

#' @title Make dictionary dimensions
#' @description Lookup basic time and geography dimensions. You can use it on your own dataset. Be aware you need to have \code{date # Date type} and \code{country # character type} columns in fact table \code{DT}.
#' @param DT data.table a fact table.
#' @return data.table fact table including time and/or geography dimension (depending on the input columns).
#' @note Required fields \code{date} and \code{country} can be also data types which can be directly converted using \code{as.character} and \code{as.Date}. See references for geography dim key details.
#' @references \url{http://dev.maxmind.com/geoip/legacy/codes/iso3166/}
#' @export
#' @examples
#' \dontrun{
#'   # load shinyBI sample DT 
#'   DT <- readRDS(system.file("extdata","cran_logs.rds",package="shinyBI"))
#'   DT <- makeDim(DT)
#'   shinyBI()
#'   
#'   # load dataset from csv
#'   DT <- fread("source.csv")
#'   DT <- makeDim(DT)
#'   shinyBI()
#' }
makeDim <- function(DT = NULL){
  stopifnot(!is.null(DT))
  inKey <- key(DT)
  # add geography dimension - if offline it will be omitted
  if("country" %in% names(DT)){
    if(!("character" %in% class(DT[["country"]]))) DT[,country:=as.character(country)]
    DT <- makeGeographyDim(DT)
  }
  # add time dimension
  if("date" %in% names(DT)){
    if(!("Date" %in% class(DT[["date"]]))) DT[,date:=as.Date(date)]
    DT <- makeTimeDim(DT)
  }
  # key, clean
  setkeyv(DT,unique(c(inKey,"date","country")))
  gc()
  DT
}

#' @title Translations
#' @description Format labels for UI objects.
#' @param x character vector.
#' @return named vector, user friendly names.
#' @export
#' @examples
#' \dontrun{
#'   translation(c("year_week","year_month","downloads"))
#' }
translation <- function(x){
  if(is.null(x)) return(character())
  x <- setNames(x,gsub("_", " ", x, fixed = T))
  names(x) <- gsub(pattern = "\\b([a-z])", replacement = "\\U\\1", names(x), perl = TRUE)
  x
}

#' @title makeGeographyDim
#' @description Basic geography dimension on \code{country} (\code{character}) column in \code{DT}. Use \code{\link{makeDim}} function instead.
#' @param DT data.table a fact table.
#' @export
makeGeographyDim <- function(DT){
  geography_dim <- fread(system.file("extdata", "country_continent.csv", package="shinyBI"), na.strings="--", showProgress = FALSE)
  setnames(geography_dim,c("iso 3166 country","continent code"),c("country","continent"))
  geography_dim[continent=="AF",continent:="Africa"
                ][continent=="EU",continent:="Europe"
                  ][continent=="AS",continent:="Asia"
                    ][continent=="NA",continent:="North America"
                      ][continent=="SA",continent:="South America"
                        ][continent=="AN",continent:="Antarctica"
                          ][continent=="OC",continent:="Australia"
                            ]
  setkeyv(geography_dim,"country")
  DT <- geography_dim[setkeyv(DT,"country")]
  rm(geography_dim)
  DT
}

#' @title makeTimeDim
#' @description Basic time dimension on \code{date} (\code{Date}) column in \code{DT}. Use \code{\link{makeDim}} function instead.
#' @param DT data.table a fact table.
#' @export
makeTimeDim <- function(DT){
  datelt <- as.POSIXlt(DT[,unique(date)])
  time_dim <- data.table(date = as.Date(datelt),
                         week = format(datelt,"%W"), 
                         month = format(datelt,"%m"), 
                         year = format(datelt,"%Y"),
                         week_day = format(datelt,"%u"), # requires 3.1.0
                         year_month = format(datelt,"%Y-%m"), 
                         year_week = format(datelt,"%Y-%W"),
                         key = "date")
  DT <- time_dim[setkeyv(DT,"date")]
  rm(datelt,time_dim)
  DT
}

# CRAN check NOTE prevention
if(getRversion() >= "2.15.1") utils::globalVariables(c("country","continent"))
