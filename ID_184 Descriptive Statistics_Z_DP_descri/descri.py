
import os,sys
import pandas as pd

input_file = sys.argv[1]

def read_file(input_file):
    global df
    if os.path.splitext(input_file)[1] == '.txt':
        df = pd.read_table(input_file)
    elif os.path.splitext(input_file)[1] == '.csv':
        df = pd.read_csv(input_file)
    elif os.path.splitext(input_file)[1] == '.xlsx' or os.path.splitext(input_file)[1] == '.xls':
        df = pd.read_excel(input_file)


read_file(input_file)


describe = df.describe([0.01,0.1,0.25,0.5,.75,.9,.99]).T
print(df.describe([0.01,0.1,0.25,0.5,.75,.9,.99]).T)

describe.to_csv('./Descriptive_statistics.txt',sep='\t',index_label='')

