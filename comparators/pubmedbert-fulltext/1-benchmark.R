library(luz)
library(foreach)
library(yardstick)
library(tidyr)

source("../alpha-char-embedding-model.R")

x = readRDS("x-with-embedding.rds")

traini = sample.int(nrow(x), round(0.9 * nrow(x)))
testi = setdiff(seq_len(nrow(x)), traini)

train = AlphaCharEmbedding(x[traini, ])
test = AlphaCharEmbedding(x[testi, ])

layers = c(train$width(), 100, 100, 21)

batch_size = c(64, 128, 256)
epochs = 30
num_workers = 6

loss = function(input, target) {
  torch_mean(-torch_sum(target * torch_log(input$squeeze() + 1e-16), 2))
}

mss = foreach (bs = batch_size, .combine = bind_rows) %do% {
  luz_model = AlphaCodeEstimator |>
      setup(
        loss = loss, #nn_cross_entropy_loss(26),
        optimizer = optim_adam
      ) |>
      set_hparams(layers = layers) |>
      fit(
        data = dataloader(
          train,
          batch_size = bs,
          shuffle = TRUE,
          num_workers = num_workers,
          worker_packages = c("torch", "dplyr")
        ),
        epochs = epochs,
        valid_data = dataloader(
          test,
          batch_size = bs,
          shuffle = FALSE,
          num_workers = num_workers,
          worker_packages = c("torch", "dplyr")
        ),
        callbacks = list(
          luz_callback_keep_best_model()
        )
      )

  preds =
    predict(
      luz_model,
      dataloader(
        test,
        batch_size = bs,
        num_workers = num_workers,
        worker_packages = c("torch", "dplyr")
      )
    )

  comp = tibble(
    obs =  x[testi,]$ll |>
      factor(levels = 1:21),
    pred = preds |>
      torch_tensor(device = "cpu") |>
      as.matrix() |>
      apply(1, which.max) |>
      factor(levels = 1:21)
  )
  bind_cols(
    metric_set(accuracy, bal_accuracy)(comp, truth = obs, estimate = pred),
    batch_size = bs
    ) |>
    select(-.estimator) |>
    pivot_wider(names_from = .metric, values_from = .estimate)
}
print(mss)
saveRDS(mss, "ms.rds")
