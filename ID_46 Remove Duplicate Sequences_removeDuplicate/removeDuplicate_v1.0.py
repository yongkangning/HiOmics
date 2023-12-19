import sys
from Bio import SeqIO

if len(sys.argv[1:]) != 2:
    print("参数个数不正确！")
    sys.exit(111)
input_file = sys.argv[1]
output_file = sys.argv[2]

sequences = {}
for seq_record in SeqIO.parse(input_file, "fasta"):
    sequence = str(seq_record.seq).upper()
    if sequence not in sequences:
        sequences[sequence] = [seq_record.id]
    else:
        sequences[sequence].append(seq_record.id)

with open(output_file,"w") as f:
    for sequence in sequences:
        f.write(">" + "|".join(sequences[sequence]) + "\n" + sequence + "\n")


