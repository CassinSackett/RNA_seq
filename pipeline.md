Transcriptomics pipeline, adapted from Smithsonian Institution workshop https://github.com/SmithsonianWorkshops/2020-01-28-NMNH-RNAseq

#### 1. Read quality assessment with FASTQC
$ for i in *.fastq; do fastqc $i; done

#### 2. Trimming adapters with TrimGalore TrimGalore will auto-detect what adapters are present and remove very low quality reads (quality score <20) by default.
$ mkdir trimgalore
$ cd trimgalore
$ for i in *1.fastq; do trim_galore --paired --retain_unpaired $i ${i%1.fastq}2.fastq; done

#### 3. Running Trinity can be tricky depending on how everything is installed on the cluster. I had to install it within a conda environment, so the 'source' and conda steps are related to calling Trinity using conda.
$ mkdir trinity
$ cd trinity

####My script to run it on the cluster looks like this. On a cluster I prefer to type the whole path to files, which I am usually not showing here for clarity.
####Consider your files when setting up the job script. Running a typical Trinity job requires ~1 hour and ~1G RAM per ~1 million PE reads. 
source /project/sackettl/miniconda3/etc/profile.d/conda.sh
conda activate trinity-2.11.0
/path/Trinity --seqType fq --max_memory 10G --samples_file /path/samplelist_trinityPE.txt --min_contig_length 150 --output /path/allbirdsPE_trinity --full_cleanup

#### 4. Evaluate the Trinity assembly in these steps. Note that g1 refers to gene 1 and i1 refers to isoform 1. There can be many isoforms per gene. This can become important in downstream applications such as orthology assessment or differential expression.
####You should have the assembly written to allbirdsPE_trinity.Trinity.fasta and a gene map file allbirdsPE_trinity.Trinity.fasta.gene_trans_map. Check out the first few lines of the assembly:
$ head RNA_Eye.trinity.Trinity.fasta

####Now check how many transcripts were assembled. An easy way to do this is to count the number of > in the fasta file. These each correspond to a transcript. You can do this with grep. 
$ grep -c '>' allbirdsPE_trinity.Trinity.fasta

####Generate stats about the transcripts. This will be a very short job.
$ /path/TrinityStats.pl /path/allbirdsPE_trinity.Trinity.fasta

####Generate more useful stats as described here: https://github.com/trinityrnaseq/trinityrnaseq/wiki/RNA-Seq-Read-Representation-by-Trinity-Assembly
####First, build a bowtie2 index for the transcriptome (this creates files with the 'assembly' part as a prefix). This is used to map the reads in the next step.
$ /path/bowtie2-build /path/allbirdsPE_trinity.Trinity.fasta /path/allbirdsPE_assembly

####Now map the original reads individually back to the assembly. Files ending in P are the trimmed fastq files from trimgalore.
$ for i in /path/*_1P; do bowtie2 -q --no-unal -k 20 -x /path/allbirdsPE_assembly -1 $i -2 ${i%1P}2P 2>${i%1P}align_stats.txt | samtools view -@10 -Sb -o ${i%1P}bowtiealn.bam; done

####Visualize the statistics. A typical Trinity transcriptome assembly will have the vast majority of all reads mapping back to the assembly, and ~70-80% of the mapped fragments found mapped as proper pairs (yielding concordant alignments 1 or more times to the reconstructed transcriptome).
$ less align_stats.txt

####Assess number of full-length coding transcripts. the .pep file is the blast database. **First I needed to break the fasta file into a bunch of pieces to make it run faster (took 72 hours to get the first <400 hits when blasting against nr)**:

$ split -l 600 /path/allbirdsPE_trinity.Trinity.fasta allbirds_trinity_Q14trimmo35Trinity_part
$ for i in allbirds_trinity_Q14trimmo35Trinity_part*; do blastx -query $i -db /path/mini_sprot.pep -out ${i/allbirds_trinity_Q14trimmo35Trinity_part/allbirds_blastx_outfmt6_part} -evalue 1e-20 -max_target_seqs 1 -outfmt 6; done

####create a table of counts, e.g., 2 transcripts had were between 90 and 100% length, 0 were between 80 and 90%, etc. The far right column is a cumulative number.
$ /trinitypath/analyze_blastPlus_topHit_coverage.pl birds_blastx.outfmt6 /path/allbirdsPE_trinity.Trinity.fasta /path/mini_sprot.pep | column -t

#### 5. Estimate abundance of transcripts with RSEM
$ trinity-2.11.0/bin/align_and_estimate_abundance.pl --seqType fq --samples_file /path/samplelist_trinityPE.txt --transcripts /path/allbirdsPE_trinity.Trinity.fasta --est_method RSEM --aln_method bowtie --trinity_mode --prep_reference --coordsort_bam --output_dir allbirdsPE.RSEM

####Generate a transcript counts matrix and perform cross-sample normalization. Is there a way to autumate instead of typing sample names individually? Certainly with RegEx 
$ path_to_trinity/bin/abundance_estimates_to_matrix.pl --est_method RSEM --out_prefix allbirdsPE_counts --name_sample_by_basedir --gene_trans_map /path/allbirdsPE_trinity.Trinity.fasta.gene_trans_map /path/r10_high/RSEM.isoforms.results r12_low/RSEM.isoforms.results

####Look at the at the first 20 lines of the isoform counts. Do the same for the normalized TMM.EXPR.matrix
$ head -20 allbirdsPE_counts.isoform.counts.matrix | column -t
$ less -S allbirdsPE_counts.isoform.counts.matrix 

#### 6. Test for differential gene expression (DGE) between groups
####Create a tab-delimited samples file with treatment/group in the first column and name of the sample folder in  the second column, e.g.
low	r14_low
high	r2_high

####Run the DE analysis using edgeR
$ /trinity-2.11.0/bin/run_DE_analysis.pl --matrix /path/allbirdsPE_counts.isoform.TMM.EXPR.matrix --samples_file /path/sample-list_forDGE.txt --method edgeR --output edgeR_trans

####Download the pdf plot to your local computer
$ $ scp you@server:/path/diffExpr.P1e-3_C2.matrix.log2.centered.genes_vs_samples_Volcano.pdf

####Get just the differentially expressed genes. This did not generate a heatmap for me even when I adjusted the p value...
$ /trinity-2.11.0/bin/analyze_diff_expr.pl --matrix /path/Trinity_trans.isoform.TMM.EXPR.matrix --samples ./samples.txt -P 1e-3 -C 2 

####Count the number of DE genes at the previously specified threshold (subtract 1 from the number since there is a header line)
$ wc -l diffExpr.P1e-3_C2.matrix

####Look at the heatmap of the differentially expressed transcripts. 
$ scp you@server:/path/diffExpr.P1e-3_C2.matrix.log2.centered.genes_vs_samples_heatmap.pdf ./

####You can also cut the dendrogram to view transcript clusters that share similar expression profiles.
$ define_clusters_by_cutting_tree.pl --Ptree 60 -R diffExpr.P1e-3_C2.matrix.RData

#### Extract candidate transcripts from the transcriptome so you can blast
First, take the first column of your DE results at the significance cutoff you choose:
$ cut -f1 DE_results > candidate_transcripts.txt

Next, extract the transcript sequences from the transcriptome assembly:
cat trinity-transcripts_infection-candidates.txt | while read line
do
        grep -A1 $line trinityfiles/allbirdsPE_trinity.Trinity.fasta > $line.fasta
done

and then (using a unique identifier - mine happened to be all isoform 1s):
$ cat *_i1.fasta > all_candidates_toblast.fasta

Now you can blast these candidates to SwissProt.


#### 7.  Test for enrichment of GO terms in Trinotate
# step 7a - create sqlite
Trinotate --db Trinotate.sqlite --create --trinotate_data_dir ./TRINOTATE_DATA_DIR

# step 7b - load sqlite database with my Trinity transcripts & predicted protein seqs - generates Trinotate.xls
Trinotate --db Trinotate.sqlite --init --gene_trans_map ../trinityfiles/allbirdsPE_trinity.Trinity.fasta.gene_trans_map \
	--transcript_fasta ../trinityfiles/allbirdsPE_trinity.Trinity.fasta \
	--transdecoder_pep ../TransDecoder-TransDecoder-v5.7.1/allbirdsPE_trinity.Trinity.fasta.transdecoder.pep

# step 7c run blast so we can add annotations to the existing Trinotate.xls file 
Trinotate --db Trinotate.sqlite --CPU 44 --transcript_fasta ../trinityfiles/allbirdsPE_trinity.Trinity.fasta \
	--transdecoder_pep ../TransDecoder-TransDecoder-v5.7.1/allbirdsPE_trinity.Trinity.fasta.transdecoder.pep \
	--trinotate_data_dir TRINOTATE_DATA_DIR \
	--run "swissprot_blastp swissprot_blastx pfam signalp6 tmhmmv2 infernal EggnogMapper" \
	--use_diamond

# step 7d - create annotation report, adding the previously generated annotations
#Trinotate --db Trinotate.sqlite --report > Trinotate.xls
Trinotate --db Trinotate.sqlite --report -E 1e-3 --incl_pep --incl_trans > TrinotateE-3transpep.xls

# step 7e - extract GO assignments for each gene feature. -G is for gene mode; -T is for transcript mode
${TRINOTATE_HOME}/util/extract_GO_assignments_from_Trinotate_xls.pl --Trinotate_xls /birdRNA_pilot/TRINOTATE/TrinotateE-3transpep.xls \
        -T --include_ancestral_terms > go_annotations_iso.txt

# step 7f - use GOseq to perform functional enrichment -- go to trinity
$TRINITY_HOME/Analysis/DifferentialExpression/analyze_diff_expr.pl --matrix /\birdRNA_pilot/quant/allbirdsPE_counts.isoform.TMM.EXPR.matrix \
        --samples /birdRNA_pilot/DGE/sample-list_forDGE_infectstatus.txt -P 0.051 --output edgeR_trans_infectGOiso \
        --examine_GO_enrichment --GO_annots ../../TRINOTATE/go_annotations_iso.txt \
        --gene_lengths ../../Trinity.fasta.seq_lens

