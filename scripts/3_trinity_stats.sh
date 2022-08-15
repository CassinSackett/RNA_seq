#!/bin/bash
#SBATCH -p single
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 1:00:00
#SBATCH -A loni_gwas_gab 
#SBATCH -o trinity-stats_081522 
#SBATCH -e trinity-stats_081522

#module load trinity/2.4.0/INTEL-14.0.2
#module load bowtie2/2.1.0/INTEL-14.0.2

source /project/sackettl/miniconda3/etc/profile.d/conda.sh
#conda activate trinity-2.11.0
source activate trinity-2.11.0

/project/sackettl/miniconda3/envs/trinity-2.11.0/bin/TrinityStats.pl /work/sackettl/RNApilot_redo/trinity_out_dir/Trinity.fasta



