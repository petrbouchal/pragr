## code to prepare `prg_endpoints` dataset goes here


#' IPR Map Services
#'
#' Contains information on a selection of available Prague raster map services.
#' Can be used manually to inspect services and is used internally by
#' prg_tile() and prg_basemap() for retrieving data from servers.
#'
#' @format A data frame with 18 rows and 5 variables:
#' \describe{
#'   \item{\code{name}}{character. Name of the service, to be used as parameter in prg_tile() and prg_basemap()}
#'   \item{\code{type}}{character. "tile" or "image"}
#'   \item{\code{description}}{character. Description of the map source}
#'   \item{\code{endpoint}}{character. endpoint. Used internally}
#'   \item{\code{url}}{character. URL, used internally but also points to human readable interface.}
#' }
#' @family Mapping
#' @export
"prg_endpoints"
prg_endpoints <- tibble::tribble(~name, ~type, ~description, ~endpoint, ~url,
                         "orto", "tile", "Latest aerial map", "",
                         "https://gs-pub.praha.eu/imgs/rest/services/ort/letecke_snimkovani/ImageServer",
                         "dsm", "tile", "DSM base map tile", "",
                         "https://mpp.praha.eu/arcgis/rest/services/MAP/DSM_HLS/ImageServer",
                         "dsm", "image", "DSM base map image", "",
                         "https://gs-pub.praha.eu/arcgis/rest/services/map/zakladni_mapa/MapServer",
                         "zakladni", "image", "", "",
                         "https://mpp.praha.eu/arcgis/rest/services/MAP/Zakladni_mapa/MapServer",
                         "orto", "image", "", "",
                         "https://gs-pub.praha.eu/imgs/rest/services/ort/letecke_snimkovani/ImageServer",
                         "orto_mimoveg", "tile", "", "",
                         "https://gs-pub.praha.eu/imgs/rest/services/ort/mimovegetacni_letecke_snimkovani/ImageServer",
                         "orto_mimoveg", "image", "", "",
                         "https://gs-pub.praha.eu/imgs/rest/services/ort/mimovegetacni_letecke_snimkovani/ImageServer",
                         "orto_2003", "image", "", "",
                         "https://mpp.praha.eu/arcgis/rest/services/MAP/Ortofotomapa_archiv/MapServer",
                         "orto_1945", "tile", "", "",
                         "https://tiles.arcgis.com/tiles/SBTXIEUGWbqzUecw/arcgis/rest/services/Ortofotomapa_Prahy_1945/MapServer",
                         "orto_archiv", "image", "", "",
                         "https://mpp.praha.eu/arcgis/rest/services/MAP/Ortofotomapa_archiv/MapServer",
                         "mpp_z02", "tile", "", "",
                         "https://tiles.arcgis.com/tiles/SBTXIEUGWbqzUecw/arcgis/rest/services/Z02_Hlavni_vykres/MapServer",
                         "uap", "image", "", "",
                         "https://mpp.praha.eu/arcgis/rest/services/UAP/UAP_platne/MapServer",
                         "mapy_archiv", "image", "", "",
                         "https://mpp.praha.eu/arcgis/rest/services/ARCH/Mapove_podklady_archiv/MapServer",
                         "cisarske_otisky_1840", "tile", "", "",
                         "https://mpp.praha.eu/arcgis/rest/services/ARCH/Cisarske_otisky_1440/ImageServer",
                         "cisarske_otisky_1840", "image", "", "",
                         "https://mpp.praha.eu/arcgis/rest/services/ARCH/Cisarske_otisky_1440/ImageServer",
                         "cisarske_otisky_1840_velke", "tile", "", "",
                         "https://mpp.praha.eu/arcgis/rest/services/ARCH/Cisarske_otisky_720/ImageServer",
                         "cisarske_otisky_1840_velke", "image", "", "",
                         "https://mpp.praha.eu/arcgis/rest/services/ARCH/Cisarske_otisky_720/ImageServer",
                         "pup_v4", "tile", "", "",
                         "https://mpp.praha.eu/arcgis/rest/services/PUP/PUP_v4/ImageServer") %>%
  dplyr::mutate(endpoint = dplyr::case_when(
    (stringr::str_detect(url, "/ImageServer") & type != "tile") ~ "exportImage",
    (stringr::str_detect(url, "/MapServer") & type != "tile") ~ "export",
    type == "tile" ~ ""))

usethis::use_data(prg_endpoints, overwrite = TRUE)
