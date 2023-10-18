import os
import argparse
import numpy as np
import time
from sklearn.linear_model import LinearRegression
from sklearn.decomposition import PCA, FactorAnalysis  # I dont like the factor_analyzer pack, sticking to sklearn
from sklearn.model_selection import cross_val_score
# from joblib import dump, load

## generates mapping_model_init.npz
## no adaptation to new data as of now, will be added
############## Arguments ############################

base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--gridsize', type=str, default= None, help="Size of stimuli grid x (stimuli is x by x)")
parser.add_argument('--subject', type=str, default= None, help="Name of the subject to generate new trial")
working_directory = os.getcwd()
args = parser.parse_args()
grid_size = int(args.gridsize)
subject_name = args.subject
# operate in subject directory
os.chdir(os.path.join(working_directory,'subjects',subject_name))
num_groups = 2
num_dims = 80
ran_seed = ((os.getpid() * int(time.time())) % 123456789)       # seed for randoms
# dataset_size = num_groups * dataset_size
stim_size = grid_size * grid_size
amp = 0    # maximum amplitude of stimuli, in log10 scale
min_amp = -2
rng = np.random.default_rng(ran_seed)
num_MCsamples = 100

############## Data Loading #########################
## load the constructed model in base directory
model_init = np.load(os.path.join(working_directory,'mapping_model_init.npz'))
data_mean = model_init['data_mean']
linreg_coeff = model_init['linreg_coeff']
components = model_init['components']
comp_s = model_init['comp_s']
err = model_init['err']
linreg_intercept=model_init["linreg_intercept"]
## load the model updates (bias for now)
model_update = np.load('mapping_model_update.npz')
subject_bias = model_update['subject_bias']     # size is (num_dims,)
############## Mapping model #########################

## reconstruction of bias: need to maintain a moving average of bias of data collected so far, subtracting the stimuli effect
## reconstruction of linreg: multiply lin reg by stimuli
## reconstruction of error: draw gaussian sample in transformed space with std = comp_s, then multiply with components, then add individual gaussian error to each dim with err as std
out_data = np.zeros((stim_size,num_dims))
## overall mean, although it is the same to include it in subject bias for now
out_data = out_data + data_mean[0,:,:]  # to match dimensions
## Linear regression
# stimuli: gridsize by gridsize by 2
stim1 = np.logspace(min_amp,amp,grid_size)
stim2 = np.logspace(min_amp,amp,grid_size)
stimuli = np.stack(np.meshgrid(stim1,stim2),axis=2)
# reconstructing linear model
X = stimuli.reshape(-1,2)
y = np.dot(X,linreg_coeff.T)+linreg_intercept
## per subject bias
y = y + subject_bias

############ Parts with randomness (MC sampling)#############
## output: stim_size by num_dimensions by num_MCsamples
## output_stim: stim_size by 2
output = np.zeros((stim_size,num_dims,num_MCsamples))
output = output + y[:,:,np.newaxis]
output_stim = X
for i in range(stim_size):
    for j in range(num_MCsamples):
        ## PCA component sampling
        comp_sample = rng.normal(scale=comp_s)
        # yes sklearn components do have unit length
        comp_reconstructed = np.dot(comp_sample,components)     # since when np doesnt bug out with 1d dot 2d array?
        ## individual noise: iid Gaussian
        individual_err = rng.normal(scale=err,size=num_dims)
        output[i,:,j] = output[i,:,j] + comp_reconstructed + individual_err
np.savez('mapping_model_inference',output=output,output_stim=output_stim)