#!/usr/bin/env python
# coding: utf-8
# task Normalization

from cgitb import handler
from cmath import log
from email.quoprimime import header_check
import numpy as np
import pandas as pd
import sys
import os
import math


input_file = sys.argv[1]
judge_name01 = sys.argv[2]  

mode_choose = sys.argv[3]

mode_range = sys.argv[4]


def judge(input_file):
    
    if judge_name01 == "0" and os.path.splitext(input_file)[1] == '.csv' :
        a = pd.read_csv(input_file, index_col=0, header=0)
        print(a)
        print('done -csv')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "0" and os.path.splitext(input_file)[1] == '.xlsx' :
        a = pd.read_excel(input_file, index_col=0, header=0)
        print(a)
        print('done -xlsx')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "0" and os.path.splitext(input_file)[1] == '.xls' :
        a = pd.read_excel(input_file, index_col=0, header=0)
        print(a)
        print('done -xls')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "0" and os.path.splitext(input_file)[1] == '.txt' :
        a = pd.read_table(input_file, index_col=0, header=0)
        print(a)
        print('done -txt')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    
    elif judge_name01 == "1" and os.path.splitext(input_file)[1] == '.csv':
        a = pd.read_csv(input_file, header=None)
        print(a)
        print('done -csv')
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        # print(df.rpow)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "1" and os.path.splitext(input_file)[1] == '.xlsx':
        a = pd.read_excel(input_file, header=None)
        print(a)
        print('done -xlsx')
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        # print(df.rpow)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "1" and os.path.splitext(input_file)[1] == '.xls':
        a = pd.read_excel(input_file, header=None)
        print(a)
        print('done -xls')
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        # print(df.rpow)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "1" and os.path.splitext(input_file)[1] == '.txt':
        a = pd.read_table(input_file, header=None)
        print(a)
        print('done -txt')
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        # print(df.rpow)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    
    elif judge_name01 == "2" and os.path.splitext(input_file)[1] == '.csv' :
        a = pd.read_csv(input_file,header=None,index_col=0)
        print(a)
        print('done -csv')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "2" and os.path.splitext(input_file)[1] == '.xlsx' :
        a = pd.read_excel(input_file,header=None,index_col=0)
        print(a)
        print('done -xlsx')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "2" and os.path.splitext(input_file)[1] == '.xls' :
        a = pd.read_excel(input_file,header=None,index_col=0)
        print(a)
        print('done -xls')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "2" and os.path.splitext(input_file)[1] == '.txt' :
        a = pd.read_table(input_file,header=None,index_col=0)
        print(a)
        print('done -txt')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    
    elif judge_name01 == "3" and os.path.splitext(input_file)[1] == '.csv' :
        a = pd.read_csv(input_file,index_col=False)
        print(a)
        print('done -csv')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "3" and os.path.splitext(input_file)[1] == '.xlsx' :
        a = pd.read_excel(input_file,index_col=False)
        print(a)
        print('done -xlsx')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "3" and os.path.splitext(input_file)[1] == '.xls' :
        a = pd.read_excel(input_file,index_col=False)
        print(a)
        print('done -xls')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)
    elif judge_name01 == "3" and os.path.splitext(input_file)[1] == '.txt' :
        a = pd.read_table(input_file,index_col=False)
        print(a)
        print('done -txt')
        
        indexs = a._stat_axis.values.tolist()
        columns = a.columns.values.tolist()
        print(indexs)
        print('')
        print(columns)
        print('')
        main_1(a,indexs,columns)

    else:
        print('Error:')

def main_1(a,indexs,columns):
    if judge_name01 == "0" and mode_range == '2' :
        print(a.shape)
        shape_a=a.shape
        a = a.values
        a = a.flatten()
        print(a)
            
        var_a = np.var(a)
        a = np.array(a)
        max_a = a.max()
        min_a = a.min()
        mean_a = np.mean(a)
        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            # print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / np.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')
    elif judge_name01 == "1" and mode_range == '2' :
        shape_a=a.shape
        a = a.values
        a = a.flatten()

        var_a = np.var(a)
        max_a = max(a)
        min_a = min(a)
        mean_a = np.mean(a)
        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            # print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / math.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            b = np.log2(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
           
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d)
            output(indexs,columns,df)
        else:
            print('')
    elif judge_name01 == "2" and mode_range == '2' :
        print(a.shape)
        shape_a=a.shape
        a = a.values
        a = a.flatten()
        print(a)
            
        var_a = np.var(a)
        a = np.array(a)
        print(a)
        max_a = a.max()
        min_a = a.min()
        mean_a = np.mean(a)
        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            # print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / np.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')
    elif judge_name01 == "3" and mode_range == '2' :
        print(a.shape)
        shape_a=a.shape
        a = a.values
        a = a.flatten()
           
        var_a = np.var(a)
        a = np.array(a)
        max_a = a.max()
        min_a = a.min()
        mean_a = np.mean(a)
        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            # print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / np.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')

    elif judge_name01 == "0" and mode_range == '0' :
        print(a.shape)
        shape_a=a.shape
        #     a = a.values
        #     a = a.flatten()
        print(a)
            
        var_a = np.var(a,axis=0)
        a = np.array(a)
        max_a = a.max(axis=0)
        min_a = a.min(axis=0)
        mean_a = np.average(a,axis=0)

        var_a = np.array(var_a).reshape(1,-1)
        max_a = max_a.reshape(1,-1)
        min_a = min_a.reshape(1,-1)
        mean_a = mean_a.reshape(1, -1)
        print(mean_a)
        print('mean_a')

        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / np.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            # b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')
    elif judge_name01 == "1" and mode_range == '0' :
        print(a.shape)
        shape_a=a.shape
        # a = a.values
        # a = a.flatten()
        print(a)
            
        var_a = np.var(a,axis=0)
        a = np.array(a)
        max_a = a.max(axis=0)
        min_a = a.min(axis=0)
        mean_a = np.average(a,axis=0)

        var_a = np.array(var_a).reshape(1,-1)
        max_a = max_a.reshape(1,-1)
        min_a = min_a.reshape(1,-1)
        mean_a = mean_a.reshape(1, -1)

        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / np.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')
    elif judge_name01 == "2" and mode_range == '0' :
        print(a.shape)
        shape_a=a.shape
        # a = a.values
        # a = a.flatten()
        print(a)
            
        var_a = np.var(a,axis=0)
        a = np.array(a)
        max_a = a.max(axis=0)
        min_a = a.min(axis=0)
        mean_a = np.average(a,axis=0)

        var_a = np.array(var_a).reshape(1,-1)
        max_a = max_a.reshape(1,-1)
        min_a = min_a.reshape(1,-1)
        mean_a = mean_a.reshape(1, -1)

        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / np.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')
    elif judge_name01 == "3" and mode_range == '0' :
        print(a.shape)
        shape_a=a.shape
        # a = a.values
        # a = a.flatten()
        print(a)
            
        var_a = np.var(a,axis=0)
        a = np.array(a)
        max_a = a.max(axis=0)
        min_a = a.min(axis=0)
        mean_a = np.average(a,axis=0)

        var_a = np.array(var_a).reshape(1,-1)
        max_a = max_a.reshape(1,-1)
        min_a = min_a.reshape(1,-1)
        mean_a = mean_a.reshape(1, -1)

        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / np.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')

    elif judge_name01 == "0" and mode_range == '1' :
        print(a.shape)
        shape_a=a.shape
        # a = a.values
        # a = a.flatten()
        print(a)
            
        var_a = np.var(a,axis=1)
        a = np.array(a)
        max_a = a.max(axis=1)
        min_a = a.min(axis=1)
        mean_a = np.average(a,axis=1)

        var_a = np.array(var_a).reshape(-1,1)
        max_a = max_a.reshape(-1,1)
        min_a = min_a.reshape(-1,1)
        mean_a = mean_a.reshape(-1, 1)

        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / np.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')
    elif judge_name01 == "1" and mode_range == '1' :
        # print(a.shape)
        shape_a=a.shape
        # a = a.values
        # a = a.flatten()
        # print(a)
            
        var_a = np.var(a,axis=1)
        a = np.array(a)
        max_a = a.max(axis=1)
        min_a = a.min(axis=1)
        mean_a = np.average(a,axis=1)

        var_a = np.array(var_a).reshape(-1,1)
        max_a = max_a.reshape(-1,1)
        min_a = min_a.reshape(-1,1)
        mean_a = mean_a.reshape(-1, 1)

        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            print('')
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / np.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')
    elif judge_name01 == "2" and mode_range == '1' :
        print(a.shape)
        shape_a=a.shape
        # a = a.values
        # a = a.flatten()
        print(a)
            
        
        var_a = np.var(a,axis=1)
        a = np.array(a)
        max_a = a.max(axis=1)
        min_a = a.min(axis=1)
        mean_a = np.average(a,axis=1)
        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            max_a = max_a.reshape(-1,1)
            min_a = min_a.reshape(-1,1)
            b = (a - min_a) / (max_a - min_a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            print(a)
            print(np.sqrt(var_a))
            
            c = np.array(np.sqrt(var_a)).reshape(-1, 1)
            shape_mean_a = mean_a.reshape(-1, 1)
            print(shape_mean_a)
            print(c)
            b = (a - shape_mean_a) / c
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            mean_a = mean_a.reshape(-1,1)
            max_a = max_a.reshape(-1,1)
            min_a = min_a.reshape(-1,1)
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            mean_a = mean_a.reshape(-1,1)
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            
            c = np.log10(max_a).reshape(-1, 1)
            # b = np.log10(a) / np.log10(max_a)
            b = np.log10(a) / c
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            var_a = np.array(var_a).reshape(-1,1)
            mean_a = mean_a.reshape(-1,1)
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')
    elif judge_name01 == "3" and mode_range == '1' :
        print(a.shape)
        shape_a=a.shape
        # a = a.values
        # a = a.flatten()
        print(a)
            
        var_a = np.var(a,axis=1)
        a = np.array(a)
        max_a = a.max(axis=1)
        min_a = a.min(axis=1)
        mean_a = np.average(a,axis=1)

        var_a = np.array(var_a).reshape(-1,1)
        max_a = max_a.reshape(-1,1)
        min_a = min_a.reshape(-1,1)
        mean_a = mean_a.reshape(-1, 1)

        if mode_choose == 'min-max':
            print('{0:s}'.format(''))
            b = (a - min_a) / (max_a - min_a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'pareto':
            print('{0:s}'.format(''))
            b = (a - mean_a) / np.sqrt(var_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'mean':
            print('{0:s}'.format(''))
            b = (a - mean_a) / (max_a - min_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'center':
            print('{0:s}'.format(''))
            b = a - mean_a
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log2':
            print('{0:s}'.format('log2'))
            print(a)
            b = np.log2(a)
            print(b)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10':
            print('{0:s}'.format('log10'))
            b = np.log10(a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'log10-max':
            print('{0:s}'.format('log10-max'))
            # 
            b = np.log10(a) / np.log10(max_a)
            b = b.reshape(shape_a)
            df = pd.DataFrame(b,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'infinite':
            print('')
            c = 1 / (1 + np.exp(-a))
            print(c)
            c = c.reshape(shape_a)
            df = pd.DataFrame(c,index=indexs)
            output(indexs,columns,df)
        elif mode_choose == 'zscore':
            print('')
            d = ((a - mean_a) / var_a)
            # print(d)
            d = d.reshape(shape_a)
            df = pd.DataFrame(d,index=indexs)
            output(indexs,columns,df)
        else:
            print('')



def output(indexs,columns,df):  # add na_rep='NaN' 2022.10.17
    if os.path.splitext(input_file)[1] == '.csv' and judge_name01 == "0":     # 
        # df.to_csv('output.csv',index_label=indexs,header=columns,index=True) 
        df.to_csv('output.csv',header=columns,index=True,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.xlsx'  and judge_name01 == "0":
        print(indexs)
        print(df)
        df.to_excel('output.xlsx',header=columns,index=True,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.xls'  and judge_name01 == "0":
        print(indexs)
        print(df)
        df.to_excel('output.xls',header=columns,index=True,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.txt'and judge_name01 == "0":
        df.to_csv('output.txt',sep = '\t',header=columns,index=True,na_rep='NaN')

    elif os.path.splitext(input_file)[1] == '.csv' and judge_name01 == "1":
        df.to_csv('output.csv',header=None,index=0,na_rep='NaN')
        print('')
    elif os.path.splitext(input_file)[1] == '.xlsx' and judge_name01 == "1":
        print(indexs)
        print(df)
        df.to_excel('output.xlsx',header=None,index=0,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.xls' and judge_name01 == "1":
        print(indexs)
        print(df)
        df.to_excel('output.xls',header=None,index=0,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.txt'and judge_name01 == "1":
        df.to_csv('output.txt',sep = '\t',header=None,index=0,na_rep='NaN')

    elif os.path.splitext(input_file)[1] == '.csv' and judge_name01 == "2":
        df.to_csv('output.csv', index=True,header=None,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.xlsx'  and judge_name01 == "2":
        print(indexs)
        print(df)
        df.to_excel('output.xlsx', index=True,header=None,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.xls'  and judge_name01 == "2":
        print(indexs)
        print(df)
        df.to_excel('output.xls', index=True,header=None,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.txt'and judge_name01 == "2":
        df.to_csv('output.txt',sep = '\t', index=True,header=None,na_rep='NaN')

    elif os.path.splitext(input_file)[1] == '.csv' and judge_name01 == "3":
        df.to_csv('output.csv', index=False,header=columns,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.xlsx'  and judge_name01 == "3":
        print(indexs)
        print(df)
        df.to_excel('output.xlsx', index=False,header=columns,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.xls'  and judge_name01 == "3":
        print(indexs)
        print(df)
        df.to_excel('output.xls', index=False,header=columns,na_rep='NaN')
    elif os.path.splitext(input_file)[1] == '.txt'and judge_name01 == "3":
        df.to_csv('output.txt',sep = '\t', index=False,header=columns,na_rep='NaN')

judge(input_file)






