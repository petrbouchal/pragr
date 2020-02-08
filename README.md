
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pragr: use Prague geodata in R <a href='https://petrbouchal.github.io/pragr'><img src='man/figures/logo.png' align="right" height="138.5" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/petrbouchal/pragr.svg?branch=master)](https://travis-ci.org/petrbouchal/pragr)
[![CRAN
status](https://www.r-pkg.org/badges/version/pragr)](https://CRAN.R-project.org/package=pragr)
<!-- badges: end -->

> Note: this is the documentation for the latest released version (the
> github release). Documentation for the current development version
> (reflecting the state of the master branch) is at
> <https://petrbouchal.github.io/pragr/dev>

`pragr` aims to provide tools for visualising data about Prague.
Currently, it makes Prague raster geodata accessible for use in R via
`ggplot2`.

It also provides a set of utilities and shortcuts for making handling
data about Prague easier.

## Installation

You can install the current version of `pragr` from GitHub with:

``` r
remotes::install_github("petrbouchal/pragr")
```

## What it does

Currently, the 📦 enables you to do two things:

1)  Add raster tiles from the Prague geoopen data portal to a `ggplot2`
    object (`prg_tile()`)
2)  Add other raster layer to a `ggplot2` object (`prg_basemap()`)

The basic logic of these two functions is that given a simple feature
dataset, they provide the tiles or image to create the base map for
those coordinates.

It relies on the REST API of ArcGis map/image services that power the
geoportal, using documentation for the following operations (endpoints):

  - [Image Tile
    endpoint](https://developers.arcgis.com/rest/services-reference/image-tile.htm)
  - [Export Image
    endoint](https://developers.arcgis.com/rest/services-reference/export-image.htm)
  - [Export Map (image)
    endpoint](https://developers.arcgis.com/rest/services-reference/export-map.htm)

The approach draws heavily on code provided by
@[yutannihilation](https://github.com/yutannihilation) in his [blog
post](https://yutani.rbind.io/post/2018-06-09-plot-osm-tiles/) on using
OpenStreetMap tiles in 📦 `ggplot2`.

The approach should be generalisable to other ArcGis-driven servers with
the same REST API, though the package as it now is assumes a projected
CRS measured in meters, specifically the Krovak crs (EPSG 5514).

# Usage

``` r
library(pragr)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(sf)
#> Linking to GEOS 3.6.1, GDAL 2.1.3, PROJ 4.9.3
library(ggplot2)
```

``` r
praha1 <- CzechData::load_RUIAN_settlement(prg_kod, "MOMC_P", WGS84 = F) %>% 
  filter(nazev == 'Praha 1')
```

``` r
ggplot() +
  prg_tile(data = praha1, zoom = 10, alpha = .7, buffer = 200,
           tile_service = 'orto') + 
  geom_sf(data = praha1, fill = alpha("red", 0.6), colour = NA) +
  theme_void()
```

<img src="man/figures/README-example-tiles-1.png" width="100%" />

``` r
ggplot() +
  prg_basemap(data = praha1, alpha = .8, buffer = 200,
              image_service = 'mapy_archiv', layer = 6) + 
  geom_sf(data = praha1, fill = alpha("red", 0.6), colour = NA) +
  theme_void()
```

<img src="man/figures/README-example-base-1.png" width="100%" />

# What’s in a name?

The name of the package refers to [Karel
Prager](https://en.wikipedia.org/wiki/Karel_Prager), a renowned Czech
modernist architect. Among other things, he designed - and for a long
time worked in - the office buildings in which the [Institute for
Planning and Development](https://iprpraha.cz), Prague’s public urban
planning body, is housed today.

The institute’s excellent data team develops and maintains the data and
software infrastructure for Prague’s geographical data on which this
package - and much of Prague’s planning, government and business -
relies.

Prag is of course how the city was once called by its many
German-speaking inhabitants.

# Data sources:

Most map/image services are accessible via
<http://www.geoportalpraha.cz/cs/clanek/22/mapove-sluzby>

A more technical route to lists of services is via

  - <https://mpp.praha.eu/arcgis/rest/services/>
  - <https://tiles.arcgis.com/tiles/SBTXIEUGWbqzUecw/arcgis/rest/services>
  - <http://mpp.iprpraha.cz/arcgis/rest/services/>

For some of the services, shortcut notation is implemented for use in
the tile/basemap functions.

## Note on geodata about Prague

\[To be added\]

# See also:

  - [CzechData](https://github.com/JanCaha/CzechData)
  - [czso](https://github.com/petrbouchal/czso)

# Acknowledgments

  - Most importantly, IPR Praha for providing the open data \!
  - The approach draws heavily on code provided by
    @[yutannihilation](https://github.com/yutannihilation) in her \[blog
    post\]
  - logo designed using the 📦 bunny by
    @[dmi3kno](https://github.com/dmi3kno) following his [blog
    post](%5Bhttps://www.ddrive.no/post/making-hex-and-twittercard-with-bunny-and-magick/%5D)
  - font in logo is Trivia Serif by [František
    Štorm](https://stormtype.com)
