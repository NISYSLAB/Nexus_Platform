import os
import argparse
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.decomposition import PCA, FactorAnalysis  # I dont like the factor_analyzer pack, sticking to sklearn
from sklearn.model_selection import cross_val_score

## generates mapping_model_update.npz
############## Arguments ############################
base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--subject', type=str, default= None, help="Name of the subject to generate new trial")
working_directory = os.getcwd()
args = parser.parse_args()
subject_name = args.subject
# operate in subject directory
os.chdir(os.path.join(working_directory,'subjects',subject_name))
num_dims = 80
############## Data Loading #########################
## load the constructed model in base directory
model_init = np.load(os.path.join(working_directory,'mapping_model_init.npz'))
data_mean = model_init['data_mean']
linreg_coeff = model_init['linreg_coeff']
components = model_init['components']
comp_s = model_init['comp_s']
err = model_init['err']
linreg_intercept=model_init["linreg_intercept"]
## load history model update
try:
    model_update = np.load('mapping_model_update.npz')
    subject_bias_history = model_update['subject_bias_history']     # size is (num_trials,num_dims)
    trial_idx = subject_bias_history.shape[0]
except:
    subject_bias_history = np.empty((0,num_dims))
    trial_idx = 0
# load the response
output = np.load('trial_{}.npz'.format(trial_idx))
stim1_amp = output['stim1_amp']
stim2_amp = output['stim2_amp']
stimulus = np.array([stim1_amp,stim2_amp])
response = output['output']
############## Mapping model #########################
y = np.dot(stimulus,linreg_coeff.T)+linreg_intercept
residual = response - y
subject_bias_new = residual
subject_bias_history = np.vstack((subject_bias_history,subject_bias_new))
np.savez('mapping_model_update.npz',subject_bias_history=subject_bias_history,subject_bias=np.mean(subject_bias_history,axis=0))