library(luz)
library(tidyr)

source("autoencoder.R")

embedding_dir = file.path("icd-10-cm-embeddings", "2019")

fn = file.path(embedding_dir, dir(embedding_dir))
set.seed(123)
train = sample.int(length(fn), round(0.9 * length(fn)))
test = setdiff(seq_len(length(fn)), train)

icd10_emb_train = ICD10Embedding(fn[train])
icd10_emb_test = ICD10Embedding(fn[test])

emb_len = icd10_emb_train[1]$x$shape[1]

# Create the set of parameters we will create autoencoders over.

params = expand_grid(
  model_layers = list(
    c(emb_len, 1000, emb_len),
    c(emb_len, 1000, 100, 1000, emb_len),
    c(emb_len, 1000, 100, 50, 100, 1000, emb_len),
    c(emb_len, 1000, 100, 50, 10, 50, 100, 1000, emb_len)),
  batch_size = c(64, 128, 256)
)

params$model_name = as.character(seq_len(nrow(params)))

make_model = function(model_layers, batch_size, model_name, epochs = 10) {

  ret_luz = ICD10AutoEncoder |>
    setup(
      loss = nn_mse_loss(),
      optimizer = optim_adam
#      metrics = list(
#        luz_metric_mse()
#      )
    ) |>
    set_hparams(layers = model_layers) |>
    fit(
      data = dataloader(
        icd10_emb_train, 
        batch_size = batch_size, 
        shuffle = TRUE, 
        num_workers = 2,
        worker_packages = "torch"
      ),
      epochs = epochs,
      valid_data = dataloader(
        icd10_emb_test, 
        batch_size = batch_size, 
        shuffle = TRUE, 
        num_workers = 2,
        worker_packages = "torch"
      ),
      callbacks = 
        list(
          luz_callback_csv_logger(sprintf("output-%s.csv", model_name)),
          luz_callback_keep_best_model()
        )
    )
  ret_luz
}

# The parameters and the models
md = params

md$model = map(
  seq_len(nrow(params)),
  ~ make_model(
    params$model_layers[[.x]], 
    params$batch_size[.x], 
    params$model_name[.x]
  )
)


md$embedding_dim = rep(c(1000, 100, 50, 10), 3)

epoch_plot = function(luz_model, take_log = FALSE) {
  ms = get_metrics(luz_model)
  p <- ggplot(ms, aes(x = epoch, y = value)) +
    geom_point() + 
    geom_line()
  if (take_log) {
    p = p + scale_y_log10()
  }
  p + facet_grid(metric ~ set, scales = "free_y")
}

# Best valid loss index
bvli = map_int(md$model, ~ which.min(unlist(.x$records$metrics$valid)))

md$best_valid_loss = 
  map_dbl(
    seq_along(md$model), 
    ~ unlist(md$model[[.x]]$records$metrics$valid[bvli[.x]])
  )

md$best_train_loss = 
  map_dbl(
    seq_along(md$model), 
    ~ unlist(md$model[[.x]]$records$metrics$train[bvli[.x]])
  )

# Save the luz_models
luz_model_dir = "luz-models"
dir.create(luz_model_dir)
md$model_path = NA
for (i in seq_len(nrow(md))) {
  model_path = file.path(luz_model_dir, sprintf("luz-model-%02d.luz", i))
  luz_save(
    md$model[[i]], 
    model_path
  )
  md$model_path = model_path
}

dir.create("autoencoder-models")

torch_save(
  (md |> filter(embedding_dim == 50, batch_size == 128))$model[[1]]$model, 
  file.path("autoencoder-models", "icd10cm-050.pt")
)

torch_save(
  (md |> filter(embedding_dim == 10, batch_size == 128))$model[[1]]$model, 
  file.path("autoencoder-models", "icd10cm-010.pt")
)

torch_save(
  (md |> filter(embedding_dim == 100, batch_size == 256))$model[[1]]$model, 
  file.path("autoencoder-models", "icd10cm-100.pt")
)

md |> 
  select(embedding_dim, batch_size, starts_with("best")) |> 
  arrange(best_valid_loss, best_train_loss) |>
  saveRDS("model-performance.rds")
