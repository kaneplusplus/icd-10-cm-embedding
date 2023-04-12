# Validate the selected models using ICD 10 codes from other years.

library(torch)
library(purrr)
library(stringr)
library(readr)
library(tibble)
library(tidyr)
library(progress)

source("autoencoder.R")

default_device = "mps"

ae_model_paths = "autoencoder-models" |>
  (\(x) file.path(x, dir(x)))()

icd10_embedding_paths = file.path("icd-10-cm-embeddings", 2019:2022) |>
  map( ~ file.path(.x, dir(.x)))

xs = tibble(
  embed = map(icd10_embedding_paths, ICD10Embedding),
  year = 2019:2022
)

vds = tibble(
  model = map(ae_model_paths, torch_load),
  embedding_dim = str_extract(ae_model_paths, "\\d{4}") |> as.integer()
)

pred_error = function(d, m, device = default_device) {
  m = m$to(device = device)
  ret = c()
  dl = dataloader(d, batch_size = 100, num_workers = 5)
  pb = progress_bar$new(
    format = "[:bar] :percent eta: :eta",
    total = length(dl)
  )
  loop(for (b in dl) {
    xt = b$x$to(device = device)
    r = torch_mean((xt - m(xt))^2, 2)$to(device = "cpu") |>
      as.numeric()
    pb$tick()
    ret = c(ret, r)
  })
  mean(ret)
}

variation = function(d, device = default_device) {
  ret = c()
  dl = dataloader(d, batch_size = 100, num_workers = 5)
  pb = progress_bar$new(
    format = "[:bar] :percent eta: :eta",
    total = length(dl)
  )
  loop(for (b in dl) {
    xt = b$x$to(device = device)
    r = torch_var(xt, 2)$to(device = "cpu") |> as.numeric()
    pb$tick()
    ret = c(ret, r)
  })
  mean(ret)
}

x = expand_grid(vds, xs) 

x$pred_error = 
  map_dbl(
    seq_len(nrow(x)), 
    ~ {print(.x); pred_error(x$embed[[.x]], x$model[[.x]])})

x$variation = 
  map_dbl(
    seq_len(nrow(x)), 
    ~ {print(.x); variation(x$embed[[.x]])})

saveRDS(x, "year-validation-raw.rds")

x |> 
  arrange(year) |> 
  select(-model, -embed) |>
  mutate(cod = pred_error / variation) |>
  select(year, embedding_dim, pred_error, cod) |>
  saveRDS("year-validation.rds")
