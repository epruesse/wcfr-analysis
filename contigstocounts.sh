#!/bin/bash

while read -r Sample; do
  bbmap.sh ref=$Sample.contigs.fasta
  #bamscript creates a script called bs.sh then runs it on the sam file to generate a sorted and indexed bam file
  bbmap.sh in=$Sample.R1.fq.gz in2=$Sample.R2.fq.gz out=$Sample.sam bamscript=bs.sh && sh bs.sh
done < Samples.text
