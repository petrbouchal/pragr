library(stringr)

url <- "https://mpp.praha.eu/arcgis/rest/services/PUP/PUP_v4/ImageServer"

tiledir <- str_extract(url, "(?<=services/).*(?=(/(Image)|(Map)Server))") %>%
  str_replace("_", "-") %>%
  str_replace("/", "_")

