xxx_png <- png::readPNG("data/osm-tiles/_10_17099_16218.png")
xxx_jpg <- jpeg::readJPEG("data/osm-tiles/_10_17097_16220.jpg")

xxx_jpg %>% dim()
xxx_png %>% dim()

xxx_png[,,4]
grid.draw(rasterGrob(xxx_png[,,3]))
