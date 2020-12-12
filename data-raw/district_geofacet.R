## code to prepare `geofacet` dataset goes here
library(geofacet)
library(dplyr)
library(purrr)
library(CzechData)

phamc0 <- CzechData::load_RUIAN_settlement("554782", "MOMC_P")

phamc <- phamc0 %>%
 select(kod, nazev)

grid_manual <- pragr::district_tilegram %>%
 mutate(cntr = st_centroid(geometry),
        cntr_x = map_dbl(cntr, `[[`, 1) %>% round(),
        cntr_y = map_dbl(cntr, `[[`, 2) %>% round()) %>%
 mutate(col = dense_rank(cntr_x),
        row = dense_rank(desc(cntr_y))) %>%
 select(row, col, name = label, code = kod) %>%
 st_set_geometry(NULL)

plot(pragr::district_tilegram, max.plot = 1)

grid_preview(grid_manual, label = "name")

district_geofacet <- grid_manual

usethis::use_data(district_geofacet, overwrite = TRUE)
