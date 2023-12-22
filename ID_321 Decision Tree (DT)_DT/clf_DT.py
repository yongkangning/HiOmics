from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix
import pandas as pd
from sklearn import tree
from sklearn.metrics import roc_curve, auc
import os,sys
from sklearn.model_selection import GridSearchCV,train_test_split
import zipfile
from sklearn import model_selection
import joblib
from sklearn.utils import shuffle
import matplotlib.pyplot as plt
import numpy as np
from imblearn.over_sampling import RandomOverSampler
import warnings
class myclf_DT:
    # read file
    def read_file(input_file1):
        global df ,df_col_0
        file_name = os.path.splitext(input_file1)[0][:8]
        if os.path.splitext(input_file1)[1] == '.txt':
            df = pd.read_table(input_file1)
        elif os.path.splitext(input_file1)[1] == '.csv':
            df = pd.read_csv(input_file1)
        elif os.path.splitext(input_file1)[1] == '.xlsx' or os.path.splitext(input_file1)[1] == '.xls':
            df = pd.read_excel(input_file1)
        df_col_0 = df.columns[0]
        if not os.path.exists('./clf_DT'):
            os.mkdir('./clf_DT')
    def read_file(input_file2):
        global df ,df_col_0
        file_name = os.path.splitext(input_file2)[0][:8]
        if os.path.splitext(input_file2)[1] == '.txt':
            df = pd.read_table(input_file2)
        elif os.path.splitext(input_file2)[1] == '.csv':
            df = pd.read_csv(input_file2)
        elif os.path.splitext(input_file2)[1] == '.xlsx' or os.path.splitext(input_file2)[1] == '.xls':
            df = pd.read_excel(input_file2)
        df_col_0 = df.columns[0]
        if not os.path.exists('./clf_DT'):
            os.mkdir('./clf_DT')
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
        global X ,y
        if not Y_lb_TF == 'T' and mode_choose == 'load_mode':
            X = df
            y = 'nan'
            print('')
        else:
            y = df.iloc[: ,0]
            X = df.iloc[: ,1:]
        
    def oversample_data():
        global X, y
        from imblearn.over_sampling import RandomOverSampler, SMOTE
        ros = RandomOverSampler()
        # smote = SMOTE()  
        X_resampled, y_resampled = ros.fit_resample(X, y)
        X = X_resampled
        y = y_resampled        
    
    def split_file_data():
        global X_test ,y_test ,X_train ,y_train
        # define seed for reproducibility
        seed = 12
        # split data into training and testing datasets
        X_train, X_test, y_train, y_test = model_selection.train_test_split(X
                                                                            , y
                                                                            , test_size=rate
                                                                            , random_state=seed)
        X_test = np.ascontiguousarray(X_test)
    def DT_fit():
        global DT_clf
        DT_clf = tree.DecisionTreeClassifier()
        DT_clf.fit(X_train, y_train)

    def DT_fit_diy(DT_criterion='entropy'
                   ,DT_max_depth=5
                   ,DT_min_samples_split=3
                   ,DT_class_weight='balanced'
                    ):
        global DT_clf
        DT_clf = tree.DecisionTreeClassifier(criterion=DT_criterion
                                    ,max_depth=DT_max_depth
                                    ,min_samples_split=DT_min_samples_split
                                    ,class_weight=DT_class_weight
                                    )
        DT_clf.fit(X_train, y_train)
        print('DT-diy',DT_criterion
                      ,DT_max_depth
                      ,DT_min_samples_split
                      ,DT_class_weight)
    argv = sys.argv
    cv_times = int(argv[9])    
    def DT_fit_cv(cv_times=cv_times, cv_scoring=None):

        global DT_clf, best_para
        
        parameters = {
    'criterion': ['gini', 'entropy'],
    'max_depth': [None, 5, 10],
    'min_samples_split': [2, 4, 6],
    'min_samples_leaf': [1, 2, 3],
    'class_weight': ['balanced', None]
}
        clf = tree.DecisionTreeClassifier()
        DT_clf = GridSearchCV(clf, parameters
                                , n_jobs=-1
                                , cv=cv_times
                                , verbose=1
                                , scoring=cv_scoring)
        DT_clf.fit(X_train, y_train)
        best_para = list(DT_clf.best_params_.values())
        print('', DT_clf.best_params_)

    
    def save_model():
        joblib.dump(DT_clf, './clf_DT/DT.pkl')

    def model_input():
        global DT_clf
        model_name = os.path.splitext(input_model)[0][:8]
        DT_clf = input_model

    def load_model(file_name='DT'):
        global fpr_DT, tpr_DT, DT_clf, predictions
        if mode_choose == 'load_mode':
            DT_clf = joblib.load(DT_clf)
        score_DT = DT_clf.predict_proba(X_test)[:,1]
        fpr_DT,tpr_DT,thres_DT = roc_curve(y_test,score_DT,)
        predictions = DT_clf.predict(X_test)
        print("DT")
        confusion = confusion_matrix(y_test, predictions)
        Accuracy = (confusion[0][0]+confusion[1][1])/(confusion[0][0]+confusion[0][1]+confusion[1][0]+confusion[1][1])
        Precision = confusion[0][0]/(confusion[0][0]+confusion[0][1])
        Sensitivity = confusion[0][0]/(confusion[0][0]+confusion[1][0])
        Specifcity = confusion[1][1]/(confusion[1][1]+confusion[0][1])
        F1 = 2*Precision*Sensitivity/(Precision+Sensitivity)
        print("Accuracy:", Accuracy, "Precision:", Precision, "F1:",F1,"Sensitivity:",Sensitivity,"Specifcity:",Specifcity)
        print(classification_report(y_test, predictions))
        report = classification_report(y_test, predictions,output_dict=True)
        report = pd.DataFrame(report).transpose()
        report.rename(columns={'precision':'','recall':'','f1-score':'','support':''},inplace=True)
        report.rename(index={'accuracy':'','macro avg':'','micro avg':'','weighted avg':''},inplace=True)
        report.loc['',['','']] = [Sensitivity,Specifcity]
        if mode_choose == 'train' and cv_TF == 'T':
            report.loc['',['criterion']] = [best_para[0]]
        report.to_csv('./clf_DT/{}_Report.txt'.format(file_name),index = 1,index_label='',sep = '\t')

    def load_model_misslb(model_name='DT'):
            global DT_clf
            DT_clf = joblib.load(DT_clf)
            predic = DT_clf.predict(X_test)
            predic = pd.DataFrame(predic)
            pd_data = pd.concat([predic, X], axis=1)
            pd_data.rename(columns={0: ''}, inplace=True)
            pd_data.to_csv('./clf_DT/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def pd_concat(model_name='DT'):
            predic = pd.DataFrame(predictions)
            pd_col_0 = predic.columns[0]
            pd_data = pd.concat([predic, X_test], axis=1)
            # pd_data.rename(columns={pd_col_0:''},inplace=True)
            pd_data = pd.concat([y_test, pd_data], axis=1)
            pd_data.rename(columns={pd_col_0: '', df_col_0: ''}, inplace=True)
            pd_data.to_csv('./clf_DT/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def plt_output(model_name='DT'):
            fig, ax = plt.subplots(figsize=(10, 8))
            ax.plot(fpr_DT, tpr_DT, linewidth=2, color="black",
                    label='DT (AUC={})'.format(str(round(auc(fpr_DT, tpr_DT), 3))))
            ax.plot([0, 1], [0, 1], linestyle='--', color='grey')
            
            plt.legend(fontsize=12)
            plt.title("Validation Cohort ROC")
            plt.xlabel("False Positive Rate")
            plt.ylabel("True Positive Rate")
            # plt.show()
            f = plt.gcf()  
            if mode_choose == 'train':
                f.savefig('./clf_DT/DT_ROC.svg', bbox_inches='tight')
            else:
                f.savefig('./clf_DT/{}_ROC.svg'.format(model_name), bbox_inches='tight')

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
    myclf_DT.read_file(input_file1)
    if shuffle_TF == 'T':
            myclf_DT.input_shuffle()
    myclf_DT.split_file()
    myclf_DT.oversample_data()
    myclf_DT.split_file_data()
    if cv_TF == 'T':
        myclf_DT.DT_fit_cv()
    else:
        if DT_diy_TF == 'T':
            myclf_DT.DT_fit_diy(DT_criterion
                                ,DT_max_depth
                                ,DT_min_samples_split
                                ,DT_class_weight)
        else:
            myclf_DT.DT_fit()
    myclf_DT.save_model()
    myclf_DT.load_model()
    myclf_DT.plt_output()
    myclf_DT.zipDir(source_dir, output_filename)

def load_mode(input_file2):
    myclf_DT.read_file(input_file2)
    myclf_DT.split_file()
    myclf_DT.split_model_pddata()
    myclf_DT.model_input()
    if Y_lb_TF == 'T':
        myclf_DT.load_model()
        myclf_DT.pd_concat()
        myclf_DT.plt_output()
        myclf_DT.zipDir(source_dir, output_filename)
    else:
        myclf_DT.load_model_misslb()
        myclf_DT.zipDir(source_dir, output_filename)

    # argv

source_dir = './clf_DT'
output_filename = './clf_DT.zip'

argv = sys.argv
mode_choose = argv[1]  # train nan train.csv
Y_lb_TF = argv[2]
input_model = argv[3]  # load_mode DT.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]

DT_diy_TF = argv[11]
if DT_diy_TF == 'T':
    DT_criterion = argv[12]
    DT_max_depth = int(argv[13])
    DT_min_samples_split = int(argv[14])
    DT_class_weight = argv[15]
    if DT_class_weight == 'None':
        DT_class_weight = None
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
        print('')