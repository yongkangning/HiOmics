from sklearn.metrics import classification_report
from sklearn import naive_bayes
from sklearn.metrics import confusion_matrix
import pandas as pd
from sklearn.naive_bayes import MultinomialNB

import os,sys
from sklearn.model_selection import GridSearchCV
import zipfile
from sklearn import model_selection
import joblib
from sklearn.utils import shuffle

class myclf_NB:
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
        if not os.path.exists('./clf_NB'):
            os.mkdir('./clf_NB')
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
        if not os.path.exists('./clf_NB'):
            os.mkdir('./clf_NB')
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

    def NB_fit():
        global NB_clf
        NB_clf = MultinomialNB()
        NB_clf.fit(X_train, y_train)

    def NB_fit_diy(NB_alpha=0.000000001
                   ,NB_class_prior=[0.2]
                   ,NB_fit_prior=True
                   ):
        global NB_clf
        NB_clf = MultinomialNB(alpha=NB_alpha,class_prior=NB_class_prior,fit_prior=NB_fit_prior)
        NB_clf.fit(X_train, y_train)
        print('NB-diy',NB_alpha
                      ,NB_class_prior
                      ,NB_fit_prior
                      )
    argv = sys.argv
    cv_times = int(argv[9])    
    def NB_fit_cv(cv_times=cv_times, cv_scoring=None):

        global NB_clf, best_para
        
        parameters = {'class_prior':[None]}
        clf = MultinomialNB()
        NB_clf = GridSearchCV(clf, parameters
                                , n_jobs=-1
                                , cv=cv_times
                                , verbose=1
                                , scoring=cv_scoring)
        NB_clf.fit(X_train, y_train)
        best_para = list(NB_clf.best_params_.values())
        print('', NB_clf.best_params_)

    
    def save_model():
        joblib.dump(NB_clf, './clf_NB/NB.pkl')

    def model_input():
        global NB_clf
        model_name = os.path.splitext(input_model)[0][:8]
        NB_clf = input_model

    def load_model(file_name='NB'):
        global fpr_NB, tpr_NB, NB_clf, predictions
        if mode_choose == 'load_mode':
            NB_clf = joblib.load(NB_clf)
        score_NB = NB_clf.predict_proba(X_test)[:,1]
        #fpr_NB,tpr_NB,thres_NB = roc_curve(y_test,score_NB,)
        predictions = NB_clf.predict(X_test)
        print("NB")
        confusion = confusion_matrix(y_test, predictions)
        Accuracy = (confusion[0][0]+confusion[1][1])/(confusion[0][0]+confusion[0][1]+confusion[1][0]+confusion[1][1])
        Precision = confusion[0][0]/(confusion[0][0]+confusion[0][1])
        Sensitivity = confusion[0][0]/(confusion[0][0]+confusion[1][0])
        Specifcity = confusion[0][0]/(confusion[0][0]+confusion[0][1])
        F1 = 2*Precision*Sensitivity/(Precision+Sensitivity)
        print("Accuracy:", Accuracy, "Precision:", Precision, "F1:",F1,"Sensitivity:",Sensitivity,"Specifcity:",Specifcity)
        print(classification_report(y_test, predictions))
        report = classification_report(y_test, predictions,output_dict=True)
        report = pd.DataFrame(report).transpose()
        report.rename(columns={'precision':'','recall':'','f1-score':'','support':''},inplace=True)
        report.rename(index={'accuracy':'','macro avg':'','micro avg':'','weighted avg':''},inplace=True)
        report.loc['',['','']] = [Sensitivity,Specifcity]
        if mode_choose == 'train' and cv_TF == 'T':
            report.loc['',['class_prior']] = [best_para[0]]
        report.to_csv('./clf_NB/{}_Report.txt'.format(file_name),index = 1,index_label='',sep = '\t')

    def load_model_misslb(model_name='NB'):
            global NB_clf
            NB_clf = joblib.load(NB_clf)
            predic = NB_clf.predict(X_test)
            predic = pd.DataFrame(predic)
            pd_data = pd.concat([predic, X], axis=1)
            pd_data.rename(columns={0: ''}, inplace=True)
            pd_data.to_csv('./clf_NB/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def pd_concat(model_name='NB'):
            predic = pd.DataFrame(predictions)
            pd_col_0 = predic.columns[0]
            pd_data = pd.concat([predic, X_test], axis=1)
            # pd_data.rename(columns={pd_col_0:''},inplace=True)
            pd_data = pd.concat([y_test, pd_data], axis=1)
            pd_data.rename(columns={pd_col_0: '', df_col_0: ''}, inplace=True)
            pd_data.to_csv('./clf_NB/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    #def plt_output(model_name='NB'):
    #        fig, ax = plt.subplots(figsize=(10, 8))
    #        ax.plot(fpr_NB, tpr_NB, linewidth=2, color="black",
    #                label='NB (AUC={})'.format(str(round(auc(fpr_NB, tpr_NB), 3))))
    #        ax.plot([0, 1], [0, 1], linestyle='--', color='grey')
            
    #        plt.legend(fontsize=12)
    #        plt.title("Validation Cohort ROC")
    #        plt.xlabel("False Positive Rate")
    #        plt.ylabel("True Positive Rate")
            # plt.show()
    #        f = plt.gcf()  
    #        if mode_choose == 'train':
    #            f.savefig('./clf_NB/NB_ROC.svg', bbox_inches='tight')
     #       else:
     #           f.savefig('./clf_NB/{}_ROC.svg'.format(model_name), bbox_inches='tight')

    def split_model_pddata():
            global X_test, y_test
            X_test = X
            y_test = y
            print(y_test)
    def split_float_name(str_name:str) -> tuple :
       
        list2 = []
        list1 = str_name.split(',')
        for i in list1:
            try:
                i = float(i)
                list2.append(i)
            except:
                pass
        return tuple(list2)

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
    myclf_NB.read_file(input_file1)
    if shuffle_TF == 'T':
            myclf_NB.input_shuffle()
    myclf_NB.split_file()
    myclf_NB.oversample_data()
    myclf_NB.split_file_data()
    if cv_TF == 'T':
        myclf_NB.NB_fit_cv()
    else:
        if NB_diy_TF == 'T':
            myclf_NB.NB_fit_diy(NB_alpha
                                ,NB_class_prior
                                ,NB_fit_prior)
        else:
            myclf_NB.NB_fit()
    myclf_NB.save_model()
    myclf_NB.load_model()
    #myclf_NB.plt_output()
    myclf_NB.zipDir(source_dir, output_filename)

def load_mode(input_file2):
    myclf_NB.read_file(input_file2)
    myclf_NB.split_file()
    myclf_NB.split_model_pddata()
    myclf_NB.model_input()
    if Y_lb_TF == 'T':
        myclf_NB.load_model()
        myclf_NB.pd_concat()
        #myclf_NB.plt_output()
        myclf_NB.zipDir(source_dir, output_filename)
    else:
        myclf_NB.load_model_misslb()
        myclf_NB.zipDir(source_dir, output_filename)

    # argv

source_dir = './clf_NB'
output_filename = './clf_NB.zip'

argv = sys.argv
mode_choose = argv[1]  # train nan train.csv
Y_lb_TF = argv[2]
input_model = argv[3]  # load_mode NB.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]

NB_diy_TF = argv[11]
if NB_diy_TF == 'T':
    NB_alpha = float(argv[12])
    NB_class_prior = myclf_NB.split_float_name(argv[13])
    NB_fit_prior = bool(argv[14])


    if cv_scoring == 'None':
        cv_scoring = None
        # python clf_SVC.py load_mode F GBNB.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15

        # python clf_GBNB.py train T NAN train.csv 0.2 T T 5 None 0

        # GBNB_loss,GBNB_learning_rate,GBNB_subsample,GBNB_n_estimators,GBNB_criterion,GBNB_max_depth,GBNB_min_samples_leaf,GBNB_min_samples_split,GBNB_max_features

if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('')