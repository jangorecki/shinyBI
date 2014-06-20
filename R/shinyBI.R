#' @title Run shinyBI app
#'
#' @description Run shinyBI app. Read in-App manual.
#' 
#' @param ... \code{runApp} params.
#' 
#' @export
#' @examples
#' \dontrun{
#'   shinyBI()
#'   shinyBI(launch.brower = FALSE)
#' }
shinyBI <- function(...){
  shiny::runApp(appDir = system.file("shinyBI", package="shinyBI"), ...)
}
