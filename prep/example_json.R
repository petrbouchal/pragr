library(sf)
st_read("https://ags.arcdata.cz/arcgis/rest/services/OpenData/AdministrativniCleneni_v12/MapServer/10/query?where=KOD_OBEC%20like%20%27%25554782%25%27&returnGeometry=true&outFields=*&f=json&&resultRecordCount=200") %>%
  plot(max.plot = 1)
