library(sf)
library(tidyverse)
library(ggplot2)
library(pragr)

mpp_gdb_path <- "~/Desktop/IPR docs/MetroPlan/zavazna_cast.gdb/" # lokální
# mpp_gdb_path <- "/Volumes/disku/Pracovni.050-MetropolitniPlan/Geodata/DATOVY_MODEL/NAVRH K PROJEDNANI/Y_DATOVE SADY/vydej_porizovatel/zavazna_regulacni_cast.gdb" # disk IPR
mpp_krovak <- "+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.28813972222222 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +towgs84=589,76,480,0,0,0,0 +units=m +no_defs"
lokality <- st_read(mpp_gdb_path,
                    "MPP_300_Lokality_p", stringsAsFactors = F) %>%
  st_transform(mpp_krovak) %>%
  st_transform(5514)

lk <- lokality %>% filter(CISLO_TXT %in% c('041', '001')) %>%
  st_simplify(preserveTopology = T,dTolerance = 15)

ggplot() +
  prg_tile(data = lk, zoom = 10, alpha = .5, buffer = 800, verbose = T,
           tile_service = 'https://mpp.praha.eu/arcgis/rest/services/PUP/PUP_v4/ImageServer') +
  geom_sf(data = lk, fill = alpha("red", 0.6), colour = NA) +
  # geom_sf(data = lk %>% st_buffer(800), fill = NA, colour = "black") +
  theme_void()

ggplot() +
  prg_basemap(data = lk, alpha = .5, size = 450, buffer = 300, verbose = T,
           image_service = 'archiv', layer = 8) +
  geom_sf(data = lk, colour = alpha("red", 0.3), fill = NA) +
  theme_void()

ggplot() +
  prg_basemap(data = lk, alpha = .5, size = 450, buffer = 1000,
           image_service = 'ortofoto', layer = 8) +
  geom_sf(data = lk, colour = alpha("red", 0.3), fill = NA) +
  theme_void()
