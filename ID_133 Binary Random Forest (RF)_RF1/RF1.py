from sklearn.metrics import classification_report

from sklearn.metrics import confusion_matrix
import pandas as pd

from sklearn.ensemble import RandomForestClassifier
import os,sys
from sklearn.model_selection import GridSearchCV
import zipfile
from sklearn import model_selection
import joblib
from sklearn.utils import shuffle
import matplotlib.pyplot as plt
from sklearn.metrics import roc_curve, auc
from sklearn import tree
import pydotplus
import numpy as np
from imblearn.over_sampling import RandomOverSampler
class myclf_RF:
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
        if not os.path.exists('./clf_RF'):
            os.mkdir('./clf_RF')
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
        if not os.path.exists('./clf_RF'):
            os.mkdir('./clf_RF')
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

    def RF_fit():
        global RF_clf
        RF_clf = RandomForestClassifier(random_state=1,n_estimators=5)
        RF_clf.fit(X_train, y_train)

        #Estimators = RF_clf.estimators_
        #for index, model in enumerate(Estimators):
        #    filename = 'RF_clf' + '.png'
        #    dot_data = tree.export_graphviz(model, out_file=None,
         #                                   feature_names=df.columns[1:],
         #                                   class_names = list(map(str, df.iloc[:, 0].unique())),
         #                                   filled=True, rounded=True,
         #                                   special_characters=True)
         #   graph = pydotplus.graph_from_dot_data(dot_data)
         #   graph.write_png(filename)

            #plt.figure(figsize=(20, 12))  
            #plt.imshow(plt.imread(filename))  
            #plt.savefig('./clf_RF/RF_clf.svg', bbox_inches='tight')  

    def RF_fit_diy(RF_criterion='entropy'
                   ,RF_max_depth=5
                   ,RF_min_samples_split=3
                   ,RF_class_weight='balanced'
                   ,RF_n_estimators=10
                   ):
        global RF_clf
        RF_clf = RandomForestClassifier(criterion=RF_criterion
                                    ,max_depth=RF_max_depth
                                    ,min_samples_split=RF_min_samples_split
                                        ,class_weight=RF_class_weight
                                        ,n_estimators=RF_n_estimators
                                    )
        RF_clf.fit(X_train, y_train)
        print('RF-diy',RF_criterion
                      ,RF_max_depth
              ,RF_class_weight
              ,RF_n_estimators
              ,RF_min_samples_split
                      )
    argv = sys.argv
    cv_times = int(argv[9])    
    def RF_fit_cv(cv_times=cv_times, cv_scoring=None):

        global RF_clf, best_para
        
        parameters = {'criterion': ('gini', 'entropy'),
                      'class_weight':('balanced',None),
                     'n_estimators':[10,30,50],
                     'max_depth':[1,2,3]}
        clf = RandomForestClassifier()
        RF_clf = GridSearchCV(clf, parameters
                                , n_jobs=-1
                                , cv=cv_times
                                , verbose=1
                                , scoring=cv_scoring)
        RF_clf.fit(X_train, y_train)
        best_para = list(RF_clf.best_params_.values())
        print('', RF_clf.best_params_)



   
    def save_model():
        joblib.dump(RF_clf, './clf_RF/RF.pkl')

    def model_input():
        global RF_clf
        model_name = os.path.splitext(input_model)[0][:8]
        RF_clf = input_model

    def load_model(file_name='RF'):
        global fpr_RF, tpr_RF, RF_clf, predictions
        if mode_choose == 'load_mode':
            RF_clf = joblib.load(RF_clf)
        score_RF = RF_clf.predict_proba(X_test)[:,1]
        fpr_RF,tpr_RF,thres_RF = roc_curve(y_test,score_RF,)
        predictions = RF_clf.predict(X_test)
        print("RF")
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
            report.loc['',['priors']] = [best_para[0]]
        report.to_csv('./clf_RF/{}_Report.txt'.format(file_name),index = 1,index_label='',sep = '\t')

    def load_model_misslb(model_name='RF'):
            global RF_clf
            RF_clf = joblib.load(RF_clf)
            predic = RF_clf.predict(X_test)
            predic = pd.DataFrame(predic)
            pd_data = pd.concat([predic, X], axis=1)
            pd_data.rename(columns={0: ''}, inplace=True)
            pd_data.to_csv('./clf_RF/{}_PredictData.txt'.format(model_name), index=0, sep='\t')

    def pd_concat(model_name='RF'):
            predic = pd.DataFrame(predictions)
            pd_col_0 = predic.columns[0]
            pd_data = pd.concat([predic, X_test], axis=1)
            # pd_data.rename(columns={pd_col_0:''},inplace=True)
            pd_data = pd.concat([y_test, pd_data], axis=1)
            pd_data.rename(columns={pd_col_0: '', df_col_0: ''}, inplace=True)
            pd_data.to_csv('./clf_RF/{}_PredictData.txt'.format(model_name), index=0, sep='\t')
    def plt_output(model_name='RF'):
        fig,ax = plt.subplots(figsize=(10,8))
        ax.plot(fpr_RF,tpr_RF,linewidth=2,color="black",
                label='RF (AUC={})'.format(str(round(auc(fpr_RF,tpr_RF),3))))
        ax.plot([0,1],[0,1],linestyle='--',color='grey')
        
        plt.legend(fontsize=12)
        plt.title("Validation Cohort ROC")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        # plt.show()
        f = plt.gcf()  
        if mode_choose == 'train':
            f.savefig('./clf_RF/RF_ROC.svg',bbox_inches='tight')
        else:
            f.savefig('./clf_RF/{}_ROC.svg'.format(model_name),bbox_inches='tight')




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
                print(':', source_dir, '\:', output_filename)
                return output_filename
            else:
                print('file not found ', source_dir)
            return

def train_mode(input_file1):
    myclf_RF.read_file(input_file1)
    if shuffle_TF == 'T':
            myclf_RF.input_shuffle()
    myclf_RF.split_file()
    myclf_RF.oversample_data()
    myclf_RF.split_file_data()
    if cv_TF == 'T':
        myclf_RF.RF_fit_cv()
    else:
        if RF_diy_TF == 'T':
            myclf_RF.RF_fit_diy(RF_criterion
                   ,RF_max_depth
                   ,RF_min_samples_split
                   ,RF_class_weight
                   ,RF_n_estimators)
        else:
            myclf_RF.RF_fit()
    myclf_RF.save_model()
    myclf_RF.load_model()
    myclf_RF.plt_output()
    myclf_RF.RF_fit()
    myclf_RF.zipDir(source_dir, output_filename)

def load_mode(input_file2):
    myclf_RF.read_file(input_file2)
    myclf_RF.split_file()
    myclf_RF.split_model_pddata()
    myclf_RF.model_input()
    if Y_lb_TF == 'T':
        myclf_RF.load_model()
        myclf_RF.pd_concat()
        myclf_RF.plt_output()
        myclf_RF.zipDir(source_dir, output_filename)
    else:
        myclf_RF.load_model_misslb()
        myclf_RF.zipDir(source_dir, output_filename)

    # argv

source_dir = './clf_RF'
output_filename = './clf_RF.zip'

argv = sys.argv
mode_choose = argv[1]  # train nan train.csv
Y_lb_TF = argv[2]
input_model = argv[3]  # load_mode RF.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]

RF_diy_TF = argv[11]
if RF_diy_TF == 'T':
    RF_criterion = argv[12]
    RF_max_depth = int(argv[13])
    RF_min_samples_split = int(argv[14])
    RF_class_weight=argv[15]
    RF_n_estimators=int(argv[16])


    if RF_class_weight == 'None':
        RF_class_weight = None
    if cv_scoring == 'None':
        cv_scoring = None
        # python clf_RF.py load_mode F GBRF.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15

        # python clf_GBRF.py train T NAN train.csv 0.2 T T 5 None 0

        # GBRF_loss,GBRF_learning_rate,GBRF_subsample,GBRF_n_estimators,GBRF_criterion,GBRF_max_depth,GBRF_min_samples_leaf,GBRF_min_samples_split,GBRF_max_features

if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('')