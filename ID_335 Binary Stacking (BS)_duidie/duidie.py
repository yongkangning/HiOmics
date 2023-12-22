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
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import GaussianNB
from sklearn.metrics import mean_squared_error
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import StackingClassifier
from sklearn.svm import SVC
import xgboost as xgb
import numpy as np
from sklearn.metrics import accuracy_score
from sklearn.neural_network import MLPClassifier
import numpy as np
from imblearn.over_sampling import RandomOverSampler

class YourCustomModel:
    pass


class myclf_Stacking:
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
        if not os.path.exists('./clf_Stacking'):
            os.mkdir('./clf_Stacking')

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
        if not os.path.exists('./clf_Stacking'):
            os.mkdir('./clf_Stacking')

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
        global X,y
        if not Y_lb_TF == 'T' and mode_choose == 'load_mode':
            X = df
            y = 'nan'
            print('')
        else:
            y = df.iloc[:,0]
            X = df.iloc[:,1:]
            #rint(y)
        
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
        X_train, X_test, y_train, y_test = model_selection.train_test_split(X, y, test_size=rate, random_state=seed)
        X_test = np.ascontiguousarray(X_test)

    def stacking_classifier_fit():
        global X_train, y_train, stacking_classifier_clf
        
        model1 = make_pipeline(StandardScaler(), RandomForestClassifier(random_state=22,n_estimators=100,max_depth=3,min_samples_split=2))
        model2 = make_pipeline(StandardScaler(), GradientBoostingClassifier(random_state=12,n_estimators=100,learning_rate=0.1,max_depth=3))
        model3 = make_pipeline(StandardScaler(), LogisticRegression(random_state=12,C=1.0,penalty='l2'))
        model4 = make_pipeline(StandardScaler(), DecisionTreeClassifier(random_state=12,criterion='gini'))
        model5 = make_pipeline(StandardScaler(), KNeighborsClassifier(weights='uniform',n_neighbors=5))
        model6 = make_pipeline(StandardScaler(), SVC(kernel='rbf',C=1.0))

        estimators = [
            ('rf', model1),
            ('gb', model2),
            ('lr', model3),
            ('dt', model4),
            ('knn', model5),
            ('svc', model6)
        ]

        meta_model = LogisticRegression()

        
        stacking_classifier_clf = StackingClassifier(
            estimators=estimators,
            final_estimator=meta_model
        )

        
        stacking_classifier_clf.fit(X_train, y_train)
        print('stacking_classifier_fit', estimators, meta_model)
        y_pred = stacking_classifier_clf.predict(X_test)
        
        accuracy = accuracy_score(y_test, y_pred)
        print(f"：{accuracy}")




    def stacking_classifier_ffit():
        global stacking_classifier_clf, meta_models, models

        model1 = make_pipeline(StandardScaler(),
                               RandomForestClassifier(random_state=42, n_estimators=100, max_depth=3,
                                                      min_samples_split=2))
        model2 = make_pipeline(StandardScaler(),
                               MLPClassifier(hidden_layer_sizes=(100, 100), activation='relu', random_state=42,
                                             max_iter=2000))
        model3 = make_pipeline(StandardScaler(), LogisticRegression(random_state=42, C=1.0, penalty='l2'))
        model4 = make_pipeline(StandardScaler(), DecisionTreeClassifier(random_state=42, criterion='gini'))
        model5 = make_pipeline(StandardScaler(), GaussianNB())
        model6 = make_pipeline(StandardScaler(), xgb.XGBClassifier(objective='binary:logistic', random_state=42))

        estimators = [
            ('rf', model1),
            ('mlpc', model2),
            ('lr', model3),
            ('dt', model4),
            ('gnb', model5),
            ('xgb', model6)
        ]

        meta_model = RandomForestClassifier(random_state=42)


        stacking_classifier_clf = StackingClassifier(estimators=estimators,
                                                     final_estimator= meta_model)
        stacking_classifier_clf.fit(X_train, y_train)
        
        y_pred = stacking_classifier_clf.predict(X_test)
        
        accuracy = accuracy_score(y_test, y_pred)
        print(f"：{accuracy}")
        print('stacking_classifier_ffit', estimators, meta_model)

        # cv_diy
    argv = sys.argv
    cv_timess = int(argv[12])    
    def stacking_classifier_fit_diycv(cv_timess=cv_timess, cv_scoringg=None):
        global stacking_classifier_clf, best_para, X_train, y_train

        
        model1 = make_pipeline(StandardScaler(),
                               RandomForestClassifier(random_state=42, n_estimators=100, max_depth=3,
                                                      min_samples_split=2))
        model2 = make_pipeline(StandardScaler(),
                               MLPClassifier(hidden_layer_sizes=(100, 100), activation='relu', random_state=42,
                                             max_iter=2000))
        model3 = make_pipeline(StandardScaler(), LogisticRegression(random_state=42, C=1.0, penalty='l2'))
        model4 = make_pipeline(StandardScaler(), DecisionTreeClassifier(random_state=42, criterion='gini'))
        model5 = make_pipeline(StandardScaler(), GaussianNB())
        model6 = make_pipeline(StandardScaler(), xgb.XGBClassifier(objective='binary:logistic', random_state=42))

        estimators = [
            ('rf', model1),
            ('mlpc', model2),
            ('lr', model3),
            ('dt', model4),
            ('gnb', model5),
            ('xgb', model6)
        ]

        meta_model = RandomForestClassifier(random_state=42)

        
        clf = StackingClassifier(
            estimators=estimators,
            final_estimator=meta_model,
            passthrough=False
        )

        
        parameters = {
            'final_estimator__n_estimators': [25,50, 100, 200],
            'final_estimator__max_depth': [3,4, 5,6, 7]
        }

        
        stacking_classifier_clf = GridSearchCV(
            clf,
            param_grid=parameters,
            n_jobs=-1,
            cv=cv_timess,
            verbose=1,
            scoring=cv_scoringg,
            error_score='raise'
        )

        
        stacking_classifier_clf.fit(X_train, y_train)

        
        best_para = list(stacking_classifier_clf.best_params_.values())
        print(stacking_classifier_clf.best_params_)
    argv = sys.argv
    cv_times = int(argv[9])    
    def stacking_classifier_fit_cv( cv_times=cv_times, cv_scoring=None):
        global stacking_classifier_clf, best_para, X_train, y_train

        
        model1 = make_pipeline(StandardScaler(), RandomForestClassifier(random_state=42,n_estimators=100,max_depth=3,min_samples_split=2))
        model2 = make_pipeline(StandardScaler(), GradientBoostingClassifier(random_state=42,n_estimators=100,learning_rate=0.1,max_depth=3))
        model3 = make_pipeline(StandardScaler(), LogisticRegression(random_state=42,C=1.0,penalty='l2'))
        model4 = make_pipeline(StandardScaler(), DecisionTreeClassifier(random_state=42,criterion='gini'))
        model5 = make_pipeline(StandardScaler(), KNeighborsClassifier(weights='uniform',n_neighbors=5))
        model6 = make_pipeline(StandardScaler(), SVC(kernel='rbf',C=1.0))

        
        estimators = [
            ('rf', model1),
            ('gb', model2),
            ('lr', model3),
            ('dt', model4),
            ('knn', model5),
            ('svc', model6)
        ]

        
        meta_model1 = LogisticRegression()

       
        clf = StackingClassifier(
            estimators=estimators,
            final_estimator=meta_model1,
            passthrough=False
        )

        
        parameters = {
            'final_estimator__C': np.arange(0.001, 61),
            'final_estimator__solver': ['liblinear', 'lbfgs']
        }

        
        stacking_classifier_clf = GridSearchCV(
            clf,
            param_grid=parameters,
            n_jobs=-1,
            cv=cv_times,
            verbose=1,
            scoring=cv_scoring,
            error_score='raise'
        )

        
        stacking_classifier_clf.fit(X_train, y_train)

        
        best_para = list(stacking_classifier_clf.best_params_.values())
        print(stacking_classifier_clf.best_params_)

    def save_model():
        joblib.dump(stacking_classifier_clf, './clf_Stacking/stacking_classifier.pkl')

    def model_input():
        global stacking_classifier_clf
        model_name = os.path.splitext(input_model)[0][:8]
        stacking_classifier_clf = input_model

    def load_model(file_name='Stacking'):
        global fpr_Stacking, tpr_Stacking, stacking_classifier_clf, predictions
        if mode_choose == 'load_mode':
            stacking_classifier_clf = joblib.load(stacking_classifier_clf)
        score_Stacking = stacking_classifier_clf.predict_proba(X_test)[:, 1]
        fpr_Stacking, tpr_Stacking, thres_Stacking = roc_curve(y_test, score_Stacking, )
        predictions = stacking_classifier_clf.predict(X_test)
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
        if mode_choose == 'train' and cv_TF == 'T':
            report.loc['', ['kernel']] = [best_para[0]]
        report.to_csv('./clf_Stacking/{}_Report.txt'.format(file_name), index=1, index_label='', sep='\t')

    def load_model_misslb(model_name='Stacking'):
        global stacking_classifier_clf
        stacking_classifier_clf = joblib.load(stacking_classifier_clf)
        predic = stacking_classifier_clf.predict(X_test)
        predic = pd.DataFrame(predic)
        pd_data = pd.concat([predic, X], axis=1)
        pd_data.rename(columns={0: ''}, inplace=True)
        pd_data.to_csv('./clf_Stacking/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def pd_concat(model_name='Stacking'):
        predic = pd.DataFrame(predictions)
        pd_col_0 = predic.columns[0]
        pd_data = pd.concat([predic, X_test], axis=1)
        # pd_data.rename(columns={pd_col_0:''},inplace=True)
        pd_data = pd.concat([y_test, pd_data], axis=1)
        pd_data.rename(columns={pd_col_0: '', df_col_0: ''}, inplace=True)
        pd_data.to_csv('./clf_Stacking/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def plt_output(model_name='Stacking'):
        fig, ax = plt.subplots(figsize=(10, 8))
        ax.plot(fpr_Stacking, tpr_Stacking, linewidth=2, color="black",
                label='Stacking (AUC={})'.format(str(round(auc(fpr_Stacking, tpr_Stacking), 3))))
        ax.plot([0, 1], [0, 1], linestyle='--', color='grey')
        
        plt.legend(fontsize=12)
        plt.title("Validation Cohort ROC")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        # plt.show()
        f = plt.gcf()  
        if mode_choose == 'train':
            f.savefig('./clf_Stacking/Stacking_ROC.svg', bbox_inches='tight')
        else:
            f.savefig('./clf_Stacking/{}_ROC.svg'.format(model_name), bbox_inches='tight')

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
    myclf_Stacking.read_file(input_file1)
    if shuffle_TF == 'T':
        myclf_Stacking.input_shuffle()
    myclf_Stacking.split_file()
    myclf_Stacking.oversample_data()
    myclf_Stacking.split_file_data()
    
    output_file = open('output.txt', 'w')
    
    sys.stdout = output_file
    if cv_TF == 'T':
        myclf_Stacking.stacking_classifier_fit_cv()
    elif Stacking_diy_TF == 'T':
        myclf_Stacking.stacking_classifier_fit_diycv()
    elif Stacking_diy_TF == 'F':
        myclf_Stacking.stacking_classifier_ffit()
    elif cv_TF == 'F':
        myclf_Stacking.stacking_classifier_fit()
    else:
         pass

        
    sys.stdout = sys.__stdout__
    output_file.close()
    myclf_Stacking.save_model()
    myclf_Stacking.load_model()
    myclf_Stacking.plt_output()
    myclf_Stacking.zipDir(source_dir, output_filename)


def load_mode(input_file2):
    myclf_Stacking.read_file(input_file2)
    myclf_Stacking.split_file()
    myclf_Stacking.split_model_pddata()
    myclf_Stacking.model_input()
    if Y_lb_TF == 'T':
        myclf_Stacking.load_model()
        myclf_Stacking.pd_concat()
        myclf_Stacking.plt_output()
        myclf_Stacking.zipDir(source_dir, output_filename)
    else:
        myclf_Stacking.load_model_misslb()
        myclf_Stacking.zipDir(source_dir, output_filename)


# argv

source_dir = './clf_Stacking'
output_filename = './clf_Stacking.zip'

argv = sys.argv
mode_choose = argv[1]  # train nan train.csv
Y_lb_TF = argv[2]
input_model = argv[3]  # load_mode Stacking.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
if cv_TF =='T':
   cv_times = int(argv[9])
   cv_scoring = argv[10]
else:
    pass

Stacking_diy_TF = argv[11]
if Stacking_diy_TF=='T':
   cv_timess = int(argv[12])
   cv_scoringg = argv[13]
else:
   pass






    # python clf_SVC.py load_mode F LR.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15

    # python clf_SVC.py train T NAN train.csv 0.2 T T 5 None 0

if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('')