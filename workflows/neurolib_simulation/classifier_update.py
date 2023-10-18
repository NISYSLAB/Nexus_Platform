import os
import argparse
import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras import backend as K
from sklearn.preprocessing import StandardScaler
# from keras.models import load_model
# from keras import backend as K
from tensorflow.python.keras.backend import eager_learning_phase_scope  

## generates classifier_update.npz
############## Arguments ############################
base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--subject', type=str, default= None, help="Name of the subject to generate new trial")
working_directory = os.getcwd()
args = parser.parse_args()
subject_name = args.subject
# operate in subject directory
os.chdir(os.path.join(working_directory,'subjects',subject_name))
####################################################################################
# try to load existing history, if not, create a new one
try:
    model_update = np.load('classifier_update.npz')
    stim_history = model_update['stim_history']
    classifier_results = model_update['classifier_results']
    trial_idx = stim_history.shape[0]
except:
    stim_history = np.empty((0,2))
    classifier_results = np.empty((0,1))
    trial_idx = 0

## load the rescaling
scaler = np.load(os.path.join(working_directory,'classifier_init_scaler.npz'))
scaler_mean = scaler['scaler_mean']
scaler_var = scaler['scaler_var']
scaler_n_fea_in = scaler['scaler_n_fea_in']
scaler_samp_seen = scaler['scaler_samp_seen']
newscaler = StandardScaler()
newscaler.mean_ = scaler_mean
newscaler.var_ = scaler_var
newscaler.scale_ = np.sqrt(scaler_var)
newscaler.n_features_in_ = scaler_n_fea_in
newscaler.n_samples_seen_ = scaler_samp_seen
# load the constructed model in base directory
model = load_model(os.path.join(working_directory,'classifier_init.keras'))
# load the response
output = np.load('trial_{}.npz'.format(trial_idx))
stim1_amp = output['stim1_amp'].reshape(1,-1)
stim2_amp = output['stim2_amp'].reshape(1,-1)
response = output['output'].reshape(1,-1)
# print(stim1_amp.shape)
# print(stim2_amp.shape)
# print(response.shape)
X = np.hstack((response,stim1_amp,stim2_amp))
X = X.reshape(1,-1)
X = newscaler.transform(X)
# do we need the uncertainty for the labeling here? probably not
# f = K.function([model.layers[0].input],
#                            [model.layers[-1].output])
# with eager_learning_phase_scope(value=1):
#     y = f([X])[0]
new_label = model.predict(X)
# print(new_label.shape)
## save the history
stim = np.hstack((stim1_amp,stim2_amp))
# print(stim.shape)
stim_history = np.vstack((stim_history,stim))
classifier_results = np.vstack((classifier_results,new_label))
np.savez('classifier_update.npz',stim_history=stim_history,classifier_results=classifier_results)