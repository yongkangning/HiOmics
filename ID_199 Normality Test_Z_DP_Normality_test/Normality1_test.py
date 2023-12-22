
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
import statsmodels.api as sm
import pylab
import os,sys
import pandas as pd
import zipfile


input_file = sys.argv[1]
source_dir = './Normality_test'
output_filename = './Normality_test.zip'

def read_file(input_file):
    global df
    if os.path.splitext(input_file)[1] == '.txt':
        df = pd.read_table(input_file)
    elif os.path.splitext(input_file)[1] == '.csv':
        df = pd.read_csv(input_file)
    elif os.path.splitext(input_file)[1] == '.xlsx' or os.path.splitext(input_file)[1] == '.xls':
        df = pd.read_excel(input_file)

def frequency_histogram(a,i):
    # seaborn.set()
    # #Draw frequency histogram
    # # fig = sns.distplot(a,hist=False,fit=norm)
    # fig = seaborn.distplot(a)
    # # fig.set_title('frequency histogram')
    # scatter_fig = fig.get_figure()
    # scatter_fig.savefig(f'./Normality_test/{i}/{i}_frequency_histogram.svg')
    
    fig = plt.figure(figsize = (10,6))
    ax2 = fig.add_subplot(1,1,1)
    a.hist(bins=50,ax = ax2)
    a.plot(kind = 'kde', secondary_y=True,ax = ax2)
    plt.title('frequency histogram')
    plt.grid()
    plt.savefig(f'./Normality_test/{i}/{i}_frequency_histogram.svg')
    return

def PP_diagram(a,i):
    #Used to display Chinese labels
    # plt.rcParams['font.sans-serif']=['SimHei']
    #Used to display negative signs normally
    # plt.rcParams['axes.unicode_minus']=False 
    
    fp = sm.ProbPlot(a).ppplot(line='45',markersize=3)
    pylab.title('P-P diagram')
    fp.savefig(f'./Normality_test/{i}/{i}_PP_diagram.svg')
    return
    
def qq_diagram(a,i):
    #Used to display Chinese labels
    # plt.rcParams['font.sans-serif']=['SimHei']
    #Used to display negative signs normally
    plt.rcParams['axes.unicode_minus']=False 
    
    #Draw Q-Q diagram
    fq = sm.qqplot(a, line='s',markersize=3)
    pylab.title('Q-Q diagram')
    # pylab.show()
    # fq = pylab.gcf()  
    fq.savefig(f'./Normality_test/{i}/{i}_QQ_diagram.svg')
    return

def statistic(a,i,df1):
    L = sorted(a)
    
    mean = pd.Series(a).mean()   
    df1.loc[i,'mean'] = '{:.3f}'.format(mean)
    
    std = pd.Series(a).std()   
    df1.loc[i,'std'] = '{:.3f}'.format(std)
    
    
    df1.loc[i,'median'] = '{:.3f}'.format(L[len(L)//2] if len(L)%2==1 else float("%.1f"%(0.5*(L[len(L)//2-1]+L[len(L)//2]))))

    # print(L[len(L)//2])
    #df1.loc[i,'median'] = '{:.3f}'.format(L[len(L)//2] if len(L)%2==1 else float("%.1f"%(0.5*(L[len(L)//2-1]+L[len(L)//2]))))

    skew = pd.Series(a).skew()   
    df1.loc[i,'skew'] = '{:.3f}'.format(skew)
    kurt = pd.Series(a).kurt()   
    df1.loc[i,'kurt'] = '{:.3f}'.format(kurt)
    
    #The distribution to be tested can be specified in CDF. Norm means 
    #that we need to test the normal distribution
    KS_result = stats.kstest(a,'norm',args=(a.mean(),a.std()))
    df1.loc[i,'ks statistic (pvalue)'] = '{:.3f}'.format(KS_result[0])+' ({:.4f})'.format(KS_result[1])
    # df1.loc[i,'ks_pvalue'] = KS_result[1]
    #W test is a method similar to the correlation test using rank
    W_result = stats.shapiro(a)
    df1.loc[i,'sw statistic (pvalue)'] = '{:.3f}'.format(W_result[0])+' ({:.4f})'.format(W_result[1])
    #Skewness and kurtosis test
    result = stats.normaltest(a)
    df1.loc[i,'Agostino-Pearson statistic (pvalue)'] = '{:.3f}'.format(result[0])+' ({:.4f})'.format(result[1])
    # print(result[0],'\t',result,'\t',result[1])


def zipDir(source_dir, output_filename):
    
    if os.path.exists(source_dir):
       zipf = zipfile.ZipFile(file=output_filename, mode='w', compression=zipfile.ZIP_LZMA)
        # zipf = zipfile.ZipFile(file=output_filename, mode='w', compression=zipfile.ZIP_DEFLATED)
        pre_len = len(os.path.dirname(source_dir))
        for parent, dirnames, filenames in os.walk(source_dir):
            for filename in filenames:
                pathfile = os.path.join(parent, filename)
                arcname = pathfile[pre_len:].strip(os.path.sep)  
                zipf.write(pathfile, arcname)
        zipf.close()
        print(':',source_dir,'',output_filename)
        return output_filename
    else:
        print('file not found ',source_dir)
    return

def main(input_file):
    if not os.path.exists('./Normality_test'):
        os.mkdir('./Normality_test')
    else:
        pass
    read_file(input_file)
    
    df1 = df.describe().T
    df1 = df1.iloc[:,0:3]
    for i in sorted(df.columns):
        a = df[i]
        if not os.path.exists(f'./Normality_test/{i}'):
            os.mkdir(f'./Normality_test/{i}')
        else:
            pass
        frequency_histogram(a,i)
        # PP_diagram(a,i)
        qq_diagram(a,i)
        statistic(a,i,df1)
    df1.to_csv('./Normality_test/Normality_test_result.txt',sep='\t')
    zipDir(source_dir, output_filename)
    
if __name__ == '__main__':
    main(input_file)



