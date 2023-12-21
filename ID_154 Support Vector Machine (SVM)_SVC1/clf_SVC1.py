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
from sklearn.utils import shuffle
import zipfile

class myclf_svc:
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
        if not os.path.exists('./clf_SVC'):
            os.mkdir('./clf_SVC')
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
        if not os.path.exists('./clf_SVC'):
            os.mkdir('./clf_SVC')

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
        global X,y
        if not Y_lb_TF == 'T' and mode_choose == 'load_mode':
            X = df
            y = 'nan'
            print('')
        else:
            y = df.iloc[:,0]
            X = df.iloc[:,1:]
            print(y)
    
    def split_file_data():
        global X_test,y_test,X_train,y_train
        # define seed for reproducibility
        seed = 12
        # split data into training and testing datasets
        X_train, X_test, y_train, y_test = model_selection.train_test_split(X
                                                                            , y
                                                                            , test_size=rate
                                                                            , random_state=seed)
    def svc_fit():
        global SVC_clf
        SVC_clf = SVC(probability=True)
        SVC_clf.fit(X_train, y_train)
        
    def svc_fit_diy(svc_c=1
                    ,svc_kernel='linear'
                    ,svc_tol=0.0001
                    ,svc_max_iter=1000
                    ,svc_dfs='ovo'
                    ):
        global SVC_clf
        SVC_clf = SVC(probability=True
                    ,C=svc_c
                    , kernel=svc_kernel
                    , tol=svc_tol
                    ,max_iter=svc_max_iter
                    ,decision_function_shape=svc_dfs)
        SVC_clf.fit(X_train, y_train)
        print('svc-diy',svc_c,svc_kernel,svc_tol,svc_max_iter,svc_dfs)
    # cv_diy 
    argv = sys.argv
    cv_times = int(argv[9])
    def scv_fit_cv(cv_times=cv_times,cv_scoring=None):
        global SVC_clf
        
        parameters = {"kernel": ["rbf","linear","poly","sigmoid"]}
        clf = SVC(probability=True)
        SVC_clf = GridSearchCV(clf,parameters
                                , n_jobs=-1
                                , cv=cv_times
                                , verbose=1
                                , scoring=cv_scoring)
        SVC_clf.fit(X_train, y_train)
        print(SVC_clf.best_params_)
        
    def save_model():
        joblib.dump(SVC_clf, './clf_SVC/SVC.pkl')
        
    def model_input():
        global SVC_clf
        model_name = os.path.splitext(input_model)[0][:8]
        SVC_clf = input_model
        
    def load_model(file_name='SVC'):
        global fpr_SVC,tpr_SVC,SVC_clf,predictions
        if mode_choose == 'load_mode':
            SVC_clf = joblib.load(SVC_clf)
        score_SVC = SVC_clf.predict_proba(X_test)[:,1]
        print(y_test)
        fpr_SVC,tpr_SVC,thres_SVC = roc_curve(y_test,score_SVC,)
        predictions = SVC_clf.predict(X_test)
        # print("SVC")
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
        report.to_csv('./clf_SVC/{}_Report.txt'.format(file_name),index = 1,index_label='',sep = '\t')

        import matplotlib.pyplot as plt
        from sklearn.manifold import TSNE
        
        X_embedded = TSNE(n_components=2, random_state=42).fit_transform(X_test)

        
        y_pred = SVC_clf.predict(X_test)
    def plt_output(model_name='SVC'):
        
        plt.figure(figsize=(10, 8))
        scatter = plt.scatter(X_embedded[:, 0], X_embedded[:, 1], c=y_pred)
        legend = plt.legend(*scatter.legend_elements(), loc="upper right", title="Classes")
        plt.title('Decision Boundary')
        plt.xlabel("x")
        plt.ylabel("y")
        plt.show()
        plt.savefig('./clf_SVC/{}_Figure.png'.format(model_name),bbox_inches='tight')


    
    def load_model_misslb(model_name='SVC'):
        global SVC_clf
        SVC_clf = joblib.load(SVC_clf)
        predic = SVC_clf.predict(X_test)
        predic = pd.DataFrame(predic)
        pd_data = pd.concat([predic,X],axis=1)
        pd_data.rename(columns={0:''},inplace=True)
        pd_data.to_csv('./clf_SVC/{}_PredictData.txt'.format(model_name),index = 0,sep='\t')

      
    def pd_concat(model_name='SVC'):
        predic = pd.DataFrame(predictions)
        pd_col_0 = predic.columns[0]
        pd_data = pd.concat([predic,X_test],axis=1)
        # pd_data.rename(columns={pd_col_0:''},inplace=True)
        pd_data = pd.concat([y_test,pd_data],axis=1)
        pd_data.rename(columns={pd_col_0:'',df_col_0:''},inplace=True)
        pd_data.to_csv('./clf_SVC/{}_PredictData.txt'.format(model_name),index = 0,sep='\t')
    def plt_output(model_name='SVC'):
        fig,ax = plt.subplots(figsize=(10,8))
        ax.plot(fpr_SVC,tpr_SVC,linewidth=2,color="black",
                label='SVC (AUC={})'.format(str(round(auc(fpr_SVC,tpr_SVC),3))))
        ax.plot([0,1],[0,1],linestyle='--',color='grey')
        
        plt.legend(fontsize=12)
        plt.title("Validation Cohort ROC")
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        # plt.show()
        f = plt.gcf()  
        if mode_choose == 'train':
            f.savefig('./clf_SVC/SVC_ROC.svg',bbox_inches='tight')
        else:
            f.savefig('./clf_SVC/{}_ROC.svg'.format(model_name),bbox_inches='tight')
        
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
    myclf_svc.read_file(input_file1)
    if shuffle_TF == 'T':
        myclf_svc.input_shuffle()
    myclf_svc.split_file()
    myclf_svc.split_file_data()
    if cv_TF == 'T':
        myclf_svc.scv_fit_cv()
    else:
        if svc_diy_TF == 'T':
            myclf_svc.svc_fit_diy(svc_c,svc_kernel,svc_tol,svc_max_iter,svc_dfs)
        else:
            myclf_svc.svc_fit()
    myclf_svc.save_model()
    myclf_svc.load_model()
    myclf_svc.plt_output()
    myclf_svc.zipDir(source_dir, output_filename)
    
    
def load_mode(input_file2):
    myclf_svc.read_file(input_file2)
    myclf_svc.split_file()
    myclf_svc.split_model_pddata()
    myclf_svc.model_input()
    if Y_lb_TF == 'T':
        myclf_svc.load_model()
        myclf_svc.pd_concat()
        myclf_svc.plt_output()
        myclf_svc.zipDir(source_dir, output_filename)
    else:
        myclf_svc.load_model_misslb()
        myclf_svc.zipDir(source_dir, output_filename)
    

# argv

source_dir = './clf_SVC'
output_filename = './clf_SVC.zip'

argv = sys.argv
mode_choose = argv[1] # train nan train.csv
Y_lb_TF= argv[2]
input_model = argv[3] # load_mode svc.pkl pd.csv
input_file1 = argv[4]
input_file2 = argv[5]
rate = float(argv[6])

shuffle_TF = argv[7]

cv_TF = argv[8]
cv_times = int(argv[9])
cv_scoring = argv[10]

svc_diy_TF = argv[11]
if svc_diy_TF == 'T':
    svc_c = int(argv[12])
    svc_kernel = argv[13]
    svc_tol = float(argv[14])
    svc_max_iter = int(argv[15])
    svc_dfs = argv[16]
    
    # python demo-class.py load_mode F SVC.pkl train.csv 0.2 T 1 2 3 10 11 12 13 14 15
    
    # python demo-class.py train T NAN train.csv 0.2 T T 5 None



if __name__ == '__main__':
    if mode_choose == 'train':
        train_mode(input_file1)
    elif mode_choose == 'load_mode':
        load_mode(input_file2)
        print('')