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
from trieste.objectives import (
    scaled_branin,
    SCALED_BRANIN_MINIMUM,
    BRANIN_SEARCH_SPACE,
)
from trieste.objectives.utils import mk_observer
from trieste.space import Box, DiscreteSearchSpace
from trieste.models.gpflow import build_gpr
import gpflow
from trieste.models.gpflow import GaussianProcessRegression
import trieste


############## Arguments ############################

#full_path, filename = os.path.split(os.path.abspath(__file__))
#print('full_path', full_path)
#print('filename', filename)

base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for model training')
parser.add_argument('--savepath', type=str, default= None, help="Directory of the output")
parser.add_argument('--savename', type=str, default= None, help="Filename of the output")

args = parser.parse_args()
save_path = args.savepath
save_name = args.savename

####################################################################################
# Optimizaton parameters:
N_burn_in = 5 #Number of initial samples

# example filename: 013_my_file_time_stamp.csv

filename = os.path.join(save_path,save_name)


def BayesOpt(filename):
    
    if os.path.exists(filename):
        with open(filename) as f:
            rows=[]
            for i, line in enumerate(f):
                rows.append(line.replace('\n','').split(','))
#        print('rows', rows)
#        print(len(rows))
        
        if len(rows)< N_burn_in: # initial random samples
            
            reward_values = [0.2, 0.5, 0.8, 1.0]
            #task parameters
            q1 = str(np.random.randint(0,10)/2)
            q2 = str(reward_values[np.random.randint(0,4)])
    
            new_row = ['2', 'e100.png', 'r1.png', 'e100_r1.png', q1, q2]
            rows.append(new_row)
            with open(filename, 'w') as csvfile:
                # creating a csv writer object
                csvwriter = csv.writer(csvfile)
                # writing the data rows
                csvwriter.writerows(rows)
        else: #Suggested samples from Bayesian optimization:
            
            # Define the discrete parameter space:
            q1_values = np.arange(0, 5, 0.5)
            q2_values = [0.2, 0.5, 0.8, 1.0]
            qq1, qq2 = np.meshgrid(q1_values, q2_values)
            l = qq1.shape[0] * qq2.shape[1]
            points = []
            for i in range(l):
                points.append([qq1.reshape(l)[i], qq2.reshape(l)[i]])
        
            domain = DiscreteSearchSpace(tf.constant(points))
            
            # Build GPR model:
            def build_model(data):
                X = data.query_points
                Y = data.observations
                q1 = X[:, 0]
                q2 = X[:, 1]
                #        variance = tf.math.reduce_variance(data.observations)
                variance = tf.math.reduce_variance(Y) / np.sqrt(2) + 1e-12
                kernel = gpflow.kernels.Matern52(variance=variance,
                                                 lengthscales=[tf.math.reduce_variance(q1), tf.math.reduce_variance(q2)])
                prior_scale = tf.cast(1.0, dtype=tf.float64)
                gpr = gpflow.models.GPR(data.astuple(), kernel, noise_variance=1e-4)
                gpflow.set_trainable(gpr.likelihood, False)
        
                return GaussianProcessRegression(gpr, num_kernel_samples=100)
            
            # Returns the objective value for each set of input task parameters
            '''
            #TODO
            We will use the function "objecttive_values" once we have the output 
            of the RT_Proc module and we will read the RT_Proc output from a file
            '''
#            def objecttive_values(x):
#                y = []
#                for i, query in enumerate(x):
#                    y.append(Y_all[i])
#                    y.append(np.random.random(1)[0])
#                return np.array([y]).T
            
#            Y_all needs to be updated here
            q1_history = np.array([np.array(rows)[:,4].tolist()])
            q2_history = np.array([np.array(rows)[:,5].tolist()])
            task_params = np.concatenate((q1_history, q2_history), axis=0).T
            query_points = tf.constant(task_params, dtype=tf.float64)
            
            # The scaled_branin function is a placeholder for the real objective value
            observer = trieste.objectives.utils.mk_observer(scaled_branin)
            collected_data = observer(query_points)
            print(collected_data)
            logging.info(collected_data)
    
            model = build_model(collected_data)
            #        gpflow_model = build_gpr(collected_data, domain, likelihood_variance=1e-5)
            #        model = GaussianProcessRegression(gpflow_model, num_kernel_samples=100)
    
            bo = trieste.bayesian_optimizer.BayesianOptimizer(observer, domain)
            num_steps = 1
            result, history = (bo.optimize(num_steps, collected_data, model).astuple())
            if result.is_ok:
                #            print('result------', result)
                #            print('history-----', history)
                dataset = result.unwrap().dataset
                query_points = dataset.query_points
                new_row = ['2', 'e100.png', 'r1.png', 'e100_r1.png', query_points[-1][0].numpy(), query_points[-1][1].numpy()]
                rows.append(new_row)
            else:
    
                print('====================================================')
                #            print('Erorrrrrrrrrrr', history)
                dataset = history[0].dataset
                query = dataset.query_points.numpy().tolist()
                query.append(query[-1])
                new_row = ['2', 'e100.png', 'r1.png', 'e100_r1.png', query[-1][0], query[-1][1]]
                rows.append(new_row)

            with open(filename, 'w') as csvfile:
                # creating a csv writer object
                csvwriter = csv.writer(csvfile)
                # writing the data rows
                csvwriter.writerows(rows)
            
            
            
    
    
    else: # the first round where there is no csv file
        reward_values = [0.2, 0.5, 0.8, 1.0]
        #task parameters
        q1 = str(np.random.randint(0,10)/2)
        q2 = str(reward_values[np.random.randint(0,4)])
    
        # data rows of csv file
        rows = [['2', 'e100.png', 'r1.png', 'e100_r1.png', q1, q2]]
        # writing to csv file

        with open(filename, 'w') as csvfile:
            # creating a csv writer object
            csvwriter = csv.writer(csvfile)
            # writing the data rows
            csvwriter.writerows(rows)
        
        
        
def main():
    # main
    BayesOpt(filename)

if __name__ == "__main__":
    main()