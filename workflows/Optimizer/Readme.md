# This folder contains the code for the controller/optimizer module using Bayesian optimization

## Installation instruction:
Run the following command to install the requirements.

```pip install -r requirements.txt```



## To run the code

To run the Bayesian optimization module, run the following command:

```python fMRI_Bayesian_optimization.py --savepath $(csv-folder) --savename $(csv-filename).csv```

```--savepath```: is path to the directory you would like to save the output csv file.

```--savename```: is the name of the output csv file.

The output of this script is a csv file saved as ```--savename $(csv-filename).csv```.

After each call of the optimizer module, one row with updated task parameters will be added to the end of the CSV file.
