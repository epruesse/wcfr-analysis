#!/bin/bash

mkdir -p blast
mkdir -p clustered
mkdir -p aligned
aasequence=$1

while read -r Sample; do
  #assembles the trimmed reads into contigs with megahit
  megahit -1 ./trimmedreads/$Sample.R1.fq.gz -2 ./trimmedreads/$Sample.R2.fq.gz -o contigs --out-prefix $Sample && gzip ./contigs/$Sample.contigs.fa
  #next two lines move contigs up to wd and remove megahit -o directory to avoid megahit error
  mv ./contigs/$Sample.contigs.fa.gz ./$Sample.contigs.fasta.gz
  rm -r contigs
  #runs a tblastn translated nucleotide to protein search using a query protein sequence provided as the first positional argument
  gunzip -c $Sample.contigs.fasta.gz | \
  xargs -I file tblastn -query $aasequence -subject file -out $Sample.blast7 -outfmt "7 qacc sacc pident length mismatch gapopen qstart qend sstart send evalue bitscore sstrand sframe score"
  #runs the blast_to_gtf python script to convert the blast7 results to a gtf file
  python blast_to_gtf.py $Sample.blast7
  mv ./$Sample.blast7 ./blast/
  mv ./$Sample.gtf ./blast/
  #removes sequences from the gtf file scoring less than 10^-90
  awk -F"\t" '$6 <= 1*10^-90 {print}' ./blast/$Sample.gtf > ./blast/$Sample.filtered.gtf
  #runs 'bedtools getfasta' to output a fasta file with just the contigs identified in a gtf filename
  bedtools getfasta -fi $Sample.contigs.fasta -bed ./blast/$Sample.filtered.gtf -fo ./$Sample.hits.fasta
  #runs cd-hit-est to cluster nucleotide sequences by similarity
  cd-hit-est -i $Sample.hits.fasta -o ./clustered/$Sample.clust.fasta -T 8
done < Samples.text

cat ./clustered/*.clust.fasta > ./all.clustered.fasta
#runs mafft to align output of clustered reads
mafft --thread 8 --nuc all.clustered.fasta > ./aligned/multiple.alignment.fasta
#runs iqtree to tree the alignments
iqtree -nt 8 -s ./aligned/multiple.alignment.fasta
