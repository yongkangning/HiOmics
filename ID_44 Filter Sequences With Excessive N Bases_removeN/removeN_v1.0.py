import os.path
import sys
from Bio import SeqIO

if len(sys.argv[1:]) != 3:
    print("")
    sys.exit(111)
input_file = sys.argv[1]
data_format = sys.argv[2]
n_per = sys.argv[3]

if data_format not in ["fasta","fastq"]:
    print("")
    sys.exit(222)

output_file = "clean_" + os.path.basename(input_file)
with open(output_file,"w") as f:
    for seq_record in SeqIO.parse(input_file, data_format):
        sequence = str(seq_record.seq).upper()
        if float(sequence.count("N")) / float(len(sequence)) * 100 <= float(n_per):
            if data_format == "fasta":
                f.write(">" + seq_record.id + "\n" + sequence + "\n")
            else:
                phredStr = "".join([chr(i + 33) for i in seq_record.letter_annotations["phred_quality"]])
                f.write("@" + seq_record.id + "\n" + sequence + "\n+\n" + phredStr + "\n")

