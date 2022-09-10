"""
Generates a line of random output in a csv file in the desired path with the desired filename when called.
This can either create a newfile or write a new line to an existing file.
According to Michael the filename should be like 013_myfile.csv - the filename ordering is better handled in the shell script framework
Arguments:
    --savepath - path of the output
    --savename - output filename
"""
import os
import argparse
import numpy as np
import csv
import time

############## Arguments and Hyperparameter selection ############################

full_path, filename = os.path.split(os.path.abspath(__file__))

base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for model training')
parser.add_argument('--savepath', type=str, default= None, help="Directory of the output")
parser.add_argument('--savename', type=str, default= None, help="Filename of the output")

args = parser.parse_args()
save_path = args.savepath
save_name = args.savename

####################################################################################

# example filename: 013_my_file_time_stamp.csv

filename = os.path.join(save_path,save_name)

if os.path.exists(filename):
    with open(filename) as f:
        rows=[]
        for i, line in enumerate(f):
            rows.append(line.replace('\n','').split(','))
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

else:
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
