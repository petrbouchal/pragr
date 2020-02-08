library(sf)
library(CzechData)

prg_polygon <- CzechData::load_RUIAN_settlement(prg_kod, layer = "obec")
st_crs(prg_polygon)

prg_bbox_krovak <- sf::st_bbox(prg_polygon)
usethis::use_data(prg_bbox_krovak, overwrite = T)

prg_bbox_wgs84 <- sf::st_bbox(prg_polygon %>% st_transform(4326))
usethis::use_data(prg_bbox_wgs84, overwrite = T)
