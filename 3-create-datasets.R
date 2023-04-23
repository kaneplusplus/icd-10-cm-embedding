# Write the datasets.

library(torch)
library(purrr)
library(stringr)
library(readr)
library(tibble)
library(tidyr)
library(progress)
library(future)
library(furrr)
library(dplyr)
plan(multicore, workers = 6)

source("autoencoder.R")

default_device = "mps"

ae_model_paths = "autoencoder-models" |>
  (\(x) file.path(x, dir(x)))()

icd10_embedding_paths = file.path("icd-10-cm-embeddings", 2019:2022) |>
  map( ~ file.path(.x, dir(.x)))

icd10_code_paths = 2019:2022 |> 
  map_chr(~file.path("icd-10-cm-codes", sprintf("icd10cm_codes_%s.txt", .x)))

xs = tibble(
  embed = map(icd10_embedding_paths, ICD10Embedding),
  year = 2019:2022,
  codes = map(icd10_code_paths, ~read_fwf(.x, fwf_cols(code = 8, desc = 150)))
)

vds = tibble(
  model = map(ae_model_paths, torch_load),
  embedding_dim = str_extract(ae_model_paths, "\\d{4}") |> as.integer()
)

get_embedding = function(d, m, device = default_device) {
  m = m$to(device = device)
  ret = c()
  dl = dataloader(d, batch_size = 100, num_workers = 6)
  pb = progress_bar$new( format = "[:bar] :percent eta: :eta",
    total = length(dl)
  )
  loop(for (b in dl) {
    xt = b$x$to(device = device)
    for (i in seq_len(length(m$decoder) / 2)) {
      x = xt
      xt = m$decoder[[i]](x)
    }
    pb$tick()
    ret = rbind(ret, as.matrix(xt$to(device = "cpu")))
  })
  ret = as_tibble(as.data.frame(ret))
  ret
}

xd = expand_grid(xs, vds)
xd$embedding = map(
  seq_len(nrow(xd)), 
  ~ {print(.x); get_embedding(xd$embed[[.x]], xd$model[[.x]])}
)

dir.create("embedding-data")

for (i in seq_len(nrow(xd))) {
  d = bind_cols(xd$codes[[i]], xd$embedding[[i]])
  write_csv(
    d, 
    file.path(
      "embedding-data", 
      sprintf("icd-10-cm-%s-%04d.csv.gz", xd$year[i], xd$embedding_dim[i])
    )
  )
}

for (year in 2019:2022) {
  x = file.path("icd-10-cm-embeddings", year) |>
    (\(x) file.path(x, dir(x)))() |>
    future_map_dfr(~{
      ret = readRDS(.x) 
      ret = 
        bind_cols(
          ret[,1:2],
          ret$emb[[1]] |> t() |> as.data.frame()
        )
      gc()
      ret
    })
  write_csv(x, sprintf("embedding-data/icd-10-cm-%s-full.csv.gz", year))
}

