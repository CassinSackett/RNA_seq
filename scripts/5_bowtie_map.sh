#!/bin/bash
#SBATCH -p workq
#SBATCH -N 1
#SBATCH -n 24
#SBATCH -t 24:00:00
#SBATCH -A loni_gwas_gab 
#SBATCH -o bowtie-map_081522 
#SBATCH -e bowtie-map_081522

#module load trinity/2.4.0/INTEL-14.0.2
#module load bowtie2/2.1.0/INTEL-14.0.2

source /project/sackettl/miniconda3/etc/profile.d/conda.sh
#conda activate trinity-2.11.0
source activate trinity-2.11.0

for i in /work/sackettl/RNApilot_redo/trimgalore_fastqs/*val_1.fq; do /project/sackettl/miniconda3/envs/trinity-2.11.0/bin/bowtie2 -q --no-unal -k 20 -x /work/sackettl/RNApilot_redo/trinity_out_dir/allsamplesPE_assembly -1 $i -2 ${i%1.fq}2.fq 2>${i%1.fq}align_stats.txt | /project/sackettl/miniconda3/envs/trinity-2.11.0/bin/samtools view -@10 -Sb -o ${i%1.fq}bowtiealn.bam; done



