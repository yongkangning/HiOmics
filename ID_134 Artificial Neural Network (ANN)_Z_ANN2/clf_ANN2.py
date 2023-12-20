from sklearn import model_selection
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.metrics import roc_curve, auc ,confusion_matrix
import joblib
import os,sys
from sklearn.model_selection import train_test_split,GridSearchCV
from sklearn.utils import shuffle
import zipfile
from sklearn.neural_network import MLPClassifier

class myclf_ANN:
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
        if not os.path.exists('./clf_ANN'):
            os.mkdir('./clf_ANN')

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
        if not os.path.exists('./clf_ANN'):
            os.mkdir('./clf_ANN')

    def mode_choose():
        global df, df_col_0
        if mode_choose == 'load_mode':
            read_file2(input_file2)
        else:
            read_file1(input_file1)

    
    def input_shuffle():
        global df
        df = shuffle(df,random_state=1)
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
        print('x,y')
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
        print('')
        # print(y_test)
    
    def ANN_fit():
        global ANN_clf
        ANN_clf = MLPClassifier(random_state=1)
        ANN_clf.fit(X_train,y_train)
        print('')
      
    def ANN_fit_diy(ANN_activation='identity'
                    ,ANN_solver='lbfgs'
                    ,ANN_alpha=0.0001
                    ,ANN_max_iter=200
                    ,ANN_hidden_layer_sizes=(100,)):
        global ANN_clf
        ANN_clf = MLPClassifier(
                    activation=ANN_activation
                    ,solver=ANN_solver
                    ,alpha=ANN_alpha
                    ,max_iter=ANN_max_iter
                    ,hidden_layer_sizes=ANN_hidden_layer_sizes
                    )
        ANN_clf.fit(X_train, y_train)
        print('')
       
    def ANN_fit_diy_adam(ANN_activation='identity'
                ,ANN_solver='adam'
                ,ANN_alpha=0.0001
                ,ANN_max_iter=200
                ,ANN_hidden_layer_sizes=(100,)
                ,ANN_learning_rate_init=0.001):
        global ANN_clf
        ANN_clf = MLPClassifier(
                    activation=ANN_activation
                    ,solver=ANN_solver
                    ,alpha=ANN_alpha
                    ,max_iter=ANN_max_iter
                    ,hidden_layer_sizes=ANN_hidden_layer_sizes
                    ,learning_rate_init=ANN_learning_rate_init)
        ANN_clf.fit(X_train, y_train)
        print('ANN-diy-adam')
        
      
    def ANN_fit_diy_sgd(ANN_activation='identity'
                ,ANN_solver='sgd'
                ,ANN_alpha=0.0001
                ,ANN_max_iter=200
                ,ANN_hidden_layer_sizes=(100,)
                ,ANN_learning_rate='constant'
                ,ANN_learning_rate_init=0.001):
        global ANN_clf
        ANN_clf = MLPClassifier(
                    activation=ANN_activation
                    ,solver=ANN_solver
                    ,alpha=ANN_alpha
                    ,max_iter=ANN_max_iter
                    ,hidden_layer_sizes=(ANN_hidden_layer_sizes)
                    ,learning_rate = ANN_learning_rate
                    ,learning_rate_init=ANN_learning_rate_init)
        ANN_clf.fit(X_train, y_train)
        print('ANN-diy-sgd',ANN_activation
                           ,ANN_solver
                           ,ANN_alpha
                           ,ANN_max_iter
                           ,ANN_hidden_layer_sizes
                           ,ANN_learning_rate
                           ,ANN_learning_rate_init)
        
    
    argv = sys.argv
    cv_times = int(argv[9])
    def ANN_fit_cv(cv_times=cv_times,cv_scoring=None):
        global ANN_clf,best_para
        parameters = {
    'hidden_layer_sizes': [(100,), (200,), (300,)],
    'activation': ['identity', 'logistic', 'tanh', 'relu'],
    'solver': ['lbfgs', 'sgd', 'adam'],
    'learning_rate': ['constant', 'invscaling', 'adaptive']
}
        clf = MLPClassifier()
        ANN_clf = GridSearchCV(clf,parameters
                                , n_jobs=-1
                                , cv=cv_times
                                , verbose=1
                                , scoring=cv_scoring)
        ANN_clf.fit(X_train, y_train)
        best_para = list(ANN_clf.best_params_.values())
        print('',ANN_clf.best_params_)

    
    def save_model():
        joblib.dump(ANN_clf, './clf_ANN/ANN.pkl')
        
    def model_input():
        global ANN_clf
        model_name = os.path.splitext(input_model)[0][:8]
        ANN_clf = input_model
        
    def load_model(file_name='ANN'):
        global fpr_ANN,tpr_ANN,ANN_clf,predictions
        if mode_choose == 'load_mode':
            ANN_clf = joblib.load(ANN_clf)
        score_ANN = ANN_clf.predict_proba(X_test)[:,1]
        fpr_ANN,tpr_ANN,thres_ANN = roc_curve(y_test,score_ANN,)
        predictions = ANN_clf.predict(X_test)
        # print("ANN")
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
        report.rename(columns={'precision':'','recall':'','f1-score':'','support':''},inplace=True)
        report.rename(index={'accuracy':'','macro avg':'','micro avg':'','weighted avg':''},inplace=True)
        report.loc['',['','']] = [Sensitivity,Specifcity]
        if mode_choose == 'train' and cv_TF == 'T':
            
            pass
        report.to_csv('./clf_ANN/{}_Report.txt'.format(file_name),index = 1,index_label='',sep = '\t')
        
        print(confusion)
        

    def load_model_misslb(model_name='ANN'):
        global ANN_clf
        ANN_clf = joblib.load(ANN_clf)
        predic = ANN_clf.predict(X_test)
        predic = pd.DataFrame(predic)
        pd_data = pd.concat([predic,X],axis=1)
        pd_data.rename(columns={0:''},inplace=True)
        pd_data.to_csv('./clf_ANN/{}_PredictData.txt'.format(model_name),index = 0,sep='\t')

    def pd_concat(model_name='ANN'):
        predic = pd.DataFrame(predictions)
        pd_col_0 = predic.columns[0]
        pd_data = pd.concat([predic,X_test],axis=1)
        # pd_data.rename(columns={pd_col_0:''},inplace=True)
        pd_data = pd.concat([y_test,pd_data],axis=1)
        pd_data.rename(columns={pd_col_0:'',df_col_0:''},inplace=True)
        pd_data.to_csv('./clf_ANN/{}_PredictData.txt'.format(model_name),index = 0,sep='\t')
    def plt_output(model_name='ANN'):
        fig,ax = plt.subplots(figsize=(10,8))
        ax.plot(fpr_ANN,tpr_ANN,linewidth=2,color="black",
                label='ANN (AUC={})'.format(str(round(auc(fpr_ANN,tpr_ANN),3))))
        ax.plot([0,1],[0,1],linestyle='--',color='grey')
        
        plt.legend(fontsize=12)
        plt.title("Validation Cohort ROC")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        # plt.show()
        f = plt.gcf()  
        if mode_choose == 'train':
            f.savefig('./clf_ANN/ANN_ROC.svg',bbox_inches='tight')
        else:
            f.savefig('./clf_ANN/{}_ROC.svg'.format(model_name),bbox_inches='tight')
        
    def split_model_pddata():
        global X_test,y_test
        X_test = X
        y_test = y
        print(y_test)

    def split_float_name(str_name:str) -> tuple :
        
        list2 = []
        list1 = str_name.split(',')
        for i in list1:
            try:
                i = int(i)
                list2.append(i)
            except:
                pass
        return tuple(list2)

    def zipDir(source_dir, output_filename):
      
        if os.path.exists(source_dir):
           
            # compression  zipfile.ZIP_DEFLATED，zipfile.ZIP_STORED， zipfile.ZIP_LZMA
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

def train_mode(input_file1):
    myclf_ANN.read_file(input_file1)
    if shuffle_TF == 'T':
        myclf_ANN.input_shuffle()
    print('')
    myclf_ANN.split_file()
    myclf_ANN.oversample_data()
    myclf_ANN.split_file_data()
    if cv_TF == 'T':
        # myclf_ANN.ANN_fit_cv()
        pass
        if ANN_diy_TF == 'T':
            if ANN_solver == 'lbfgs':
                myclf_ANN.ANN_fit_diy(ANN_activation
                                            ,ANN_solver
                                            ,ANN_alpha
                                            ,ANN_max_iter
                                            ,ANN_hidden_layer_sizes)
            elif ANN_solver == 'adam':
                myclf_ANN.ANN_fit_diy_adam(ANN_activation
                                            ,ANN_solver
                                            ,ANN_alpha
                                            ,ANN_max_iter
                                            ,ANN_hidden_layer_sizes
                                            ,ANN_learning_rate_init)
            elif ANN_solver == 'sgd':
                myclf_ANN.ANN_fit_diy_sgd(ANN_activation
                                            ,ANN_solver
                                            ,ANN_alpha
                                            ,ANN_max_iter
                                            ,ANN_hidden_layer_sizes
                                            ,ANN_learning_rate
                                            ,ANN_learning_rate_init)
        else:
            myclf_ANN.ANN_fit()
    else:
        print('cv')
        if ANN_diy_TF == 'T':
            if ANN_solver == 'lbfgs':
                print('lbfgs-diy')
                myclf_ANN.ANN_fit_diy(ANN_activation
                                            ,ANN_solver
                                            ,ANN_alpha
                                            ,ANN_max_iter
                                            ,ANN_hidden_layer_sizes)
            elif ANN_solver == 'adam':
                print('adam-diy')
                myclf_ANN.ANN_fit_diy_adam(ANN_activation
                                            ,ANN_solver
                                            ,ANN_alpha
                                            ,ANN_max_iter
                                            ,ANN_hidden_layer_sizes
                                            ,ANN_learning_rate_init)
            elif ANN_solver == 'sgd':
                print('sgd-diy')
                myclf_ANN.ANN_fit_diy_sgd(ANN_activation
                                            ,ANN_solver
                                            ,ANN_alpha
                                            ,ANN_max_iter
                                            ,ANN_hidden_layer_sizes
                                            ,ANN_learning_rate
                                            ,ANN_learning_rate_init)
        else:
            myclf_ANN.ANN_fit()
    myclf_ANN.save_model()
    myclf_ANN.load_model()
    myclf_ANN.plt_output()
    myclf_ANN.zipDir(source_dir, output_filename)
    
def load_mode(input_file2):
    myclf_ANN.read_file(input_file2)
    myclf_ANN.split_file()
    myclf_ANN.split_model_pddata()
    myclf_ANN.model_input()
    if Y_lb_TF == 'T':
        myclf_ANN.load_model()
        myclf_ANN.pd_concat()
        myclf_ANN.plt_output()
        myclf_ANN.zipDir(source_dir, output_filename)
    else:
        myclf_ANN.load_model_misslb()
        myclf_ANN.zipDir(source_dir, output_filename)
    
# argv
source_dir = './clf_ANN'
output_filename = './clf_ANN.zip'

argv = sys.argv
mode_choose = argv[1] # train nan train.csv
Y_lb_TF= argv[2]
input_model = argv[3] # load_mode ANN.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]

ANN_diy_TF = argv[11]
if ANN_diy_TF == 'T':
    ANN_activation = argv[12] 
    ANN_solver = argv[13]   
    ANN_alpha = float(argv[14])    
    ANN_max_iter= int(argv[15] )  
    ANN_hidden_layer_sizes = myclf_ANN.split_float_name(argv[16])   
    ANN_learning_rate = argv[17]  
    ANN_learning_rate_init = float(argv[18]) 
    
    
    #ANN_activation,ANN_solver,ANN_alpha,ANN_max_iter,ANN_hidden_layer_sizes,ANN_learning_rate,ANN_learning_rate_init
    # python clf_SVC.py load_mode F ANN.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15
    # python clf_ANN.py train T NAN train.csv 0.2 T T 5 None 0 



if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('')