from sklearn.svm import SVC
from sklearn import model_selection
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.metrics import roc_curve, auc
import joblib
import os,sys
from sklearn.model_selection import train_test_split,GridSearchCV
from sklearn.utils import shuffle
import zipfile
from sklearn.ensemble import GradientBoostingClassifier
import numpy as np
from imblearn.over_sampling import RandomOverSampler
import warnings


class myclf_GBDT:
    # read file
    def read_file(input_file1):
        global df,df_col_0
        file_name = os.path.splitext(input_file1)[0][:8]
        if os.path.splitext(input_file1)[1] == '.txt':
            df = pd.read_table(input_file1)
        elif os.path.splitext(input_file1)[1] == '.csv':
            df = pd.read_csv(input_file1)
        elif os.path.splitext(input_file1)[1] == '.xlsx' or os.path.splitext(input_file1)[1] == '.xls':
            df = pd.read_excel(input_file1)
        df_col_0 = df.columns[0]
        if not os.path.exists('./clf_GBDT'):
            os.mkdir('./clf_GBDT')
    def read_file(input_file2):
        global df,df_col_0
        file_name = os.path.splitext(input_file2)[0][:8]
        if os.path.splitext(input_file2)[1] == '.txt':
            df = pd.read_table(input_file2)
        elif os.path.splitext(input_file2)[1] == '.csv':
            df = pd.read_csv(input_file2)
        elif os.path.splitext(input_file2)[1] == '.xlsx' or os.path.splitext(input_file2)[1] == '.xls':
            df = pd.read_excel(input_file2)
        df_col_0 = df.columns[0]
        if not os.path.exists('./clf_GBDT'):
            os.mkdir('./clf_GBDT')
    def mode_choose():
        global df, df_col_0
        if mode_choose == 'load_mode':
            read_file2(input_file2)
        else:
            read_file1(input_file1)

    # 洗牌
    def input_shuffle():
        global df
        df = shuffle(df)
        
    # 分割
    def split_file():
        global X,y
        if not Y_lb_TF == 'T' and mode_choose == 'load_mode':
            X = df
            y = 'nan'
            print('无标签输入')
        else:
            y = df.iloc[:,0]
            X = df.iloc[:,1:]
        # 过采样
    def oversample_data():
        global X, y
        from imblearn.over_sampling import RandomOverSampler, SMOTE
        ros = RandomOverSampler()
        # smote = SMOTE()  # 如果想使用SMOTE方法进行过采样，可以使用这个替换上一行的代码
        X_resampled, y_resampled = ros.fit_resample(X, y)
        X = X_resampled
        y = y_resampled        
    # 划分
    def split_file_data():
        global X_test,y_test,X_train,y_train
        # define seed for reproducibility
        seed = 12
        # split data into training and testing datasets
        X_train, X_test, y_train, y_test = model_selection.train_test_split(X
                                                                            , y
                                                                            , test_size=rate
                                                                            , random_state=seed)
        X_test = np.ascontiguousarray(X_test)
    # 无cv，这是一个使用python编写的GBDT模型训练函数，可以通过调整参数来自定义模型。
    def GBDT_fit():
        global GBDT_clf
        GBDT_clf = GradientBoostingClassifier()
        GBDT_clf.fit(X_train,y_train)
        
    def GBDT_fit_diy(GBDT_loss='log_loss' # 这个deviance准备过期所以改用log_loss exponential
                    ,GBDT_learning_rate=0.1
                    ,GBDT_subsample=1
                    ,GBDT_n_estimators=100
                    ,GBDT_criterion='friedman_mse' #friedman_mse squared_error
                    ,GBDT_max_depth=3
                    ,GBDT_min_samples_leaf=1
                    ,GBDT_min_samples_split=2
                    ,GBDT_max_features=None #log2 sqrt None
                    ):
        global GBDT_clf
        GBDT_clf = GradientBoostingClassifier(loss=GBDT_loss
                                    ,learning_rate=GBDT_learning_rate
                                    ,subsample=GBDT_subsample
                                    ,n_estimators=GBDT_n_estimators
                                    ,criterion=GBDT_criterion
                                    ,max_depth=GBDT_max_depth
                                    ,min_samples_leaf=GBDT_min_samples_leaf
                                    ,min_samples_split=GBDT_min_samples_split
                                    ,max_features=GBDT_max_features
                                    ,random_state=1)#该参数必须保留，其他参数可以百度适当调整，现在采取默认值
        GBDT_clf.fit(X_train, y_train)
        print('GBDT-diy',GBDT_loss
                        ,GBDT_learning_rate
                        ,GBDT_subsample
                        ,GBDT_n_estimators
                        ,GBDT_criterion
                        ,GBDT_max_depth
                        ,GBDT_min_samples_leaf
                        ,GBDT_min_samples_split
                        ,GBDT_max_features)
        
    # cv_diy
    argv = sys.argv
    cv_times = int(argv[9])
    def GBDT_fit_cv(cv_times=cv_times,cv_scoring=None):
        
        global GBDT_clf,best_para
        #5折交叉验证，网格搜索优化参数
        parameters = {'loss':('log_loss','exponential')
                        ,'criterion':('friedman_mse','squared_error')
                        ,'max_features':('log2','sqrt',None)}
        clf = GradientBoostingClassifier()
        GBDT_clf = GridSearchCV(clf,parameters
                                , n_jobs=-1
                                , cv=cv_times
                                , verbose=1
                                , scoring=cv_scoring)
        GBDT_clf.fit(X_train, y_train)
        best_para = list(GBDT_clf.best_params_.values())
        print('选出的最佳参数',GBDT_clf.best_params_)
        

#save_model()函数用于将模型保存为.pkl格式文件，model_input()函数用于读取.pkl格式文件作为输入模型，load_model()函数用于加载模型并计算各种评估指标，
    # 包括准确率、精确率、F1分数、灵敏度和特效度等，并将结果保存在.txt格式的文件中。load_model_misslb()函数也是用于加载模型，
    # 但它还会将预测结果与原始数据合并保存为.txt格式的文件。pd_concat()函数则是将预测结果与测试集数据合并保存成.txt格式的文件。
    # 最后，plt_output()函数可将ROC曲线保存为.svg格式的文件。
    def save_model():
        joblib.dump(GBDT_clf, './clf_GBDT/GBDT.pkl')
        
    def model_input():
        global GBDT_clf
        model_name = os.path.splitext(input_model)[0][:8]
        GBDT_clf = input_model
        
    def load_model(file_name='GBDT'):
        global fpr_GBDT,tpr_GBDT,GBDT_clf,predictions
        if mode_choose == 'load_mode':
            GBDT_clf = joblib.load(GBDT_clf)
        score_GBDT = GBDT_clf.predict_proba(X_test)[:,1]
        fpr_GBDT,tpr_GBDT,thres_GBDT = roc_curve(y_test,score_GBDT,)
        predictions = GBDT_clf.predict(X_test)
        # print("GBDT")
        confusion = confusion_matrix(y_test, predictions)
        Accuracy = (confusion[0][0]+confusion[1][1])/(confusion[0][0]+confusion[0][1]+confusion[1][0]+confusion[1][1])
        Precision = confusion[0][0]/(confusion[0][0]+confusion[0][1])
        Sensitivity = confusion[0][0]/(confusion[0][0]+confusion[1][0])
        Specifcity = confusion[1][1]/(confusion[1][1]+confusion[0][1])
        F1 = 2*Precision*Sensitivity/(Precision+Sensitivity)
        #score
        print("Accuracy:", Accuracy, "Precision:", Precision, "F1:",F1,"Sensitivity:",Sensitivity,"Specifcity:",Specifcity)
        report = classification_report(y_test, predictions,output_dict=True)
        report = pd.DataFrame(report).transpose()
        report.rename(columns={'precision':'精确率','recall':'召回率','f1-score':'F1分数','support':'支持度'},inplace=True)
        report.rename(index={'accuracy':'准确率','macro avg':'宏平均','micro avg':'微平均','weighted avg':'加权平均'},inplace=True)
        report.loc['其他评判指标',['灵敏度','特效度']] = [Sensitivity,Specifcity]
        if mode_choose == 'train' and cv_TF == 'T':
            report.loc['cv选出的最佳参数',['criterion']] = [best_para[0]]
            report.loc['cv选出的最佳参数',['loss']] = [best_para[1]]
            report.loc['cv选出的最佳参数',['max_features']] = [best_para[2]]
        report.to_csv('./clf_GBDT/{}_Report.txt'.format(file_name),index = 1,index_label='评分',sep = '\t')
        
        
    def load_model_misslb(model_name='GBDT'):
        global GBDT_clf
        GBDT_clf = joblib.load(GBDT_clf)
        predic = GBDT_clf.predict(X_test)
        predic = pd.DataFrame(predic)
        pd_data = pd.concat([predic,X],axis=1)
        pd_data.rename(columns={0:'预测值'},inplace=True)
        pd_data.to_csv('./clf_GBDT/{}_PredictData.txt'.format(model_name),index = 0,sep='\t')
            
    def pd_concat(model_name='GBDT'):
        predic = pd.DataFrame(predictions)
        pd_col_0 = predic.columns[0]
        pd_data = pd.concat([predic,X_test],axis=1)
        # pd_data.rename(columns={pd_col_0:'预测值'},inplace=True)
        pd_data = pd.concat([y_test,pd_data],axis=1)
        pd_data.rename(columns={pd_col_0:'预测值',df_col_0:'真实值'},inplace=True)
        pd_data.to_csv('./clf_GBDT/{}_PredictData.txt'.format(model_name),index = 0,sep='\t')
    def plt_output(model_name='GBDT'):
        fig,ax = plt.subplots(figsize=(10,8))
        ax.plot(fpr_GBDT,tpr_GBDT,linewidth=2,color="black",
                label='GBDT (AUC={})'.format(str(round(auc(fpr_GBDT,tpr_GBDT),3))))
        ax.plot([0,1],[0,1],linestyle='--',color='grey')
        #调整字体大小
        plt.legend(fontsize=12)
        plt.title("Validation Cohort ROC")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        # plt.show()
        f = plt.gcf()  #获取当前图像
        if mode_choose == 'train':
            f.savefig('./clf_GBDT/GBDT_ROC.svg',bbox_inches='tight')
        else:
            f.savefig('./clf_GBDT/{}_ROC.svg'.format(model_name),bbox_inches='tight')
        
    def split_model_pddata():
        global X_test,y_test
        X_test = X
        y_test = y
        print(y_test)



    def zipDir(source_dir, output_filename):
        """
        压缩指定文件夹
        :param source_dir: 目标文件夹路径
        :param output_filename: 压缩文件保存路径+xxxx.zip
        :return: 无
        """
        if os.path.exists(source_dir):
            # compression压缩比例，默认是不压缩，ZIP_LZMA=14级别的压缩，影响的是时间，但是包能更小
            # vue使用级别=9的，var archive = archiver('zip', {zlib: {level: 9}});
            # mac install: brew install xz
            # mode 解压是 r , 压缩是 w 追加压缩是 a
            # compression 为  zipfile.ZIP_DEFLATED，zipfile.ZIP_STORED， zipfile.ZIP_LZMA
            zipf = zipfile.ZipFile(file=output_filename, mode='w', compression=zipfile.ZIP_LZMA)
            # zipf = zipfile.ZipFile(file=output_filename, mode='w', compression=zipfile.ZIP_DEFLATED)
            pre_len = len(os.path.dirname(source_dir))
            for parent, dirnames, filenames in os.walk(source_dir):
                for filename in filenames:
                    pathfile = os.path.join(parent, filename)
                    arcname = pathfile[pre_len:].strip(os.path.sep)  # 相对路径
                    zipf.write(pathfile, arcname)
            zipf.close()
            print('压缩目标文件夹:',source_dir,'\n压缩文件保存至:',output_filename)
            return output_filename
        else:
            print('file not found 压缩路径找不到',source_dir)
        return

def train_mode(input_file1):
    myclf_GBDT.read_file(input_file1)
    if shuffle_TF == 'T':
        myclf_GBDT.input_shuffle()
    myclf_GBDT.split_file()
    myclf_GBDT.oversample_data()
    myclf_GBDT.split_file_data()
    if cv_TF == 'T':
        myclf_GBDT.GBDT_fit_cv()
    else:
        if GBDT_diy_TF == 'T':
            myclf_GBDT.GBDT_fit_diy(GBDT_loss
                    ,GBDT_learning_rate
                    ,GBDT_subsample
                    ,GBDT_n_estimators
                    ,GBDT_criterion
                    ,GBDT_max_depth
                    ,GBDT_min_samples_leaf
                    ,GBDT_min_samples_split
                    ,GBDT_max_features)
        else:
            myclf_GBDT.GBDT_fit()
    myclf_GBDT.save_model()
    myclf_GBDT.load_model()
    myclf_GBDT.plt_output()
    myclf_GBDT.zipDir(source_dir, output_filename)
    
    
def load_mode(input_file2):
    myclf_GBDT.read_file(input_file2)
    myclf_GBDT.split_file()
    myclf_GBDT.split_model_pddata()
    myclf_GBDT.model_input()
    if Y_lb_TF == 'T':
        myclf_GBDT.load_model()
        myclf_GBDT.pd_concat()
        myclf_GBDT.plt_output()
        myclf_GBDT.zipDir(source_dir, output_filename)
    else:
        myclf_GBDT.load_model_misslb()
        myclf_GBDT.zipDir(source_dir, output_filename)
    

# argv

source_dir = './clf_GBDT'
output_filename = './clf_GBDT.zip'

argv = sys.argv
mode_choose = argv[1] # train nan train.csv
Y_lb_TF= argv[2]
input_model = argv[3] # load_mode GBDT.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]

GBDT_diy_TF = argv[11]
if GBDT_diy_TF == 'T':
    GBDT_loss = argv[12]
    GBDT_learning_rate = float(argv[13])
    GBDT_subsample = int(argv[14])
    GBDT_n_estimators = int(argv[15])
    
    GBDT_criterion= argv[16]
    GBDT_max_depth= int(argv[17])

    GBDT_min_samples_leaf= int(argv[18])
    GBDT_min_samples_split= int(argv[19])
    GBDT_max_features= argv[20]
    if GBDT_max_features == 'None':
        GBDT_max_features = None
    if cv_scoring == 'None':
        cv_scoring = None
    # python clf_SVC.py load_mode F GBDT.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15
    
    # python clf_GBDT.py train T NAN train.csv 0.2 T T 5 None 0 
    
    
    # GBDT_loss,GBDT_learning_rate,GBDT_subsample,GBDT_n_estimators,GBDT_criterion,GBDT_max_depth,GBDT_min_samples_leaf,GBDT_min_samples_split,GBDT_max_features



if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('加载模式')