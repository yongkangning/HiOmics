
import pandas as pd
import sys
import os
import time
import openpyxl
import xlrd
import shutil

inpath = sys.argv[1]
file_sep = sys.argv[2]

def table_totxt(inpath):
    
    for afile in os.listdir(inpath):
        if afile[-4:].lower() == 'xlsx':
            print(afile)
            name = inpath+'/'+afile
            
            wb = openpyxl.load_workbook(name)
            sheets = wb.sheetnames
            if file_sep == 'comma':
                for sheet in sheets:
                    print(sheet)
                    df = pd.read_excel(name, sheet_name=sheet, header=None)
                    print('')
                    
                    df.to_csv(outpath_txt+'/'+afile[:-5]+'_'+sheet+'.txt', header=None, sep=',', index=False)
                    print(' ')
            elif file_sep == 'tab':
                for sheet in sheets:
                    print(sheet)
                    df = pd.read_excel(name, sheet_name=sheet, header=None)
                    print(' ')
                     
                    df.to_csv(outpath_txt+'/'+afile[:-5]+'_'+sheet+'.txt', header=None, sep='\t', index=False)
                    print(' ')
            elif file_sep == 'blank':
                for sheet in sheets:
                    print(sheet)
                    df = pd.read_excel(name, sheet_name=sheet, header=None)
                    print(' ')
                     
                    df.to_csv(outpath_txt+'/'+afile[:-5]+'_'+sheet+'.txt', header=None, sep=' ', index=False)
                    print(' ')
            elif file_sep == 'semicolon':
                for sheet in sheets:
                    print(sheet)
                    df = pd.read_excel(name, sheet_name=sheet, header=None)
                    print(' ')
                     
                    df.to_csv(outpath_txt+'/'+afile[:-5]+'_'+sheet+'.txt', header=None, sep=';', index=False)
                    print(' ')
            else:
                print(' ')

def table_totxt2(inpath):
    for afile in os.listdir(inpath):
        if afile[-4:].lower() == '.xls':
            print(afile)
            name = inpath+'/'+afile
             
            wb = xlrd.open_workbook(name)
            sheets = wb.sheet_names()
            if file_sep == 'comma':
                for sheet in sheets:
                    print(sheet)
                    df = pd.read_excel(name, sheet_name=sheet, header=None)
                    print(' ')
                     
                    df.to_csv(outpath_txt+'/'+afile[:-5]+'_'+sheet+'.txt', header=None, sep=',', index=False)
                    print(' ')
            elif file_sep == 'tab':
                for sheet in sheets:
                    print(sheet)
                    df = pd.read_excel(name, sheet_name=sheet, header=None)
                    print(' ')
                     
                    df.to_csv(outpath_txt+'/'+afile[:-5]+'_'+sheet+'.txt', header=None, sep='\t', index=False)
                    print(' ')
            elif file_sep == 'blank':
                for sheet in sheets:
                    print(sheet)
                    df = pd.read_excel(name, sheet_name=sheet, header=None)
                    print(' ')
                     
                    df.to_csv(outpath_txt+'/'+afile[:-5]+'_'+sheet+'.txt', header=None, sep=' ', index=False)
                    print(' ')
            elif file_sep == 'semicolon':
                for sheet in sheets:
                    print(sheet)
                    df = pd.read_excel(name, sheet_name=sheet, header=None)
                    print(' ')
                     
                    df.to_csv(outpath_txt+'/'+afile[:-5]+'_'+sheet+'.txt', header=None, sep=';', index=False)
                    print(' ')
            else:
                print(' ')


# def file_move(outpath,afile,sheet):
#     os.mkdir(outpath+'/'+'1/')
#     file = os.listdir(outpath)
#     for i in file:
#         shutil.move(outpath+'/'+afile[:-5]+'_'+sheet+'.txt',os.path.join(outpath,'1'))
#         print(afile[:-5]+'_'+sheet+'.txt','move')
#     print(' ')

def time_master():
    print('{0:s}'.format(''))
    start = time.time()
    table_totxt(inpath)
    table_totxt2(inpath)
    stop = time.time()
    print('{0:s}'.format(''))
    print(f'')
    

os.mkdir('outputFile')
outpath_txt='outputFile'
time_master()
