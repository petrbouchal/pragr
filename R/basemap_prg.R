# tiletypes$orto_archiv$maxsizes[x]
# tile_type <- 'stare'
# layer_long <- str_glue('show:{8}')
# x %in% names(tiletypes[[tile_type]][['maxsizes']])

#' Prague base maps for ggplot2
#'
#' Include raster maps from Prague geoportal in your ggplot map
#'
#' @param data sf data frame from which to extract the bounding box
#' @param image_service map service from which to draw the map; `prg_endpoints` provides details.
#' @param layer layer from map service to use, see https://mpp.praha.eu/arcgis/rest/services/
#' @param width width in pixels, in effect sets image resolution; integer or "max"
#' @param alpha transparency of the tile
#' @param buffer distance between feature end and image end; for EPSG 5514 in meters.
#' @param verbose display information on image URLs and image processing.
#'
#' @return list including raster annotation layers for ggplot2
#' @family Mapping
#' @examples
#' \dontrun{
#' praha1 <- CzechData::load_RUIAN_settlement(prg_kod, "MOMC_P", WGS84 = F) %>%
#'   filter(nazev == 'Praha 1')
#'
#' ggplot() +
#'   prg_basemap(data = praha1, alpha = .8, buffer = 200,
#'               image_service = 'mapy_archiv', layer = 6) +
#'   geom_sf(data = praha1, fill = alpha("red", 0.6), colour = NA) +
#'   theme_void()
#' }
#' @export
#'
prg_basemap <- function(data, image_service = "orto", layer = '',
                     width = 900, alpha = 1, buffer = 0, verbose = F) {
  image_services <- prg_endpoints[prg_endpoints$type == "image",]
  service_is_url <- !(image_service %in% image_services$name) &
    stringr::str_detect(image_service, "http[s]?://.*/(Image|Map)Server")
  stopifnot((image_service %in% image_services$name | service_is_url),
            is.numeric(width) | width == "max",
            dplyr::between(alpha, 0, 1),
            sf::st_crs(data)$epsg %in% c(5514, 102067),
            buffer >= 0, is.numeric(buffer),
            any(c('sf', 'sfc', 'sfg') %in% class(data)))
  if (service_is_url) {
    url <- image_service
    endpoint <- if (stringr::str_detect(image_service, "MapServer")) "export" else "exportImage"
  } else {
    url <- image_services$url[image_services$name == image_service]
    endpoint <- image_services$endpoint[image_services$name == image_service]
    }
  service_spec <- jsonlite::fromJSON(stringr::str_glue("{url}?f=pjson"))
  if(layer != '') layer_for_url <- stringr::str_glue("show:{layer}") else
    layer_for_url <- layer
  data <- data %>% sf::st_buffer(buffer)
  bbx_uz <- sf::st_bbox(data)
  bbox_uz <- sf::st_bbox(data) %>% paste0(collapse = ",")
  ratio <- ((bbx_uz$ymin - bbx_uz$ymax)/(bbx_uz$xmin - bbx_uz$xmax)) %>% unname()
  distx <- abs(bbx_uz$xmin - bbx_uz$xmax) %>% unname()
  img_w = round(width)
  if (width == "max") {
    img_w <- service_spec$maxImageWidth
    img_h <- img_w * ratio
  } else {
    img_w = round(width)
    img_h = round(img_w * ratio)
  }
  newdims <- constrain_dimensions(img_w, img_h,
                                  service_spec$maxImageWidth, service_spec$maxImageHeight,
                                  verbose)
  img_w_new <- newdims[1] %>% floor()
  img_h_new <- newdims[2] %>% floor()
  url <- stringr::str_glue("{url}/{endpoint}?bbox={bbox_uz}&&size={img_w_new},{img_h_new}&layers={layer_for_url}&time=&format=png&pixelType=C128&noData=&noDataInterpretation=esriNoDataMatchAny&interpolation=+RSP_BilinearInterpolation&compression=&compressionQuality=&bandIds=&mosaicRule=&renderingRule=&f=image&dpi=200&bboxSR=102067&imageSR=102067")
  path <- raster_temp_path(url, bbox = bbx_uz)
  local_img <- here::here(file.path("temp", "tiles", paste0(path, ".", "png")))

  if (!file.exists(local_img)) {
    dir.create(dirname(local_img), showWarnings = FALSE, recursive = TRUE)

    # add header
    h <- curl::new_handle()
    curl::handle_setheaders(h, .list = ua_header)

    curl::curl_download(url, destfile = local_img, quiet = !verbose)
  }
  x <- png::readPNG(local_img)
  # https://stackoverflow.com/questions/11357926/r-add-alpha-value-to-png-image
  if(alpha < 1) {
    if(dim(x)[3] < 4) {
      if(verbose) message("Adding alpha channel to basemap image.")
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

