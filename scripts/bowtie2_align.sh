#!/bin/bash
#PBS -j oe
#PBS -o bowtiealign2_allbirdsPE_originalfqs_output
#PBS -N bowtiealign2_allbirdsPE_originalfqs_101420

source /sackettl/miniconda3/etc/profile.d/conda.sh
conda activate trinity-2.11.0

for i in /sackettl/birdRNA_pilot/*1.fastq.gz; do bowtie2 -q --no-unal -k 30 -x /sackettl/birdRNA_pilot/bowtie2/allbirdsPE_assembly -1 $i -2 ${i%1.fastq.gz}2.fastq.gz 2>${i%1.fastq.gz}alignmentstats_rawfqtoPE.txt | samtools view -@10 -Sb -o ${i%1.fastq.gz}rawfqPE.bowtiealn2.bam; done
