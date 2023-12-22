
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
        
def count():

    df1 = df.isnull().sum()
    # print(df.isnull().sum())
    
    df2 = df.isnull().mean()

    df3 = pd.concat([df1,df2],axis=1)
    # print(df.isnull().mean())
    df3.columns=['','']

    df3.to_csv('./Missing_value_statistics.txt',sep='\t',index_label='')
    # print(df3)

def main():
    read_file(input_file)
    count()

if __name__ == '__main__':
    main()