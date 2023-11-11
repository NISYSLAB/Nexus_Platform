import os
import argparse
import numpy as np

## generates classifier_update.npz
############## Arguments ############################
base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--subject', type=str, default= None, help="Name of the subject to generate new trial")
parser.add_argument('--algorithm', type=str, default= None, help="Classifier algorithm to use for classification")
working_directory = os.getcwd()
args = parser.parse_args()
alg = args.algorithm
n_alg_random = 4
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
    if alg == 'random':
        classifier_results = np.empty((0,n_alg_random))
    trial_idx = 0

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

if alg == 'bnn':
    from algorithms.uncertainty_classifier.bayesian_neural_network import BayesianNeuralNetwork as Classifier
    c = Classifier(alg)
    c.load_model(working_directory)
if alg == 'knn':
    from algorithms.uncertainty_classifier.k_nearest_neighbor import KNearestNeighbor as Classifier
    c = Classifier(alg)
    c.load_model(working_directory)
if alg == 'rf':
    from algorithms.uncertainty_classifier.random_forest import RandomForest as Classifier
    c = Classifier(alg)
    c.load_model(working_directory)
if alg == 'logistic':
    from algorithms.uncertainty_classifier.logistic_regression import LogisticRegression as Classifier
    c = Classifier(alg)
    c.load_model(working_directory)
if alg == 'random':
    from algorithms.uncertainty_classifier.bayesian_neural_network import BayesianNeuralNetwork as Classifier
    c1 = Classifier('bnn')
    c1.load_model(working_directory)
    from algorithms.uncertainty_classifier.k_nearest_neighbor import KNearestNeighbor as Classifier
    c2 = Classifier('knn')
    c2.load_model(working_directory)
    from algorithms.uncertainty_classifier.random_forest import RandomForest as Classifier
    c3 = Classifier('rf')
    c3.load_model(working_directory)
    from algorithms.uncertainty_classifier.logistic_regression import LogisticRegression as Classifier
    c4 = Classifier('logistic')
    c4.load_model(working_directory)
    
if alg == 'random':
    new_label = np.empty((1,n_alg_random))
    new_label[0,0] = c1.model.predict(X)
    new_label[0,1] = c2.model.predict(X)
    new_label[0,2] = c3.model.predict(X)
    new_label[0,3] = c4.model.predict(X)
else:
    try:
        new_label = c.model.predict_proba(X)
    except:
        new_label = c.model.predict(X)
    new_label = new_label.reshape(-1)
    if len(new_label) > 1:
        print(new_label.shape)
        new_label = new_label[1]
# print(new_label.shape)
## save the history
stim = np.hstack((stim1_amp,stim2_amp))
print(X)
print(new_label)
# print(stim.shape)
stim_history = np.vstack((stim_history,stim))
classifier_results = np.vstack((classifier_results,new_label))
np.savez('classifier_update.npz',stim_history=stim_history,classifier_results=classifier_results)