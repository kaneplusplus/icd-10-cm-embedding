# Create a directory called icd-10-embeddings and add BioGPT embedding
# values to it.

library(reticulate)
library(dplyr)
library(tidyr)
library(purrr)
library(foreach)
library(itertools)
library(readr)

# Use the conda environment created from make-biogpt-conda-env
use_condaenv("biogpt")

# Import the needed libraries.
torch = import("torch")
BioGptTokenizer = import("transformers")$BioGptTokenizer
BioGptForCausalLM = import("transformers")$BioGptForCausalLM

# Get the BioGPT tokenizer and model from Huggingface.
tokenizer = BioGptTokenizer$from_pretrained("microsoft/biogpt")
model = BioGptForCausalLM$from_pretrained("microsoft/biogpt")

# A function to calculate the embedding location.
mean_pooling = function(model_output, attention_mask) {
  #First element of model_output contains all token embeddings
  token_embeddings = model_output[1] 
  input_mask_expanded = attention_mask$unsqueeze(-1L)$expand(token_embeddings$logits$size())$float()
  sum_embeddings = torch$sum(torch$multiply(token_embeddings$logits, input_mask_expanded), 1L)
  sum_mask = torch$clamp(input_mask_expanded$sum(1L), min=1e-9)
  ret = purrr::reduce(sum_embeddings$div(sum_mask)$tolist(), rbind)
  rownames(ret) = as.character(seq_len(nrow(ret)))
  ret
}

# A function to embed a set of string.
embed = function(strings) {
  encoded_input = tokenizer(
    strings,
    padding = TRUE,
    truncation = TRUE,
    max_length = 256,
    return_tensors = 'pt'
  )
  model_output = model(
    input_ids = encoded_input$input_ids, 
    attention_mask = encoded_input$attention_mask
  )
  mean_pooling(model_output, encoded_input$attention_mask) |> 
    (\(x) {rownames(x) = strings; x})() 
}

create_embeddings = function(icd10, dir_name) {
  dir.create(dir_name)
  
  foreach(it = isplitVector(seq_len(nrow(icd10)), chunkSize = 500)) %do% {
    icds = icd10[it,] 
    emb = embed(icds$desc) 
    icds$emb = map(seq_len(nrow(emb)), ~ emb[.x,])
    walk(
      seq_len(nrow(icds)), 
      ~ saveRDS(icds[.x,], sprintf("%s/%s.rds", dir_name, icds$code[.x]))
    )
    print(it[length(it)])
    NULL
  } |> unlist() |> invisible()
}

# The directory where the embeddings will go, by year.
dir.create("icd-10-cm-embeddings")

# Write the embeddings to their respective years.

for (year in 2019:2022) {
  print(year)
  icd10 = sprintf("icd-10-cm-codes/icd10cm_codes_%s.txt", year) |>
    read_fwf(fwf_cols(code = 8, desc = 150))

  write_dir = file.path("icd-10-cm-embeddings", year)
  dir.create(write_dir)

  # Write the code, description, and embedding to a file with one file
  # per code.
  foreach(it = isplitVector(seq_len(nrow(icd10)), chunkSize = 200)) %do% {
    icds = icd10[it,] 
    emb = embed(icds$desc) 
    icds$emb = map(seq_len(nrow(emb)), ~ emb[.x,])
    walk(
      seq_len(nrow(icds)), 
      ~ saveRDS(icds[.x,], sprintf("%s/%s.rds", write_dir, icds$code[.x]))
    )
    gc()
    NULL
  }
}


