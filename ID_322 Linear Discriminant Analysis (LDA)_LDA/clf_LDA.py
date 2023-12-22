from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
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
import numpy as np
from imblearn.over_sampling import RandomOverSampler
import warnings

class myclf_LDA:
    # read file
    def read_file(input_file1):
        global df, df_col_0
        file_name = os.path.splitext(input_file1)[0][:8]
        if os.path.splitext(input_file1)[1] == '.txt':
            df = pd.read_table(input_file1)
        elif os.path.splitext(input_file1)[1] == '.csv':
            df = pd.read_csv(input_file1)
        elif os.path.splitext(input_file1)[1] == '.xlsx' or os.path.splitext(input_file1)[1] == '.xls':
            df = pd.read_excel(input_file1)
        df_col_0 = df.columns[0]
        if not os.path.exists('./clf_LDA'):
            os.mkdir('./clf_LDA')

    def read_file(input_file2):
        global df, df_col_0
        file_name = os.path.splitext(input_file2)[0][:8]
        if os.path.splitext(input_file2)[1] == '.txt':
            df = pd.read_table(input_file2)
        elif os.path.splitext(input_file2)[1] == '.csv':
            df = pd.read_csv(input_file2)
        elif os.path.splitext(input_file2)[1] == '.xlsx' or os.path.splitext(input_file2)[1] == '.xls':
            df = pd.read_excel(input_file2)
        df_col_0 = df.columns[0]
        if not os.path.exists('./clf_LDA'):
            os.mkdir('./clf_LDA')

    def mode_choose():
        global df, df_col_0
        if mode_choose == 'load_mode':
            read_file2(input_file2)
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

    
    def LDA_fit():
        global LDA_clf
        LDA_clf = LinearDiscriminantAnalysis()
        LDA_clf.fit(X_train, y_train)

    def LDA_fit_diy(LDA_solver='svd'  
                     , LDA_shrinkage=None
                     , LDA_tol=0.0001
                     , LDA_n_components=1
                     , LDA_store_covariance=True
                     ):
        global LDA_clf
        LDA_clf = LinearDiscriminantAnalysis(solver=LDA_solver
                                              , shrinkage=LDA_shrinkage
                                              , tol=LDA_tol
                                              , n_components=LDA_n_components
                                              , store_covariance=bool(LDA_store_covariance)
                                              )  
        LDA_clf.fit(X_train, y_train)
        print('LDA-diy', LDA_solver
                       , LDA_shrinkage
                       , LDA_tol
                       , LDA_n_components
                       , LDA_store_covariance)

    # cv_diy
    argv = sys.argv
    cv_times = int(argv[9])
    def LDA_fit_cv(cv_times=cv_times, cv_scoring=None):

        global LDA_clf, best_para
        
        parameters = {'solver': ('svd', 'lsqr','eigen')
                       }
        clf = LinearDiscriminantAnalysis()
        LDA_clf = GridSearchCV(clf, parameters
                                , n_jobs=-1
                                , cv=cv_times
                                , verbose=1
                                , scoring=cv_scoring)
        LDA_clf.fit(X_train, y_train)
        best_para = list(LDA_clf.best_params_.values())
        print('', LDA_clf.best_params_)

  
    def save_model():
        joblib.dump(LDA_clf, './clf_LDA/LDA.pkl')

    def model_input():
        global LDA_clf
        model_name = os.path.splitext(input_model)[0][:8]
        LDA_clf = input_model

    def load_model(file_name='LDA'):
        global fpr_LDA, tpr_LDA, LDA_clf, predictions
        if mode_choose == 'load_mode':
            LDA_clf = joblib.load(LDA_clf)
        score_LDA = LDA_clf.predict_proba(X_test)[:,1]
        fpr_LDA,tpr_LDA,thres_LDA = roc_curve(y_test,score_LDA,)
        predictions = LDA_clf.predict(X_test)
        print("LDA")
        confusion = confusion_matrix(y_test, predictions)
        Accuracy = (confusion[0][0]+confusion[1][1])/(confusion[0][0]+confusion[0][1]+confusion[1][0]+confusion[1][1])
        Precision = confusion[0][0]/(confusion[0][0]+confusion[0][1])
        Sensitivity = confusion[0][0]/(confusion[0][0]+confusion[1][0])
        Specifcity = confusion[1][1]/(confusion[1][1]+confusion[0][1])
        F1 = 2*Precision*Sensitivity/(Precision+Sensitivity)
        print("Accuracy:", Accuracy, "Precision:", Precision, "F1:",F1,"Sensitivity:",Sensitivity,"Specifcity:",Specifcity)
        print(classification_report(y_test, predictions))
        report = classification_report(y_test, predictions, output_dict=True)
        report = pd.DataFrame(report).transpose()
        report.rename(columns={'precision': '', 'recall': '', 'f1-score': '', 'support': ''},
                      inplace=True)
        report.rename(
            index={'accuracy': '', 'macro avg': '', 'micro avg': '', 'weighted avg': ''},
            inplace=True)
        report.loc['', ['', '']] = [Sensitivity, Specifcity]
        if mode_choose == 'train' and cv_TF == 'T':
            report.loc['', ['solver']] = [best_para[0]]
            report.loc['', ['shrinkage']] = [best_para[1]]
        report.to_csv('./clf_LDA/{}_Report.txt'.format(file_name), index=1, index_label='', sep='\t')

    def load_model_misslb(model_name='LDA'):
        global LDA_clf
        LDA_clf = joblib.load(LDA_clf)
        predic = LDA_clf.predict(X_test)
        predic = pd.DataFrame(predic)
        pd_data = pd.concat([predic, X], axis=1)
        pd_data.rename(columns={0: ''}, inplace=True)
        pd_data.to_csv('./clf_LDA/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def pd_concat(model_name='LDA'):
        predic = pd.DataFrame(predictions)
        pd_col_0 = predic.columns[0]
        pd_data = pd.concat([predic, X_test], axis=1)
        # pd_data.rename(columns={pd_col_0:''},inplace=True)
        pd_data = pd.concat([y_test, pd_data], axis=1)
        pd_data.rename(columns={pd_col_0: '', df_col_0: ''}, inplace=True)
        pd_data.to_csv('./clf_LDA/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def plt_output(model_name='LDA'):
        fig, ax = plt.subplots(figsize=(10, 8))
        ax.plot(fpr_LDA, tpr_LDA, linewidth=2, color="black",
                label='LDA (AUC={})'.format(str(round(auc(fpr_LDA, tpr_LDA), 3))))
        ax.plot([0, 1], [0, 1], linestyle='--', color='grey')
        
        plt.legend(fontsize=12)
        plt.title("Validation Cohort ROC")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        # plt.show()
        f = plt.gcf()  
        if mode_choose == 'train':
            f.savefig('./clf_LDA/LDA_ROC.svg', bbox_inches='tight')
        else:
            f.savefig('./clf_LDA/{}_ROC.svg'.format(model_name), bbox_inches='tight')

    def split_model_pddata():
        global X_test, y_test
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
            print('', source_dir, '', output_filename)
            return output_filename
        else:
            print('file not found ', source_dir)
        return

def train_mode(input_file1):
    myclf_LDA.read_file(input_file1)
    if shuffle_TF == 'T':
        myclf_LDA.input_shuffle()
    myclf_LDA.split_file()
    myclf_LDA.oversample_data()
    myclf_LDA.split_file_data()
    if cv_TF == 'T':
        myclf_LDA.LDA_fit_cv()
    else:
        if LDA_diy_TF == 'T':
            myclf_LDA.LDA_fit_diy(LDA_solver
                    , LDA_shrinkage
                    , LDA_tol
                    , LDA_n_components
                    , LDA_store_covariance)
        else:
            myclf_LDA.LDA_fit()
    myclf_LDA.save_model()
    myclf_LDA.load_model()
    myclf_LDA.plt_output()
    myclf_LDA.zipDir(source_dir, output_filename)

def load_mode(input_file2):
    myclf_LDA.read_file(input_file2)
    myclf_LDA.split_file()
    myclf_LDA.split_model_pddata()
    myclf_LDA.model_input()
    if Y_lb_TF == 'T':
        myclf_LDA.load_model()
        myclf_LDA.pd_concat()
        myclf_LDA.plt_output()
        myclf_LDA.zipDir(source_dir, output_filename)
    else:
        myclf_LDA.load_model_misslb()
        myclf_LDA.zipDir(source_dir, output_filename)

    # argv

source_dir = './clf_LDA'
output_filename = './clf_LDA.zip'

argv = sys.argv
mode_choose = argv[1]  # train nan train.csv
Y_lb_TF = argv[2]
input_model = argv[3]  # load_mode LDA.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]

LDA_diy_TF = argv[11]
if LDA_diy_TF == 'T':
    LDA_solver = argv[12]
    LDA_shrinkage = argv[13]
    LDA_tol = float(argv[14])
    LDA_n_components = int(argv[15])

    LDA_store_covariance = argv[16]

    if cv_scoring == 'None':
        cv_scoring = None
    if LDA_shrinkage == 'None':
        LDA_shrinkage = None

        # python clf_SVC.py load_mode F LDA.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15

        # python clf_LDA.py train T NAN train.csv 0.2 T T 5 None 0

        # LDA_loss,LDA_learning_rate,LDA_subsample,LDA_n_estimators,LDA_criterion,LDA_max_depth,LDA_min_samples_leaf,LDA_min_samples_split,LDA_max_features

if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('')