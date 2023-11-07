import os
import argparse
import numpy as np
import time
############## Arguments ############################

base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--mode', type=str, default= None, help="Bump or dent")
parser.add_argument('--subject', type=str, default= None, help="Name of the subject to generate new trial")
parser.add_argument('--stimuli', type=str, default= None, help="Name of the stimuli file to generate new trial")

working_directory = os.getcwd()

args = parser.parse_args()
mode = args.mode
subject_name = args.subject
stimuli_file = args.stimuli

####################################################################################
def bump(x,y):
    return np.exp(-(x-1)**2 - (y-1)**2)
def dent(x,y):
    return 1 - np.exp(-(x-1)**2 - (y-1)**2)
os.chdir(working_directory)
subject_path = os.path.join(working_directory,'subjects',subject_name)
os.chdir(subject_path)
# load stimuli
stimuli = np.load(stimuli_file)
x = stimuli['x']
y = stimuli['y']
trial_num = stimuli['trial_num']
if mode == 'bump':
    output = bump(x,y)
elif mode == 'dent':
    output = dent(x,y)
np.savez('trial_{}'.format(trial_num),stim1_amp=x,stim2_amp=y,output=np.ones(80)*output)
