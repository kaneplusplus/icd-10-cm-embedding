# Validate the selected models using ICD 10 codes from other years.

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

xs = tibble(
  embed = map(icd10_embedding_paths, ICD10Embedding),
  year = 2019:2022
)

vds = tibble(
  model = map(ae_model_paths, torch_load),
  embedding_dim = str_extract(ae_model_paths, "\\d{3}") |> as.integer()
)

pred_error = function(d, m, device = default_device) {
  m = m$to(device = device)
  ret = c()
  loop(for (b in dataloader(d, batch_size = 100, num_workers = 5)) {
    xt = b$x$to(device = device)
    r = torch_mean((xt - m(xt))^2, 2)$to(device = "cpu") |>
      as.numeric()
    ret = c(ret, r)
  })
  mean(ret)
}

x = expand_grid(vds, xs) 

x$pred_error = 
  map_dbl(seq_len(nrow(x)), ~ pred_error(x$embed[[.x]], x$model[[.x]]))


