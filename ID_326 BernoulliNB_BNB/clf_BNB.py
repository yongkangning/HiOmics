from sklearn import model_selection
from sklearn.metrics import classification_report
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.metrics import roc_curve, auc ,confusion_matrix
import joblib
import os,sys
from sklearn.model_selection import GridSearchCV
from sklearn.utils import shuffle
import zipfile
from sklearn.naive_bayes import BernoulliNB



class myclf_BNB:
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
        if not os.path.exists('./clf_BNB'):
            os.mkdir('./clf_BNB')

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
        if not os.path.exists('./clf_BNB'):
            os.mkdir('./clf_BNB')

    def mode_choose():
        global df, df_col_0
        if mode_choose == 'load_mode':
            read_file2(input_file2)
        else:
            read_file1(input_file1)

    
    def input_shuffle():
        global df
        df = shuffle(df,random_state=1)

    
    def split_file():
        global X, y
        if not Y_lb_TF == 'T' and mode_choose == 'load_mode':
            X = df
            y = 'nan'
            print('')
        else:
            y = df.iloc[:, 0]
            X = df.iloc[:, 1:]
            print(y)

    
    def split_file_data():
        global X_test,y_test,X_train,y_train
        # define seed for reproducibility
        seed = 12
        # split data into training and testing datasets
        X_train, X_test, y_train, y_test = model_selection.train_test_split(X, y, test_size=rate, random_state=seed)
    
    def BNB_fit():
        global BNB_clf
        BNB_clf = BernoulliNB()  
        BNB_clf.fit(X_train, y_train)

    def BNB_fit_diy(BNB_alpha=1.0
                    ,BNB_class_prior= [0.6]
                    ):
        global BNB_clf
        BNB_clf = BernoulliNB(alpha=BNB_alpha
                      ,class_prior=BNB_class_prior)  
        BNB_clf.fit(X_train, y_train)
        print('BNB-diy', BNB_alpha,BNB_class_prior)

    # cv_diy
    argv = sys.argv
    cv_times = int(argv[9])
    def scv_fit_cv(cv_times=cv_times, cv_scoring=None):
        global BNB_clf
        
        parameters = {}  
        clf = BernoulliNB()
        BNB_clf = GridSearchCV(clf, parameters
                               , n_jobs=-1
                               , cv=cv_times
                               , verbose=1
                               , scoring=cv_scoring)
        BNB_clf.fit(X_train, y_train)
        print(BNB_clf.best_params_)

    def save_model():
        joblib.dump(BNB_clf, './clf_BNB/BNB.pkl')

    def model_input():
        global BNB_clf
        model_name = os.path.splitext(input_model)[0][:8]
        BNB_clf = input_model

    def load_model(file_name='BNB'):
        global fpr_BNB, tpr_BNB, BNB_clf, predictions
        if mode_choose == 'load_mode':
            BNB_clf = joblib.load(BNB_clf)
        score_BNB = BNB_clf.predict_proba(X_test)[:, 1]
        print(y_test)
        fpr_BNB, tpr_BNB, thres_BNB = roc_curve(y_test, score_BNB,)
        predictions = BNB_clf.predict(X_test)
        print("BNB")
        confusion = confusion_matrix(y_test, predictions)
        Accuracy = (confusion[0][0]+confusion[1][1])/(confusion[0][0]+confusion[0][1]+confusion[1][0]+confusion[1][1])
        Precision = confusion[0][0]/(confusion[0][0]+confusion[0][1])
        Sensitivity = confusion[0][0]/(confusion[0][0]+confusion[1][0])
        Specifcity = confusion[0][0]/(confusion[0][0]+confusion[0][1])
        F1 = 2*Precision*Sensitivity/(Precision+Sensitivity)
        # score
        print("Accuracy:", Accuracy, "Precision:", Precision, "F1:", F1, "Sensitivity:", Sensitivity, "Specificity:",
              Specifcity)
        report = classification_report(y_test, predictions, output_dict=True,zero_division=1.0)
        report = pd.DataFrame(report).transpose()
        report.rename(columns={'precision': '', 'recall': '', 'f1-score': '', 'support': ''},
                      inplace=True)
        report.rename(
            index={'accuracy': '', 'macro avg': '', 'micro avg': '', 'weighted avg': ''},
            inplace=True)
        report.loc['', ['', '']] = [Sensitivity, Specifcity]
        report.to_csv('./clf_BNB/{}_Report.txt'.format(file_name), index=1, index_label='', sep='\t')


    def load_model_misslb(model_name='BNB'):
        global BNB_clf
        BNB_clf = joblib.load(BNB_clf)
        predic = BNB_clf.predict(X_test)
        predic = pd.DataFrame(predic)
        pd_data = pd.concat([predic, X], axis=1)
        pd_data.rename(columns={0: ''}, inplace=True)
        pd_data.to_csv('./clf_BNB/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    
    def pd_concat(model_name='BNB'):
        predic = pd.DataFrame(predictions)
        pd_col_0 = predic.columns[0]
        pd_data = pd.concat([predic, X_test], axis=1)
        # pd_data.rename(columns={pd_col_0:''},inplace=True)
        pd_data = pd.concat([y_test, pd_data], axis=1)
        pd_data.rename(columns={pd_col_0: '', df_col_0: ''}, inplace=True)
        pd_data.to_csv('./clf_BNB/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def plt_output(model_name='BNB'):
        fig, ax = plt.subplots(figsize=(10, 8))
        ax.plot(fpr_BNB, tpr_BNB, linewidth=2, color="black",
                label='BNB (AUC={})'.format(str(round(auc(fpr_BNB, tpr_BNB), 3))))
        ax.plot([0, 1], [0, 1], linestyle='--', color='grey')
        
        plt.legend(fontsize=12)
        plt.title("Validation Cohort ROC")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        # plt.show()
        f = plt.gcf()  
        if mode_choose == 'train':
            f.savefig('./clf_BNB/BNB_ROC.svg', bbox_inches='tight')
        else:
            f.savefig('./clf_BNB/{}_ROC.svg'.format(model_name), bbox_inches='tight')

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
    myclf_BNB.read_file(input_file1)
    if shuffle_TF == 'T':
        myclf_BNB.input_shuffle()
    myclf_BNB.split_file()
    myclf_BNB.split_file_data()
    if cv_TF == 'T':
        myclf_BNB.scv_fit_cv()
    else:
        if BNB_diy_TF == 'T':
            myclf_BNB.BNB_fit_diy(BNB_alpha, BNB_class_prior)
        else:
            myclf_BNB.BNB_fit()
    myclf_BNB.save_model()
    myclf_BNB.load_model()
    myclf_BNB.plt_output()
    myclf_BNB.zipDir(source_dir, output_filename)


def load_mode(input_file2):
    myclf_BNB.read_file(input_file2)
    myclf_BNB.split_file()
    myclf_BNB.split_model_pddata()
    myclf_BNB.model_input()
    if Y_lb_TF == 'T':
        myclf_BNB.load_model()
        myclf_BNB.pd_concat()
        myclf_BNB.plt_output()
        myclf_BNB.zipDir(source_dir, output_filename)
    else:
        myclf_BNB.load_model_misslb()
        myclf_BNB.zipDir(source_dir, output_filename)


# argv

source_dir = './clf_BNB'
output_filename = './clf_BNB.zip'

argv = sys.argv
mode_choose = argv[1]  # train nan train.csv
Y_lb_TF = argv[2]
input_model = argv[3]  # load_mode BNB.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]

BNB_diy_TF = argv[11]
if BNB_diy_TF == 'T':
    BNB_alpha = float(argv[12])

    BNB_class_prior = myclf_BNB.split_float_name(argv[13])
    if cv_scoring == 'None':
        cv_scoring = None
    if BNB_class_prior == 'None':
        BNB_class_prior = None


    # python demo-class.py load_mode F BNB.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15

    # python demo-class.py train T NAN train.csv 0.2 T T 5 None

if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('')

