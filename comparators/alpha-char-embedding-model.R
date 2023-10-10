library(torch)
library(dplyr)
library(foreach)

AlphaCharEmbedding = dataset(
  name = "AlphaCharEmbedding",
  initialize = function(x) {
    self$x = x
    self$contr = contr.treatment(sort(unique(x$ll)), contrasts = FALSE)
  },
  width = function() {
    self$x$embed[[1]] |> length()
  },
  .getitem = function(i) {
    list(
      x = torch_tensor(self$x$embed[[i]]),
      y = torch_tensor(self$contr[self$x$ll[i],])
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
    x = x$squeeze()
    for (i in seq_along(self$feature_net)) {
      x = self$feature_net[[i]](x)
    }
    nnf_softmax(x, dim = 1)
  }
)
