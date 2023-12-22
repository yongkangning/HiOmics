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
import xgboost
import lightgbm as lgb
import numpy as np
from imblearn.over_sampling import RandomOverSampler
import warnings

class myclf_XGB:
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
        if not os.path.exists('./clf_'):
            os.mkdir('./clf_XGB')

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
        if not os.path.exists('./clf_XGB'):
            os.mkdir('./clf_XGB')

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

    
    def XGB_fit():
        global XGB_clf
        XGB_clf = lgb.LGBMClassifier(colsample_bytree=0.7, max_depth=8, min_child_weight=0.0, min_child_samples=26,
                                     n_estimators=65, num_leaves=30, objective='binary', learning_rate=0.01,
                                     subsample=0.6)
        XGB_clf.fit(X_train, y_train)

    def XGB_fit_diy(XGB_colsample_bytree=0.7
                     , XGB_max_depth=8
                     , XGB_min_child_weight=0.0
                     , XGB_min_child_samples=26
                     , XGB_n_estimators=65
                     , XGB_num_leaves=30
                     , XGB_objective='binary'
                     , XGB_learning_rate=0.01
                     , XGB_subsample=0.6  # log2 sqrt None
                     ):
        global XGB_clf
        XGB_clf = lgb.LGBMClassifier(colsample_bytree=XGB_colsample_bytree
                                    , max_depth=XGB_max_depth
                                    , min_child_weight=XGB_min_child_weight
                                    , min_child_samples=XGB_min_child_samples
                                    , n_estimators=XGB_n_estimators
                                    , num_leaves=XGB_num_leaves
                                    , objective=XGB_objective
                                    , learning_rate=XGB_learning_rate
                                    , subsample=XGB_subsample)
        XGB_clf.fit(X_train, y_train)
        print('XGB-diy', XGB_colsample_bytree
              , XGB_max_depth
              , XGB_min_child_weight
              , XGB_min_child_samples
              , XGB_n_estimators
              , XGB_num_leaves
              , XGB_objective
              , XGB_learning_rate
              , XGB_subsample)

    # cv_diy
    argv = sys.argv
    cv_times = int(argv[9])
    def XGB_fit_cv(cv_times=cv_times, cv_scoring=None):

        global XGB_clf, best_para
        
        parameters = {
            'max_depth': [4, 6, 8],
            'learning_rate': [0.01, 0.1, 1.0],
            'n_estimators': [50, 100, 200],
            'subsample': [0.6, 0.8, 1.0],
            'colsample_bytree': [0.6, 0.8, 1.0],
        }
        clf = lgb.LGBMClassifier( min_child_weight=0.0, min_child_samples=26,
                                      num_leaves=30, objective='binary')
        XGB_clf = GridSearchCV(clf, parameters
                                , n_jobs=-1
                                , cv=cv_times
                                , verbose=1
                                , scoring=cv_scoring)
        XGB_clf.fit(X_train, y_train)
        best_para = list(XGB_clf.best_params_.values())
        print('', XGB_clf.best_params_)

    
    def save_model():
        joblib.dump(XGB_clf, './clf_XGB/XGB.pkl')

    def model_input():
        global XGB_clf
        model_name = os.path.splitext(input_model)[0][:8]
        XGB_clf = input_model

    def load_model(file_name='XGB'):
        global fpr_XGB, tpr_XGB, XGB_clf, predictions
        if mode_choose == 'load_mode':
            XGB_clf = joblib.load(XGB_clf)
        score_XGB = XGB_clf.predict_proba(X_test)[:,1]
        fpr_XGB,tpr_XGB,thres_XGB = roc_curve(y_test,score_XGB,)
        predictions = XGB_clf.predict(X_test)
        print("LGBM")
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
            report.loc['', ['objective']] = [best_para[0]]
        report.to_csv('./clf_XGB/{}_Report.txt'.format(file_name), index=1, index_label='', sep='\t')

    def load_model_misslb(model_name='XGB'):
        global XGB_clf
        XGB_clf = joblib.load(XGB_clf)
        predic = XGB_clf.predict(X_test)
        predic = pd.DataFrame(predic)
        pd_data = pd.concat([predic, X], axis=1)
        pd_data.rename(columns={0: ''}, inplace=True)
        pd_data.to_csv('./clf_XGB/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def pd_concat(model_name='XGB'):
        predic = pd.DataFrame(predictions)
        pd_col_0 = predic.columns[0]
        pd_data = pd.concat([predic, X_test], axis=1)
        # pd_data.rename(columns={pd_col_0:''},inplace=True)
        pd_data = pd.concat([y_test, pd_data], axis=1)
        pd_data.rename(columns={pd_col_0: '', df_col_0: ''}, inplace=True)
        pd_data.to_csv('./clf_XGB/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def plt_output(model_name='XGB'):
        fig, ax = plt.subplots(figsize=(10, 8))
        ax.plot(fpr_XGB, tpr_XGB, linewidth=2, color="black",
                label='XGB (AUC={})'.format(str(round(auc(fpr_XGB, tpr_XGB), 3))))
        ax.plot([0, 1], [0, 1], linestyle='--', color='grey')
        
        plt.legend(fontsize=12)
        plt.title("Validation Cohort ROC")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        # plt.show()
        f = plt.gcf()  
        if mode_choose == 'train':
            f.savefig('./clf_XGB/XGB_ROC.svg', bbox_inches='tight')
        else:
            f.savefig('./clf_XGB/{}_ROC.svg'.format(model_name), bbox_inches='tight')

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
            print(':', source_dir, '', output_filename)
            return output_filename
        else:
            print('file not found ', source_dir)
        return

def train_mode(input_file1):
    myclf_XGB.read_file(input_file1)
    if shuffle_TF == 'T':
        myclf_XGB.input_shuffle()
    myclf_XGB.split_file()
    myclf_XGB.oversample_data()
    myclf_XGB.split_file_data()
    if cv_TF == 'T':
        myclf_XGB.XGB_fit_cv()
    else:
        if XGB_diy_TF == 'T':
            myclf_XGB.XGB_fit_diy(XGB_colsample_bytree
                                , XGB_max_depth
                                , XGB_min_child_weight
                                , XGB_min_child_samples
                                , XGB_n_estimators
                                , XGB_num_leaves
                                , XGB_objective
                                , XGB_learning_rate
                                , XGB_subsample)
        else:
            myclf_XGB.XGB_fit()
    myclf_XGB.save_model()
    myclf_XGB.load_model()
    myclf_XGB.plt_output()
    myclf_XGB.zipDir(source_dir, output_filename)

def load_mode(input_file2):
    myclf_XGB.read_file(input_file2)
    myclf_XGB.split_file()
    myclf_XGB.split_model_pddata()
    myclf_XGB.model_input()
    if Y_lb_TF == 'T':
        myclf_XGB.load_model()
        myclf_XGB.pd_concat()
        myclf_XGB.plt_output()
        myclf_XGB.zipDir(source_dir, output_filename)
    else:
        myclf_XGB.load_model_misslb()
        myclf_XGB.zipDir(source_dir, output_filename)

    # argv

source_dir = './clf_XGB'
output_filename = './clf_XGB.zip'

argv = sys.argv
mode_choose = argv[1]  # train nan train.csv
Y_lb_TF = argv[2]
input_model = argv[3]  # load_mode XGB.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]

XGB_diy_TF = argv[11]
if XGB_diy_TF == 'T':
    XGB_colsample_bytree = float(argv[12])
    XGB_max_depth = int(argv[13])
    XGB_min_child_weight = float(argv[14])
    XGB_min_child_samples = int(argv[15])

    XGB_n_estimators = int(argv[16])
    XGB_num_leaves = int(argv[17])

    XGB_objective = argv[18]
    XGB_learning_rate = float(argv[19])
    XGB_subsample = float(argv[20])
    if cv_scoring == 'None':
        cv_scoring = None
        # python clf_SVC.py load_mode F XGB.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15

        # python clf_XGB.py train T NAN train.csv 0.2 T T 5 None 0

        # XGB_loss,XGB_learning_rate,XGB_subsample,XGB_n_estimators,XGB_criterion,XGB_max_depth,XGB_min_samples_leaf,XGB_min_samples_split,XGB_max_features

if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('')

