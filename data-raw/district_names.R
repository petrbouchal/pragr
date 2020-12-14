## code to prepare `district_names` dataset goes here

library(pragr)

district_names <- district_tilegram %>%
  sf::st_set_geometry(NULL) %>%
  dplyr::select(code = kod, name = nazev, label) %>%
  dplyr::mutate(name_medium = stringr::str_remove(name, "Praha[\\-]|"),
                name_short = stringr::str_replace_all(name_medium, "(olní)|(ední)|(elká)", "."),
                name_spaced = stringr::str_replace(name, "\\-", " - ")) %>%
  mutate(across(starts_with("name"), ~fct_relevel(., ~str_sort(., numeric = T))))

usethis::use_data(district_names, overwrite = TRUE)
