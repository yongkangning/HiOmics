import sys
from Bio import SeqIO

if len(sys.argv[1:]) != 3:
    print(sys.argv[1:])
    print("")
    sys.exit(111)
input_file = sys.argv[1]
data_format = sys.argv[2]
batch_size = int(sys.argv[3])

if data_format not in ["fasta", "fastq"]:
    print("")
    sys.exit(222)

def batch_iterator(iterator, batch_size):
    """Returns lists of length batch_size.

    This can be used on any iterator, for example to batch up
    SeqRecord objects from Bio.SeqIO.parse(...), or to batch
    Alignment objects from Bio.AlignIO.parse(...), or simply
    lines from a file handle.

    This is a generator function, and it returns lists of the
    entries from the supplied iterator.  Each list will have
    batch_size entries, although the final list may be shorter.
    """
    entry = True  # Make sure we loop once
    while entry:
        batch = []
        while len(batch) < batch_size:
            try:
                entry = iterator.__next__()
            except StopIteration:
                entry = None
            if entry is None:
                # End of file
                break
            batch.append(entry)
        if batch:
            yield batch

record_iter = SeqIO.parse(open(input_file), data_format)
for i, batch in enumerate(batch_iterator(record_iter, batch_size)):
    filename = "part{0}.{1}".format(i + 1, data_format)
    with open(filename, "w") as handle:
        count = SeqIO.write(batch, handle, data_format)
    # print("Wrote {0} records to {1}".format(count, filename))
