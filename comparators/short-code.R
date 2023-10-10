library(purrr)

ccc = c(
  "^[AB].*",
  "(^C|^D[0-4]).*",
  "^D[5-8].*",
  "^E[0-8][0-9].*",
  "^F.*",
  "^G.*",
  "^H[0-5][0-9].*",
  "^H[6-9][0-9].*",
  "^I.*",
  "^J.*",
  "^K.*",
  "^L.*",
  "^M.*",
  "^N.*",
  "^O[0-9].*",
  "^P.*",
  "^Q.*",
  "^R.*",
  "^[ST].*",
  "^[UVWXY].*",
  "^[Z].*"
)

get_short_code_impl = function(code) {
  which(map_lgl(ccc, ~ grepl(.x, code)))
}

get_short_code = function(code) {
  map_int(code, get_short_code_impl)
}
