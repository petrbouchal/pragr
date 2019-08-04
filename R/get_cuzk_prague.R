#' Download GML geodata file for Prague from CUZK
#'
#' @param date Date of file, must be last day of month. Defaults to end of previous month.
#' @param path Where to save the downloaded zip file and unzipped xml file
#' @param cachetime Redownload if the zip file found in path exists and is older than cachetime. Defaults to 32. Set to 0 to always redownload. Only checks existence and timestamp of downloaded zip file, not unzipped file.
#' @keywords internal
#' @return string Path to downloaded and unzipped file incl. path
get_cuzk_prague <- function(date = strftime(lubridate::rollback(Sys.Date()),
                                                                format = "%Y%m%d"),
                            path = ".",
                            cachetime = 32) {
  # from http://vdp.cuzk.cz/vdp/ruian/vymennyformat/vyhledej
  obeckod <- "554782"
  # obeckod <- "582433" # Svinosice: smaller for testing purposes
  dlurl <- paste0("https://vdp.cuzk.cz/vymenny_format/soucasna/",
                  date,"_OB_", obeckod,"_UKSH.xml.zip")

  if (file.exists(paste0(path, "/cuzk_praha.xml.zip"))) {
    if(Sys.time() - file.info(paste0(path, "/cuzk_praha.xml.zip"))$mtime > cachetime * 24 * 60) {
      message("file is old, downloading")
      rslt <- utils::download.file(dlurl,
                    destfile = paste0(path, "/cuzk_praha.xml.zip"))
       }
    else {
      message("file downloaded recently, not downloading")
      rslt <- paste0(path, "/cuzk_praha.xml.zip")
    }
  }
  else {
    message("file not yet downloaded, downloading")
    utils::download.file(url = dlurl, destfile = paste0(path, "/cuzk_praha.xml.zip"))
  }
  utils::unzip(paste0(path, "/cuzk_praha.xml.zip"), overwrite = T, exdir = path)
  rslt <- utils::unzip(paste0(path, "/cuzk_praha.xml.zip"), list = T)
  return(paste0(path, "/", rslt$Name))
}

# get_cuzk_prague(cachetime = 0, path = "data-raw")
