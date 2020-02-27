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
hexogram_by_seed <- future_map(1:12, function(x) {
  new_cells <- calculate_grid(shape = mc_projected, grid_type = "hexagonal", seed = x)
  new_grid <- assign_polygons(mc_projected, new_cells)
  ggplot() +
    geom_sf(data = new_grid, fill = NA) +
    geom_sf(data = mc_projected, fill = NA, colour = "blue") +
    coord_sf(datum = NA)
})

library(gridExtra)
grid.arrange(grobs = hexogram_by_seed)

new_cells <- calculate_grid(shape = mc_projected, grid_type = "hexagonal", seed = 3)
district_hexogram0 <- assign_polygons(mc_projected, new_cells) %>%
  mutate(ns = str_remove(nazev, "Praha[\\-\\s]{1}") %>%
           str_sub(1,3),
         area_km = area/1e6)

unique(district_hexogram0$ns)
district_hexogram0 %>% select(ns, area_km)

plot(district_hexogram0, max.plot = 1)

regplot2 <- tm_shape(district_hexogram0) +
  tm_polygons("area_km", palette = "viridis", border.col = "white") +
  tm_text("ns")

regplot2

district_hexogram <- district_hexogram0 %>%
  mutate(label = str_remove(nazev, "Praha-") %>%
           str_replace("Přední ", "Př") %>%
           str_replace("Dolní ", "D") %>%
           str_replace("Praha ", "P") %>%
           str_replace("Kolo", "Kl") %>%
           str_sub(1, 3)) %>%
  select(kod, nazev, label, mop_kod, spo_kod, pou_kod, okres_kod,
         CENTROIX, CENTROIY, row, col)
table(district_hexogram$label)
length(unique(district_hexogram$label)) == nrow(district_hexogram)

regplotx <- tm_shape(district_hexogram) +
  tm_polygons("row", palette = "viridis", border.col = "white") +
  tm_text("label")

regplotx

usethis::use_data(district_hexogram, overwrite = T)
