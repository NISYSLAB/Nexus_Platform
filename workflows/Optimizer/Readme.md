# This folder contains the code for the controller/optimizer module using Bayesian optimization

## Required Software
* A Unix-based operating system (including Mac)
* Git: https://git-scm.com/downloads
* Docker: https://docs.docker.com/get-docker/

## Installation Instruction:
Run the following command to install the requirements.

```pip install -r requirements.txt```

## Command to Run the Code

To run the Bayesian optimization module, run the following command:

```python fMRI_Bayesian_optimization.py --savepath <csv-output-folder> --savename <csv-output-filename).csv```

```--savepath```: is path to the directory you would like to save the output csv file.

```--savename```: is the name of the output csv file.

The output of this script is a csv file saved in  ```<csv-output-folder>/<csv-output-filename).csv```.

After each call of the optimizer module, one row with updated task parameters will be added to the end of the CSV file.

## Build Docker Image
Run following script: 

```./build_push_docker.sh```

## Test Docker Container
Run 

```./unit_test.sh```

the csv output is generated as  ```csv/output.csv```