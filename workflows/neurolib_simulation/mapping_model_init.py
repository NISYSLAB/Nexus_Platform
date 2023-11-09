import os
import argparse
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.decomposition import PCA, FactorAnalysis  # I dont like the factor_analyzer pack, sticking to sklearn
from sklearn.model_selection import cross_val_score
from joblib import dump, load

## generates mapping_model_init.npz

############## Arguments ############################

base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--size', type=str, default= None, help="Size of the dataset for each group")
parser.add_argument('--gridsize', type=str, default= None, help="Size of stimuli grid x (stimuli is x by x)")
parser.add_argument('--model', type=str, default= None, help="Model to use for mapping")
working_directory = os.getcwd()

args = parser.parse_args()
dataset_size = int(args.size)
grid_size = int(args.gridsize)
model = args.model
num_groups = 2
num_dims = 80
ran_seed = 0        # seed for randoms
dataset_size = num_groups * dataset_size
stim_size = grid_size * grid_size

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

############## Mapping model #########################
if model == 'resample':
    from algorithms.mapping_model.resample import resample as mapping_model
elif model == 'linearPCA':
    from algorithms.mapping_model.linear_pca_gaussian import LinearPCA as mapping_model
c = mapping_model(model)
c.train(out_label,out_data,working_directory)