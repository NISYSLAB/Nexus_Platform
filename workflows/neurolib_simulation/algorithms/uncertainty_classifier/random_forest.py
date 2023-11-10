from .base_classifier import BaseClassifier
import numpy as np
from sklearn.ensemble import RandomForestClassifier
# joblib saving is required
from joblib import dump, load
from os import path

class RandomForest(BaseClassifier):
    # default hyper param grid
    default_params = {
    'n_estimators':[10,30,50,100,300,500],
    'min_samples_split':[2,4,6,8,10],
    }
    # noutputs is the number of outputs of the model
    def __init__(self, name, noutputs=2, rescale=True, ndims=82):
        super().__init__(name, noutputs, rescale, ndims)
    def train_init(self, hyper_param_space=default_params, **kwargs):
        return super().train_init(hyper_param_space, **kwargs)
    def _train_init_additional(self,**kwargs):
        self.sklclassifier = RandomForestClassifier()
    def _inference_init_additional(self,**kwargs):
        pass
    def _save_classifier_model(self,working_directory):
        dump(self.model, path.join(working_directory,'classifier_init_{}.joblib'.format(self.name)))
    def _load_classifier_model(self,working_directory):
        self.model = load(path.join(working_directory,'classifier_init_{}.joblib'.format(self.name)))
    def _build_model_from_params(self, **hyper_params):
        # initialize the model with hyper params
        self.model = RandomForestClassifier(**hyper_params)
    def acquisition(self, MC_samples):
        # note that the probability returned by random forest is disagreement - each tree is 1 or 0
        expected_p = np.mean(MC_samples, axis=0)    # stim_size by modelout_shape
        acquisition = - np.sum(expected_p * np.log(expected_p + 1e-10), axis=-1)  # [batch size]
        return acquisition  
    def _MC_predict(self, X):
        MC_samples = self.model.predict_proba(X)
        MC_samples = MC_samples[:,1]  # binary classification
        MC_samples = MC_samples[:,np.newaxis]
        return MC_samples