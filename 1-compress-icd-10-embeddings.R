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

make_model = function(model_layers, batch_size, model_name, epochs = 30) {

  ret_luz = ICD10AutoEncoder |>
    setup(
      loss = nn_mse_loss(),
      optimizer = optim_adam
#      metrics = list(
#        luz_metric_mse(),
#        luz_metric_data_variation()
#      )
    ) |>
    set_hparams(layers = model_layers) |>
    fit(
      data = dataloader(
        icd10_emb_train, 
        batch_size = batch_size, 
        shuffle = TRUE, 
        num_workers = 4,
        worker_packages = "torch"
      ),
      epochs = epochs,
      valid_data = dataloader(
        icd10_emb_test, 
        batch_size = batch_size, 
        shuffle = TRUE, 
        num_workers = 4,
        worker_packages = "torch"
      ),
      callbacks = 
        list(
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

md$embedding_dim = rep(c(1000, 100, 50, 10), each = 3)

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

md = md |> arrange(best_valid_loss, best_train_loss)

mdo = md |> 
  select(embedding_dim, batch_size, starts_with("best")) 

saveRDS(mdo, "model-performance.rds")

dir.create("autoencoder-models")

torch_save(
  (md |> filter(embedding_dim == 10))$model[[1]]$model, 
  file.path("autoencoder-models", "icd10cm-0010.pt")
)

torch_save(
  (md |> filter(embedding_dim == 50))$model[[1]]$model, 
  file.path("autoencoder-models", "icd10cm-0050.pt")
)

torch_save(
  (md |> filter(embedding_dim == 100))$model[[1]]$model, 
  file.path("autoencoder-models", "icd10cm-0100.pt")
)

torch_save(
  (md |> filter(embedding_dim == 1000))$model[[1]]$model, 
  file.path("autoencoder-models", "icd10cm-1000.pt")
)

