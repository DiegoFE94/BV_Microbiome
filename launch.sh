#!/bin/bash
#SBATCH -N 1
#SBATCH -p thinnodes
#SBATCH -t 01:00:00
#SBATCH --mem=16G

module load gcc/6.4.0 R/4.0.2
TMP=/mnt/netapp2/Store_uni/home/ulc/co/dfe/TEMPR Rscript /home/ulc/co/dfe/git/Entropy/TaxaAcquisition2.R
