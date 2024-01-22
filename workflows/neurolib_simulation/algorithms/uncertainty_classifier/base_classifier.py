###########################################################################
## The base algorithm class
###########################################################################
from abc import ABC, abstractmethod
from sklearn.preprocessing import StandardScaler
import numpy as np
from sklearn.model_selection import GridSearchCV
from os import path
metric = 'accuracy'

class BaseClassifier(ABC):
    def __init__(self, name, noutputs, rescale=True, ndims=82, modeltype='skl'):
        self.name = name
        # Whether to rescale the data
        self.rescale = rescale
        if self.rescale:
            self.scaler = StandardScaler()
        # Number of dimensions in the output
        self.ndims = ndims
        self.noutputs = noutputs
        self.model = None
        self.modeltype = modeltype
    # parameter space used in grid search, only used in initialization
    @property
    def hyper_param_space(self):
        return self._hyper_param_space
    @hyper_param_space.setter
    def hyper_param_space(self, hyper_param_space):
        self._hyper_param_space = hyper_param_space
    # parameters determined by grid search
    @property
    def hyper_params(self):
        return self._hyper_params
    @hyper_params.setter
    def hyper_params(self, hyper_params):
        self._hyper_params = hyper_params
    
    ## initialization workflow
    def train_init(self,hyper_param_space,**kwargs):
        self.hyper_param_space = hyper_param_space
        self._train_init_additional(**kwargs)
    # for additional initialization, note: self.sklclassifier is initialized here
    @abstractmethod
    def _train_init_additional(self,**kwargs):
        self.sklclassifier = None
        pass
    def train(self,X,y,cvgroups,cv,working_directory):
        if self.rescale:
            X = self.scaler.fit_transform(X)
        gs = GridSearchCV(estimator=self.sklclassifier,param_grid=self.hyper_param_space,
                  cv=cv, 
                  scoring='accuracy',verbose=1)
        gs = gs.fit(X,y,groups=cvgroups)
        print('Algorithm {} grid search params: \n{}'.format(self.name,gs.best_params_))
        print('Algorithm {} grid search score: {}'.format(self.name,gs.best_score_))
        self.hyper_params = gs.best_params_
        # fit on the entire set as initial classifier
        self._build_model(self.hyper_params)
        if 'nb_epoch' in self.hyper_params:
            self.model.fit(X, y, epochs=self.hyper_params['nb_epoch'])
        else:
            self.model.fit(X, y)
        self.save_model(working_directory)

    def test(self,Xtest,ytest):
        if self.rescale:
            Xtest = self.scaler.transform(Xtest)
        if self.modeltype == 'skl':
            if metric == 'accuracy':
                score = self.model.score(Xtest,ytest) 
            elif metric == 'AUC':
                # in case we want AUC
                from sklearn.metrics import roc_auc_score
                ypred = self.model.predict_proba(Xtest)
                score = roc_auc_score(ytest,ypred[:,1])
        elif self.modeltype == 'keras':
            metrics_names = self.model.metrics_names
            scores = self.model.evaluate(x=Xtest,y=ytest)
            if metric == 'accuracy':
                score = scores[metrics_names.index('accuracy')]
            elif metric == 'AUC':
                score = scores[metrics_names.index('AUC')]
        print('Algorithm {} test score: {}'.format(self.name,score))   
        return score

    ## inference workflow
    def inference_init(self,model_update,acquisition_mode=None,penalty_mode='gaussian',
                       penalty_weight = 0.2,penalty_decay = 4,num_MCsamples=1,**kwargs):
        self.stim_history = model_update
        self.acquisition_mode = acquisition_mode
        self.penalty_mode = penalty_mode
        self.penalty_weight = penalty_weight
        self.penalty_decay = penalty_decay
        self.num_MCsamples = num_MCsamples
        self._inference_init_additional(**kwargs)
    # for additional initialization
    @abstractmethod
    def _inference_init_additional(self,**kwargs):
        pass
    def find_optimal_stimulus(self, X, stim, subject_dir):
        # X is of shape (stim_size, num_samples, num_dims-2)
        # X_stim is of shape (stim_size, 2)
        ## load the model updates (history)
        mc_samples = self._MC_sampling(X, stim)
        # print(mc_samples.shape)
        acquisition = self.acquisition(mc_samples)
        penalty = self.penalty(self.stim_history, stim)
        acquisition = acquisition - penalty
        optimal_stim_idx = np.argmax(acquisition)  # only one new stim needed
        stim_x = stim[optimal_stim_idx,0]
        stim_y = stim[optimal_stim_idx,1]
        stim_idx = self.stim_history.shape[0]  # next index
        np.savez(path.join(subject_dir,'next_stimulus'),x=stim_x,y=stim_y,trial_num=stim_idx)

    ## update workflow
    def predict(self,X):
        if self.rescale:
            X = self.scaler.transform(X)
        if self.modeltype == 'skl':
            l = self.model.predict_proba(X)
        elif self.modeltype == 'keras':
            l = self.model.predict(X)
        else:
            raise ValueError('Unknown model type')
        # for binary classification stuff
        # TODO: multiclass support... but wait these should be separate classifiers
        l = l.reshape(-1)
        if self.noutputs == 2:
            l = l[1]  # only return the probability of class 1
        return l
    ## methods used for workflows
    def save_model(self,working_directory):
        if self.rescale:
            self._save_scaler(working_directory)
        np.savez(path.join(working_directory,self.name+'_hyper_params'),hyper_params=self.hyper_params)
        self._save_classifier_model(working_directory)
    def _save_scaler(self,working_directory):
        np.savez(path.join(working_directory,'classifier_init_scaler'),scaler_mean=self.scaler.mean_,scaler_var=self.scaler.var_,scaler_n_fea_in=self.scaler.n_features_in_,scaler_samp_seen=self.scaler.n_samples_seen_)
    @abstractmethod
    def _save_classifier_model(self,working_directory):
        pass
    def load_model(self,working_directory):
        if self.rescale:
            self._load_scaler(working_directory)
        hyper_params = np.load(path.join(working_directory,self.name+'_hyper_params.npz'),allow_pickle=True)
        hyper_params = hyper_params['hyper_params']
        hyper_params = hyper_params[()]  # convert to dict, otherwise it's a np array
        self._build_model(hyper_params)
        self._load_classifier_model(working_directory)
    def _load_scaler(self,working_directory):
        scaler = np.load(path.join(working_directory,'classifier_init_scaler.npz'),allow_pickle=True)
        scaler_mean = scaler['scaler_mean']
        scaler_var = scaler['scaler_var']
        scaler_n_fea_in = scaler['scaler_n_fea_in']
        scaler_samp_seen = scaler['scaler_samp_seen']
        self.scaler.mean_ = scaler_mean
        self.scaler.var_ = scaler_var
        self.scaler.scale_ = np.sqrt(scaler_var)
        self.scaler.n_features_in_ = scaler_n_fea_in
        self.scaler.n_samples_seen_ = scaler_samp_seen
    @abstractmethod
    def _load_classifier_model(self,working_directory):
        pass

    # the model should be wrapped to skl model
    def _build_model(self, hyper_params):
        self._build_model_from_params(**hyper_params)
        self.hyper_params = hyper_params
    @abstractmethod
    def _build_model_from_params(self, hyper_params):
        # initialize the model with hyper params
        pass
    
    @abstractmethod
    def acquisition(self, MC_samples):
        # return the acquisition function
        pass

    def _MC_sampling(self, X, stim):
        modelout_shape = self.noutputs
        if self.noutputs ==1:
            modelout_shape = 2  # add back the null class
        stim_size = stim.shape[0]
        num_MCsamples_mapping = X.shape[2]
        # print("num_MCsamples_mapping:",num_MCsamples_mapping)
        # print("num_MCsamples_classifier:",self.num_MCsamples)
        # group the inference by stimuli used
        MC_samples = np.empty((self.num_MCsamples*num_MCsamples_mapping,stim_size,modelout_shape))
        for stim_idx in range(stim_size):
            out = X[stim_idx,:,:]  # num_dims by num_MCsamples in mapping
            s = stim[stim_idx,:]  # (2,)
            s = np.tile(s,(out.shape[1],1)).T     # 2 by num_MCsamples in mapping
            X_stim = np.vstack((out,s))
            X_stim = X_stim.T   # num_MCsamples in mapping by num_dims+2
            # print("X_stim:",X_stim)
            if self.rescale:
                X_stim = self.scaler.transform(X_stim)
            # print("X_stim:",X_stim)
            # print("X_stim.shape:",X_stim.shape)
            # with eager_learning_phase_scope(value=1):
            #     MC_samples_stim = [MC_output([X_stim])[0] for _ in range(T)]
            # This line was the issue
            # MC_samples_stim = self._MC_predict(X_stim)[0] # num_MCsamples_classifier * num_MCsamples by modelout_shape
            MC_samples_stim = self._MC_predict(X_stim) # num_MCsamples_classifier * num_MCsamples by modelout_shape
            # print("MC_samples_stim:",MC_samples_stim)
            if self.noutputs == 1:
                # add back the null class
                MC_samples[:,stim_idx,0] = MC_samples_stim[:,0]
                MC_samples[:,stim_idx,1] = 1 - MC_samples_stim[:,0]
            else:
                MC_samples[:,stim_idx,:] = MC_samples_stim
        # print(MC_samples.shape)
        return MC_samples

    @abstractmethod
    def _MC_predict(self, X):
        # returns one or multiple MC samples
        pass

    def penalty(self, stim_history, X_stim):
        if self.penalty_mode == 'gaussian':
            return self._penalty_gaussian(stim_history, X_stim)
        else:
            raise ValueError('Unknown penalty mode')
    def _penalty_gaussian(self, stim_history, X_stim):
        stim_size = X_stim.shape[0]
        history_size = stim_history.shape[0]
        stim_history[0,:] = stim_history[0,:] + 1e-4  # to avoid log(0)
        # calculate distance in log space
        out_x = np.log10(X_stim[:,0])
        out_y = np.log10(X_stim[:,1])
        penalty = np.zeros(stim_size)
        for i in range(history_size):
            history_x = np.log10(stim_history[i,0])
            history_y = np.log10(stim_history[i,1])
            dist = (out_x - history_x)**2 + (out_y - history_y)**2
            penalty = penalty + self.penalty_weight*np.exp(-dist*self.penalty_decay)
        return penalty