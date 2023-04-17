require(phyloseq)
require(dplyr)
require(reshape2)
require(tidyverse)

# Arguments
setwd("~/../git/vaginosis-jlb/")
data_dir <- "extdata/"
out_dir <- "MEFISTO/data/"
cohort <- "PRJNA302078"

# Load data from cohort PRJNA302078
files <- list.files(data_dir)
file <- files[grep(cohort, files)]
pseq <- readRDS(
  file.path(
    data_dir, file
  ))

# Preprocess otu table
pseq <- tax_glom(pseq, taxrank =  "Species")                                      # agglomerating by taxa
pseq <- microbiome::transform(pseq, transform = "clr", shift = 1, reference = 1)  # normalization

# Format clinical variable
sample_id <- get_variable(pseq, "sample_alias")
id <- sapply(strsplit(sample_id, "D"), "[", 1)
time <- as.numeric(sapply(strsplit(sample_id, "D"), "[", 2))
sample_data(pseq)$time <- time
sample_data(pseq)$id <- id

# Prepare data
otu <- 
  data.frame(otu_table(pseq)) %>% 
  rownames_to_column(var = "ASV") %>% 
  melt()

taxa <- 
  data.frame(tax_table(pseq)) %>% 
  rownames_to_column(var = "ASV")

meta <- 
  data.frame(sample_data(pseq)) %>% 
  rownames_to_column(var = "variable")

microbiome <- 
  left_join(otu, meta, by = "variable") %>% 
  rename(
    sample = sample_alias,
    feature = ASV,
    group = id) %>% 
  mutate(view = "microbiome")
feature_meta <- left_join(otu, taxa, by = "ASV")

saveRDS(microbiome, file = file.path(out_dir, paste0(cohort, "_microbiome.rds")))
saveRDS(feature_meta, file = file.path(out_dir, paste0(cohort, "_featdata.rds")))