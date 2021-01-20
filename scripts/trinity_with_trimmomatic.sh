#!/bin/bash
#PBS -j oe
#PBS -o trinity_allbirdsPE_output
#PBS -N trinity_allbirdsPE_080320

source /project/sackettl/miniconda3/etc/profile.d/conda.sh
conda activate trinity-2.11.0

#skeleton from SI workshop
#Trinity --seqType fq --left /sackettl/birdRNA_pilot/*1P --right /sackettl/birdRNA_pilot/*2P --min_contig_length 150 --output allbirdsPE.trinity --full_cleanup

#using input file
/sackettl/miniconda3/envs/trinity-2.11.0/bin/Trinity --seqType fq --max_memory 10G --samples_file /sackettl/birdRNA_pilot/trinityfiles/rawsample-list_for_trinity-w-trimmo.txt --min_contig_length 150 --trimmomatic --quality_trimming_params "ILLUMINACLIP:/sackettl/birdRNA_pilot/NexteraPE-PE_plusextras.fa:2:30:10:6:true LEADING:5 TRAILING:5 SLIDINGWINDOW:5:12 MINLEN:30" --output /sackettl/birdRNA_pilot/trinityfiles/allbirds_trinity_Q12trimmo30 --full_cleanup
