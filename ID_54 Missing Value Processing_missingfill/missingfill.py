import csv
from dataclasses import replace
from operator import index
from posixpath import sep
import pandas as pd
import sys
import os
import numpy as np

# python missingfill.py data1.xls 1 0 0 3 3 3 mean-0 csv

input_file = sys.argv[1]
output_file = sys.argv[2]
judge_name01 = sys.argv[3]  


misssing = sys.argv[4]  
misssing_diy = sys.argv[5]  
judge_delete = sys.argv[6]  

missing_diy_proportions = sys.argv[7]  

judge_fill = sys.argv[8]

file_shape = sys.argv[9]

if os.path.splitext(input_file)[1] == '.csv' or os.path.splitext(input_file)[1] == '.txt':
    missing_values = ["n/a", "na", "--", "-", "Na", "NaN", "", "nan"]
    df = pd.read_csv(input_file, na_values=missing_values)
    df = pd.read_csv(sys.argv[1])
elif os.path.splitext(input_file)[1] == '.xlsx':
    missing_values = ["n/a", "na", "--", "-", "Na", "NaN", "", "nan"]
    df = pd.read_excel(input_file, na_values=missing_values)
    df = pd.read_excel(input_file)
else :
    print('')

os.path.splitext(input_file)
if os.path.splitext(input_file)[1] == '.csv'or os.path.splitext(input_file)[1] == '.txt':
    print()
    print('os.path.splitext(input_file)[1]')
    print()
    df = pd.read_csv(input_file)
    
    if judge_name01 == "0":
        df = pd.read_csv(input_file, index_col=0)
        print(df)
        print('done ')
        
        indexs = df._stat_axis.values.tolist()
        columns = df.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
    elif judge_name01 == "1":
        df = pd.read_csv(input_file, header=None, index_col=0)
        print(df)
        print('done ')
        indexs = df._stat_axis.values.tolist()
        columns = df.columns.values.tolist()
        print(indexs)
        # print(df.rpow)
        print('')
        print(columns)
        print('')
    else:
        print('Error')

    

    if misssing == "0":
        df.replace(0, None, inplace=True)
        print('done 0')
    elif misssing == "blank":
        df.replace('', None, inplace=True)
        print('done ')
    elif misssing == "-":
        df.replace('-', None, inplace=True)
        print('done -')
    elif misssing == "--":
        df.replace('--', None, inplace=True)
        print('done --')
    elif misssing == "---":
        df.replace('---', None, inplace=True)
        print('done ---')
    elif misssing == 'diy':
        df.replace(sys.argv[5],  None, inplace=True)
        print('done ')
    else:
        print('Error:')
    

    print(df)
    print('done ')

    
    if judge_delete == '0':
        df7 = df.dropna()
        print(df7)
        print('done ')
    
    elif judge_delete == '1':
        df7 = df.dropna(axis=1)
        print(df7)
        print('done ')

    

    elif judge_delete == 'diy-1':
        
        a = 1-float(missing_diy_proportions)
        t = int(a*df.shape[0])
        df = df.dropna(thresh=t, axis=1)  
        print(df)
        b = round(float(missing_diy_proportions), 2)
        print('done ' % (b))
    elif judge_delete == 'diy-0':
        
        a = 1-float(missing_diy_proportions)
        t = int(a*df.shape[0])
        t = int(a*df.shape[1])
        df = df.dropna(thresh=t)  
        print(df)
        b = round(float(missing_diy_proportions), 2)
        print('done ' % (b))
    else:
        print('done ')
    
    if judge_fill == 'mean-0':
        df.fillna(df.mean(), inplace=True, axis=0)
        print(df)
        print('done ')
    elif judge_fill == 'median-0':
        df.fillna(df.median(), inplace=True, axis=0)
        print(df)
        print('done ')
    elif judge_fill == 'min-0':
        df.fillna(df.min(), inplace=True, axis=0)
        print(df)
        print('done ')
    elif judge_fill == 'max-0':
        df.fillna(df.max(), inplace=True, axis=0)
        print(df)
        print('done ')
        
    elif judge_fill == 'mean-1':
        df = df.T
        df.fillna(df.mean(), inplace=True, axis=0)
        df = df.T
        print(df)
        print('done ')
    elif judge_fill == 'median-1':
        df = df.T
        df.fillna(df.median(), inplace=True, axis=0)
        df = df.T
        print(df)
        print('done ')
    elif judge_fill == 'min-1':
        df = df.T
        df.fillna(df.min(), inplace=True, axis=0)
        df = df.T
        print(df)
        print('done ')
    elif judge_fill == 'max-1':
        df = df.T
        df.fillna(df.max(), inplace=True, axis=0)
        df = df.T
        print(df)
        print('done ')
    else:
        print('')
    if file_shape == 'csv':
        df.to_csv(output_file)
        print('done csv')
    # elif file_shape == 'xlsx':
    #     df.to_excel('output.xlsx')
    #     print('done xlsx')
    else:
        print('Error')
elif os.path.splitext(input_file)[1] == '.xlsx':
    print()
    print('os.path.splitext(input_file)[1]')
    print()
    df = pd.read_excel(input_file)
    
    if judge_name01 == "0":
        df = pd.read_excel(input_file, index_col=0)
        print(df)
        print('done ')
       
        indexs = df._stat_axis.values.tolist()
        columns = df.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
    elif judge_name01 == "1":
        df = pd.read_excel(input_file, header=None, index_col=0)
        print(df)
        print('done ')
        indexs = df._stat_axis.values.tolist()
        columns = df.columns.values.tolist()
        print(indexs)
        # print(df.rpow)
        print('')
        print(columns)
        print('')
    else:
        print('Error')

    

    if misssing == "0":
        df.replace(0, None, inplace=True)
        print('done 0')
    elif misssing == "blank":
        df.replace('', None, inplace=True)
        print('done ')
    elif misssing == "-":
        df.replace('-', None, inplace=True)
        print('done -')
    elif misssing == "--":
        df.replace('--', None, inplace=True)
        print('done --')
    elif misssing == "---":
        df.replace('---', None, inplace=True)
        print('done ---')
    elif misssing == 'diy':
        df.replace(sys.argv[5],  None, inplace=True)
        print('done')
    else:
        print('Error')
   

    print(df)
    print('done')

   
    if judge_delete == '0':
        df7 = df.dropna()
        print(df7)
        print('done')
   
    elif judge_delete == '1':
        df7 = df.dropna(axis=1)
        print(df7)
        print('done')

    

    elif judge_delete == 'diy-1':
        
        a = 1-float(missing_diy_proportions)
        t = int(a*df.shape[0])
        df = df.dropna(thresh=t, axis=1)  
        print(df)
        b = round(float(missing_diy_proportions), 2)
        print('done ' % (b))
    elif judge_delete == 'diy-0':
        # 
        a = 1-float(missing_diy_proportions)
        t = int(a*df.shape[0])
        t = int(a*df.shape[1])
        df = df.dropna(thresh=t)  # 
        print(df)
        b = round(float(missing_diy_proportions), 2)
        print('done ' % (b))
    else:
        print('done ')
    
    if judge_fill == 'mean-0':
        df.fillna(df.mean(), inplace=True, axis=0)
        print(df)
        print('done ')
    elif judge_fill == 'median-0':
        df.fillna(df.median(), inplace=True, axis=0)
        print(df)
        print('done')
    elif judge_fill == 'min-0':
        df.fillna(df.min(), inplace=True, axis=0)
        print(df)
        print('done ')
    elif judge_fill == 'max-0':
        df.fillna(df.max(), inplace=True, axis=0)
        print(df)
        print('done ')
        
    elif judge_fill == 'mean-1':
        df = df.T
        df.fillna(df.mean(), inplace=True, axis=0)
        df = df.T
        print(df)
        print('')
    elif judge_fill == 'median-1':
        df = df.T
        df.fillna(df.median(), inplace=True, axis=0)
        df = df.T
        print(df)
        print('done')
    elif judge_fill == 'min-1':
        df = df.T
        df.fillna(df.min(), inplace=True, axis=0)
        df = df.T
        print(df)
        print('done ')
    elif judge_fill == 'max-1':
        df = df.T
        df.fillna(df.max(), inplace=True, axis=0)
        df = df.T
        print(df)
        print('done')
    else:
        print('')
    if file_shape == 'csv':
        df.to_csv(output_file)
        print('done csv')
    # elif file_shape == 'xlsx':
    #     df.to_excel('output.xlsx')
    #     print('done xlsx')
    else:
        print('Error')
else:
    print('')
    print(os.path.splitext(input_file)[1])