#!/bin/bash
#SBATCH -p single
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -t 6:00:00
#SBATCH -A loni_gwas_ajax 
#SBATCH -o trimgaloreQ14adaptors_retainpaired2ndset_081222 
#SBATCH -e trimgaloreQ14adaptors_retainpaired2ndset_081222

source /project/sackettl/miniconda3/etc/profile.d/conda.sh
#conda activate trinity-2.11.0
source activate cutadaptenv

for i in /work/sackettl/RNApilot_redo/fastqs/*R1_001.fastq; do /project/sackettl/birdRNA_pilot/TrimGalore/trim_galore --paired $i ${i%R1_001.fastq}R2_001.fastq -q 14 --stringency 2 --length 35 --retain_unpaired --path_to_cutadapt /project/sackettl/miniconda3/envs/cutadaptenv/bin/cutadapt; done

