#!/bin/bash
#SBATCH -p workq
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -t 24:00:00
#SBATCH -A loni_gwas_gab 
#SBATCH -o trinity-after-TrimGalore_081522 
#SBATCH -e trinity-after-TrimGalore_081522

#module load trinity/2.4.0/INTEL-14.0.2
#module load bowtie2/2.1.0/INTEL-14.0.2

source /project/sackettl/miniconda3/etc/profile.d/conda.sh
#conda activate trinity-2.11.0
source activate trinity-2.11.0


#skeleton from SI workshop
#Trinity --seqType fq --left /project/sackettl/birdRNA_pilot/*1P --right /project/sackettl/birdRNA_pilot/*2P --min_contig_length 150 --output allbirdsPE.trinity --full_cleanup

#using input file and creating a single assembly for all samples
Trinity --seqType fq --samples_file /work/sackettl/RNApilot_redo/sample-list_for_trinityPE.txt --min_contig_length 150 --CPU 20 --max_memory 40G --output /work/sackettl/RNApilot_redo/allsamplesPE --full_cleanup 



