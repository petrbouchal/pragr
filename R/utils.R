constrain_dimensions <- function(width, height, max_width, max_height, verbose) {
  stopifnot(width > 0, height > 0, max_height > 0, max_width > 0)
  constraining <- FALSE
  if(width > max_width & height <= max_height) {
    new_width <- max_width
    new_height <- height*(max_width/width)
    constraining <- TRUE
  } else if (width <= max_width & height > max_height) {
    new_height <- max_height
    new_width <- width * (max_height/height)
    constraining <- TRUE
  } else if (width <= max_width & height <= max_height) {
    new_width <- width
    new_height <- height
  } else if(width > max_width & height > max_width) {
    if(width/max_width > height/max_height) {
      new_width <- max_width
      new_height <- height * (max_width/width)
    } else {
      new_height <- max_height
      new_width <- width * (max_height/height)
    }
    constraining <- TRUE
  }
  if (verbose & constraining) message("Downsizing image to max size")
  return(c(new_width, new_height))
}

raster_temp_path <- function(url, layer = 0,
                             size = 0, image_ext = "png", bbox = c(0,0,0,0)) {
  service_id <- stringr::str_extract(url, "(?<=services/).*(?=(/(Image)|(Map)Server))") %>%
    stringr::str_replace("_", "-") %>%
    stringr::str_replace("/", "_")

  bbox_str <- stringr::str_c(bbox, collapse = "-")

  tile <- stringr::str_detect(url, "/\\d+/\\d+/\\d+")

  if(tile) tileid <- stringr::str_extract(url, "/\\d+/\\d+/\\d+") %>%
    stringr::str_replace_all("/", "-") %>%
    stringr::str_remove("^-")
  if(tile) filename <- stringr::str_glue("{service_id}__{layer}__{tileid}")
  else filename <- stringr::str_glue("{service_id}__{layer}__{size}__{bbox_str}")

  return(filename)
}
