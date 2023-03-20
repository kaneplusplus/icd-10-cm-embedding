library(torch)
library(tibble)
library(dplyr)
library(purrr)
library(foreach)

ICD10Embedding = dataset( 
  name = "ICD10Embedding",
  initialize = function(files, device = "mps") {
    self$files = files
    self$device = device
  },
  .getitem = function(i) {
    ret = readRDS(self$files[i])
    x = torch_tensor(ret$emb[[1]], device = self$device, 
                 dtype = torch_float())
    list(x = x, y = x$clone())
  },
  .length = function() {
    length(self$files)
  }
)

ICD10AutoEncoder = nn_module(
  initialize = function(layers) {
    if (length(layers) %% 2 != 1) {
      stop("The number of layers must be odd.")
    }
    encoder_layers = layers[ceiling(length(layers) / 2)]
    decoder_layers = layers[(length(encoder_layers)):length(layers)]
    self$encoder = nn_module_list(
      foreach(i = seq_along(encoder_layers)[-1]) %do% {
        nn_linear(encoder_layers[i-1], encoder_layers[i])
      }
    )
    self$decoder = nn_module_list(
      foreach(i = seq_along(decoder_layers)[-1]) %do% {
        nn_linear(decoder_layers[i-1], decoder_layers[i])
      }
    )
  },
  run_forward = function(x, m) {
    for (i in seq_along(m)) {
      x = m[[i]](x)
    }
    x
  },
  encode = function(x) {
    self$run_forward(x, self$encoder)
  },
  decode = function(x) {
    self$run_forward(x, self$decoder)
  },
  forward = function(x) {
    x |>
      self$encode() |>
      self$decode()
  }
)


