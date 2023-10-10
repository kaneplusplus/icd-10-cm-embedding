This directory contains the code used to compare the performance of the BioGPT model with MedBERT and two version of PubMedBERT (pubmedbert-fulltext and pubmedbert-ms-marco).

The following files are in the current directory.
- `setup` creates the conda environment to run each of the models.
- short-codes.R creates the training data to estimate the icd10 category(leading letter).
- alpha-char-embedding-model.R contains the `dataset` object and supervised models.

Each directory (medbert, pubmedbert-fulltext, pubmedbert-ms-marco) contains:
- ref.txt contains the url the model was downloaded from on HuggingFace.
- 0-make-embedding.R create the embedding data set.
- 1-benchmark.R performs the benchmark.
