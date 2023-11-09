from sklearn.decomposition import PCA
from sklearn.model_selection import cross_val_score
from sklearn.linear_model import LinearRegression
import numpy as np
from os import path

class LinearPCA:
    def __init__(self, name, ndimsin=2, ndimsout=80, num_MCsamples=100):
        self.name = name
        self.ndimsin = ndimsin
        self.ndimsout = ndimsout
        self.num_MCsamples = num_MCsamples
    def train(self,stim,response,working_directory):
        out_data = response
        out_label = stim
        dataset_size = out_data.shape[0]
        stim_size = out_data.shape[1]
        num_dims = self.ndimsout
        ## remove the mean across subject and trials first
        data_mean = np.mean(out_data,(0,1),keepdims=True)
        out_data = out_data - data_mean
        ## Linear regression
        y = out_data.reshape(-1,num_dims)
        X = out_label.reshape(-1,3)
        X_label = (X[:,0] - 0.5)*2  # make the label balanced -1, 1 instead of 0,1
        X = X[:,1:]  # linear regress the label separately
        # print(X)
        reg = LinearRegression().fit(X,y)
        var_linReg = reg.score(X,y)
        var_linreg_perdim = [LinearRegression().fit(X,y[:,dim]).score(X,y[:,dim]) for dim in range(num_dims)]
        print(np.array(var_linreg_perdim))
        # print(var_linReg)
        var_linReg = var_linReg # ratio of total variance explained
        linreg_coeff = reg.coef_
        # because we zero meaned and the stimuli isnt balanced, there is bias
        linreg_intercept = reg.intercept_
        residual = y - reg.predict(X)
        ## linear effect of subject group (patient vs healthy)
        var_label = 0
        X_label = X_label[:,np.newaxis]
        reg = LinearRegression().fit(X_label,residual)
        var_label = reg.score(X_label,residual)
        var_label = var_label * (1-var_linReg)
        residual = residual - reg.predict(X_label)
        ## per subject bias for training
        var_whole = np.var(residual)
        residual = residual.reshape((dataset_size,stim_size,num_dims))  # reshape to original to calculate per subject bias
        residual = residual - np.mean(residual,1,keepdims=True)  # removing mean across trials
        var_bias = (var_whole - np.var(residual))/var_whole * (1-var_linReg)* (1-var_label) # ratio of total variance explained
        residual = residual.reshape((-1,num_dims))     # flatten again
        ## PCA modeling of remaining noise
        n_components = np.arange(1,num_dims/4,2,dtype=np.int32)  # of course it needs to be int
        # cross validate to choose the number of PCA components
        def compute_scores(X):
            pca = PCA(svd_solver="full")

            pca_scores = []
            for n in n_components:
                pca.n_components = n
                pca_scores.append(np.mean(cross_val_score(pca, X)))

            return pca_scores
        pca_scores = compute_scores(residual)
        n_components_pca = n_components[np.argmax(pca_scores)]
        print("best n_components by PCA CV = %d" % n_components_pca)
        pca_model = PCA(svd_solver="full",n_components=n_components_pca)
        residual_transformed = pca_model.fit_transform(residual)
        print('PCA complete')
        components = pca_model.components_
        comp_s = np.sqrt(pca_model.explained_variance_)
        err = pca_model.noise_variance_
        var_pca = np.sum(pca_model.explained_variance_ratio_)
        var_noise = 1-var_pca
        var_pca = var_pca * (1-var_linReg)* (1-var_label) * (1-var_bias)
        var_noise = var_noise * (1-var_linReg)* (1-var_label) * (1-var_bias)
        print("Variance distribution:")
        print("Linear effect of stimuli: {:.2%}".format(var_linReg))
        print("Linear effect of subject group: {:.2%}".format(var_label))
        print("Per subject bias: {:.2%}".format(var_bias))
        print("PCA noise components: {:.2%}".format(var_pca))
        print("Remaining white noise: {:.2%}".format(var_noise))
        np.savez(path.join(working_directory,'PCA_scores'),n_components=n_components,score=pca_scores)  # used for plotting in data processing, score is log likelihood
        np.savez(path.join(working_directory,'mapping_model_init'),data_mean=data_mean,linreg_coeff=linreg_coeff,linreg_intercept=linreg_intercept,components=components,comp_s=comp_s,err=err)
        np.savez(path.join(working_directory,'variance_distribution'),var_linReg=var_linReg,var_bias=var_bias,var_pca=var_pca,var_noise=var_noise)
        

    def MC_sampling(self,stimuli,working_directory,subject_directory):
        stim_size = stimuli.shape[0] * stimuli.shape[1]
        num_dims = self.ndimsout
        ## load the constructed model in base directory
        model_init = np.load(path.join(working_directory,'mapping_model_init.npz'))
        data_mean = model_init['data_mean']
        linreg_coeff = model_init['linreg_coeff']
        components = model_init['components']
        comp_s = model_init['comp_s']
        err = model_init['err']
        linreg_intercept=model_init["linreg_intercept"]
        ## load the model updates (bias for now)
        model_update = np.load(path.join(subject_directory,'mapping_model_update.npz'))
        subject_bias = model_update['subject_bias']     # size is (num_dims,)
        ############## Mapping model #########################
        ## reconstruction of bias: need to maintain a moving average of bias of data collected so far, subtracting the stimuli effect
        ## reconstruction of linreg: multiply lin reg by stimuli
        ## reconstruction of error: draw gaussian sample in transformed space with std = comp_s, then multiply with components, then add individual gaussian error to each dim with err as std
        out_data = np.zeros((stim_size,num_dims))
        ## overall mean, although it is the same to include it in subject bias for now
        out_data = out_data + data_mean[0,:,:]  # to match dimensions
        ## Linear regression
        # reconstructing linear model
        X = stimuli.reshape(-1,2)
        y = np.dot(X,linreg_coeff.T)+linreg_intercept
        ## per subject bias
        y = y + subject_bias

        ############ Parts with randomness (MC sampling)#############
        ## output: stim_size by num_dimensions by num_MCsamples
        ## output_stim: stim_size by 2
        output = np.zeros((stim_size,num_dims,self.num_MCsamples))
        output = output + y[:,:,np.newaxis]
        output_stim = X
        for i in range(stim_size):
            for j in range(self.num_MCsamples):
                ## PCA component sampling
                comp_sample = np.random.normal(scale=comp_s)
                # yes sklearn components do have unit length
                comp_reconstructed = np.dot(comp_sample,components)     # since when np doesnt bug out with 1d dot 2d array?
                ## individual noise: iid Gaussian
                individual_err = np.random.normal(scale=err,size=num_dims)
                output[i,:,j] = output[i,:,j] + comp_reconstructed + individual_err
        np.savez(path.join(subject_directory,'mapping_model_inference'),output=output,output_stim=output_stim)
    

    def update(self,working_directory,subject_directory):
        num_dims = self.ndimsout
        ## load the constructed model in base directory
        model_init = np.load(path.join(working_directory,'mapping_model_init.npz'))
        data_mean = model_init['data_mean']
        linreg_coeff = model_init['linreg_coeff']
        components = model_init['components']
        comp_s = model_init['comp_s']
        err = model_init['err']
        ## load history model update
        try:
            model_update = np.load(path.join(subject_directory,'mapping_model_update.npz'))
            subject_bias_history = model_update['subject_bias_history']     # size is (num_trials,num_dims)
            trial_idx = subject_bias_history.shape[0]
        except:
            subject_bias_history = np.empty((0,num_dims))
            trial_idx = 0
        # load the response
        output = np.load('trial_{}.npz'.format(trial_idx))
        stim1_amp = output['stim1_amp']
        stim2_amp = output['stim2_amp']
        stimulus = np.array([stim1_amp,stim2_amp])
        response = output['output']
        linreg_intercept=model_init["linreg_intercept"]
        y = np.dot(stimulus,linreg_coeff.T)+linreg_intercept
        residual = response - y
        subject_bias_new = residual
        subject_bias_history = np.vstack((subject_bias_history,subject_bias_new))
        np.savez(path.join(subject_directory,'mapping_model_update'),subject_bias_history=subject_bias_history,subject_bias=np.mean(subject_bias_history,axis=0))