# pragr (development version)

# pragr 0.3.0

## New features

* added `district_tilegram`, an equal-area square grid for Prague city districts 
* added `district_geofacet`, a grid that can be used as an input into the `facet_geo()` 
function in the `geofacet` package. See the `geofacet` vignette for examples.
* added `district_names`, a tibble with various forms of Prague's district names and their codes
* added basic demographic data for Prague districts: population and median age by age and sex, 2011-19. See the `geofacet` vignette for examples.

## Improvements

* new basic vignettes (getting started; using Prague data in {leaflet})
* updated core map server endpoint URLs to reflect new scheme as per http://app.iprpraha.cz/apl/app/service_viewer/
* improved documentation on which services are at which URLs
* updated image type detection to work with new servers

## Bug fixes

* `prg_[tile|basemap]` checking now correctly detects map server URLs passed to `*_service` parameters

# pragr 0.2.0

* added `district_hexogram`, an equal-area hex grid for Prague city districts 
* added `prg_ico`
* added other `prg_*` codes that identify Prague in various registers
* added basic examples to core functions
* improved documentation incl. pkgdown site
* clarified and added detail to README

# pragr 0.1.1

* improved file handling in raster data functions
* improved sizing in prg_basemap()
* streamlined interface to existing map services in raster functions

# pragr 0.1.0

* new raster data functions

# pragr 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
* basic project infrastructure
* added a `verbose` parameter to prg_*()
