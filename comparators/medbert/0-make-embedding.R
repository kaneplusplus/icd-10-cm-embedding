library(reticulate)
library(readr)
library(purrr)
library(foreach)
library(itertools)

use_condaenv("icd-10-huggingface", required = TRUE)

source("../short-code.R")

transformers = import("transformers")
tokenizer = transformers$AutoTokenizer$from_pretrained("Charangan/MedBERT")
torch = import("torch")
np = import("numpy")

builtins = import_builtins()
builtins$setattr(torch$distributed, "is_initialized", py_eval("lambda : False"))
model = transformers$AutoModel$from_pretrained("Charangan/MedBERT")

# A function to embed a set of string.
embed = function(strings) {
  encoded_input = tokenizer(
    strings,
    padding = TRUE,
    truncation = TRUE,
    max_length = 256L,
    return_tensors = 'pt'
  )
  ret = model(
    input_ids = encoded_input$input_ids,
    attention_mask = encoded_input$attention_mask
  )$pooler_output 
  ret$detach()$cpu()$numpy()
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
