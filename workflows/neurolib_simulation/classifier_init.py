import os
import argparse
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Flatten
from tensorflow.keras import initializers
from tensorflow.keras.regularizers import l2
from tensorflow.keras import optimizers
from tensorflow.keras import backend as K
from tensorflow.keras.wrappers.scikit_learn import KerasClassifier
# from keras.models import Sequential
# from keras.layers import Dense, Dropout, Flatten
# from keras import initializers
# from keras.regularizers import l2
# from keras import optimizers
# from keras import backend as K
# from keras.wrappers.scikit_learn import KerasClassifier

import numpy as np
from sklearn.model_selection import GridSearchCV
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from training_cv_split import CustomGroupStratifiedKFold
import time
# https://github.com/tensorflow/tensorflow/issues/34201#issuecomment-690137283
# to make things work.....
from tensorflow.python.keras.backend import eager_learning_phase_scope  

## generates classifier_init.npy
############## Arguments ############################

base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--size', type=str, default= None, help="Size of the dataset for each group")
parser.add_argument('--gridsize', type=str, default= None, help="Size of stimuli grid x (stimuli is x by x)")
working_directory = os.getcwd()

args = parser.parse_args()
dataset_size = int(args.size)
grid_size = int(args.gridsize)
num_groups = 2
num_dims = 80
ran_seed = 0        # seed for randoms
if dataset_size <5:
    n_splits = dataset_size
else:
    n_splits = 5
dataset_size = num_groups * dataset_size
stim_size = grid_size * grid_size
num_batch = 1       # batch size

############## Data Loading #########################
## output data matrix: subject by stimuli by output dimensions
## output label matrix: subject by stimuli by 3 (label, stim1, stim2)
out_data = np.empty((dataset_size,stim_size,num_dims))
out_label = np.empty((dataset_size,stim_size,3))
for s in range(dataset_size):
    subject_name = 'subject_train_{}'.format(s)
    subject_path = os.path.join(working_directory,'subjects',subject_name)
    os.chdir(subject_path)
    with np.load('subject_info.npz') as data:
        ## we read the label of the subject, should not be needed usually as most models should combine both groups
        label = data['label']
        out_label[s,:,0] = label
    for t in range(stim_size):
        with np.load('trial_{}.npz'.format(t)) as data:
            out_data[s,t,:] = data['output']
            out_label[s,t,1] = data['stim1_amp']
            out_label[s,t,2] = data['stim2_amp']
os.chdir(working_directory)
# X = out_data.reshape(-1,num_dims)
# print(X.shape)
# y = out_label.reshape(-1,3)
# print(y.shape)
XX = np.concatenate((out_data,out_label[:,:,1:]),axis=-1)
cvgroups = np.array([np.ones((stim_size))*i for i in range(dataset_size)])
yy = out_label[:,:,0]
print(XX.shape)
print(cvgroups.shape)
print(yy.shape)
sanity_check = XX[0,8,:]
XX = XX.reshape((-1,num_dims+2))
if not np.isclose(sanity_check,XX[8,:]).all():
    print('Sanity check failed')
    exit()
cvgroups = cvgroups.reshape(-1)
# print(cvgroups)
y = yy.reshape(-1)
# X = np.hstack((X,y))    # just a dumb check to see if model is smart enough if we put label into input - the answer is yes
# X = np.hstack((X,stim))  # expand X to contain stimuli
# y = y[:,0]

## Standard rescaling
scaler = StandardScaler()
scaler.fit(XX)
scaler_mean = scaler.mean_
scaler_var = scaler.var_
scaler_n_fea_in = scaler.n_features_in_
scaler_samp_seen = scaler.n_samples_seen_
X = scaler.transform(XX)
# save rescaling parameters
np.savez('classifier_init_scaler',scaler_mean=scaler_mean,scaler_var=scaler_var,scaler_n_fea_in=scaler_n_fea_in,scaler_samp_seen=scaler_samp_seen)
## data loading testing
# newscaler = StandardScaler()
# newscaler.mean_ = scaler_mean
# newscaler.var_ = scaler_var
# newscaler.n_features_in_ = scaler_n_fea_in
# newscaler.n_samples_seen_ = scaler_samp_seen
############## Classifier model #########################
## building simple mlp model with dropout
def build_model(learning_rate,unit_l1,unit_l2,unit_l3):
    model = Sequential()
    init_scheme = initializers.HeNormal(time.time_ns())
    init_scheme_input = initializers.HeUniform(time.time_ns())
    optimize_scheme = optimizers.Adam(learning_rate=learning_rate)
    model.add(Dense(unit_l1, input_dim=X.shape[1],activation='relu',kernel_initializer=init_scheme_input,bias_initializer="zeros"))
    model.add(Dropout(0.25))
    model.add(Dense(unit_l2,activation='relu',kernel_initializer=init_scheme,bias_initializer="zeros"))
    model.add(Dropout(0.25))
    model.add(Dense(unit_l3,activation='relu',kernel_initializer=init_scheme,bias_initializer="zeros"))
    model.add(Dropout(0.125))
    model.add(Dense(1,activation='sigmoid',kernel_initializer=init_scheme,bias_initializer="zeros"))
    model.compile(loss='binary_crossentropy', optimizer=optimize_scheme, metrics=['accuracy'])
    return model

params = {
    'nb_epoch':[300 * i + 300 for i in range(1)],
    'batch_size':[1,2,4,8,16,32],
    'learning_rate':[0.01,0.001,0.0001],
    'unit_l1':[64,128,256],
    'unit_l2':[64,32],
    'unit_l3':[32,16]
}
## you idiot you are running on gpu stop this fucking nonsense
# try:
#     cpus_per_task = len(os.sched_getaffinity(0))  # assigned in slurm script
# except:
#     cpus_per_task = min(os.cpu_count(),5)  # for test running on local pc
model = KerasClassifier(build_fn=build_model)
gs = GridSearchCV(estimator=model,param_grid=params,
                  cv=CustomGroupStratifiedKFold(n_splits=n_splits,n_meta=num_groups), 
                  scoring='accuracy',verbose=1)
gs = gs.fit(X,y,groups=cvgroups)
print(gs.best_params_)
print(gs.best_score_)
# fit on the entire set as initial classifier
model = build_model(gs.best_params_['learning_rate'],gs.best_params_['unit_l1'],gs.best_params_['unit_l2'],gs.best_params_['unit_l3'])
history = model.fit(X, y, epochs=gs.best_params_['nb_epoch'], verbose=1)
model.save('classifier_init.keras')

## sanity check linear classifier
## yes I need sklearn newer than jun 2023... sigh, workaround
# clf= LogisticRegressionCV(cv=CustomGroupStratifiedKFold(n_splits=n_splits,n_meta=num_groups),random_state=ran_seed,max_iter=1000).fit(X,y,groups=cvgroups)
# print('Logistic regression score: {}'.format(clf.score(X,y)))
# print(clf.predict(X))
# print(y)
clf = GridSearchCV(estimator=LogisticRegression(),param_grid={'max_iter':[1000,]},cv=CustomGroupStratifiedKFold(n_splits=n_splits,n_meta=num_groups), scoring='accuracy',verbose=1)
clf = clf.fit(X,y,groups=cvgroups)
print('Logistic regression score: {}'.format(clf.best_score_))
print(clf.score(X,y))
# print(clf.cv_results_)
