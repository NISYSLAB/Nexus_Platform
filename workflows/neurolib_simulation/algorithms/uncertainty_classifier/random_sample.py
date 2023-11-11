from .base_classifier import BaseClassifier
import numpy as np
from os import path

# this is the special random sampling which only returns the random sampling
# no classifier included
class RandomSample(BaseClassifier):
    # noutputs is the number of outputs of the model
    def __init__(self, name, noutputs=2, rescale=True, ndims=82):
        super().__init__(name, noutputs, rescale, ndims)
    def _train_init_additional(self,**kwargs):
        self.sklclassifier = None
        pass
    def _inference_init_additional(self,**kwargs):
        pass
    def _save_classifier_model(self):
        pass
    def _load_classifier_model(self):
        pass
    def _build_model_from_params(self, hyper_params):
        pass
    def _MC_predict(self, X):
        pass
    def acquisition(self, stim):
        acquisition = np.random.normal(stim.shape[0])/2
        return acquisition  
    def find_optimal_stimulus(self, X, stim, subject_dir):
        ## override the base class method to get rid of the classifier
        # X is of shape (stim_size, num_samples, num_dims-2)
        # X_stim is of shape (stim_size, 2)
        ## load the model updates (history)
        acquisition = self.acquisition(stim)
        penalty = self.penalty(self.stim_history, stim)
        acquisition = acquisition - penalty
        optimal_stim_idx = np.argmax(acquisition)  # only one new stim needed
        stim_x = stim[optimal_stim_idx,0]
        stim_y = stim[optimal_stim_idx,1]
        stim_idx = self.stim_history.shape[0]  # next index
        np.savez(path.join(subject_dir,'next_stimulus'),x=stim_x,y=stim_y,trial_num=stim_idx)