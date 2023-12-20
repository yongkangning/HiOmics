
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
from sklearn.ensemble import AdaBoostClassifier
import numpy as np
from imblearn.over_sampling import RandomOverSampler
import warnings
best_para=[]
class myclf_Ada:
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
        if not os.path.exists('./clf_Ada'):
            os.mkdir('./clf_Ada')
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
        if not os.path.exists('./clf_Ada'):
            os.mkdir('./clf_Ada')
    def mode_choose():
        global df, df_col_0
        if mode_choose == 'load_mode':
            read_file2(input_file2)
        else:
            read_file1(input_file1)

    
    def input_shuffle():
        global df
        df = shuffle(df)
        print('')
        
    
    def split_file():
        global X,y
        if not Y_lb_TF == 'T' and mode_choose == 'load_mode':
            X = df
            y = 'nan'
            print('')
        else:
            y = df.iloc[:,0]
            X = df.iloc[:,1:]
        
    def oversample_data():
        global X, y
        from imblearn.over_sampling import RandomOverSampler, SMOTE
        ros = RandomOverSampler()
        # smote = SMOTE()  
        X_resampled, y_resampled = ros.fit_resample(X, y)
        X = X_resampled
        y = y_resampled        
    
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
    
    def Ada_fit():
        global Ada_clf
        Ada_clf = AdaBoostClassifier(random_state=12)
        Ada_clf.fit(X_train,y_train)
        print('Ada-')
        
    def Ada_fit_diy(Ada_n=50
                    ,Ada_lr=1):
        global Ada_clf
        Ada_clf = AdaBoostClassifier(random_state=12
                                    ,n_estimators=Ada_n
                                    ,learning_rate=Ada_lr)
        Ada_clf.fit(X_train, y_train)
        print('Ada-')
        
    
    argv = sys.argv
    cv_times = int(argv[9])
    def Ada_fit_cv(cv_times=cv_times, cv_scoring=None):
        global Ada_clf, best_para
        parameters = {
        }
        clf = AdaBoostClassifier()
        Ada_clf = GridSearchCV(clf, parameters
                               , n_jobs=-1
                               , cv=cv_times
                               , verbose=1
                               , scoring=cv_scoring)
        Ada_clf.fit(X_train, y_train)
        best_para = list(Ada_clf.best_params_.values())
        print(f'{cv_times}{cv_scoring}')
        return best_para
        
    
    def Ada_fit_cv_diy(cv_times=cv_times,cv_scoring=None):
        global Ada_clf,best_para
        
        parameters = {
            'n_estimators': [50, 100, 200],
            'learning_rate': [0.1, 0.5, 1.0],
            'base_estimator': [DecisionTreeClassifier(max_depth=1), LogisticRegression(penalty='l2', max_iter=10000)]
        }
        clf = AdaBoostClassifier()
        Ada_clf = GridSearchCV(clf,parameters
                                , n_jobs=-1
                                , cv=cv_times
                                , verbose=1
                                , scoring=cv_scoring)
        Ada_clf.fit(X_train, y_train)
        best_para = list(Ada_clf.best_params_.values())
        print(f':{cv_times}:{cv_scoring}\t{Ada_clf.best_params_}')
        
        
    def save_model():
        joblib.dump(Ada_clf, './clf_Ada/Ada.pkl')
        
    def model_input():
        global Ada_clf
        model_name = os.path.splitext(input_model)[0][:8]
        Ada_clf = input_model

    def load_model(file_name='Ada', best_para=[]):
        global fpr_Ada, tpr_Ada, Ada_clf, predictions
        if mode_choose == 'load_mode':
            Ada_clf = joblib.load(Ada_clf)
        score_Ada = Ada_clf.predict_proba(X_test)[:, 1]
        fpr_Ada, tpr_Ada, thres_Ada = roc_curve(y_test, score_Ada, )
        predictions = Ada_clf.predict(X_test)
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
            best_para = myclf_Ada.Ada_fit_cv()
        if best_para:
            report.loc['', ['base_estimator']] = best_para

        report.to_csv('./clf_Ada/{}_Report.txt'.format(file_name), index=1, index_label='', sep='\t')


    def load_model_misslb(model_name='Ada'):
        global Ada_clf
        Ada_clf = joblib.load(Ada_clf)
        predic = Ada_clf.predict(X_test)
        predic = pd.DataFrame(predic)
        pd_data = pd.concat([predic,X],axis=1)
        pd_data.rename(columns={0:''},inplace=True)
        pd_data.to_csv('./clf_Ada/{}_PredictData.txt'.format(model_name),index = 0,sep='\t')
            
    def pd_concat(model_name='Ada'):
        predic = pd.DataFrame(predictions)
        pd_col_0 = predic.columns[0]
        pd_data = pd.concat([predic,X_test],axis=1)
        # pd_data.rename(columns={pd_col_0:''},inplace=True)
        pd_data = pd.concat([y_test,pd_data],axis=1)
        pd_data.rename(columns={pd_col_0:'',df_col_0:''},inplace=True)
        pd_data.to_csv('./clf_Ada/{}_PredictData.txt'.format(model_name),index = 0,sep='\t')
    def plt_output(model_name='Ada'):
        fig,ax = plt.subplots(figsize=(10,8))
        ax.plot(fpr_Ada,tpr_Ada,linewidth=2,color="black",
                label='Ada (AUC={})'.format(str(round(auc(fpr_Ada,tpr_Ada),3))))
        ax.plot([0,1],[0,1],linestyle='--',color='grey')
        
        plt.legend(fontsize=12)
        plt.title("Validation Cohort ROC")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        # plt.show()
        f = plt.gcf()  
        if mode_choose == 'train':
            f.savefig('./clf_Ada/Ada_ROC.svg',bbox_inches='tight')
        else:
            f.savefig('./clf_Ada/{}_ROC.svg'.format(model_name),bbox_inches='tight')
        
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
            print(':',source_dir,'\:',output_filename)
            return output_filename
        else:
            print('file not found ',source_dir)
        return

def train_mode(input_file1):
    myclf_Ada.read_file(input_file1)
    if shuffle_TF == 'T':
        myclf_Ada.input_shuffle()
    myclf_Ada.split_file()
    myclf_Ada.oversample_data()
    myclf_Ada.split_file_data()
    if cv_TF == 'T':
        # myclf_Ada.Ada_fit_cv()
        pass
        if Ada_diy_TF == 'T':
            myclf_Ada.Ada_fit_diy(n_estimators,learning_rate)
        else:
            myclf_Ada.Ada_fit()
    else:
        print('')
        if Ada_diy_TF == 'T':
            # myclf_Ada.Ada_fit_diy(Ada_c,Ada_kernel,Ada_tol,Ada_max_iter,Ada_dfs)
            myclf_Ada.Ada_fit_diy(n_estimators,learning_rate)
        else:
            myclf_Ada.Ada_fit()
    myclf_Ada.save_model()
    myclf_Ada.load_model()
    myclf_Ada.plt_output()
    myclf_Ada.zipDir(source_dir, output_filename)
    #     #
    # myclf_Ada.plot_matrix(y_test,predictions,'example-confusion matrix')
    # f1 = plt.gcf()
    # f1.savefig('./clf_Ada/demo.svg')
    
def load_mode(input_file2):
    myclf_Ada.read_file(input_file2)
    myclf_Ada.split_file()
    myclf_Ada.split_model_pddata()
    myclf_Ada.model_input()
    if Y_lb_TF == 'T':
        myclf_Ada.load_model()
        myclf_Ada.pd_concat()
        myclf_Ada.plt_output()
        myclf_Ada.zipDir(source_dir, output_filename)
    else:
        myclf_Ada.load_model_misslb()
        myclf_Ada.zipDir(source_dir, output_filename)

    

# argv

source_dir = './clf_Ada'
output_filename = './clf_Ada.zip'

argv = sys.argv
mode_choose = argv[1] # train nan train.csv
Y_lb_TF = argv[2]
input_model = argv[3] # load_mode Ada.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]



Ada_diy_TF = argv[11]
if Ada_diy_TF == 'T':
    Ada_n = int(argv[12])
    Ada_lr = float(argv[13])
    
    # python clf_SVC.py load_mode F Ada.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15
    
    # python clf_Ada.py train T NAN train.csv 0.2 T T 5 None 0 



if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('')