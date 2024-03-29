from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Flatten
from tensorflow.keras import initializers
from tensorflow.keras.regularizers import l2
from tensorflow.keras import optimizers
from tensorflow.keras.models import load_model
from tensorflow.keras import backend as K
from tensorflow.keras.wrappers.scikit_learn import KerasClassifier
import time
import os
import numpy as np
# https://github.com/tensorflow/tensorflow/issues/34201#issuecomment-690137283
# to make things work.....
from tensorflow.python.keras.backend import eager_learning_phase_scope  
from .base_classifier import BaseClassifier
from os import path

ran_seed = ((os.getpid() * int(time.time())) % 123456789)        # seed for randoms
rng = np.random.default_rng(ran_seed)
metric = ['accuracy','AUC']
# we pull it out separately for KerasClassifier wrapper
def build_model(learning_rate,unit_l1,unit_l2,unit_l3):
    model = Sequential()
    init_scheme = initializers.HeNormal(time.time_ns())
    init_scheme_input = initializers.HeUniform(time.time_ns())
    optimize_scheme = optimizers.Adam(learning_rate=learning_rate)
    model.add(Dense(unit_l1, input_dim=82,activation='relu',kernel_initializer=init_scheme_input,bias_initializer="zeros"))
    model.add(Dropout(0.25))
    model.add(Dense(unit_l2,activation='relu',kernel_initializer=init_scheme,bias_initializer="zeros"))
    model.add(Dropout(0.25))
    model.add(Dense(unit_l3,activation='relu',kernel_initializer=init_scheme,bias_initializer="zeros"))
    model.add(Dropout(0.125))
    model.add(Dense(1,activation='sigmoid',kernel_initializer=init_scheme,bias_initializer="zeros"))
    model.compile(loss='binary_crossentropy', optimizer=optimize_scheme, metrics=metric)
    return model

class BayesianNeuralNetwork(BaseClassifier):
    # default hyper param grid
    default_params = {
    'nb_epoch':[300 * i + 300 for i in range(1)],
    'batch_size':[1,2,4,8,16,32],
    'learning_rate':[0.01,0.001,0.0001],
    'unit_l1':[64,128,256],
    'unit_l2':[64,32],
    'unit_l3':[32,16]
    }
    # default_params = {
    # 'nb_epoch':[300 * i + 300 for i in range(1)],
    # 'batch_size':[1],
    # 'learning_rate':[0.01],
    # 'unit_l1':[64],
    # 'unit_l2':[64],
    # 'unit_l3':[32]
    # }
    def __init__(self, name, noutputs=1, rescale=True, ndims=82, modeltype='keras'):
        super().__init__(name, noutputs, rescale, ndims, modeltype)
    def train_init(self, hyper_param_space=default_params, **kwargs):
        return super().train_init(hyper_param_space, **kwargs)
    def _train_init_additional(self,**kwargs):
        self.sklclassifier = KerasClassifier(build_fn=build_model)
    # purely for setting default acquisition mode
    def inference_init(self, model_update, acquisition_mode='BALD', **kwargs):
        return super().inference_init(model_update,acquisition_mode=acquisition_mode, **kwargs)
    def _inference_init_additional(self,**kwargs):
        pass
    def _save_classifier_model(self,working_directory):
        self.model.save(path.join(working_directory,'classifier_init_{}.keras'.format(self.name)))
    def _load_classifier_model(self,working_directory):
        # keras loading does not need the model built with hyper params
        self.model = load_model(path.join(working_directory,'classifier_init_{}.keras'.format(self.name)))
        # yeah we want to have it called score instead of evaluate...
        self.model.score = self.model.evaluate
    def _build_model_from_params(self, **hyper_params):
        # batch size and nb_epoch are not used in the model
        hyper_params.pop('batch_size')
        hyper_params.pop('nb_epoch')
        # print("Received Hyperparameters:", hyper_params)
        self.model = build_model(**hyper_params)
        # print(self.model.summary())
    def acquisition(self, MC_samples):
        if self.acquisition_mode == 'uniform':
            return self._acquisition_uniform(MC_samples)
        elif self.acquisition_mode == 'max_entropy':
            return self._acquisition_max_entropy(MC_samples)
        elif self.acquisition_mode == 'BALD':
            return self._acquisition_bald(MC_samples)
    
    def _acquisition_uniform(self,MC_samples):
        acquisition = rng.normal(size=(MC_samples.shape[1],))  # [batch size]
        return acquisition
    def _acquisition_max_entropy(self,MC_samples):
        expected_p = np.mean(MC_samples, axis=0)    # stim_size by modelout_shape
        acquisition = - np.sum(expected_p * np.log(expected_p + 1e-10), axis=-1)  # [batch size]
        return acquisition     # we use -acquisition to fine the stimulus giving the most certain prediction
    # BALD
    def _acquisition_bald(self,MC_samples):
        expected_entropy = - np.mean(np.sum(MC_samples * np.log(MC_samples + 1e-10), axis=-1), axis=0)  # [batch size]
        expected_p = np.mean(MC_samples, axis=0)
        entropy_expected_p = - np.sum(expected_p * np.log(expected_p + 1e-10), axis=-1)  # [batch size]
        # print("MC_samples for 5th stimuli: ",MC_samples[:,4,:])
        # print("size of MC_samples: ",MC_samples.shape)
        # print("expected_p:",expected_p)
        # print("expected_entropy:",expected_entropy)
        # print("entropy_expected_p:",entropy_expected_p)
        acquisition = entropy_expected_p - expected_entropy
        # print("acquisition:",acquisition)
        return acquisition
    
    def _MC_predict(self, X):
        with eager_learning_phase_scope(value=1):
            MC_samples_stim = [self._MC_fun([X])[0] for _ in range(self.num_MCsamples)]
        MC_samples_stim = np.array(MC_samples_stim)  # num_MCsamples_classifier by num_MCsamples by modelout_shape
        MC_samples_stim = MC_samples_stim.reshape(-1,self.noutputs)
        return MC_samples_stim

    def _MC_sampling(self, output, output_stim):
        self._MC_fun = K.function([self.model.layers[0].input],
                           [self.model.layers[-1].output])
        return super()._MC_sampling(output, output_stim)
