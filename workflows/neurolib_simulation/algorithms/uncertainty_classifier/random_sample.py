from .base_classifier import BaseClassifier
import numpy as np

# this is the special random sampling which only returns the random sampling
# no classifier included
class RandomSample(BaseClassifier):
    # noutputs is the number of outputs of the model
    def __init__(self, name, noutputs=2, rescale=True, ndims=82):
        super().__init__(name, noutputs, rescale, ndims)
    def acquisition(self, MC_samples):
        acquisition = np.random.normal(MC_samples.shape[1])/2
        return acquisition  