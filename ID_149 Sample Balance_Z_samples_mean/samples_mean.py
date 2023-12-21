
import os
import zipfile
import pandas as pd
import random
import sys
from matplotlib import pyplot as plt

from imblearn.over_sampling import SMOTE
from imblearn.over_sampling import RandomOverSampler as  ros
from imblearn.over_sampling import ADASYN

from imblearn.under_sampling import RandomUnderSampler
from imblearn.under_sampling import ClusterCentroids

from imblearn.combine import SMOTEENN,SMOTETomek



input_data = sys.argv[1]
mode_choose = sys.argv[2]

mode_choose_up = sys.argv[3]
mode_choose_down = sys.argv[4]
mode_choose_conbine = sys.argv[5]



if not os.path.exists('./samples_mean'):
    os.mkdir('./samples_mean')
else:
    pass

def plt_draw(x,y,n_sample,n_1_sample,n_0_sample,name_plt):
    # plt.rcParams['font.sans-serif']=['SimHei'] 
    plt.rcParams['axes.unicode_minus']=False 
    y1 = y.replace(1,'r')
    y1 = y1.replace(0,'b')


    # a = np.random.randn(y.shape[0])
    # b = np.random.randn(y.shape[0])
    #
    df1 = pd.DataFrame(x)
    n = int((df1.shape[1])/2)
    if n == 0:
        a = df1.iloc[:,0]
        b = df1.iloc[:,0]
    else:
        a = df1.iloc[:,:n].mean(axis=1)
        b = df1.iloc[:,n:df1.shape[1]].mean(axis=1)
    
    list_a=[]
    for i in a :
        i = (i + random.uniform(0,10*i))/11
        list_a.append(i)
    a = list_a
    list_b=[]
    for i in b :
        i = (i + random.uniform(0,10*i))/11
        list_b.append(i)
    b = list_b
    #
    plt.figure(figsize=(5, 5),dpi=300)
    plt.title("{} counts: {}".format(name_plt,n_sample))
    plt.xlabel("0 counts: {}  rate: {:.2%}\n1 counts: {}  rate: {:.2%}".format(n_0_sample,n_0_sample/n_sample,n_1_sample,n_1_sample/n_sample))
    plt.scatter(a,b,c=y1,s=10,lw = 0.005,label=y[0])
    plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0)
    f = plt.gcf()  
    f.savefig('./samples_mean/{}.svg'.format(name_plt),bbox_inches='tight')


def output(x,y,name):
    df0 = pd.concat([y,x],axis=1)
    df0.to_csv('./samples_mean/{}.txt'.format(name),sep = '\t',index = 0)


source_dir = './samples_mean'
output_filename = './samples_mean.zip'
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
        print('',source_dir,'',output_filename)
        return output_filename
    else:
        print('file not found ',source_dir)
    return


def read_file(input_file):
    if os.path.splitext(input_file)[1] == '.txt':
        df = pd.read_table(input_file)
    elif os.path.splitext(input_file)[1] == '.csv':
        df = pd.read_csv(input_file)
    elif os.path.splitext(input_file)[1] == '.xlsx' or os.path.splitext(input_file)[1] == '.xls':
        df = pd.read_excel(input_file)
    return df



df = read_file(input_data)

x = df.iloc[:,1:]

y = df.iloc[:,0]

print(y.value_counts())


n_sample_ = x.shape[0]
n_1_sample_ = y.value_counts()[1]
n_0_sample_ = y.value_counts()[0]
print(''.format(n_sample_,n_1_sample_/n_sample_,n_0_sample_/n_sample_))

# plt_draw(x,y,n_sample_,n_1_sample_,n_0_sample_,'input')

#mode_choose
if mode_choose == 'up':
    if mode_choose_up == 'up':
        sm = SMOTE(random_state=42)  
        x,y = sm.fit_resample(x,y) 
        n_sample = x.shape[0]
        n_1_sample = y.value_counts()[1]
        n_0_sample = y.value_counts()[0]
        print(''.format(n_sample,n_1_sample/n_sample,n_0_sample/n_sample))
        
        # plt_draw(x,y,n_sample,n_1_sample,n_0_sample,'up-SMOTE')
        name = ''
        output(x,y,name)
    elif mode_choose_up == 'up_RD':
        ros = ros(random_state=0)
        x,y = ros.fit_resample(x,y)
        n_sample = x.shape[0]
        n_1_sample = y.value_counts()[1]
        n_0_sample = y.value_counts()[0]
        print(''.format(n_sample,n_1_sample/n_sample,n_0_sample/n_sample))
        # plt_draw(x,y,n_sample,n_1_sample,n_0_sample,'up-RD')
        name = ''
        output(x,y,name)
    elif mode_choose_up == 'up_ADASYN':
        ada = ADASYN(random_state=42)
        x, y = ada.fit_resample(x, y)
        n_sample = x.shape[0]
        n_1_sample = y.value_counts()[1]
        n_0_sample = y.value_counts()[0]
        print(''.format(n_sample_,n_1_sample_/n_sample_,n_0_sample_/n_sample_))
        # plt_draw(x,y,n_sample,n_1_sample,n_0_sample,'up_ADASYN')
        name = ''
        output(x,y,name)
    else:
        print(mode_choose,'')

elif mode_choose == 'down':
    if mode_choose_down == 'down_Random':
        rus = RandomUnderSampler(random_state=0)
        x, y = rus.fit_resample(x,y) 
        n_sample = x.shape[0]
        n_1_sample = y.value_counts()[1]
        n_0_sample = y.value_counts()[0]
        print(''.format(n_sample,n_1_sample/n_sample,n_0_sample/n_sample))
        # plt_draw(x,y,n_sample,n_1_sample,n_0_sample,'down_Random')
        name = ''
        output(x,y,name)
    elif mode_choose_down == 'down_cc':
        cc = ClusterCentroids(random_state=0)
        x, y = cc.fit_resample(x, y)
        n_sample = x.shape[0]
        n_1_sample = y.value_counts()[1]
        n_0_sample = y.value_counts()[0]
        print(''.format(n_sample,n_1_sample/n_sample,n_0_sample/n_sample))
        # plt_draw(x,y,n_sample,n_1_sample,n_0_sample,'down_cc')
        name = ''
        output(x,y,name)
    else:
        print(mode_choose,'')

elif mode_choose == 'conbine':
    if mode_choose_conbine == 'SMOTE_ENN':
        smote_enn = SMOTEENN(random_state=0)
        x, y = smote_enn.fit_resample(x, y)
        n_sample = x.shape[0]
        n_1_sample = y.value_counts()[1]
        n_0_sample = y.value_counts()[0]
        print(''.format(n_sample,n_1_sample/n_sample,n_0_sample/n_sample))
        # plt_draw(x,y,n_sample,n_1_sample,n_0_sample,'conbine-SMOTE_ENN')
        name = ''
        output(x,y,name)
    elif mode_choose_conbine == 'SMOTE_Tomek':
        smote_tomek = SMOTETomek(random_state=0)
        x, y = smote_tomek.fit_resample(x, y)
        n_sample = x.shape[0]
        n_1_sample = y.value_counts()[1]
        n_0_sample = y.value_counts()[0]
        print(''.format(n_sample,n_1_sample/n_sample,n_0_sample/n_sample))
        # plt_draw(x,y,n_sample,n_1_sample,n_0_sample,'conbine-SMOTE_Tomek')
        name = ''
        output(x,y,name)
    else:
        print(mode_choose,'')

else:
    print(mode_choose,'')

# zip
zipDir(source_dir,output_filename)