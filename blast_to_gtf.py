import sys
from ymp import blast, gff

blasthit = sys.argv[1]
gtf = (blasthit.split(".")[0]) + ".gtf"

with open(blasthit, "r") as inf, open(gtf, "w") as outf:
    writer = gff.writer(outf)
    for hit in blast.reader(inf):
        feature = gff.Feature(
            seqid=hit.sacc,
            source='BLAST',
            type='CDS',
            start=min(hit.sstart, hit.send),
            end=max(hit.sstart, hit.send),
            score=hit.evalue,
            strand='+' if hit.sframe > 0 else '-',
            phase='0',
            attributes="ID={}_{}_{};Name={}".format(
                hit.sacc, hit.sstart, hit.send,
                hit.qacc)
        )
        writer.write(feature)
