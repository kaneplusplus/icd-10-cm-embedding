library(reticulate)
library(readr)
library(purrr)
library(foreach)
library(itertools)

use_condaenv("icd-10-huggingface", required = TRUE)

source("../short-code.R")

transformers = import("transformers")
torch = import("torch")
np = import("numpy")
builtins = import_builtins()
builtins$setattr(torch$distributed, "is_initialized", py_eval("lambda : False"))

tokenizer = transformers$AutoTokenizer$from_pretrained(
  'pritamdeka/S-PubMedBert-MS-MARCO'
)
model = transformers$AutoModel$from_pretrained(
  'pritamdeka/S-PubMedBert-MS-MARCO'
)

mean_pooling = function(model_output, attention_mask) {
    token_embeddings = model_output[[1]] #First element of model_output contains all token embeddings
    input_mask_expanded = attention_mask$unsqueeze(-1L)$expand(token_embeddings$size())$float()
    torch$sum(token_embeddings * input_mask_expanded, 1L) / torch$clamp(input_mask_expanded$sum(1L), min=1e-9)
}


# A function to embed a set of string.
embed = function(strings) {
  encoded_input = tokenizer(
    strings,
    padding = TRUE,
    truncation = TRUE,
    max_length = 256L,
    return_tensors = 'pt'
  )
  model_output = model(
    input_ids = encoded_input$input_ids,
    attention_mask = encoded_input$attention_mask
  )
  mean_pooling(model_output, 
               encoded_input$attention_mask)$detach()$cpu()$numpy() |>
    (\(x) {rownames(x) = strings; x})()
}

x = read_fwf(
  "../../icd-10-cm-codes/icd10cm_codes_2019.txt",
  fwf_cols(code = 8, desc = 150)
)

embs = foreach(it = isplitVector(seq_len(nrow(x)), chunkSize = 1000),
               .combine = c) %do% {
  ret = embed(x$desc[it])
  ret = map(seq_len(nrow(ret)), ~ list(ret[.x,,drop = FALSE]))
  message(tail(it, 1), " of ", nrow(x))
  gc()
  ret
}

x$embed = unlist(embs, recursive = FALSE)
x$ll = get_short_code(x$code)
saveRDS(x, "x-with-embedding.rds")
