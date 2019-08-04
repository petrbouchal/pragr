resize_to_longside <- function(dimc, maxsize) {
  if(max(dimc) > maxsize) {
    ratio_x <- maxsize/dimc[1]
    ratio_y <- maxsize/dimc[2]

    ratio = min(ratio_x, ratio_y)
    c(dimc[1] * ratio, dimc[2] * ratio)
  } else { dimc }
}

image_services <- list(ortofoto = list(url = "MAP/letecke_snimky_posledni_snimkovani_cache/ImageServer/exportImage",
                                  maxsizes = 5000),
                  dsm = list(url = 'MAP/DSM_HLS/ImageServer/exportImage',
                             maxsizes = 5000),
                  zakladni = list(url = 'MAP/Zakladni_mapa/MapServer/export',
                                  maxsizes = 5000),
                  ortofoto_mimovegetacni = list(url = 'MAP/mimovegetacni_snimkovani_cache/ImageServer/exportImage',
                                  maxsizes = 5000),
                  cisarske_otisky = list(url = 'ARCH/Cisarske_otisky_1440/ImageServer/exportImage',
                                  maxsizes = 5000),
                  archiv = list(url = 'ARCH/Mapove_podklady_archiv/MapServer/export',
                                  maxsizes = c(`show:8` = 900,
                                               `show:1011` = 900)),
                  orto_archiv = list(url = "MAP/Ortofotomapa_archiv/MapServer/export",
                                  maxsizes = 5000),
                  uzemni_plan = list(url = 'PUP/PUP_v4/ImageServer/exportImage'),
                  uap = list(url = 'UAP/UAP_platne/MapServer/export',
                             maxsizes = 4096))

# tiletypes$orto_archiv$maxsizes[x]
# tile_type <- 'stare'
# layer_long <- str_glue('show:{8}')
# x %in% names(tiletypes[[tile_type]][['maxsizes']])


#' Show map services available in `basemap_prg`
#'
#' @return a data frame with name and URL
#' @export
show_map_services <- function() {
  tibble::data_frame(name = names(pragr:::image_services),
             URL = purrr::map_chr(pragr:::image_services, `[[`, 'url'))
}

#' Prague base maps for ggplot2
#'
#' Include raster maps from Prague geoportal in your ggplot map
#'
#' @param data sf data frame from which to extract the bounding box
#' @param image_service map service from which to draw the map; `show_map_services()` provides a list.
#' @param layer layer from map service to use, see https://mpp.praha.eu/arcgis/rest/services/
#' @param size longer side of the downloaded image in pixels
#' @param alpha transparency
#' @param buffer distance between feature end and image end; for EPSG 5514 in meters.
#'
#' @return annotation object for ggplot
#' @examples
#' @export
#'
prg_basemap <- function(data, image_service = "ortofoto", layer = '',
                     size = 900, alpha = 1, buffer = 0) {
  stopifnot(image_service %in% names(pragr:::image_services),
            dplyr::between(alpha, 0, 1),
            sf::st_crs(data)$epsg %in% c(5514, 102067),
            buffer >= 0, is.numeric(buffer),
            any(c('sf', 'sfc', 'sfg') %in% class(data)))
  service_spec <- pragr:::image_services[[image_service]]
  if(layer != '') layer <- stringr::str_glue("show:{layer}")
  if(layer %in% names(service_spec[['maxsizes']])) {
    message('restricting size to server max for layer')
    maxsize <- min(service_spec[['maxsizes']][[layer]], size)
  } else {
    maxsize <- min(5000, size)
  }
  data <- data %>% sf::st_buffer(buffer)
  bbx_uz <- sf::st_bbox(data)
  bbox_uz <- sf::st_bbox(data) %>% paste0(collapse = ",")
  ratio <- ((bbx_uz$ymin - bbx_uz$ymax)/(bbx_uz$xmin - bbx_uz$xmax)) %>% unname()
  distx <- abs(bbx_uz$xmin - bbx_uz$xmax) %>% unname()
  img_w = round(distx * 1.3)
  img_h = round(img_w * ratio)
  newdims <- pragr:::resize_to_longside(c(img_w, img_h), maxsize)
  img_w_new <- newdims[1] %>% floor()
  img_h_new <- newdims[2] %>% floor()
  url <- stringr::str_glue("https://mpp.praha.eu/arcgis/rest/services/{service_spec[['url']]}?bbox={bbox_uz}&&size={img_w_new},{img_h_new}&layers={layer}&time=&format=png&pixelType=C128&noData=&noDataInterpretation=esriNoDataMatchAny&interpolation=+RSP_BilinearInterpolation&compression=&compressionQuality=&bandIds=&mosaicRule=&renderingRule=&f=image&dpi=200&bboxSR=102067&imageSR=102067")
  tmpfile <- tempfile()
  utils::download.file(url, tmpfile)
  x <- png::readPNG(tmpfile)
  # https://stackoverflow.com/questions/11357926/r-add-alpha-value-to-png-image
  if(alpha < 1) {
    if(dim(x)[3] < 4) {
      message("Adding alpha channel to basemap image.")
      x_after_alpha <- abind::abind(x, x[,,1])
      x_after_alpha[,,4] <- alpha
    } else {
      x_after_alpha <- matrix(grDevices::rgb(x[,,1],x[,,2],x[,,3], x[,,4] * alpha),
                              nrow=dim(x)[1])}
  } else {x_after_alpha <- x}
  # https://drmowinckels.io/blog/adding-external-images-to-plots/
  ccx <- 0
  ccy <- 0
  rslt <- ggplot2::annotation_raster(raster = x_after_alpha, xmin = bbx_uz$xmin - ccx, xmax = bbx_uz$xmax + ccx,
                    ymin = bbx_uz$ymin - ccy, ymax = bbx_uz$ymax + ccy)
  if(buffer > 0) rslt <- append(rslt, ggplot2::geom_sf(data = data, colour = NA, fill = NA))
  return(rslt)
}

