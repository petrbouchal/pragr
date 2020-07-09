library(sf)
library(geogrid)
library(dplyr)
library(ggplot2)
library(stringr)
library(furrr)
library(CzechData)
library(tmap)

# praha_hranice_url <- "http://opendata.iprpraha.cz/CUR/DTMP/PRAHA_P/WGS_84/PRAHA_P.json"
# praha_hranice_mc_url <- "http://opendata.iprpraha.cz/CUR/DTMP/TMMESTSKECASTI_P/WGS_84/TMMESTSKECASTI_P.json"

# pha <- read_sf(praha_hranice_url)
pha <- CzechData::load_RUIAN_settlement(prg_kod, "obec")
# mc <- read_sf(praha_hranice_mc_url)
mc <- CzechData::load_RUIAN_settlement(prg_kod, "MOMC_P")
mc_projected <- mc %>% st_transform(5514) %>%
  st_cast("MULTIPOLYGON") %>%
  mutate(area = st_area(geometry))

# par(mfrow = c(3, 4), mar = c(0, 0, 2, 0))
# for (i in 1:12) {
#   new_cells <- calculate_grid(shape = mc_projected, grid_type = "hexagonal", seed = i)
#   plot(new_cells, main = paste("Seed", i, sep = " "))
# }

plan("multiprocess")
tilegram_by_seed <- future_map(1:12, function(x) {
  new_cells <- calculate_grid(shape = mc_projected, grid_type = "regular", seed = x)
  new_grid <- assign_polygons(mc_projected, new_cells)
  ggplot() +
    geom_sf(data = new_grid, fill = NA) +
    geom_sf(data = mc_projected, fill = NA, colour = "blue") +
    coord_sf(datum = NA)
})

library(gridExtra)
grid.arrange(grobs = tilegram_by_seed)

new_cells <- calculate_grid(shape = mc_projected, grid_type = "regular", seed = 1)
district_tilegram0 <- assign_polygons(mc_projected, new_cells) %>%
  mutate(ns = str_remove(nazev, "Praha[\\-\\s]{1}") %>%
           str_sub(1,3),
         area_km = area/1e6)

unique(district_tilegram0$ns)
district_tilegram0 %>% select(ns, area_km)

plot(district_tilegram0, max.plot = 1)

regplot2 <- tm_shape(district_tilegram0) +
  tm_polygons("area_km", palette = "viridis", border.col = "white") +
  tm_text("ns")

regplot2

district_tilegram <- district_tilegram0 %>%
  mutate(label = str_remove(nazev, "Praha-") %>%
           str_replace("Přední ", "Př") %>%
           str_replace("Dolní ", "D") %>%
           str_replace("Praha ", "P") %>%
           str_replace("Kolo", "Kl") %>%
           str_sub(1, 3)) %>%
  select(kod, nazev, label, mop_kod, sop_kod, pou_kod, okres_kod,
         CENTROIX, CENTROIY, row, col) %>%
  sf::st_as_sf()
table(district_tilegram$label)
length(unique(district_tilegram$label)) == nrow(district_tilegram)

regplotx <- tm_shape(district_tilegram) +
  tm_polygons("row", palette = "viridis", border.col = "white") +
  tm_text("label")

regplotx

regploty <- tm_shape(district_tilegram) +
  tm_polygons("row", palette = "viridis", border.col = "white") +
  tm_text("label")

regploty

usethis::use_data(district_tilegram, overwrite = T)
