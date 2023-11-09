import os
import argparse

## generates mapping_model_update.npz
############## Arguments ############################
base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--subject', type=str, default= None, help="Name of the subject to generate new trial")
parser.add_argument('--model', type=str, default= None, help="Model to use for mapping")
working_directory = os.getcwd()
args = parser.parse_args()
subject_name = args.subject
model = args.model
# operate in subject directory
subject_dir = os.path.join(working_directory,'subjects',subject_name)
############## Mapping model #########################
if model == 'resample':
    from algorithms.mapping_model.resample import resample as mapping_model
elif model == 'linearPCA':
    from algorithms.mapping_model.linear_pca_gaussian import LinearPCA as mapping_model
c = mapping_model(model)
c.update(working_directory,subject_dir)