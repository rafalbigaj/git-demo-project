import os
import pandas as pd
import sys
import numpy
numpy.set_printoptions(threshold=sys.maxsize)
import pickle
from sklearn.ensemble.gradient_boosting import GradientBoostingClassifier
from sklearn.utils.multiclass import type_of_target
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OrdinalEncoder
from sklearn.compose import ColumnTransformer


def find_project_dir():
    if os.path.isdir("project_git_repo"):
        return os.path.realpath("project_git_repo/cpd35-clustering-demo")
    elif os.path.isdir("assets"):
        return os.getcwd()
    else:
        return os.path.join(os.getcwd(), '../..')


PROJECT_DIR = find_project_dir()
SCRIPT_DIR = os.path.join(PROJECT_DIR, "assets/jupyterlab")
DATA_DIR = os.path.join(PROJECT_DIR, "assets/data_asset")
sys.path.append(os.path.normpath(SCRIPT_DIR))
print(SCRIPT_DIR)
print(DATA_DIR)

data_df = pd.read_csv(os.path.join(DATA_DIR, "credit_risk_training.csv"))

data_df.head()

target_label_name = "Risk"
feature_cols = data_df.drop(columns=[target_label_name])
label = data_df[target_label_name]

# Set model evaluation properties
optimization_metric = 'roc_auc'
random_state = 33
cv_num_folds = 3
holdout_fraction = 0.1

if type_of_target(label.values) in ['multiclass', 'binary']:
    X_train, X_holdout, y_train, y_holdout = train_test_split(feature_cols, label, test_size=holdout_fraction, random_state=random_state, stratify=label.values)
else:
    X_train, X_holdout, y_train, y_holdout = train_test_split(feature_cols, label, test_size=holdout_fraction, random_state=random_state)

# Data preprocessing transformer generation

numeric_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())])
categorical_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ('OrdinalEncoder', OrdinalEncoder(categories='auto', dtype=numpy.float64 ))])

numeric_features = feature_cols.select_dtypes(include=['int64', 'float64']).columns
categorical_features = feature_cols.select_dtypes(include=['object']).columns

preprocessor = ColumnTransformer(
    transformers=[
        ('num', numeric_transformer, numeric_features),
        ('cat', categorical_transformer, categorical_features)])

# Initiate model and create pipeline
model = GradientBoostingClassifier()
gbt_pipeline = Pipeline(steps=[('preprocessor', preprocessor), ('classifier', model)])
model_gbt = gbt_pipeline.fit(X_train, y_train)

with open('model.pickle', 'wb') as mf:
    md = pickle.dumps(model_gbt)
    mf.write(md)
