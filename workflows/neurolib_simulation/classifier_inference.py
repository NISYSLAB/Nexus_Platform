import os
import argparse
# from keras.models import load_model
# from keras import backend as K
import numpy as np
import time


## generates next_stimulus.npz
############## Arguments ############################
base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--algorithm', type=str, default= None, help="Classifier algorithm to use for classification")
parser.add_argument('--subject', type=str, default= None, help="Name of the subject to generate new trial")
working_directory = os.getcwd()
args = parser.parse_args()
algorithm = args.algorithm
subject_name = args.subject
# operate in subject directory
subject_dir = os.path.join(working_directory,'subjects',subject_name)
os.chdir(subject_dir)
####################################################################################

## loading initial data
input_data = np.load('mapping_model_inference.npz')
X = input_data['output']
X_stim = input_data['output_stim']

## load the model updates (history)
model_update = np.load('classifier_update.npz')
stim_history = model_update['stim_history']

# finding optimal stimulus
def find_optimal_stimulus(alg):
    if alg == 'bnn':
        from algorithms.uncertainty_classifier.bayesian_neural_network import BayesianNeuralNetwork as Classifier
        c = Classifier(alg)
        c.inference_init(stim_history,acquisition_mode='BALD')
        c.load_model(working_directory)
        c.find_optimal_stimulus(X,X_stim,subject_dir)
    if alg == 'knn':
        from algorithms.uncertainty_classifier.k_nearest_neighbor import KNearestNeighbor as Classifier
        c = Classifier(alg)
        c.inference_init(stim_history,acquisition_mode='BALD')
        c.load_model(working_directory)
        c.find_optimal_stimulus(X,X_stim,subject_dir)
    if alg == 'rf':
        from algorithms.uncertainty_classifier.random_forest import RandomForest as Classifier
        c = Classifier(alg)
        c.inference_init(stim_history,acquisition_mode='BALD')
        c.load_model(working_directory)
        c.find_optimal_stimulus(X,X_stim,subject_dir)
    if alg == 'logistic':
        from algorithms.uncertainty_classifier.logistic_regression import LogisticRegression as Classifier
        c = Classifier(alg)
        c.inference_init(stim_history,acquisition_mode='BALD')
        c.load_model(working_directory)
        c.find_optimal_stimulus(X,X_stim,subject_dir)
    if alg == 'random':
        from algorithms.uncertainty_classifier.random_sample import RandomSample as Classifier
        c = Classifier(alg)
        c.find_optimal_stimulus(X,X_stim,subject_dir)


if __name__ == "__main__":
    find_optimal_stimulus(algorithm)
