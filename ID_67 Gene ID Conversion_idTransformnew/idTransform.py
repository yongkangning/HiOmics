import sqlite3
import sys

args = sys.argv[1:]
input_file = args[0]
output_file = args[1]
db_name = args[2]
query_column = args[3]
gene_stable_id_isneed = args[4]
gene_name_isneed = args[5]
gene_synonym_isneed = args[6]
ncbi_gene_id_isneed = args[7]
ncbi_gene_description_isneed = args[8]

all_columns = ["gene_stable_id", "gene_name", "gene_synonym", "ncbi_gene_id", "ncbi_gene_description"]
if query_column not in all_columns:
    print("未知字段：{}".format(query_column))
    exit(111)

isout_column = {"gene_stable_id": gene_stable_id_isneed, "gene_name": gene_name_isneed,
                "gene_synonym": gene_synonym_isneed, "ncbi_gene_id": ncbi_gene_id_isneed,
                "ncbi_gene_description": ncbi_gene_description_isneed}
return_columns = [i for i in all_columns if isout_column[i].upper() == "TRUE"]

column_index_map = {i: return_columns.index(i) for i in return_columns}
return_column_join = ",".join(return_columns)

conn = sqlite3.connect(db_name)
c = conn.cursor()
with open(output_file, "w") as out_file:
    with open(input_file, "r") as in_file:
        out_file.write(query_column + "\t" + "\t".join(return_columns) + "\n")
        for line in in_file:
            query_column_value = line.strip()
            sql = '''select {0} from id_transform 
                    where {1} = '{2}' group by {3}'''.format(return_column_join, query_column,
                                                             query_column_value,
                                                             return_column_join)
            cursor = c.execute(sql)
            has_row = False
            for row in cursor:
                res = []
                has_row = True
                for col in return_columns:
                    res.append(row[column_index_map[col]])
                out_file.write(query_column_value + "\t" + "\t".join(res) + "\n")

            if not has_row:
                out_file.write(query_column_value + "\t" + "\t".join([""] * len(return_columns)) + "\n")
conn.close()
