## code to prepare `district_names` dataset goes here

district_names <- district_tilegram %>%
  sf::st_set_geometry(NULL) %>%
  dplyr::select(kod, nazev, label) %>%
  dplyr::mutate(nazev_medium = stringr::str_remove(nazev, "Praha[\\-]|"),
         nazev_short = stringr::str_replace_all(nazev_medium, "(olní)|(ední)|(elká)", "."),
         nazev_spaced = stringr::str_replace(nazev, "\\-", " - "))

usethis::use_data(district_names, overwrite = TRUE)
