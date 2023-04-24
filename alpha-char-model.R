library(torch)
library(tibble)
library(dplyr)
library(purrr)
library(foreach)
library(readr)

AlphaCharEmbedding = dataset(
  name = "AlphaCharEmbedding",
  initialize = function(icd10_emb, output_levels) {
    self$x = icd10_emb |>
      collect()
    lc = contr.treatment(output_levels, contrasts = FALSE)
    adf = map_dfr(self$x$code, ~ lc[.x,])
    names(adf) = paste0("alpha_", names(adf))
    self$x = bind_cols(adf, icd10_emb)
    self$v_width = ncol(self$x |> select(starts_with("V")))
  }, 
  width = function() {
    self$v_width
  },
  .getitem = function(x) {
    list(
      x = torch_tensor(select(self$x[x,], starts_with("V")) |> unlist()),
      y = torch_tensor(select(self$x[x,], starts_with("alpha")) |> unlist())
    )
  },
  .length = function() {
    nrow(self$x)
  }
)

AlphaCodeEstimator = nn_module( 
  initialize = function(layers) {
    self$feature_net = nn_module_list(
      foreach(i = seq_along(layers)[-1]) %do% {
        nn_linear(layers[i-1], layers[i])
      }
    )
  },
  forward = function(x) {
    for (i in seq_along(self$feature_net)) {
      x = self$feature_net[[i]](x)
    }
    nnf_softmax(x, dim = 2)
  }
)


