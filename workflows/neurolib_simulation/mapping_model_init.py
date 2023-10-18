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
working_directory = os.getcwd()

args = parser.parse_args()
dataset_size = int(args.size)
grid_size = int(args.gridsize)
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
## remove the mean across subject and trials first
data_mean = np.mean(out_data,(0,1),keepdims=True)
out_data = out_data - data_mean
## Linear regression
y = out_data.reshape(-1,num_dims)
X = out_label.reshape(-1,3)
X_label = (X[:,0] - 0.5)*2  # make the label balanced -1, 1 instead of 0,1
X = X[:,1:]  # linear regress the label separately
# print(X)
reg = LinearRegression().fit(X,y)
var_linReg = reg.score(X,y)
var_linreg_perdim = [LinearRegression().fit(X,y[:,dim]).score(X,y[:,dim]) for dim in range(num_dims)]
print(np.array(var_linreg_perdim))
# print(var_linReg)
var_linReg = var_linReg # ratio of total variance explained
linreg_coeff = reg.coef_
# because we zero meaned and the stimuli isnt balanced, there is bias
linreg_intercept = reg.intercept_
residual = y - reg.predict(X)
## linear effect of subject group (patient vs healthy)
var_label = 0
X_label = X_label[:,np.newaxis]
reg = LinearRegression().fit(X_label,residual)
var_label = reg.score(X_label,residual)
var_label = var_label * (1-var_linReg)
residual = residual - reg.predict(X_label)
## per subject bias for training
var_whole = np.var(residual)
residual = residual.reshape((dataset_size,stim_size,num_dims))  # reshape to original to calculate per subject bias
residual = residual - np.mean(residual,1,keepdims=True)  # removing mean across trials
var_bias = (var_whole - np.var(residual))/var_whole * (1-var_linReg)* (1-var_label) # ratio of total variance explained
residual = residual.reshape((-1,num_dims))     # flatten again
## FA modeling of remaining noise
n_components = np.arange(1,num_dims/4,2,dtype=np.int32)  # of course it needs to be int
# cross validate to choose the number of fa components
def compute_scores(X):
    pca = PCA(svd_solver="full")

    pca_scores = []
    for n in n_components:
        pca.n_components = n
        pca_scores.append(np.mean(cross_val_score(pca, X)))

    return pca_scores
pca_scores = compute_scores(residual)
n_components_pca = n_components[np.argmax(pca_scores)]
print("best n_components by FactorAnalysis CV = %d" % n_components_pca)
np.savez('PCA_scores',n_components=n_components,score=pca_scores)  # used for plotting in data processing, score is log likelihood
pca_model = PCA(svd_solver="full",n_components=n_components_pca)
residual_transformed = pca_model.fit_transform(residual)
print('PCA complete')
components = pca_model.components_
comp_s = np.sqrt(pca_model.explained_variance_)
err = pca_model.noise_variance_
var_pca = np.sum(pca_model.explained_variance_ratio_)
var_noise = 1-var_pca
var_pca = var_pca * (1-var_linReg)* (1-var_label) * (1-var_bias)
var_noise = var_noise * (1-var_linReg)* (1-var_label) * (1-var_bias)
print("Variance distribution:")
print("Linear effect of stimuli: {:.2%}".format(var_linReg))
print("Linear effect of subject group: {:.2%}".format(var_label))
print("Per subject bias: {:.2%}".format(var_bias))
print("PCA noise components: {:.2%}".format(var_pca))
print("Remaining white noise: {:.2%}".format(var_noise))
np.savez('mapping_model_init',data_mean=data_mean,linreg_coeff=linreg_coeff,linreg_intercept=linreg_intercept,components=components,comp_s=comp_s,err=err)
np.savez('variance_distribution',var_linReg=var_linReg,var_bias=var_bias,var_pca=var_pca,var_noise=var_noise)
## reconstruction of bias: need to maintain a moving average of bias of data collected so far, subtracting the stimuli effect
## reconstruction of linreg: multiply lin reg by stimuli
## reconstruction of error: draw gaussian sample in transformed space with std = comp_s, then multiply with components, then add individual gaussian error to each dim with err as std