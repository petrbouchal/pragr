#' Prague RUIAN code
#'
#' Prague RUIAN code
#'
#' @format character vector of length 1
#' \describe{
#'   Prague RUIAN code
#' }
#' @family Codes and metadata
"prg_kod"

#' Prague ICO code
#'
#' Prague ICO code
#'
#' @format character vector of length 1
#' \describe{
#'   Prague ICO code
#' }
#' @family Codes and metadata
"prg_ico"

#' Prague NUTS2 code
#'
#' Prague NUTS2 code
#'
#' @format character vector of length 1
#' \describe{
#'   Prague NUTS2 code
#' }
#' @family Codes and metadata
"prg_nuts2"

#' Prague NUTS3 code
#'
#' Prague NUTS3 code, level of kraj. Comes from CZSO registry 108 - NUTS3-2004.
#'
#' @format character vector of length 1
#' \describe{
#'   Prague NUTS3 code
#' }
#' @family Codes and metadata
"prg_nuts3"

#' Prague LAU1 code
#'
#' Prague LAU1 code - level of okres.
#'
#' @format character vector of length 1
#' \describe{
#'   Prague LAU1 code. Comes from CZSO registry 109 - OKRES_LAU.
#' }
#' @family Codes and metadata
"prg_lau1"

#' Prague 'okres' code
#'
#' Prague 'okres' code. Comes from CZSO registry 101 - OKRES_NUTS.
#'
#' @format character vector of length 1
#' \describe{
#'   Prague okres code
#' }
#' @family Codes and metadata
"prg_okres"

#' Prague 'kraj' code
#'
#' Prague 'kraj' code. Comes from CZSO registry 100, KRAJ_NUTS.
#'
#' @format character vector of length 1
#' \describe{
#'   Prague kraj code
#' }
#' #' @family Codes and metadata
"prg_kraj"

#' Prague 'okres LAU' code
#'
#' Prague 'okres LAU' code. Comes from CZSO register 101 (OKRES_NUTS) - yes these are
#' confusing but that is how it is.
#'
#' @format character vector of length 1
#' \describe{
#'   Prague okres (NUTS) code.
#' }
#' @family Codes and metadata
"prg_okres_nuts"

#' Prague code in OECD database of Functional Urban Areas
#'
#' Prague code in OECD Functional Urban Area database.
#'
#' See https://www.oecd.org/cfe/regional-policy/functionalurbanareasbycountry.htmz
#'
#' @format character vector of length 1
#' \describe{
#'   Prague code in OECD Functional Urban Area database.
#' }
#' @family Codes and metadata
"prg_fua_oecd"

#' Prague code in OECD CITIES database of data on Functional Urban Areas
#'
#' Prague code in OECD database on Metropolitan Areas.
#'
#' See https://stats.oecd.org/Index.aspx?DataSetCode=CITIES
#'
#' @format character vector of length 1
#' \describe{
#'   Prague code in OECD Functional Urban Area database.
#' }
#' @family Codes and metadata
"prg_metro_oecd"

#' Prague bbox in EPSG 4326 (WGS 84)
#'
#' Prague bbox in EPSG 4326 (WGS 84)
#'
#' @format named numeric of class `bbox`, length 4
#' \describe{
#'   Prague RUIAN code
#' }
#' @family Codes and metadata
"prg_bbox_wgs84"

#' Prague bbox in EPSG 5514 (Krovak)
#'
#' Prague bbox in EPSG 5514 (Krovak)
#'
#' @format named numeric of class `bbox`, length 4
#' \describe{
#'   Prague RUIAN code
#' }
#' @family Codes and metadata
"prg_bbox_krovak"


# Hexogram ----------------------------------------------------------------

#' Equal-area hexogram of Prague districts
#'
#' Equal-area hexogram of 57 Prague districts. Best available representation
#' though some district tiles neighbor districts they do not in reality.
#'
#' @format A data frame with 57 rows and 11 variables:
#' \describe{
#'   \item{\code{kod}}{character. RUIAN code.}
#'   \item{\code{nazev}}{character. Full name.}
#'   \item{\code{label}}{character. Three-character unique label.}
#'   \item{\code{mop_kod}}{character. Prague district code.}
#'   \item{\code{spo_kod}}{character. Admin district code.}
#'   \item{\code{pou_kod}}{character. Higher-level unit code.}
#'   \item{\code{okres_kod}}{character. District code.}
#'   \item{\code{CENTROIX}}{double. X coordinate of centroid.}
#'   \item{\code{CENTROIY}}{double. Y coordinate of centroid.}
#'   \item{\code{row}}{integer. row number.}
#'   \item{\code{col}}{integer. column number.}
#'   \item{\code{geometry}}{list. geometry.}
#' }
#' @family Mapping
"district_hexogram"

# Tilegram ----------------------------------------------------------------

#' Equal-area tilegram of Prague districts
#'
#' Equal-area hexogram of 57 Prague districts. Best available representation
#' though some district tiles neighbor districts they do not in reality.
#'
#' @format A data frame with 57 rows and 11 variables:
#' \describe{
#'   \item{\code{kod}}{character. RUIAN code.}
#'   \item{\code{nazev}}{character. Full name.}
#'   \item{\code{label}}{character. Three-character unique label.}
#'   \item{\code{mop_kod}}{character. Prague district code.}
#'   \item{\code{spo_kod}}{character. Admin district code.}
#'   \item{\code{pou_kod}}{character. Higher-level unit code.}
#'   \item{\code{okres_kod}}{character. District code.}
#'   \item{\code{CENTROIX}}{double. X coordinate of centroid.}
#'   \item{\code{CENTROIY}}{double. Y coordinate of centroid.}
#'   \item{\code{row}}{integer. row number.}
#'   \item{\code{col}}{integer. column number.}
#'   \item{\code{geometry}}{list. geometry.}
#' }
#' @family Mapping
"district_tilegram"

