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
from sklearn.linear_model import LogisticRegression
from sklearn.utils import shuffle
import zipfile
import numpy as np
from imblearn.over_sampling import RandomOverSampler

best_para = []
class myclf_LR:
    global best_para


    # read file
    def read_file1(input_file1):
        global df, df_col_0
        file_name1 = os.path.splitext(input_file1)[0][:8]
        if os.path.splitext(input_file1)[1] == '.txt':
            df = pd.read_table(input_file1)
        elif os.path.splitext(input_file1)[1] == '.csv':
            df = pd.read_csv(input_file1)
        elif os.path.splitext(input_file1)[1] == '.xlsx' or os.path.splitext(input_file1)[1] == '.xls':
            df = pd.read_excel(input_file1)
        df_col_0 = df.columns[0]
        if not os.path.exists('./clf_LR'):
            os.mkdir('./clf_LR')

    def read_file2(input_file2):
        global df, df_col_0
        file_name2 = os.path.splitext(input_file2)[0][:8]
        if os.path.splitext(input_file2)[1] == '.txt':
            df = pd.read_table(input_file2)
        elif os.path.splitext(input_file2)[1] == '.csv':
            df = pd.read_csv(input_file2)
        elif os.path.splitext(input_file2)[1] == '.xlsx' or os.path.splitext(input_file2)[1] == '.xls':
            df = pd.read_excel(input_file2)
        df_col_0 = df.columns[0]
        if not os.path.exists('./clf_LR'):
            os.mkdir('./clf_LR')

    def mode_choose():
        global df, df_col_0,best_para
        if mode_choose == 'load_mode':
            read_file2(input_file2)
            load_model(best_para=best_para)
        else:
            read_file1(input_file1)

    
    def input_shuffle():
        global df
        df = shuffle(df)

    
    def split_file():
        global X, y
        if not Y_lb_TF == 'T' and mode_choose == 'load_mode':
            X = df
            y = 'nan'
            print('')
        else:
            y = df.iloc[:, 0]
            X = df.iloc[:, 1:]
        
    def oversample_data():
        global X, y
        from imblearn.over_sampling import RandomOverSampler, SMOTE
        ros = RandomOverSampler()
        # smote = SMOTE()  
        X_resampled, y_resampled = ros.fit_resample(X, y)
        X = X_resampled
        y = y_resampled        

    
    def split_file_data():
        global X_test, y_test, X_train, y_train
        # define seed for reproducibility
        seed = 12
        # split data into training and testing datasets
        X_train, X_test, y_train, y_test = model_selection.train_test_split(X
                                                                            , y
                                                                            , test_size=rate
                                                                            , random_state=seed)
        X_test = np.ascontiguousarray(X_test)    

    
    def LR_fit():
        global LR_clf
        LR_clf = LogisticRegression(penalty='l2', max_iter=10000)
        LR_clf.fit(X_train, y_train)

    def LR_fit_diy(LR_penalty='l2'
                   , LR_C=1.0
                   , LR_fi=True
                   , LR_max_iter=1000
                   , LR_tol=0.001):
        global LR_clf
        LR_clf = LogisticRegression(penalty=LR_penalty
                                    , C=LR_C
                                    , fit_intercept=LR_fi
                                    , max_iter=LR_max_iter
                                    , tol=LR_tol)  
        LR_clf.fit(X_train, y_train)
        print('LR-diy')

    # cv_diy
    argv = sys.argv
    cv_times = int(argv[9])
    def LR_fit_cv(cv_times=cv_times, cv_scoring=None):
        global LR_clf,best_para
        best_para = []
        
        parameters = {
    'penalty': ['l1', 'l2'],
    'C': [0.01, 0.1, 1.0],
    'solver': ['lbfgs', 'liblinear', 'sag', 'newton-cg', 'saga']}
        clf = LogisticRegression()
        LR_clf = GridSearchCV(clf, parameters
                              , n_jobs=-1
                              , cv=cv_times
                              , verbose=1
                              , scoring=cv_scoring)
        LR_clf.fit(X_train, y_train)
        best_para=[]
        best_para = list(LR_clf.best_params_.values())
        print('', LR_clf.best_params_)
        return best_para

    def save_model():
        joblib.dump(LR_clf, './clf_LR/LR.pkl')

    def model_input():
        global LR_clf
        model_name = os.path.splitext(input_model)[0][:8]
        LR_clf = input_model

    def load_model(file_name='LR'):
        global fpr_LR, tpr_LR, LR_clf, predictions, best_para
        if mode_choose == 'load_mode':
            LR_clf = joblib.load(LR_clf)
        score_LR = LR_clf.predict_proba(X_test)[:, 1]
        fpr_LR, tpr_LR, thres_LR = roc_curve(y_test, score_LR, )
        predictions = LR_clf.predict(X_test)
        confusion = confusion_matrix(y_test, predictions)
        Accuracy = (confusion[0][0] + confusion[1][1]) / (
                confusion[0][0] + confusion[0][1] + confusion[1][0] + confusion[1][1])
        Precision = confusion[0][0] / (confusion[0][0] + confusion[0][1])
        Sensitivity = confusion[0][0] / (confusion[0][0] + confusion[1][0])
        Specifcity = confusion[1][1] / (confusion[1][1] + confusion[0][1])
        F1 = 2 * Precision * Sensitivity / (Precision + Sensitivity)
        print("Accuracy:", Accuracy, "Precision:", Precision, "F1:", F1, "Sensitivity:", Sensitivity, "Specifcity:",
              Specifcity)
        report = classification_report(y_test, predictions, output_dict=True)
        report = pd.DataFrame(report).transpose()
        report.rename(columns={'precision': '', 'recall': '', 'f1-score': '', 'support': ''},
                      inplace=True)
        report.rename(
            index={'accuracy': '', 'macro avg': '', 'micro avg': '', 'weighted avg': ''},
            inplace=True)
        report.loc['', ['', '']] = [Sensitivity, Specifcity]
        if mode_choose == 'train':
            if best_para == []:
                best_para = myclf_LR.LR_fit_cv()
        if len(best_para) > 0:
            report.loc['', ['solver']] = [best_para[0]]
        report.to_csv('./clf_LR/{}_Report.txt'.format(file_name), index=1, index_label='', sep='\t')


    def load_model_misslb(model_name='LR'):
        global LR_clf
        LR_clf = joblib.load(LR_clf)
        predic = LR_clf.predict(X_test)
        predic = pd.DataFrame(predic)
        pd_data = pd.concat([predic,X],axis=1)
        pd_data.rename(columns={0:''},inplace=True)
        pd_data.to_csv('./clf_LR/{}_PredictData.txt'.format(model_name),index = 0,sep='\t')
            
    def pd_concat(model_name='LR'):
        predic = pd.DataFrame(predictions)
        pd_col_0 = predic.columns[0]
        pd_data = pd.concat([predic,X_test],axis=1)
        # pd_data.rename(columns={pd_col_0:''},inplace=True)
        pd_data = pd.concat([y_test,pd_data],axis=1)
        pd_data.rename(columns={pd_col_0:'',df_col_0:''},inplace=True)
        pd_data.to_csv('./clf_LR/{}_PredictData.txt'.format(model_name),index = 0,sep='\t')
    def plt_output(model_name='LR'):
        fig,ax = plt.subplots(figsize=(10,8))
        ax.plot(fpr_LR,tpr_LR,linewidth=2,color="black",
                label='LR (AUC={})'.format(str(round(auc(fpr_LR,tpr_LR),3))))
        ax.plot([0,1],[0,1],linestyle='--',color='grey')
        
        plt.legend(fontsize=12)
        plt.title("Validation Cohort ROC")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        # plt.show()
        f = plt.gcf()  
        if mode_choose == 'train':
            f.savefig('./clf_LR/LR_ROC.svg',bbox_inches='tight')
        else:
            f.savefig('./clf_LR/{}_ROC.svg'.format(model_name),bbox_inches='tight')
        
    def split_model_pddata():
        global X_test,y_test
        X_test = X
        y_test = y
        print(y_test)



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

def train_mode(input_file1):
    myclf_LR.read_file1(input_file1)
    if shuffle_TF == 'T':
        myclf_LR.input_shuffle()
    myclf_LR.split_file()
    myclf_LR.oversample_data()
    myclf_LR.split_file_data()
    if cv_TF == 'T':
        myclf_LR.LR_fit_cv()
    else:
        if LR_diy_TF == 'T':
            # myclf_LR.LR_fit_diy(LR_c,LR_kernel,LR_tol,LR_max_iter,LR_dfs)
            myclf_LR.LR_fit_diy()
        else:
            myclf_LR.LR_fit()
    myclf_LR.save_model()
    myclf_LR.load_model()
    myclf_LR.plt_output()
    myclf_LR.zipDir(source_dir, output_filename)
    
    
def load_mode(input_file2):
    myclf_LR.read_file2(input_file2)
    myclf_LR.split_file()
    myclf_LR.split_model_pddata()
    myclf_LR.model_input()
    if Y_lb_TF == 'T':
        myclf_LR.load_model()
        myclf_LR.pd_concat()
        myclf_LR.plt_output()
        myclf_LR.zipDir(source_dir, output_filename)
    else:
        myclf_LR.load_model_misslb()
        myclf_LR.zipDir(source_dir, output_filename)
    

# argv

source_dir = './clf_LR'
output_filename = './clf_LR.zip'

argv = sys.argv
mode_choose = argv[1] # train nan train.csv
Y_lb_TF= argv[2]
input_model = argv[3] # load_mode LR.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]

LR_diy_TF = argv[11]
if LR_diy_TF == 'T':
    LR_penalty = argv[12]
    LR_C = float(argv[13])
    LR_fi = argv[14]
    LR_tol = float(argv[15])
    LR_max_iter= argv[16]
    
    # python clf_SVC.py load_mode F LR.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15
    
    # python clf_SVC.py train T NAN train.csv 0.2 T T 5 None 0 



if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('')