# tileExt.xmin = tileId.column * tileSize.cols * lod.resolution + origin.x;
# tileExt.xmax = tileExt.xmin + tileSize.cols * lod.resolution;
# tileExt.ymin = tileId.row * tileSize.rows * lod.resolution + origin.y; # NB wrong sign of origin.y
# tileExt.ymax = tileExt.ymin + tileSize.rows * lod.resolution;

# see https://developers.arcgis.com/rest/services-reference/image-tile.htm

mpp_krovak <- "+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.28813972222222 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +towgs84=589,76,480,0,0,0,0 +units=m +no_defs"

xy2krovak <- function(tileid_row, tileid_col, zoom, spec) {
  origin_x <- spec$tileInfo$origin$x
  origin_y <- spec$tileInfo$origin$y
  lod_resolution <- spec$tileInfo$lods %>% dplyr::filter(.data$level == zoom) %>% dplyr::pull(.data$resolution)
  tilesize_cols <- spec$tileInfo$cols
  tilesize_rows <- spec$tileInfo$rows
  c_xmin <- tileid_col * tilesize_cols * lod_resolution + origin_x
  c_ymin <- origin_y - tileid_row * tilesize_rows * lod_resolution
  c_ymax <- c_ymin + tilesize_rows * lod_resolution
  return(list(x_krovak = c_xmin, y_krovak = c_ymax))
}

krovak2xy <- function(x, y, zoom, spec) {
  origin_x <- spec$tileInfo$origin$x
  origin_y <- spec$tileInfo$origin$y
  lod_resolution <- spec$tileInfo$lods %>% dplyr::filter(.data$level == zoom) %>% dplyr::pull(.data$resolution)
  tilesize_cols <- spec$tileInfo$cols
  tilesize_rows <- spec$tileInfo$rows
  x_out <- (x - origin_x)/lod_resolution/tilesize_cols
  y_out <- -((y - origin_y)/lod_resolution/tilesize_rows)
  return(list(x = floor(x_out),
              y = ceiling(y_out)))
}

get_tile <- function(url, spec, bbox, verbose) {

  resp <- httr::GET(url, httr::add_headers(.headers = ua_header))

  content_type <- resp[['headers']][['content-type']]

  # build a local path
  if(verbose) print(url)
  if (stringr::str_detect(content_type, "jpe?g"))
  { image_fn <- jpeg::readJPEG
    image_ext <- "jpg"
    }
  else if (stringr::str_detect(content_type, "png"))
  { image_fn <- png::readPNG
    image_ext <- "png" }
  else
    { stop(stringr::str_glue("Unknown tile format: {content_type}")) }

  path <- raster_temp_path(url, bbox = bbox)
  local_img <- here::here(file.path("temp", "tiles", paste0(path, ".", image_ext)))

  if (!file.exists(local_img)) {
    dir.create(dirname(local_img), showWarnings = FALSE, recursive = TRUE)
    writeBin(resp[['content']], local_img)
  }
  image_fn(local_img)
}

#' Prague tiles for ggplot2 plots
#'
#' Include raster tiles for Prague in ggplot2
#'
#' @param data sf data frame from which to extract the bounding box
#' @param tile_service map service from which to draw the map (see `prg_endpoints`), or a URL of a service.
#' @param zoom zoom level, from 0 to the service's limit
#' @param alpha transparency of the tiles.
#' @param buffer distance between feature end and tile end; for EPSG 5514 in meters.
#' @param verbose display information on tile URLs and image processing.
#'
#' @return list including raster annotation layers for ggplot2
#' @family Mapping
#' @examples
#' \dontrun{
#' praha1 <- CzechData::load_RUIAN_settlement(prg_kod, "MOMC_P", WGS84 = F) %>%
#'   filter(nazev == 'Praha 1')
#'
#' ggplot() +
#' prg_tile(data = praha1, zoom = 10, alpha = .7, buffer = 200,
#'          tile_service = 'orto') +
#'   geom_sf(data = praha1, fill = alpha("red", 0.6), colour = NA) +
#'   theme_void()
#' }
#'
#' @export
#'
prg_tile <- function(data, tile_service = "orto", zoom = 6, alpha = 1, buffer = 0, verbose = F) {
  tile_services <- prg_endpoints[prg_endpoints$type == "tile",]
  service_is_url <- !(tile_service %in% tile_services$name) &
    stringr::str_detect(tile_service, "http[s]?://.*/(Map|Image)Server")
  stopifnot((tile_service %in% tile_services$name | service_is_url),
            dplyr::between(alpha, 0, 1),
            sf::st_crs(data)$epsg %in% c(5514, 102067),
            buffer >= 0, is.numeric(buffer),
            any(c('sf', 'sfc', 'sfg') %in% class(data)))
  url <- if (service_is_url) tile_service else tile_services$url[tile_services$name == tile_service]
  data <- data %>% sf::st_buffer(buffer)
  b <- sf::st_bbox(data)
  spec <- jsonlite::fromJSON(stringr::str_glue("{url}?f=pjson"))
  xy <- krovak2xy(b[c("xmin", "xmax")], b[c("ymin", "ymax")], zoom, spec)
  tiles <- expand.grid(x = seq(xy$x["xmin"], xy$x["xmax"]),
                       y = seq(xy$y["ymin"], xy$y["ymax"]))
  nw_corners <- xy2krovak(tileid_row = tiles$y, tileid_col = tiles$x, zoom, spec)
  se_corners <- xy2krovak(tileid_row = tiles$y + 1, tileid_col = tiles$x + 1, zoom, spec)
  names(nw_corners) <- c("xmin", "ymax")
  names(se_corners) <- c("xmax", "ymin")
  tile_positions <- dplyr::bind_cols(nw_corners, se_corners)

  tiles$srv_url <- url
  urls <- stringr::str_glue_data(tiles, "{srv_url}/tile/{zoom}/{y-1}/{x}")

  imgs <- purrr::map(urls, get_tile, spec, b, verbose)
  args <- tile_positions %>%
    dplyr::mutate(grob = purrr::map(imgs, function(x) {
      if(alpha < 1) {
        if(dim(x)[3] < 4) {
          if(verbose) message("Adding alpha channel to tile image.")
          x_after_alpha <- abind::abind(x, x[,,1])
          x_after_alpha[,,4] <- alpha
          } else {
            x_after_alpha <- matrix(grDevices::rgb(x[,,1],x[,,2],x[,,3], x[,,4] * alpha),
                          nrow=dim(x)[1])}
      } else {x_after_alpha <- x}
      grid::rasterGrob(x_after_alpha)}))

  # args <- tile_positions %>%
  #   dplyr::mutate(raster = imgs)
  rslt <- purrr::pmap(args, ggplot2::annotation_custom)
  if(buffer > 0) rslt <- append(rslt, ggplot2::geom_sf(data = data, colour = NA, fill = NA))
  return(rslt)
}
