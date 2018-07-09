#!/bin/bash

for filename in *.tsv; do
  echo $filename >> Samples.txt
done

python3 make_otu_table2.py Samples.txt >> otu_table.tsv
