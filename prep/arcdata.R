
arc_base_url <- "https://ags.arcdata.cz/arcgis/rest/services/OpenData/"
service_admin <- "AdministrativniCleneni_v12"
service_geomorph <- "ArcCR500_v32"
service_listing <- "MapServer?f=pjson"

usethis::use_data(arc_base_url, service_admin, service_geomorph, service_listing,
         internal = T, overwrite = T)

get_arcdata <- function() {}
get_arcdata_toc <- function(which = "both") {
}

get_arcdata_layerinfo <- function() {
  arc_base_url <- "https://ags.arcdata.cz/arcgis/rest/services/OpenData/"
  # https://ags.arcdata.cz/arcgis/rest/services/OpenData/AdministrativniCleneni_v12/MapServer/10?f=pjson
}

ds_list_url <- "http://arccr-arcdata.opendata.arcgis.com/datasets.json?sort_by=relevance"
