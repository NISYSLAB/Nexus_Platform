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
parser.add_argument('--model', type=str, default= None, help="Model to use for mapping")
working_directory = os.getcwd()
args = parser.parse_args()
grid_size = int(args.gridsize)
subject_name = args.subject
model = args.model
# operate in subject directory
subject_dir = os.path.join(working_directory,'subjects',subject_name)
num_groups = 2
num_dims = 80
# dataset_size = num_groups * dataset_size
stim_size = grid_size * grid_size
amp = 0    # maximum amplitude of stimuli, in log10 scale
min_amp = -2
stim1 = np.logspace(min_amp,amp,grid_size)
stim2 = np.logspace(min_amp,amp,grid_size)
stimuli = np.stack(np.meshgrid(stim1,stim2),axis=2)

############## Mapping model #########################
if model == 'resample':
    from algorithms.mapping_model.resample import resample as mapping_model
elif model == 'linearPCA':
    from algorithms.mapping_model.linear_pca_gaussian import LinearPCA as mapping_model
c = mapping_model(model)
c.MC_sampling(stimuli,working_directory,subject_dir)