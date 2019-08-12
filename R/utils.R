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
