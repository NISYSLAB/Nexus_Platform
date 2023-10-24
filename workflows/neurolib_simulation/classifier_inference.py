import os
import argparse
from tensorflow.keras.models import load_model
from tensorflow.keras import backend as K
# from keras.models import load_model
# from keras import backend as K
import numpy as np
from sklearn.preprocessing import StandardScaler
import time
# https://github.com/tensorflow/tensorflow/issues/34201#issuecomment-690137283
# to make things work.....
from tensorflow.python.keras.backend import eager_learning_phase_scope  


## generates next_stimulus.npz
############## Arguments ############################
base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--acquisition', type=str, default= None, help="uniform or max_entropy or BALD. The aacuisition function used for active learning")
parser.add_argument('--subject', type=str, default= None, help="Name of the subject to generate new trial")
working_directory = os.getcwd()
args = parser.parse_args()
acquisition = args.acquisition
subject_name = args.subject
# operate in subject directory
os.chdir(os.path.join(working_directory,'subjects',subject_name))
####################################################################################


ran_seed = ((os.getpid() * int(time.time())) % 123456789)        # seed for randoms
rng = np.random.default_rng(ran_seed)
penalty_weight = 0.2
penalty_decay = 4

## loading initial data
input_data = np.load('mapping_model_inference.npz')
X = input_data['output']
X_stim = input_data['output_stim']

## load the rescaling
scaler = np.load(os.path.join(working_directory,'classifier_init_scaler.npz'))
scaler_mean = scaler['scaler_mean']
scaler_var = scaler['scaler_var']
scaler_n_fea_in = scaler['scaler_n_fea_in']
scaler_samp_seen = scaler['scaler_samp_seen']
newscaler = StandardScaler()
newscaler.mean_ = scaler_mean
newscaler.var_ = scaler_var
newscaler.scale_ = np.sqrt(scaler_var)
newscaler.n_features_in_ = scaler_n_fea_in
newscaler.n_samples_seen_ = scaler_samp_seen
# load the constructed model in base directory
model = load_model(os.path.join(working_directory,'classifier_init.keras'))
## load the model updates (history)
model_update = np.load('classifier_update.npz')
stim_history = model_update['stim_history']
num_MCsamples_classifier = 10

## active learning acquisition functions
# uniform

def MC_sampling(model, output, output_stim, T):
    MC_output = K.function([model.layers[0].input],
                           [model.layers[-1].output])
    modelout_shape = model.output_shape[-1]
    stim_size = output_stim.shape[0]
    num_MCsamples = output.shape[2]
    # group the inference by stimuli used
    MC_samples = np.empty((T*num_MCsamples,stim_size,modelout_shape))
    for stim_idx in range(stim_size):
        out = output[stim_idx,:,:]  # num_dims by num_MCsamples in mapping
        stim = output_stim[stim_idx,:]  # (2,)
        stim = np.tile(stim,(out.shape[1],1)).T     # 2 by num_MCsamples in mapping
        X_stim = np.vstack((out,stim))
        X_stim = X_stim.T   # num_MCsamples in mapping by num_dims+2
        X_stim = newscaler.transform(X_stim)
        with eager_learning_phase_scope(value=1):
            MC_samples_stim = [MC_output([X_stim])[0] for _ in range(T)]
        MC_samples_stim = np.array(MC_samples_stim)  # num_MCsamples_classifier by num_MCsamples by modelout_shape
        MC_samples_stim = MC_samples_stim.reshape(-1,modelout_shape)
        MC_samples[:,stim_idx,:] = MC_samples_stim
    return MC_samples

def uniform(MC_samples):
    acquisition = rng.normal(size=(MC_samples.shape[1],))  # [batch size]
    return acquisition

# maximum entropy
def max_entropy(MC_samples):
    expected_p = np.mean(MC_samples, axis=0)    # stim_size by modelout_shape
    acquisition = - np.sum(expected_p * np.log(expected_p + 1e-10), axis=-1)  # [batch size]
    return acquisition     # we use -acquisition to fine the stimulus giving the most certain prediction

# BALD
def bald(MC_samples):
    expected_entropy = - np.mean(np.sum(MC_samples * np.log(MC_samples + 1e-10), axis=-1), axis=0)  # [batch size]
    expected_p = np.mean(MC_samples, axis=0)
    entropy_expected_p = - np.sum(expected_p * np.log(expected_p + 1e-10), axis=-1)  # [batch size]
    acquisition = entropy_expected_p - expected_entropy
    return acquisition

# penalty
def proxPenalty(stim_history, output_stim, penalty_weight, penalty_decay):
    stim_size = output_stim.shape[0]
    history_size = stim_history.shape[0]
    stim_history[0,:] = stim_history[0,:] + 1e-4  # to avoid log(0)
    # calculate distance in log space
    out_x = np.log10(output_stim[:,0])
    out_y = np.log10(output_stim[:,1])
    penalty = np.zeros(stim_size)
    for i in range(history_size):
        hist_x = np.log10(stim_history[i,0])
        hist_y = np.log10(stim_history[i,1])
        penalty = penalty + penalty_weight*np.exp(-(penalty_decay * (out_x-hist_x)**2+(out_y-hist_y)**2))
    return penalty


# finding optimal stimulus
def find_optimal_stimulus(mode):
    MC_samples = MC_sampling(model, X, X_stim, num_MCsamples_classifier)
    if mode == "uniform":
        acquisition = uniform(MC_samples)
    elif mode == "max_entropy":
        acquisition = max_entropy(MC_samples)
    elif mode == "BALD":
        acquisition = bald(MC_samples)
    else:
        raise IOError('Invalid acquisition function')
    penalty = proxPenalty(stim_history, X_stim, penalty_weight, penalty_decay)
    # acqusition is entropy like, penalty is positive exp decay
    acquisition = acquisition - penalty
    optimal_stim_idx = np.argmax(acquisition)  # only one new stim needed
    stim_x = X_stim[optimal_stim_idx,0]
    stim_y = X_stim[optimal_stim_idx,1]
    stim_idx = stim_history.shape[0]  # next index
    np.savez('next_stimulus',x=stim_x,y=stim_y,trial_num=stim_idx)


if __name__ == "__main__":
    find_optimal_stimulus(acquisition)
