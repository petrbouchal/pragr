library(sf)
library(CzechData)

prg_polygon <- CzechData::load_RUIAN_settlement(prg_kod, layer = "obec")
st_crs(prg_polygon)


#' Prague bbox in EPSG 5514 (Krovak)
#'
#' Prague bbox in EPSG 5514 (Krovak)
#'
#' @format named numeric of class `bbox`, length 4
#' \describe{
#'   Prague RUIAN code
#' }
#' @export
"prg_bbox_krovak"
prg_bbox_krovak <- sf::st_bbox(prg_polygon)
usethis::use_data(prg_bbox_krovak, overwrite = T)


#' Prague bbox in EPSG 4326 (WGS 84)
#'
#' Prague bbox in EPSG 4326 (WGS 84)
#'
#' @format named numeric of class `bbox`, length 4
#' \describe{
#'   Prague RUIAN code
#' }
#' @export
"prg_bbox_wgs84"
prg_bbox_wgs84 <- sf::st_bbox(prg_polygon %>% st_transform(4326))
usethis::use_data(prg_bbox_wgs84, overwrite = T)
