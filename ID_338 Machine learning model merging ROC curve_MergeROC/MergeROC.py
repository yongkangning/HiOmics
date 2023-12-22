import pandas as pd
import joblib
import matplotlib.pyplot as plt
import os, sys
from imblearn.over_sampling import RandomOverSampler
from sklearn.model_selection import train_test_split
import sklearn.metrics as metrics

argv = sys.argv
input_file1 = argv[1]

def read_data(input_file1):
    global df, df_col_0, X_train, X_test, y_train, y_test
    file_name = os.path.splitext(input_file1)[0][:8]
    if os.path.splitext(input_file1)[1] == '.txt':
        df = pd.read_table(input_file1)
    elif os.path.splitext(input_file1)[1] == '.csv':
        df = pd.read_csv(input_file1)
    elif os.path.splitext(input_file1)[1] == '.xlsx' or os.path.splitext(input_file1)[1] == '.xls':
        df = pd.read_excel(input_file1)
    df_col_0 = df.columns[0]
    y = df.iloc[:, 0]
    X = df.iloc[:, 1:]

    ros = RandomOverSampler()
    X_resampled, y_resampled = ros.fit_resample(X, y)
    X_train, X_test, y_train, y_test = train_test_split(X_resampled, y_resampled, test_size=0.2, random_state=12)
model_folder_path = argv[2]
def load_models_from_folder(model_folder_path):
    model_paths = []
    for filename in os.listdir(model_folder_path):
        if filename.endswith(".pkl"):
            model_path = os.path.join(model_folder_path, filename)
            model_paths.append(model_path)
    return model_paths

def plot_roc_curve(model_paths, model_folder_path):
    fig = plt.figure(figsize=(8, 6))
    for i, model_path in enumerate(model_paths):
        model = joblib.load(model_path)
        y_scores = model.predict_proba(X_test)[:, 1]
        fpr, tpr, thresholds = metrics.roc_curve(y_test, y_scores)
        roc_auc = metrics.auc(fpr, tpr)
        model_name = os.path.basename(model_path).replace('.pkl', '')
        plt.plot(fpr, tpr, label=f"{model_name} (AUC = {roc_auc:.2f})")

    plt.plot([0, 1], [0, 1], linestyle='--', color='r')
    plt.xlim([0, 1])
    plt.ylim([0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('ROC Curve')
    plt.legend(loc='lower right')
    plt.rcParams["font.family"] = "Times New Roman"
    fig.savefig('./Merge_ROC_curve.svg', format='svg')

    plt.close(fig)


read_data(input_file1)

model_paths = load_models_from_folder(model_folder_path)
plot_roc_curve(model_paths, model_folder_path)





