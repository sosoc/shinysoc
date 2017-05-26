
#' L3 bin prepared files
#'
#' These functions return a data frame of
#' * `fullname` the path to the file
#' * `date` the day of the file (`POSIXct`)
#'
#' The files are pre-prepared using `raadtools`, making this more
#' generally available is a future goal.
#'
#' `modis_files` and `seawifs_files` are convenience wrappers around the more
#' general `soc_files`.
#'
#' @param ... ignored
#' @param platform satellite platform
#'
#' @return
#' @export
#' @importFrom raadtools chla_johnsonfiles
#' @examples
#' soc_files()
soc_files <- function(platform = "MODISA", ...) {
  raadtools::chla_johnsonfiles(product = platform)
}
modis_files <- function(...) {
  soc_files(platform = "MODISA", ...)
}
seawifs_files <- function(...) {
  soc_files(platform = "SeaWiFS", ...)
}
