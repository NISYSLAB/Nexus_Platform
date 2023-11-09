import numpy as np
from os import path

class resample:
    def __init__(self, name, ndimsin=2, ndimsout=80, num_MCsamples=100):
        self.name = name
        self.ndimsin = ndimsin
        self.ndimsout = ndimsout
        self.num_MCsamples = num_MCsamples


    def train(self,stim,response,working_directory):
        np.savez(path.join(working_directory,'mapping_model_init'),response=response,stim=stim)
        

    def MC_sampling(self,stimuli,working_directory,subject_directory):
        stim_size = stimuli.shape[0] * stimuli.shape[1]
        num_dims = self.ndimsout
        ## load the constructed model in base directory
        model_init = np.load(path.join(working_directory,'mapping_model_init.npz'))
        saved_response = model_init['response']
        saved_size = saved_response.shape[0]
        saved_stim = model_init['stim']
        X = stimuli.reshape(-1,2)
        ############ Parts with randomness (MC sampling)#############
        ## output: stim_size by num_dimensions by num_MCsamples
        ## output_stim: stim_size by 2
        output = np.zeros((stim_size,num_dims,self.num_MCsamples))
        output_stim = X
        for t in range(stim_size):
            a = np.random.choice(saved_size,self.num_MCsamples)
            output[t,:,:] = saved_response[a,t,:].T
        np.savez(path.join(subject_directory,'mapping_model_inference'),output=output,output_stim=output_stim)
    

    def update(self,working_directory,subject_directory):
        pass