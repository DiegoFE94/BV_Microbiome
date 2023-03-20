setwd(dirname(rstudioapi::getSourceEditorContext()$path))
# 1.Descargar el enaBrowserTools desde el siguiente link: https://github.com/enasequence/enaBrowserTools

# 2.Descargar FASTQC desde el siguiente link: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

# 3.Filtrado de las muestras de 2013 del PRJNA208535
PRJNA208535 <- data.frame(read.delim(url("https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJNA208535&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,submission_accession,tax_id,scientific_name,instrument_platform,instrument_model,library_name,nominal_length,library_layout,library_strategy,library_source,library_selection,read_count,base_count,center_name,first_public,last_updated,experiment_title,study_title,study_alias,experiment_alias,run_alias,fastq_bytes,fastq_md5,fastq_ftp,fastq_aspera,fastq_galaxy,submitted_bytes,submitted_md5,submitted_ftp,submitted_aspera,submitted_galaxy,submitted_format,sra_bytes,sra_md5,sra_ftp,sra_aspera,sra_galaxy,cram_index_ftp,cram_index_aspera,cram_index_galaxy,sample_alias,broker_name,sample_title,nominal_sdev,first_created&format=tsv&download=true&limit=0"), header = TRUE))
PRJNA208535$first_created <- substr(PRJNA208535$first_created, 1, 4)
PRJNA208535<- PRJNA208535[PRJNA208535$first_created == "2013",]
maintain <- c("run_accession","sample_title", "sample_alias", "library_layout",
              "instrument_platform", "instrument_model", "first_created")
PRJNA208535 <- PRJNA208535[, maintain]
# Las muestras de Ravel de 2013  son single, regiones V1-V3 y tecnología 454
# Por las regiones tendríamos un tamaño total de ~510 pb.
# Para descargar los fastq lo que nos interesa es el run_accession
samples <- PRJNA208535$run_accession

# 4.Ahora creamos directorio para alojar las muestras descargadas
dir.create(path = "PRJNA208535/")
setwd(dir <- paste0("PRJNA208535"))

# 5.Declaramos el path a la funcion enaDataGet 
path_ena <- "/Users/diego/Programas/enaBrowserTools/python3/enaDataGet" # Cambiar para donde la tengas

# 5.1.Corremos en la terminal donde vamos a descargar cada muestars de "samples"
for (i in seq_along(samples)) {
  system(command = paste(path_ena, "-f fastq -m", samples[i]))
}

# 6. Una vez descargadas habría que comprobar la calidad con el Fastqc
# para saber donde meter el corte. Declaramos path al programa Fastqc y
# a la carpeta donde descargamos los Fastq
path_fastq <- "~/git/BV_Microbiome/PRJNA302078"
path_fastqc <- "~/Programas/FastQC/fastqc"
# 6.1.Listamos de manera recursiva todos los fastq (Debería haber 1657 sino algo falla)
l <- list.files(path_fastq, pattern = "fastq.gz", include.dirs = TRUE, recursive = TRUE, full.names = TRUE)
# 6.2.Cremamos una lista con los comandos y las muestras para correr fastqc y la corremos
cmd <- list()
for (i in seq_along(l)){
  cmd[[i]] <- paste0(path_fastqc, " ", l[[i]])
}
for (i in seq_along(cmd)){
  system(cmd[[i]])
}

# 7. Una vez hecho esto yo abriría 10-15 y me quedaría más o menos donde cortar
# Yo miré las 5 primeras, la primera tiene una longitud de > de 1000pb y 50000
# lecturas pb no sé a que se debe. Las otras 4 parecen estar bien y de una calidad bastante buena
# Yo le metería el corte cerca de 500 pb
# En la pipeline te dejo puesto de corte 490, te pongo los parametros indicados
# para la tecnología 454 y el resto de los parámetros los dejo por default

# 8 Antes de correr la pipeline hay que descargar las bases de datos de referencia
# de Silva:
# -General: https://zenodo.org/record/4587955/files/silva_nr99_v138.1_train_set.fa.gz?download=1
# -Especies: https://zenodo.org/record/4587955/files/silva_nr99_v138.1_wSpecies_train_set.fa.gz?download=1
# **** Acuerdate de cambiar el path en el config file de estas dos bases de datos ****

# Ravel con muestreas de 2013 y 2021 (6593 muestras) Single V1-V3 region 454 (510 pb)
PRJNA208535 <- data.frame(read.delim(url("https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJNA208535&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,submission_accession,tax_id,scientific_name,instrument_platform,instrument_model,library_name,nominal_length,library_layout,library_strategy,library_source,library_selection,read_count,base_count,center_name,first_public,last_updated,experiment_title,study_title,study_alias,experiment_alias,run_alias,fastq_bytes,fastq_md5,fastq_ftp,fastq_aspera,fastq_galaxy,submitted_bytes,submitted_md5,submitted_ftp,submitted_aspera,submitted_galaxy,submitted_format,sra_bytes,sra_md5,sra_ftp,sra_aspera,sra_galaxy,cram_index_ftp,cram_index_aspera,cram_index_galaxy,sample_alias,broker_name,sample_title,nominal_sdev,first_created&format=tsv&download=true&limit=0"), header = TRUE))
PRJNA208535$first_created <- substr(PRJNA208535$first_created, 1, 4)
PRJNA208535<- PRJNA208535[PRJNA208535$first_created == "2013",]
PRJNA208535_CD <- read.xlsx("~/git/BV_Microbiome/40168_2013_28_MOESM1_ESM.xlsx", startRow = 4, sheet = 1)

# Ravel 2023 Paired Illumina 
PRJNA797778 <- data.frame(read.delim(url("https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJNA797778&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,submission_accession,tax_id,scientific_name,instrument_platform,instrument_model,library_name,nominal_length,library_layout,library_strategy,library_source,library_selection,read_count,base_count,center_name,first_public,last_updated,experiment_title,study_title,study_alias,experiment_alias,run_alias,fastq_bytes,fastq_md5,fastq_ftp,fastq_aspera,fastq_galaxy,submitted_bytes,submitted_md5,submitted_ftp,submitted_aspera,submitted_galaxy,submitted_format,sra_bytes,sra_md5,sra_ftp,sra_aspera,sra_galaxy,cram_index_ftp,cram_index_aspera,cram_index_galaxy,sample_alias,broker_name,sample_title,nominal_sdev,first_created&format=tsv&download=true&limit=0"), header = TRUE)) # No existe en el ena
PRJNA797778<- PRJNA797778[PRJNA797778$library_strategy == "AMPLICON",]
PRJNA797778$first_created <- substr(PRJNA797778$first_created, 1, 4)
maintain <- c("run_accession","sample_title", "sample_alias", "library_layout",
              "instrument_platform", "instrument_model", "first_created")
PRJNA797778 <- PRJNA797778[,maintain]
samples <- PRJNA797778$run_accession
PRJNA797778_subset <- PRJNA797778[grep("_W", PRJNA797778$sample_alias), ]
PRJNA797778_subset <- data.frame(PRJNA797778_subset[,-1], row.names=PRJNA797778_subset[,1])
saveRDS(object = PRJNA797778_subset, file = "extdata/PRJNA797778/PRJNA797778_metadata.rds")

# Cohorte fármaco
PRJNA302078 <- data.frame(read.delim(url("https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJNA302078&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,submission_accession,tax_id,scientific_name,instrument_platform,instrument_model,library_name,nominal_length,library_layout,library_strategy,library_source,library_selection,read_count,base_count,center_name,first_public,last_updated,experiment_title,study_title,study_alias,experiment_alias,run_alias,fastq_bytes,fastq_md5,fastq_ftp,fastq_aspera,fastq_galaxy,submitted_bytes,submitted_md5,submitted_ftp,submitted_aspera,submitted_galaxy,submitted_format,sra_bytes,sra_md5,sra_ftp,sra_aspera,sra_galaxy,cram_index_ftp,cram_index_aspera,cram_index_galaxy,sample_alias,broker_name,sample_title,nominal_sdev,first_created&format=tsv&download=true&limit=0"), header = TRUE))
samples <- PRJNA302078$run_accession
PRJNA302078$first_created <- substr(PRJNA302078$first_created, 1, 4)
maintain <- c("run_accession","sample_title", "sample_alias", "library_layout",
              "instrument_platform", "instrument_model", "first_created")
PRJNA302078 <- PRJNA302078[,maintain]
d0_subset <- PRJNA302078[grep("D0", PRJNA302078$sample_alias), ]
sample_names <- strsplit(PRJNA302078$sample_alias, "D", 1)
PRJNA302078$sample_ID <- sapply(strsplit(basename(PRJNA302078$sample_alias), "D"), `[`, 1)
cd <- read.delim(file = "PRJNA302078/PRJNA302078_mdata.csv", header = TRUE,sep = ";")
metadata <- merge(x = cd, y = PRJNA302078, by.x = "ID", by.y = "sample_ID")
metadata <- data.frame(metadata[,-3], row.names=metadata[,3])
saveRDS(object = metadata, file = "extdata/PRJNA302078/PRJNA302078_metadata.rds")