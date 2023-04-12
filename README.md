
- [A Compressedd Large-Language Model Embedding Dataset of ICD-10-CM
  Descriptions](#a-compressedd-large-language-model-embedding-dataset-of-icd-10-cm-descriptions)
  - [Datasets](#datasets)
    - [2022](#2022)
    - [2021](#2021)
    - [2020](#2020)
    - [2019](#2019)
  - [Background and introduction](#background-and-introduction)
  - [Model description and
    performance](#model-description-and-performance)
    - [Validating the dimension
      reduction](#validating-the-dimension-reduction)
    - [Validating representation](#validating-representation)
  - [An example using the embedding data in
    R](#an-example-using-the-embedding-data-in-r)
  - [Reproducing these results](#reproducing-these-results)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# A Compressedd Large-Language Model Embedding Dataset of ICD-10-CM Descriptions

[![License: CC BY-NC-SA
4.0](https://img.shields.io/badge/License-CC_BY--NC--SA_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
(data); [![License: GPL
v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
(code)

© Michael J. Kane (kaneplusplus at proton mail dot com)

## Datasets

### 2022

1.  [ICD-10-CM,
    10-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2022-0010.csv?raw=true)
2.  [ICD-10-CM,
    50-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2022-0050.csv?raw=true)
3.  [ICD-10-CM,
    100-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2022-0100.csv?raw=true)
4.  [ICD-10-CM,
    1000-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2022-1000.csv?raw=true)

### 2021

1.  [ICD-10-CM,
    10-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2021-0010.csv?raw=true)
2.  [ICD-10-CM,
    50-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2021-0050.csv?raw=true)
3.  [ICD-10-CM,
    100-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2021-0100.csv?raw=true)
4.  [ICD-10-CM,
    1000-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2021-1000.csv?raw=true)

### 2020

1.  [ICD-10-CM,
    10-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2020-0010.csv?raw=true)
2.  [ICD-10-CM,
    50-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2020-0050.csv?raw=true)
3.  [ICD-10-CM,
    100-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2020-0100.csv?raw=true)
4.  [ICD-10-CM,
    1000-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2020-1000.csv?raw=true)

### 2019

1.  [ICD-10-CM,
    10-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2019-0010.csv?raw=true)
2.  [ICD-10-CM,
    50-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2019-0050.csv?raw=true)
3.  [ICD-10-CM,
    100-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2019-0100.csv?raw=true)
4.  [ICD-10-CM,
    1000-dimensions](https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-2019-1000.csv?raw=true)

## Background and introduction

The ICD-10-CM (International Classification of Diseases, 10th Revision,
Clinical Modification) is a standardized classification system for
diagnosing diseases, disorders, and health conditions. Developed by the
World Health Organization (WHO) and adapted for use in the United States
by the National Center for Health Statistics (NCHS). The standard plays
a crucial role in the analysis of electronic medical records (EMRs) or
electronic health records (EHRs) for several reasons:

1.  Consistency and Standardization: The ICD-10-CM allows for a
    consistent and standardized method of coding and documenting medical
    conditions across healthcare providers and facilities. This helps to
    ensure accurate and uniform data exchange, analysis, and comparison.
2.  Data Analysis and Research: The ICD-10-CM codes can be used to
    analyze patient data for clinical research, epidemiological studies,
    and public health surveillance. It helps to identify trends and
    patterns in diseases, monitor the effectiveness of treatments, and
    develop better prevention and management strategies.
3.  Quality Measurement and Improvement: ICD-10-CM codes can be used to
    evaluate the quality of care provided by healthcare facilities,
    monitor patient outcomes, and identify areas for improvement. This
    information can be used to enhance the overall healthcare delivery
    system.
4.  Reimbursement and Billing: ICD-10-CM codes play a vital role in
    healthcare reimbursement by providing a standardized method to
    classify and report medical conditions. Insurance companies and
    other payers use these codes to determine appropriate payments for
    medical services rendered.
5.  Health Policy and Planning: ICD-10-CM codes help health authorities
    and policymakers to identify population health needs, allocate
    resources, and develop targeted healthcare policies and
    interventions.

While they do provide a consistent and comprehensive set of categories,
their incorporation into statistical and machine learning analyses can
be challenging for several reasons. First, in the 2019 version of the
standard there are 71,932 categories and that number has increased since
then with the 2022 version containing 72,750 categories. As a result,
analyses using these codes, where the set of codes is not restricted to
smaller set, must take into account their high-dimensionality or will
require a large number of samples in order to fit consistent models.
Second, categorical variables are usually incorporated into analyses
with a contrast encoding such as treatment, one-hot, etc. Contrast
numeric representations are orthogonal or, under appropriate statistical
assumptions, independent. However, ICD-10-CM codes represent a
hierarchical structure, where codes are organized into chapters, blocks,
and categories based on the type and anatomical location of the diseases
or conditions. Applying traditional contrast encoding methods like (eg.
one-hot, treatment, etc.) may not fully capture this hierarchical
information, potentially resulting in a loss of valuable context and
relationships between codes.

Researchers have considered alternative encoding methods or feature
extraction techniques that can better represent the hierarchical
structure of ICD-10-CM codes. However, incorporating both hierarchical
structure and other contextual information in a general way can be
difficult. The previous generation of word embeddings, which provide
vector-encodings of words were shown effective for these types of tasks,
with models like [med2vec providing improved abilities to predict
patient
mortality](https://academic.oup.com/jamiaopen/article/4/1/ooab022/6172949?login=false).
Despite their advantages, word embeddings also have certain limitations.
First, word embeddings are typically generated at the word or code
level, which may not always be sufficient for capturing the hierarchical
structure of ICD-10-CM codes. Second, the quality and representativeness
of the word embeddings depend on the training data used to generate
them. If the training data does not adequately cover the entire spectrum
of medical conditions or encounters, the embeddings may not capture all
relevant relationships or information. Third, Many word embeddings do
not account for the specific context in which a code appears. This can
limit their ability to capture the nuances of medical conditions and the
relationships between them.

Large language models (LLMs), address some of the shortcomings of
traditional word embeddings through a combination of advanced techniques
and architectures. Unlike traditional word embeddings that generate
static representations, large language models generate contextualized
embeddings. These embeddings take into account the surrounding words or
tokens, allowing for a more nuanced representation of words and codes in
different contexts. This helps in capturing the semantic relationships
between codes more effectively. These models are pre-trained on vast
amounts of text data, allowing them to learn general language
representations before being fine-tuned for specific tasks. This
pre-training enables the models to leverage existing knowledge and adapt
more effectively to new tasks, even with limited task-specific data.
Large language models can be incrementally updated or fine-tuned with
new data, allowing them to adapt to evolving medical knowledge and
practices more effectively than static word embeddings. And, while not
explicitly designed for hierarchical data like ICD-10-CM codes, large
language models can implicitly learn hierarchical relationships through
their deep architectures and the context in which codes appear. This can
help capture different levels of granularity and relationships between
codes more effectively than traditional word embeddings.

This paper describes data sets provided as csv files, mapping ICD-10-CM
codes to embeddings (a numeric vector of values), based on their
descriptions. The embeddings were generated using the [BioGPT Large
Language
Model](https://academic.oup.com/bib/article/23/6/bbac409/6713511?guestAccessKey=a66d9b5d-4f83-4017-bb52-405815c907b9&login=false),
which was trained on the biomedical literature including PubMed, PubMed
Central, and clinical notes from MIMIC-III. This model was shown to do a
better job of encoding context and relational information than
competitors in the medical domain. Since the dimension of the embedding
LLM is of high dimension (~42,000), we provide dimension-reduced
versions in 1,000, 100, 50, and 10 dimensions. The model generating the
data were validated in two ways. The first validates the dimension
reduction. The embedding data were compressed using an auto-encoder. The
out-of-sample accuracy of a validation set is examined as well as the
performance of the model for other versions (by year) of the ICD-10-CM
specification. Our results show that we are able to reduce the dimension
of the data down to 10 dimensions while maintaining the ability to
reproduce the original embeddings with the fidelity decreasing as the
reduced-dimension representation decreases. The second validates the
conceptual representation by creating a supervised model to estimate the
ICD-10-CM hiearchical categories. Again we see as the dimension of the
compressed representation decreases the model accuracy decreases. Since
multiple compression levels are provided, a user is free to choose
whichever suits their needs, allowing them to trade off accuracy for
dimensionality.

The paper proceeds as follows. The next section provides a high level
description of the BioGPT and the embedding along with the construction
of the autoencoder used to reduce the dimension of the embedding
representation. That section then provides validation for both the
dimension reduction as well as the representation. The third section
provides an example of how to use the dataset to cluster ICD-10-CM codes
using the R programming environment. The final section describes how to
reproduce all of the results presented here.

The data sets and code use to generate them are available at
<https://github.com/kaneplusplus/icd-10-cs-embedding>. The data are
licensed under the [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode).
The code is licensed under
[GPL-v2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

## Model description and performance

The provided data are generated by embedding ICD-10-CM descriptions
using the BioGPT-Large model, which comprises 1.5 billion parameters and
is accessible via the Hugging Face repository. The embedding process
involves tokenizing textual phrases into tokens (words, subwords, or
characters) and mapping them to unique vocabulary IDs. Token IDs are
passed through an embedding layer, resulting in a sequence of continuous
embedding vectors. Positional encodings are added element-wise to these
vectors, enabling the model to capture token order and relative
positions. The embeddings are then contextualized by passing them
through the model’s layers. An attention mask selectively controls
information flow in the attention mechanism, allowing the model to weigh
the importance of input tokens when generating contextualized embeddings
in a 42,384 dimensional space.

The embedding is then compressed using an auto encoder. The auto-encoder
is a series of fully connected layers where the number of hidden nodes
is approximately one order of magnitude smaller than the previous layer
and then an order of magnitude larger until the output layer. For
example the autoencoder compressing to 10 dimensions has layers of size
42,384, 1,000, 100, 50, 10, 50, 100, 1,000, 42,384. Models whose
dimension is large use them same structure while retaining only the
appropriate layers.

### Validating the dimension reduction

| Embedding Dimension | Batch Size | Training Loss | Validation Loss |
|--------------------:|-----------:|--------------:|----------------:|
|                 100 |         64 |         0.534 |           0.339 |
|                 100 |        128 |         0.487 |           0.381 |
|                  50 |        256 |         0.403 |           0.392 |
|                1000 |         64 |         0.542 |           0.402 |
|                 100 |        256 |         0.556 |           0.444 |
|                1000 |        128 |         1.073 |           0.486 |
|                  10 |        256 |         0.599 |           0.594 |
|                  10 |        128 |         0.628 |           0.609 |
|                  10 |         64 |         0.679 |           0.641 |
|                  50 |         64 |         1.134 |           0.699 |
|                1000 |        256 |        30.435 |           0.803 |
|                  50 |        128 |         1.053 |           0.894 |

The autoencoder performance diagnostics.

The autoencoder compressing the LLM embedding was fit on the 2019
ICD-10-CM descriptions for 20 epochs, with batch sizes 64, 128, and 256,
mean-square error loss between the embedding and autoencoder estimate,
and a validation data set comprised of random subset of 10% of the
samples. The model performance is shown above. Based on these results
the models with the best validation loss where selected for
distribution.

| Year | Embedding Dimension |   MSE | Coef. of Determination |
|-----:|--------------------:|------:|-----------------------:|
| 2019 |                  10 | 0.593 |                  0.086 |
| 2019 |                  50 | 0.388 |                  0.056 |
| 2019 |                 100 | 0.336 |                  0.049 |
| 2019 |                1000 | 0.400 |                  0.058 |
| 2020 |                  10 | 0.593 |                  0.086 |
| 2020 |                  50 | 0.388 |                  0.056 |
| 2020 |                 100 | 0.336 |                  0.049 |
| 2020 |                1000 | 0.400 |                  0.058 |
| 2021 |                  10 | 0.594 |                  0.086 |
| 2021 |                  50 | 0.389 |                  0.056 |
| 2021 |                 100 | 0.337 |                  0.049 |
| 2021 |                1000 | 0.401 |                  0.058 |
| 2022 |                  10 | 0.595 |                  0.086 |
| 2022 |                  50 | 0.390 |                  0.056 |
| 2022 |                 100 | 0.338 |                  0.049 |
| 2022 |                1000 | 0.402 |                  0.058 |

The autoencoder year validation performance

In addition to the 2019 validation the models selected for distribution
were tested on the 2020-2022 data sets to ensure their performance is
comparable over years. It should be noted that the ICD-10-CM codes do
not vary too much so we should not expect large differences. As
expected, the mean square error and coefficients of determination are
similar to the 2019 data.

### Validating representation

As a final step in the validation process, we use the fact that in
addition to the description, the ICD-10-CM codes themselves carry
hierarchical information, which can be used to ensure that conceptual
relationships are preserved in the compressed embeddings. In particular,
the leading letter and two numeric values categorize codes. For example,
codes A00-B99 correspond to infectious and parasitic diseases, C00-D49
correspond to Neoplasms, etc. We can therefore ensure that at least some
of the relevant relationships are preserved in the compressed embedding
representation by confirming that the categories can be estimated at a
rate higher than chance using a supervised model. Furthermore, we can
quantify how much relevant predictive information is lost in
lower-dimensional representations.

The training data consists of a one-hot encoding of the ICD-10-CM
categories as the dependent variable and the compressed embedding values
as the indepedent values. The model consisted of two hidden layers with
100 nodes each. The loss function selected was categorical
cross-entropy. The model was trained using 30 epoch and a validation
data set comprised of 10% of samples, chosen at random. The peformance
is shown below.

| Sepal.Length | Sepal.Width | Petal.Length | Petal.Width | Species |
|-------------:|------------:|-------------:|------------:|:--------|
|          5.1 |         3.5 |          1.4 |         0.2 | setosa  |
|          4.9 |         3.0 |          1.4 |         0.2 | setosa  |
|          4.7 |         3.2 |          1.3 |         0.2 | setosa  |
|          4.6 |         3.1 |          1.5 |         0.2 | setosa  |
|          5.0 |         3.6 |          1.4 |         0.2 | setosa  |
|          5.4 |         3.9 |          1.7 |         0.4 | setosa  |

The supervised model performance.

The

## An example using the embedding data in R

``` r
library(dplyr)
library(ggplot2)
library(readr)
library(Rtsne)
library(stringr)

# Download the locations of the embeddings.
dl = readRDS(
  "https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/icd10_dl.rds"
)

# Read in the unspecified injury codes.
icd10s = read_csv(dl$url[dl$year == 2019 & dl$emb_dim = 50]) |>
  filter(str_detect(code, "^(A|B|C|D)")) |>
  mutate(desc = tolower(desc)) |>
  filter(str_detect(desc, "^unspecified")) |>
  mutate(`Leading Letter` = str_sub(code, 1, 1)) |>
  distinct(pick(starts_with("V")), .keep_all = TRUE)

# Fit tSNE to the embedding.
tsne_fit = icd10s |> 
  select(starts_with("V")) |>
  scale() |>
  Rtsne()

# Bind the tSNE values to the data set.
icd10p = bind_cols(
  icd10s |>
    select(-starts_with("V")),
  tsne_fit$Y |>
    as.data.frame() |>
    rename(tSNE1="V1", tSNE2="V2") |>
    as_tibble()
)

# Visualize the results.
ggplot(icd10p, aes(x = tSNE1, y = tSNE2, color = `Leading Letter`)) +
  geom_point() +
  theme_minimal()
```

## Reproducing these results

R version: \>= 4.2

R package dependencies:

- `torch`
- `reticulate`
- `dplyr`
- `tidyr`
- `purrr`
- `foreach`
- `itertoos`
- `readr`
- `luz`
- `tidyr`
- `tibble`
- `progress`
- `stringr`
- `yardstick`

Scripts

- `0-make-embeddings.R`
  - Purpose - create the embeddings created by BioGPT-Large
  - Dependencies
    - A conda evironment with the `torch` and `transformers` packages
      (see the `make-biogpt-conda-env` script)
  - Inputs
    - `icd-10-cm-codes/icd10cm_codes_2019.txt`
    - `icd-10-cm-codes/icd10cm_codes_2020.txt`
    - `icd-10-cm-codes/icd10cm_codes_2021.txt`
    - `icd-10-cm-codes/icd10cm_codes_2022.txt`
  - Outputs
    - An `icd-10-cm-embeddings` directory with subdirectories
      corresponding to each year, and subsubdirectories with files whose
      names correspond to the ICD-10-CM code holding R .rds files with
      the code, description, and BioGPT embedding values stored as a
      `data.frame`.
- `1-compress-icd-10-embeddings.R`
  - Purpose - recreate the embeddings created by BioGPT
  - Dependencies
    - R files: `autoencoder.R`
  - Inputs
  - Outputs
- `2-validation.R`
  - Purpose - recreate the embeddings created by BioGPT-Large
  - Dependencies
    - R files: `autoencoder.R`
  - Inputs
    - Files in the `icd-10-cm-embeddings/2019` directory.
  - Outputs
    - `model-performance.rds` holding a `data.frame` consisting of the
      model performance table.
    - Files in the `autoencoder-models` directory containing model to
      create the compressed embeddings.
- `3-create-datasets.R`
  - Purpose - recreate the embeddings created by BioGPT-Large
  - Dependencies
    - R files: `autoencoder.R`
  - Inputs
    - Files in the `autoencoder-models` directory.
    - Files in the `icd-10-cm-embeddings` directory for all years
      (2019-2020).
  - Outputs
    - `year-validation.rds` holding a data frame of the autoencoder
      year-validation model performance.
    - Files in the `embedding-data` directory holding the embedding
      values as .csv files for all year-dimension combinations.
- `4-estimate-leading-char.R`
  - Purpose - recreate the embeddings created by BioGPT-Large
  - Dependencies
    - R files: `alpha-char-model.R`
  - Inputs
    - Files in the `embedding-data` directory.
  - Outputs
    - Files in the `luz-supervised-models` directory holding the `luz`
      package representation of the fitted models.
    - The `supervised-model-perf.rds` files containing a `data.frame`
      summarizing the supervised model performance.
