import sys
from Bio import SeqIO

if len(sys.argv[1:]) != 2:
    print("")
    sys.exit(111)
input_file = sys.argv[1]
output_file = sys.argv[2]

with open(output_file,"w") as f:
    for seq_record in SeqIO.parse(input_file, "fastq"):
        sequence = str(seq_record.seq)
        f.write(">" + seq_record.id + "\n" + sequence + "\n")

