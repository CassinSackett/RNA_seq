#!/bin/bash
#PBS -j oe
#PBS -o bowtie_allbirds_trimmo35_output
#PBS -N bowtie_allbirds_trimmo35_100120

source /sackettl/miniconda3/etc/profile.d/conda.sh
conda activate trinity-2.11.0

bowtie2-build /sackettl/birdRNA_pilot/trinityfiles/allbirds_trinity_trimmo35.Trinity.fasta allbirds_trimmo35_assembly
