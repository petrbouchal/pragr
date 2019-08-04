library(CzechData)
library(tidyverse)
# pak::pkg_install("dmi3kno/bunny")
library(bunny)
library(magick)

# https://pkgdown.r-lib.org/reference/build_favicon.html
# https://pkgdown.r-lib.org/reference/build_home.html
# https://www.ddrive.no/post/making-hex-and-twittercard-with-bunny-and-magick/

reky <- CzechData::load_Data200("VodniTokNad50m")
praha <- CzechData::load_RUIAN_settlement(pragr::prg_kod, "obec", WGS84 = F) %>%
  st_simplify(dTolerance = 100)
vltava <- reky %>%
  filter(NAMN1 %in% c("Vltava", "Berounka")) %>%
  filter(lengths(st_intersects(geometry, praha)) > 0) %>%
  mutate(buffer = ifelse(NAMN1 == "Vltava", 300, 100)) %>%
  st_buffer(.$buffer) %>%
  st_union()

plot(vltava, max.plot = 1)

hex_canvas <- image_canvas_hex(border_color="grey", border_size = 2, fill_color = "#000000")
hex_border <- image_canvas_hexborder(border_color="grey", border_size = 4)
hex_canvas

ggplot() +
  geom_sf(data = praha, colour = NA, fill = 'white') +
  geom_sf(data = vltava, size = 1, colour = NA, fill = "black", linejoin = 'bevel') +
  theme_void()
ggsave("temp/praha_for_hex.png",width = 12, height = 10, units = "cm",
       bg = "transparent")

praha_for_hex <- image_read("temp/praha_for_hex.png")
img_hex <- hex_canvas %>%
  bunny::image_compose(praha_for_hex, gravity = "north", offset = "+0+220") %>%
  image_annotate("pragr", size=300, gravity = "south", location = "+0+300",
                 font = "Trivia Serif 10", color = "white") %>%
  bunny::image_compose(hex_border, gravity = "center", operator = "Over")

img_hex %>%
  image_convert("png") %>%
  image_write("prep/logo.png")
img_hex %>%
  image_scale("300x300")

img_hex %>%
  image_scale("1200x1200") %>%
  image_write(here::here("prep", "logo_hex_large.png"), density = 600)

img_hex %>%
  image_scale("200x200") %>%
  image_write(here::here("logo.png"), density = 600)

img_hex %>%
  image_scale("400x400") %>%
  image_write(here::here("logo.png"), density = 600)

img_hex_gh <- img_hex %>%
  image_scale("400x400")

gh_logo <- bunny::github %>%
  image_scale("50x50")

gh <- image_canvas_ghcard("black") %>%
  image_compose(img_hex_gh, gravity = "East", offset = "+100+0") %>%
  image_annotate("For mapping Prague", gravity = "West", location = "+100-30",
                 color="white", size=60, font="Fira Sans") %>%
  image_compose(gh_logo, gravity="West", offset = "+100+40") %>%
  image_annotate("petrbouchal/pragr", gravity="West", location="+160+45",
                 size=50, font="Fira Sans", color = "grey") %>%
  image_border_ghcard("grey")

gh

gh %>%
  image_write(here::here("prep", "pragr_ghcard.png"))
