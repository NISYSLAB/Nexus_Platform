import numpy as np
from os import path

import os
import time
ran_seed = ((os.getpid() * int(time.time())) % 123456789)        # seed for randoms
# print('Random seed is {}'.format(ran_seed))
rng = np.random.default_rng(ran_seed)

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
        model_init = np.load(path.join(working_directory,'mapping_model_init.npz'),allow_pickle=True)
        saved_response = model_init['response']
        saved_size = saved_response.shape[0]
        # print("saved_size:",saved_size)
        saved_stim = model_init['stim']
        X = stimuli.reshape(-1,2)
        ############ Parts with randomness (MC sampling)#############
        ## output: stim_size by num_dimensions by num_MCsamples
        ## output_stim: stim_size by 2
        output = np.zeros((stim_size,num_dims,self.num_MCsamples))
        output_stim = X
        for t in range(stim_size):
            a = rng.choice(saved_size,self.num_MCsamples)
            # print("a:",a)
            output[t,:,:] = saved_response[a,t,:].T
        # print("output for 5th stimuli:",output[4,:,:])
        np.savez(path.join(subject_directory,'mapping_model_inference'),output=output,output_stim=output_stim)
    

    def update(self,working_directory,subject_directory):
        pass