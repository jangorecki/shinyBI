#' shinyBI package
#' 
#' @references \link{https://github.com/jangorecki/shinyBI}
#' @import plyr markdown shiny rCharts data.table
#' @docType package
#' @name shinyBI-package
NULL

#' @title Run shinyBI app
#'
#' @description Run shinyBI app. App can perform simple Business Intelligence processes on provided denormalized data \code{DT} object.
#' 
#' @param ... params to be passed to \code{\link{runApp}}. Excluding code{appDir} argument.
#' @param appDir param will be omitted and not passed to \code{runApp}.
#' 
#' @note In case of no DT object provided the example data will be loaded. Example data are CRAN rstudio mirror logs from 2013-11-17 to 2014-06-15 (1.6mln rows). See references for details.
#' 
#' @references \link{http://cran-logs.rstudio.com/}
#' 
#' @export
#' @examples
#' \dontrun{
#'   DT <- fread("source.csv")
#'   shinyBI()
#' }
shinyBI <- function(..., appDir = NULL){
  if(!is.null(appDir)) warning("shinyBI function do not allow to pass the appDir argument to runApp function, it will be omitted", immediate. = TRUE)
  runApp(appDir = system.file("shinyBI", package="shinyBI"), ...)
  #runApp(appDir = "inst/shinyBI", ...)
}
