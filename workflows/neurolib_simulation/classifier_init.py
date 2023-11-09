import os
import argparse
import numpy as np
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
## we init every algorithm in the list
# parser.add_argument('--alg', type=str, default= None, help="Algorithm to use for classification")
working_directory = os.getcwd()

args = parser.parse_args()
dataset_size = int(args.size)
grid_size = int(args.gridsize)
# alg = args.alg
algorithms = ['bnn','knn','rf','logistic']
num_groups = 2
num_dims = 80
ran_seed = 0        # seed for randoms
if dataset_size <5:
    n_splits = dataset_size
else:
    n_splits = 5
dataset_size = num_groups * dataset_size
dataset_size_test = 40  # hard coded for now
stim_size = grid_size * grid_size
num_batch = 1       # batch size

############## Data Loading #########################
## output data matrix: subject by stimuli by output dimensions
## output label matrix: subject by stimuli by 3 (label, stim1, stim2)
def load_data(subject_header,dataset_size,stim_size):
    out_data = np.empty((dataset_size,stim_size,num_dims))
    out_label = np.empty((dataset_size,stim_size,3))
    for s in range(dataset_size):
        subject_name = '{}_{}'.format(subject_header,s)
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
    XX = np.concatenate((out_data,out_label[:,:,1:]),axis=-1)
    cvgroups = np.array([np.ones((stim_size))*i for i in range(dataset_size)])
    yy = out_label[:,:,0]
    # print(XX.shape)
    # print(cvgroups.shape)
    # print(yy.shape)
    sanity_check = XX[0,8,:]
    XX = XX.reshape((-1,num_dims+2))
    if not np.isclose(sanity_check,XX[8,:]).all():
        print('Sanity check failed')
        exit()
    cvgroups = cvgroups.reshape(-1)
    y = yy.reshape(-1)
    cv=CustomGroupStratifiedKFold(n_splits=n_splits,n_meta=num_groups)
    return XX,y,cvgroups,cv

XX,y,cvgroups,cv = load_data('subject_train',dataset_size,stim_size)
XXtest,ytest,cvgroupstest,cvtest = load_data('subject_test',dataset_size_test,stim_size)
# X = np.hstack((X,y))    # just a dumb check to see if model is smart enough if we put label into input - the answer is yes
# X = np.hstack((X,stim))  # expand X to contain stimuli
# y = y[:,0]

for alg in algorithms:
    if alg == 'bnn':
        from algorithms.uncertainty_classifier.bayesian_neural_network import BayesianNeuralNetwork as Classifier
        c = Classifier(alg)
        c.train_init()
        c.model = None
        c.train(XX,y,cvgroups,cv,working_directory)
        bnn = c.test(XXtest,ytest)
    if alg == 'knn':
        from algorithms.uncertainty_classifier.k_nearest_neighbor import KNearestNeighbor as Classifier
        c = Classifier(alg)
        c.train_init()
        c.train(XX,y,cvgroups,cv,working_directory)
        knn = c.test(XXtest,ytest)
    if alg == 'rf':
        from algorithms.uncertainty_classifier.random_forest import RandomForest as Classifier
        # kind of slow, we implement n_jobs = -1
        c = Classifier(alg)
        c.train_init()
        c.train(XX,y,cvgroups,cv,working_directory)
        rf = c.test(XXtest,ytest)
    if alg == 'logistic':
        from algorithms.uncertainty_classifier.logistic_regression import LogisticRegression as Classifier
        c = Classifier(alg)
        c.train_init()
        c.train(XX,y,cvgroups,cv,working_directory)
        lr = c.test(XXtest,ytest)
np.savez('classifier_init_scores',bnn=bnn,knn=knn,rf=rf,lr=lr)
