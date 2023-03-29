# Write the datasets.

library(torch)
library(purrr)
library(stringr)
library(readr)
library(tibble)
library(tidyr)

source("autoencoder.R")

default_device = "mps"

ae_model_paths = "autoencoder-models" |>
  (\(x) file.path(x, dir(x)))()

icd10_embedding_paths = file.path("icd-10-embeddings", 2019:2022) |>
  map( ~ file.path(.x, dir(.x)))

icd10_code_paths = 2019:2022 |> 
  map_chr(~file.path("icd-10-codes", sprintf("icd10cm_codes_%s.txt", .x)))

xs = tibble(
  embed = map(icd10_embedding_paths, ICD10Embedding),
  year = 2019:2022,
  codes = map(icd10_code_paths, ~read_fwf(.x, fwf_cols(code = 8, desc = 150)))
)

vds = tibble(
  model = map(ae_model_paths, torch_load),
  embedding_dim = str_extract(ae_model_paths, "\\d{3}") |> as.integer()
)

get_embedding = function(d, m, device = default_device) {
  m = m$to(device = device)
  ret = c()
  loop(for (b in dataloader(d, batch_size = 100, num_workers = 6)) {
    xt = b$x$to(device = device)
    for (i in seq_len(length(m$decoder) / 2)) {
      x = xt
      xt = m$decoder[[i]](x)
    }
    ret = rbind(ret, as.matrix(xt$to(device = "cpu")))
  })
  ret = as_tibble(as.data.frame(ret))
  ret
}

xd = expand_grid(xs, vds)
xd$embedding = map(
  seq_len(nrow(xd)), 
  ~ get_embedding(xd$embed[[.x]], xd$model[[.x]])
)

dir.create("embedding-data")

for (i in seq_len(nrow(xd))) {
  d = bind_cols(xd$codes[[i]], xd$embedding[[i]])
  write_csv(
    d, 
    file.path(
      "embedding-data", 
      sprintf("icd-10-%s-%03d.csv", xd$year[i], xd$embedding_dim[i])
    )
  )
}



