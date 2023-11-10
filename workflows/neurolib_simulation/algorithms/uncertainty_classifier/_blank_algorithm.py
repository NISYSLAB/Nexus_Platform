## This is a blank algorithm that can be used as a template for new algorithms
from base_classifier import BaseClassifier

class Blank(BaseClassifier):
    ## Attributes
    # model: the model object, need to have predict
    # default hyper param grid
    default_params = {
    'param1':[1,2,3]
    }
    # noutputs is the number of outputs of the model
    def __init__(self, name, noutputs=1, rescale=True, ndims=82):
        super().__init__(name, noutputs, rescale, ndims)
    def train_init(self, hyper_param_space=default_params, **kwargs):
        return super().train_init(hyper_param_space, **kwargs)
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
        # initialize the model with hyper params
        pass
    def acquisition(self, MC_samples):
        # return the acquisition function
        pass
    def _MC_predict(self, X):
        # returns one or multiple MC samples
        pass
    def test(self, Xtest, ytest):
        # if the model does not have score method, overwrite this method
        # like keras evaluate
        # if overwrite, remember to rescale the data
        # default metric is accuracy, auc support is preferred
        return super().test(Xtest, ytest)