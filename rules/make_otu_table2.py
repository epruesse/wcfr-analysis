#!/usr/bin/python3

import csv
import sys

#takes a list of filenames, files should be one tsv of all uqiue otu/count pairs in each sample
filelist = sys.argv[1]

samples = []
with open(filelist, "r") as files:
    for file in files:
        samples.append(file.rstrip("\n"))

#list where each entry corresponds to a sample and entries are a dictionary of otu:count pairs
counts = []
#list of all unique otus across all samples
otus = []

for sample in samples:
    counts.append({})
    with open(sample, "r") as tsv:
        reader = csv.reader(tsv, delimiter="\t")
        #each row from tsv generates a list of strings seperated on "\t", ex. ["otu", "length", "count"]
        for row in reader:
            if row[0] == "name":
                continue
            otu = row[0]
            if otu == "*":
                break
            #Divide the read count by length of the otu to normalize
            count = int(row[2]) / int(row[1])
            counts[-1][otu]=count
            if otu not in otus: otus.append(otu)

otu_table = []
for otu in otus:
    otu_table.append([0]*len(samples))
    for i in range(len(counts)):
        if otu in counts[i]:
            otu_table[-1][i]=counts[i][otu]

header = print("#OTU", *samples, sep="\t")
for i in range(len(otu_table)):
    rows = otus[i] + "\t"
    for j in otu_table[i]: rows+= str(j)+"\t"
    print(rows)
