library(luz)
library(yardstick)
library(tibble)
library(stringr)

source("alpha-char-model.R")

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

emb_data_dir = "embedding-data"

params = tibble(
  embedding_files = 
    file.path(emb_data_dir, dir(emb_data_dir) |> str_subset("2019")),
  emb_dim = 
    str_extract(embedding_files, "-\\d{3}\\.") |> str_extract("\\d{3}")
)

dir.create("luz-supervised-models")

ms = list()

for (i in seq_len(nrow(params))) {

  aced = params$embedding_files[i]|> read_csv() 

  traini = sample.int(nrow(aced), round(0.9 * nrow(aced)))
  testi = setdiff(seq_len(nrow(aced)), traini)

  aced$code = get_short_code(aced$code)

  train = AlphaCharEmbedding(aced[traini, ], sort(unique(aced$code)))
  test = AlphaCharEmbedding(aced[testi, ], sort(unique(aced$code)))

  layers = c(train$width(), 100, 100, 21)
  batch_size = 64
  epochs = 30

  # Cross entropy
  loss = function(input, target) {
    torch_mean(-torch_sum(target * torch_log(input + 1e-16), 2))
  }

  luz_model = AlphaCodeEstimator |>
    setup(
      loss = loss, #nn_cross_entropy_loss(26),
      optimizer = optim_adam
    ) |>
    set_hparams(layers = layers) |>
    fit(
      data = dataloader(
        train,
        batch_size = batch_size,
        shuffle = TRUE,
        num_workers = 4,
        worker_packages = c("torch", "dplyr")
      ),
      epochs = epochs,
      valid_data = dataloader(
        test,
        batch_size = batch_size,
        shuffle = TRUE,
        num_workers = 4,
        worker_packages = c("torch", "dplyr")
      ),
      callbacks = list(
        luz_callback_keep_best_model()
      )
    )

  luz_save(
    luz_model, 
    file.path("luz-supervised-models", 
              sprintf("luz-model-%s.pt", params$emd_dim[i]))
  )

  preds = 
    predict(
      luz_model,
      dataloader(
        test,
        batch_size = batch_size,
        num_workers = 4,
        worker_packages = c("torch", "dplyr")
      )
    )

  comp = tibble(
    obs =  aced[testi,]$code |>
      factor(levels = 1:21),
    pred = preds |> 
      torch_tensor(device = "cpu") |>
      as.matrix() |>
      apply(1, which.max) |> 
      factor(levels = 1:21)
  )

  ms = c(ms, 
    metric_set(accuracy, bal_accuracy)(comp, truth = obs, estimate = pred) 
  )
  print(ms)
}
