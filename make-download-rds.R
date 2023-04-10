library(tibble)
library(tidyr)

icd10_dl = expand_grid(
  tibble(year = 2019:2022),
  tibble(emb_dim = c(10, 50, 100, 1000))
)

icd10_dl$url = 
  sprintf(
    "https://github.com/kaneplusplus/icd-10-cm-embedding/blob/main/embedding-data/icd-10-cm-%d-%04d.csv?raw=true", 
    icd10_dl$year,
    icd10_dl$emb_dim
  )

saveRDS(icd10_dl, "icd10_dl.rds")
