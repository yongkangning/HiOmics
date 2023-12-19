from Bio.Seq import Seq
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
import sys


args = sys.argv
input_file = args[1]
output_file = args[2]
code_table = int(args[3])

code_table_all = [1,2,3,4,5,6,9,10,11,12,13,14,16,
                    21,22,23,24,25,26,27,28,29,30,31,33]
if code_table not in code_table_all:
    print("".format(code_table))
    exit(111)




def split_seq(string, max_width):
    result1 = [string[i:i + max_width] for i in range(0, len(string), max_width)]
    result = '\n'.join(result1)
    return result


with open(output_file, "w") as f:
    for record in SeqIO.parse(input_file, "fasta"):
        f.write(">" + record.id + "\n")
        # print(">" + record.id)
        protein = str(record.seq.translate(table=code_table))
        protein_length = len(protein)
        # if protein_length > 58:
        protein = split_seq(protein, 58)
        f.write(protein + "\n")
