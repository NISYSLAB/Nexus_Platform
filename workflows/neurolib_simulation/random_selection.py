#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May 06 09:44:40 2022

@author: parisa sarikhani (parisasarikhani@gmail.com)

This python script reads the history of sampled parameters of the fMRI task from a CSV file, 
and uses Bayesian optimization to suggest the next set of parameters to be sampled

The next set of parameters to be sampled at the next round of experiment will be added as
a line of output in a csv file in the desired path with the desired filename when called.

This can either create a new file if it is at the befginning of the experiemnt or write a new line to an existing file otherwise
.
According to Michael the filename should be like 013_myfile.csv - the filename ordering is better handled in the shell script framework

Arguments:
    --savepath - path of the output
    --savename - output filename
"""
import os
import argparse
import numpy as np
import csv
import logging
import tensorflow as tf
import time

############## Arguments ############################
base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--subject', type=str, default= None, help="Name of the subject to generate new trial")
parser.add_argument('--savename', type=str, default= None, help="Filename of the output")
parser.add_argument('--objectivename', type=str, default= None, help="Filename of the input")
working_directory = os.getcwd()
args = parser.parse_args()
subject_name = args.subject
save_name = args.savename
obj_filename = args.objectivename
# operate in subject directory
os.chdir(os.path.join(working_directory,'subjects',subject_name))
####################################################################################

# Optimizaton parameters:
# Define the discrete parameter space:
amp = 0    
min_amp = -2
grid_size = 7
q1_values = np.logspace(min_amp,amp,grid_size)
q2_values = np.logspace(min_amp,amp,grid_size)
ran_seed = ((os.getpid() * int(time.time())) % 123456789)        # seed for randoms
rng = np.random.default_rng(ran_seed)

# example filename: 013_my_file_time_stamp.csv

# filename = os.path.join(save_path,save_name)
# obj_filename = args.objectivepath


def BayesOpt(filename, obj_filename):
    
    flag_end = 0 # flag to the end of experiment
    if os.path.exists(filename):
        with open(filename) as f:
            rows=[]
            for i, line in enumerate(f):
                rows.append(line.replace('\n','').split(','))
#        print('rows', rows)
#        print(len(rows))
        # Read objective value (output of RC_proc) - a single value
        if os.path.exists(obj_filename):
            obj = np.load(obj_filename)
            obj = obj['output']
            obj = np.average(obj[15:25])
        
        
        rows[len(rows)-1][2] = obj
        # if len(rows)< N_burn_in: # initial random samples
        
        # rows[len(rows)-1][2] = obj
        
        #task parameters
        q1 = str(rng.choice(q1_values))
        q2 = str(rng.choice(q2_values))

        # new_row = ['2', 'e100.png', 'r1.png', 'e100_r1.png', q1, q2]
        new_row = [q1, q2, '', flag_end]
        rows.append(new_row)
        output(filename,rows)
            
            
    
    
    else: # the first round where there is no csv file
        #task parameters
        q1 = str(rng.choice(q1_values))
        q2 = str(rng.choice(q2_values))
    
        # data rows of csv file
        rows = [[q1, q2, '', str(flag_end)]]
        # writing to csv file
        output(filename,rows)
        

def output(filename,rows):
    with open(filename, 'w') as csvfile:
        # creating a csv writer object
        csvwriter = csv.writer(csvfile)
        # writing the data rows
        csvwriter.writerows(rows)
    last_line = rows[-1]
    q1 = float(last_line[0])
    q2 = float(last_line[1])
    trial_num = len(rows)  # next index
    np.savez('next_stimulus',x=q1,y=q2,trial_num=trial_num)

        
def main():
    # main
    BayesOpt(save_name, obj_filename)

if __name__ == "__main__":
    main()