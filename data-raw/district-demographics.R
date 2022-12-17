library(tidyverse)

tmp_age <- tempfile(fileext = ".xlsx")

download.file("https://www.czso.cz/documents/11236/37543548/1_PHA_VEK_obyv_mc.xlsx/30cf56c3-cf58-410c-bfd5-92e80284417a?version=1.5",
              destfile = tmp_age)
# https://www.czso.cz/csu/xa/casove-rady-za-mestske-casti-prahy > věkové složení

ranges_structure <- c(Total = "E4:W61",
                      Male = "Y4:AQ61",
                      Female = "AS4:BK61")

ranges_median_age <- c(Total = "X4:X61",
                       Male = "AR4:AR61",
                       Female = "BL4:BL61")

get_range_per_sheet <- function(range, file) {

  front <- readxl::read_excel(file, range = "A4:D61") %>%
    select(-`název správního obvodu`, -`název městské části`)

  # print(front)

  shts <- readxl::excel_sheets(file)
  names(shts) <- shts
  pxl2 <- shts %>% purrr::map_dfr(~readxl::read_excel(file,
                                                      sheet = .x, .name_repair = "none",
                                                      range = range) %>%
                                    bind_cols(front), .id = "year") %>%
    mutate(year = as.integer(year))
  # print(pxl)
  # pxl2 <- bind_cols(front, pxl)

  pxl2
}

district_age_structure <- purrr::map_dfr(ranges_structure,
                                         ~get_range_per_sheet(.x, tmp_age) %>%
                                           gather("age", "count", -KOD_ZUJ, -year, -KOD_SO) %>%
                                           mutate(age = str_replace(age, fixed("...1"), "Total"),
                                                  age = fct_relevel(age, ~str_sort(., numeric = T)),
                                                  year = as.integer(year)),
                                         .id = "sex")

district_age_structure %>%
  group_by(year) %>%
  summarise(x = n_distinct(KOD_ZUJ))

district_age_structure %>%
  count(sex, year, age) %>%
  spread(year, n)

district_age_structure %>%
  count(sex, year, age) %>%
  distinct(n)

unique(district_age_structure$sex)

levels(district_age_structure$age)

district_age_structure %>%
  mutate(tot = age == "Total") %>%
  count(year, sex, tot, wt = count) %>%
  spread(tot, n) %>%
  filter(`TRUE` != `FALSE`)

usethis::use_data(district_age_structure, overwrite = T)

district_age_median <- purrr::map_dfr(ranges_median_age, get_range_per_sheet, tmp_age, .id = "sex") %>%
  rename(median_age = `...2`) %>%
  select(-KOD_SO)

usethis::use_data(district_age_median, overwrite = T)
