#!/bin/bash
#PBS -j oe
#PBS -o blast2.10_swissprot_all_output
#PBS -N blast2.10_swissprot_all_092720

cd $PBS_O_WORKDIR
source /sackettl/miniconda3/etc/profile.d/conda.sh
#conda activate trinity-2.11.0
conda activate blast-2.10.1
export BLASTDB=/sackettl/birdRNA_pilot/bowtie2/nr


/sackettl/miniconda3/envs/blast-2.10.1/bin/blastx -query /sackettl/birdRNA_pilot/trinityfiles/allbirds_trinity_trimmo.Trinity.fasta -db swissprot  -out /sackettl/birdRNA_pilot/trinityfiles/allbirds_blastx_swp.out -evalue 1e-20 -max_target_seqs 1 -outfmt 6 -num_threads 20
