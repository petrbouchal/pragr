library(sf)
library(tidyverse)
library(grid)
# remotes::install_github("yonghah/esri2sf")
# esri2sf::esri2sf("https://mpp.praha.eu/arcgis/rest/services/FS/verejne_toalety/MapServer/0") %>% plot(max.plot = 1)

# https://tiles.arcgis.com/tiles/SBTXIEUGWbqzUecw/arcgis/rest/services/Z02_Hlavni_vykres/MapServer/tile/9/12823/12166?token=
# https://tiles.arcgis.com/tiles/SBTXIEUGWbqzUecw/arcgis/rest/services/Z02_Hlavni_vykres/MapServer
# https://developers.arcgis.com/rest/services-reference/image-tile.htm
# https://yutani.rbind.io/post/2018-06-09-plot-osm-tiles/

srv_url <- "https://tiles.arcgis.com/tiles/SBTXIEUGWbqzUecw/arcgis/rest/services/Ortofotomapa_Prahy_1945/MapServer"

mpp_tile_spec <- fromJSON(str_glue("{srv_url}?f=pjson"))


# tileid_row <- 12823
# tileid_col <- 12166

# tileExt.xmin = tileId.column * tileSize.cols * lod.resolution + origin.x;
# tileExt.xmax = tileExt.xmin + tileSize.cols * lod.resolution;
# tileExt.ymin = tileId.row * tileSize.rows * lod.resolution + origin.y; # NB wrong sign of origin.y
# tileExt.ymax = tileExt.ymin + tileSize.rows * lod.resolution;

# tileId.column = (tileExt.xmin - origin.x) / tileSize.cols/lod.resolution
# tilex
#
#

mpp_gdb_path <- "~/Desktop/IPR docs/MetroPlan/zavazna_cast.gdb/" # lokální
# mpp_gdb_path <- "/Volumes/disku/Pracovni.050-MetropolitniPlan/Geodata/DATOVY_MODEL/NAVRH K PROJEDNANI/Y_DATOVE SADY/vydej_porizovatel/zavazna_regulacni_cast.gdb" # disk IPR
mpp_krovak <- "+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.28813972222222 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +towgs84=589,76,480,0,0,0,0 +units=m +no_defs"
lokality <- st_read(mpp_gdb_path,
                    "MPP_300_Lokality_p", stringsAsFactors = F) %>%
  st_transform(mpp_krovak)

xy2krovak <- function(tileid_row, tileid_col, zoom, spec) {
  mpp_tile_spec <- spec
  origin_x <- mpp_tile_spec$tileInfo$origin$x
  origin_y <- mpp_tile_spec$tileInfo$origin$y
  lod_resolution <- mpp_tile_spec$tileInfo$lods %>% filter(level == zoom) %>% pull(resolution)
  tilesize_cols <- mpp_tile_spec$tileInfo$cols
  tilesize_rows <- mpp_tile_spec$tileInfo$rows
  c_xmin <- tileid_col * tilesize_cols * lod_resolution + origin_x
  c_ymin <- origin_y - tileid_row * tilesize_rows * lod_resolution
  c_ymax <- c_ymin + tilesize_rows * lod_resolution
  print(c_ymin)
  print(c_ymax)
  return(list(x_krovak = c_xmin, y_krovak = c_ymax))
}

krovak2xy <- function(x, y, zoom, spec) {
  mpp_tile_spec <- spec
  origin_x <- mpp_tile_spec$tileInfo$origin$x
  origin_y <- mpp_tile_spec$tileInfo$origin$y
  lod_resolution <- mpp_tile_spec$tileInfo$lods %>% filter(level == zoom) %>% pull(resolution)
  lod_scale <- mpp_tile_spec$tileInfo$lods %>% filter(level == zoom) %>% pull(scale)
  tilesize_cols <- mpp_tile_spec$tileInfo$cols
  tilesize_rows <- mpp_tile_spec$tileInfo$rows
  x_out <- (x - origin_x)/lod_resolution/tilesize_cols
  y_out <- -((y - origin_y)/lod_resolution/tilesize_rows)
  return(list(x = floor(x_out),
              y = ceiling(y_out)))
}

get_tile <- function(url) {
  # build a local path
  print(url)
  path <- stringr::str_extract(url, "/\\d+/\\d+/\\d+") %>%
    str_replace_all("/", "_")
  local_png <- here::here(file.path("data", "osm-tiles", paste0(path, ".png")))

  if (!file.exists(local_png)) {
    dir.create(dirname(local_png), showWarnings = FALSE, recursive = TRUE)

    # add header
    h <- curl::new_handle()
    curl::handle_setheaders(h, `User-Agent` = "Yutani's blog post")

    curl::curl_download(url, destfile = local_png)
  }
  # png::readPNG(local_png)
  jpeg::readJPEG(local_png)
}

lk <- lokality %>% filter(CISLO_TXT %in% c('001')) %>%
  st_simplify(preserveTopology = T,dTolerance = 15)
b <- st_bbox(lk)
corners <- expand.grid(x = b[c(1, 3)], y = b[c(2, 4)])
zoom <- 12
xy <- krovak2xy(b[c("xmin", "xmax")], b[c("ymin", "ymax")], zoom)
xy
tiles <- expand.grid(x = seq(xy$x["xmin"], xy$x["xmax"]),
                     y = seq(xy$y["ymin"], xy$y["ymax"]))

tiles
nw_corners <- xy2krovak(tileid_row = tiles$y, tileid_col = tiles$x, zoom)
se_corners <- xy2krovak(tileid_row = tiles$y + 1, tileid_col = tiles$x + 1, zoom)
names(nw_corners) <- c("xmin", "ymax")
names(se_corners) <- c("xmax", "ymin")
tile_positions <- bind_cols(nw_corners, se_corners)
tile_pos <- tile_positions %>% bind_cols(tiles)

ggplot(lk) +
  geom_sf() +
  geom_rect(data = tile_pos,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            colour = "blue", fill = "transparent") +
  geom_text(data = tile_pos, size = 3, aes(label = paste0(x, "\n", y),
                                  x = xmax - (xmax-xmin)/2,
                                  y = ymax - (ymax-ymin)/2)) +
  annotate("rect", xmin = b["xmin"], xmax = b["xmax"], ymin = b["ymin"], ymax = b["ymax"],
           colour = alpha("red", 0.4), fill = "transparent", linetype = "dashed", size = 1.2) +
  geom_point(aes(x, y), corners[2:3,], colour = "red", size = 5) +
  geom_point(aes(x, y), corners[2:3,], colour = "red", size = 5) +
  theme_void()

# ggplot() +
#   geom_rect(data = tile_pos,
#                          aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
#                          colour = "blue", fill = "transparent")
#
# download.file(str_glue("https://tiles.arcgis.com/tiles/SBTXIEUGWbqzUecw/arcgis/rest/services/Z02_Hlavni_vykres/MapServer/tile/13/{tiles$x[1]}/{tiles$y[1]}?token="), "tile.png")
urls <- sprintf("https://tiles.arcgis.com/tiles/SBTXIEUGWbqzUecw/arcgis/rest/services/Z02_Hlavni_vykres/MapServer/tile/%d/%d/%d", zoom, tiles$y-1, tiles$x)

tiles$srv_url <- srv_url
urls <- str_glue_data(tiles, "{srv_url}/tile/{zoom}/{y-1}/{x}")

pngs <- map(urls, get_tile)
args <- tile_positions %>%
  mutate(grob = map(pngs, rasterGrob))

args <- tile_positions %>%
  mutate(raster = pngs)

ggplot() +
  tile_prg(data = lk, zoom = 12, url = srv_url) +
  geom_sf(data = lk, fill = alpha("red", 0.3)) +
  theme_void()
