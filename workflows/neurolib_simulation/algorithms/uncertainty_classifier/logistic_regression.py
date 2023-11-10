## This is a blank algorithm that can be used as a template for new algorithms
from .base_classifier import BaseClassifier
from sklearn.linear_model import LogisticRegression as skl_LogisticRegression
import numpy as np
from os import path
class LogisticRegression(BaseClassifier):
    # default hyper param grid
    # this will run l1 and l2 multiple times but it's fast so it's ok
    default_params = {
    'penalty':['l1','l2','elasticnet'],
    'C':[0.1,1,10,100],
    'l1_ratio':[0.1,0.5,0.9],
    'max_iter':[1000],
    }
    def __init__(self, name, noutputs=2, rescale=True, ndims=82):
        super().__init__(name, noutputs, rescale, ndims)
    def train_init(self, hyper_param_space=default_params, **kwargs):
        return super().train_init(hyper_param_space, **kwargs)
    def _train_init_additional(self,**kwargs):
        self.sklclassifier = skl_LogisticRegression()
    def _inference_init_additional(self,**kwargs):
        pass
    def _save_classifier_model(self,working_directory):
        classes_ = self.model.classes_
        coef_ = self.model.coef_
        intercept_ = self.model.intercept_
        n_features_in_ = self.model.n_features_in_
        n_iter_ = self.model.n_iter_
        np.savez(path.join(working_directory,'classifier_init_{}.npz'.format(self.name)),classes_=classes_,coef_=coef_,intercept_=intercept_,n_features_in_=n_features_in_,n_iter_=n_iter_)
    def _load_classifier_model(self,working_directory):
        data = np.load(path.join(working_directory,'classifier_init_{}.npz'.format(self.name)))
        classes_ = data['classes_']
        coef_ = data['coef_']
        intercept_ = data['intercept_']
        n_features_in_ = data['n_features_in_']
        n_iter_ = data['n_iter_']
        self.model.classes_ = classes_
        self.model.coef_ = coef_
        self.model.intercept_ = intercept_
        self.model.n_features_in_ = n_features_in_
        self.model.n_iter_ = n_iter_

    def _build_model_from_params(self, **hyper_params):
        # the hyper params are for training only
        self.model = skl_LogisticRegression(**hyper_params)
    def _MC_predict(self, X):
        # returns one or multiple MC samples
        MC_samples = self.model.predict_proba(X)
        MC_samples = MC_samples[:,1]  # binary classification
        MC_samples = MC_samples[:,np.newaxis]
        return MC_samples
    def acquisition(self, X, X_stim):
        MC_samples = self._MC_sampling(X, X_stim)
        expected_p = np.mean(MC_samples, axis=0)    # stim_size by modelout_shape
        acquisition = - np.sum(expected_p * np.log(expected_p + 1e-10), axis=-1)  # [batch size]
        return acquisition  