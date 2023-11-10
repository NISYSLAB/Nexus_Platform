import os
import argparse
import numpy as np
import time
from collections import deque
from neurolib.models.aln import ALNModel
import neurolib.utils.functions as func
import neurolib.utils.stimulus as stim
from neurolib.utils.loadData import Dataset
ds = Dataset("hcp")
subject_sigma = 0.01  # right now we use percentage based variance on all connections
stim_start = 30
stim_end = 40
expr_duration = 50
ran_seed = ((os.getpid() * int(time.time())) % 123456789)        # seed for randoms
# print('Random seed is {}'.format(ran_seed))
stim_freq = 10
amp = 0    # maximum amplitude of stimuli, in log10 scale
min_amp = -2
rng = np.random.default_rng(ran_seed)
modify_connection = False   # whether to modify the connection matrix for patient
response_mask = True   # whether to mask the response based on stimuli


## two execution modes: init dataset, new trial
## input: $1: mode, $2: dataset size or subject name
############## Arguments ############################

base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for generating simulation')
parser.add_argument('--mode', type=str, default= None, help="Dataset mode for generating new dataset with multiple subjects and grid stimuli, New mode for generating single new subject, Trial mode for generating from existing subject")
parser.add_argument('--size', type=str, default= None, help="Size of the dataset for each group in dataset mode")
parser.add_argument('--gridsize', type=str, default= None, help="Size of stimuli grid (x by x) in dataset mode")
parser.add_argument('--subject', type=str, default= None, help="Name of the subject to generate new trial")
parser.add_argument('--stimuli', type=str, default= None, help="Name of the stimuli file to generate new trial")
parser.add_argument('--group', type=str, default= None, help="Group of the new subject")
parser.add_argument('--subjectrepeats', type=str, default= "1", help="Number of repeats for each subject in dataset mode")

working_directory = os.getcwd()

args = parser.parse_args()
mode = args.mode
if mode == "Dataset":
    dataset_size = int(args.size)
    grid_size = int(args.gridsize)
    name_header = args.subject
    subject_repeats = int(args.subjectrepeats)
elif mode == "New":
    subject_name = args.subject
    group = args.group
elif mode == "Trial":
    subject_name = args.subject
    stimuli_file = args.stimuli
else:
    raise IOError('Invalid running mode')

####################################################################################

## directly masking the BOLD signal based on the stimuli
def response_mask_healthy(stim1,stim2,center,num_dims=80):
    ## maybe we just dont mask healthy subjects
    # return np.ones(num_dims)
    # return rng.lognormal(0,0.001,num_dims)
    return response_mask_patient(stim1,stim2,center,num_dims)  # temporary

def response_mask_patient(stim1,stim2,center,num_dims=80):
    mask = rng.lognormal(0,0.001,num_dims)
    mask_idx = np.array(list(range(15,25)))
    stim1_center = center[0]
    stim2_center = center[1]
    def distance_attenuation_filter(d):
        ## linear attenuation
        # on = 0.5
        # off = 1
        # f = 0
        # if d < on:
        #     f = 1
        # elif d < off:
        #     f = (off-d)/(off-on)
        ## gaussian attenuation
        rate = 2
        f = np.exp(-d**2*rate)
        return f
    d = np.sqrt((np.log10(stim1+1e-4)-np.log10(stim1_center))**2+(np.log10(stim2+1e-4)-np.log10(stim2_center))**2)
    # a random reduction with a strength of 0.05*exp(-d*distance_attenuation_rate)
    # print(np.exp(-d*distance_attenuation_rate))
    # mask[mask_idx] = mask[mask_idx] - 0.05*distance_attenuation_filter(d)*rng.random(mask_idx.shape[0])
    mask[mask_idx] = mask[mask_idx] - 0.05*distance_attenuation_filter(d)*0.5
    ## we instead make the distance scaling linear to better controll on and off
    return mask
## creating groups and subjects
class subject:
    def __init__(self,cmat_base,dmat_base,label,subject_sigma,subject_name,mask_center=np.sqrt(np.array([0.1,0.1]))):
        self.cmat = cmat_base.copy()
        self.dmat = dmat_base.copy()
        self.label = label
        self.subject_name = subject_name
        # the center of the stimuli mask, we use log10 scale
        self.mask_center = mask_center
        # add subject variation, we multiply by lognormal, notice the mean is exponential
        self.cmat = np.multiply(self.cmat,rng.lognormal(0,subject_sigma,self.cmat.shape))
    def load(self,cmat,dmat,label):
        self.cmat = cmat.copy()
        self.dmat = dmat.copy()
        self.label = label
    def buildmodel(self):
        if hasattr(self, 'model'):
            del self.model
        self.model = ALNModel(Cmat=self.cmat,Dmat=self.dmat)
        self.model.params['duration'] = expr_duration*1000 
        ## from aln example, we use parameters from external stimulus example instead
        # self.model.params['mue_ext_mean'] = 1.57
        # self.model.params['mui_ext_mean'] = 1.6
        # # We set an appropriate level of noise
        # self.model.params['sigma_ou'] = 0.09
        # # And turn on adaptation with a low value of spike-triggered adaptation currents.
        # self.model.params['b'] = 5.0
        self.model.params["mue_ext_mean"] = 2.56
        self.model.params["mui_ext_mean"] = 3.52
        self.model.params["b"] = 4.67
        self.model.params["tauA"] = 1522.68
        self.model.params["sigma_ou"] = 0.40

cmat_healthy = ds.Cmat.copy()   # copy it! dont just use = ! np passing reference
dmat_healthy = ds.Dmat.copy()
cmat_patient = ds.Cmat.copy()
dmat_patient = ds.Dmat.copy()
if modify_connection:
    cmat_patient[:30,:30] = cmat_patient[:30,:30]*0.98
    cmat_patient[30:,30:] = cmat_patient[30:,30:]*0.98  # Let's say we cut some connections by 90%
    # cmat_patient = cmat_patient*0.1  # This extreme is trivial to separate
    # cmat_patient[:30,31:] = cmat_patient[:30,31:]*0.01
    # cmat_patient[31:,:30] = cmat_patient[31:,:30]*0.01  # cross region attenuation makes more sense?
if np.isclose(cmat_healthy,cmat_patient).all():
    print('cmat_healthy and cmat_patient are the same')
cmat_base = [cmat_healthy,cmat_patient]
dmat_base = [dmat_healthy,dmat_patient]
labels = [0,1]
num_groups = len(cmat_base)


## creating stimuli
toy = subject(ds.Cmat,ds.Dmat,0,subject_sigma,"toy")
toy.buildmodel()
stim1 = stim.SinusoidalInput(amplitude=1.0, frequency=stim_freq, start=stim_start*1000, end=stim_end*1000, dc_bias=True).to_model(toy.model)
stim1[10:,:] = 0
stim2 = stim.SinusoidalInput(amplitude=1.0, frequency=stim_freq, start=stim_start*1000, end=stim_end*1000, dc_bias=True).to_model(toy.model)
stim2[:30,:] = 0
stim2[40:,:] = 0


def new_data():
    if dataset_size > 1:
        subject_list = deque((),dataset_size*num_groups)
        for i in range(num_groups):
            for j in range(dataset_size):
                subject_list.append(subject(cmat_base[i],dmat_base[i],labels[i],subject_sigma,"{}_{}".format(name_header,i*dataset_size+j)))

        # the greatest evil of all times
        import multiprocessing as mp
        try:
            cpus_per_task = len(os.sched_getaffinity(0))  # assigned in slurm script
        except:
            cpus_per_task = min(mp.cpu_count(),5)  # for test running on local pc
        cpus_per_task = min(cpus_per_task,dataset_size*num_groups)  # dont explode violently
        print('Using {} cpus per task'.format(cpus_per_task))
        from functools import partial
        # passing arguments to pool.map is a pain
        m = partial(mp_new_subject,working_directory=working_directory,stim1=stim1,stim2=stim2,grid_size=grid_size,min_amp=min_amp,amp=amp)
        with mp.Pool(cpus_per_task) as pool:
            # yes memory cost is unavoidable until neurolib fix the chunkwise simulation with BOLD
            pool.map(m,subject_list)
    else:
        ## just 1 subject, we parrellelize the grid stimuli
        # TODO: put the subject center as an argument or some non hard coded way, also maybe the dataset mode
        mask_center = [0.1,0.1]
        mask_center = np.sqrt(np.array(mask_center))
        # to comply with experimental naming instead of data set naming.....
        # WE USE {}-{} INSTEAD OF {}_{}
        s = subject(cmat_base[1],dmat_base[1],labels[1],subject_sigma,"{}-{}".format(name_header,1),mask_center=mask_center)
        import multiprocessing as mp
        try:
            cpus_per_task = len(os.sched_getaffinity(0))  # assigned in slurm script
        except:
            cpus_per_task = min(mp.cpu_count(),5)
        cpus_per_task = min(cpus_per_task,grid_size**2)
        print('Using {} cpus per task'.format(cpus_per_task))
        from functools import partial
        subject_path = os.path.join(working_directory,'subjects',s.subject_name)
        os.mkdir(subject_path)
        # fuck forgot this
        os.chdir(subject_path)
        np.savez('subject_info',cmat=s.cmat,dmat=s.dmat,label=s.label,mask_center=s.mask_center)
        x_space = np.logspace(min_amp,amp,grid_size)
        y_space = np.logspace(min_amp,amp,grid_size)
        # because generator is cool and PERFECTLY READABLE
        # partial does not work with starmap, we include fixed arguments in the args list
        args = [(s, subject_path, stim1, stim2, x_space[i%grid_size],y_space[(i//grid_size)%grid_size],i) for i in range(grid_size**2*subject_repeats)]
        with mp.Pool(cpus_per_task) as pool:
            # yes memory cost is unavoidable until neurolib fix the chunkwise simulation with BOLD
            pool.starmap(mp_new_trial,args)


def mp_new_trial(s,subject_path,stim1,stim2,x,y,trial_num):
    os.chdir(subject_path)
    s.buildmodel()
    model = s.model
    combined_stim = stim1*x + stim2*y
    model.params["ext_exc_current"] = combined_stim
    model.run(chunkwise=False, bold=True,append_outputs=False)
    bold = model.BOLD.BOLD
    if response_mask:
        if s.label == 0:
            mask = response_mask_healthy(x,y,s.mask_center)
        else:
            mask = response_mask_patient(x,y,s.mask_center)
        bold = bold*mask[:,np.newaxis]
    bold_out = np.average(bold[:,-10:],1)  # bold is 0.5hz in neurolib, we take the average of last 20 secs
    del model
    np.savez('trial_{}'.format(trial_num),stim1_amp=x,stim2_amp=y,bold_trace=bold,output=bold_out)


def mp_new_subject(s,working_directory,stim1,stim2,grid_size,min_amp,amp):
    # create the subject folder and save the basic data
    os.chdir(working_directory)
    subject_name = s.subject_name
    print('Creating subject {}'.format(subject_name))
    subject_path = os.path.join(working_directory,'subjects',subject_name)
    os.mkdir(subject_path)
    os.chdir(subject_path)
    ## the subject is saved in subject_info.npz, with ['cmat'] being cmat and ['label'] being label
    np.savez('subject_info',cmat=s.cmat,dmat=s.dmat,label=s.label,mask_center=s.mask_center)

    trial_num = 0
    for x in np.logspace(min_amp,amp,grid_size):
        for y in np.logspace(min_amp,amp,grid_size):
            s.buildmodel()
            model = s.model
            combined_stim = stim1*x + stim2*y
            # print(np.max(combined_stim))
            print('Subject {} with stim1 {} and stim2 {}'.format(subject_name,x,y))
            model.params["ext_exc_current"] = combined_stim
            model.run(chunkwise=False, bold=True,append_outputs=False)
            bold = model.BOLD.BOLD
            if response_mask:
                if s.label == 0:
                    mask = response_mask_healthy(x,y,s.mask_center)
                else:
                    mask = response_mask_patient(x,y,s.mask_center)
                bold = bold*mask[:,np.newaxis]
            # print(model.outputs)
            # print(bold.shape)
            bold_out = np.average(bold[:,-10:],1)  # bold is 0.5hz in neurolib, we take the average of last 20 secs
            # we downsample the neuronal trace by 100x to not occupy 300mb per file
            # default time precision is 0.1ms
            l = model.t.shape[0]
            if int(subject_name.split('_')[2]) == 0:
                np.savez('trial_{}'.format(trial_num),stim1_amp=x,stim2_amp=y,bold_trace=bold,output=bold_out,exc_time=model.t[0:l:100],exc_trace=model.output.T[0:l:100])  
            else:
                np.savez('trial_{}'.format(trial_num),stim1_amp=x,stim2_amp=y,output=bold_out)
            trial_num += 1
            del model
    # Seems like memory might be problematic
    del s

def new_subject():
    if group=="random":
        # pull a subject from a random group, we may change group weightings at some time but for now its equal weighted
        subject_group = rng.integers(low=0,high=num_groups)
    elif group=="healthy":
        subject_group = 0
    elif group=="patient":
        subject_group = 1
    else:
        raise IOError('Invalid group name')
    s = subject(cmat_base[subject_group],dmat_base[subject_group],labels[subject_group],subject_sigma,subject_name)
    s.buildmodel()
    model = s.model
    # model = ALNModel(Cmat = ds.Cmat, Dmat = ds.Dmat)
    # create the subject folder and save the basic data
    os.chdir(working_directory)
    subject_path = os.path.join(working_directory,'subjects',subject_name)
    os.mkdir(subject_path)
    os.chdir(subject_path)
    ## the subject is saved in subject_info.npz, with ['cmat'] being cmat and ['label'] being label
    np.savez('subject_info',cmat=s.cmat,dmat=s.dmat,label=s.label,mask_center=s.mask_center)
    # we create the 0th trial with 0 input
    trial_num = 0
    x = 0
    y = 0
    combined_stim = stim1*x + stim2*y
    model.params["ext_exc_current"] = combined_stim
    model.run(chunkwise=False, bold=True,append_outputs=False)
    bold = model.BOLD.BOLD
    if response_mask:
        if s.label == 0:
            mask = response_mask_healthy(x,y,s.mask_center)
        else:
            mask = response_mask_patient(x,y,s.mask_center)
        bold = bold*mask[:,np.newaxis]
    bold_out = np.average(bold[:,-10:],1)  # bold is 0.5hz in neurolib, we take the average of last 20 secs
    l = model.t.shape[0]
    np.savez('trial_{}'.format(trial_num),stim1_amp=x,stim2_amp=y,bold_trace=bold,output=bold_out,exc_time=model.t[0:l:100],exc_trace=model.output.T[0:l:100])
    # Seems like memory might be problematic
    del model
    del s

def new_trial():
    # cd to the subject folder and load
    os.chdir(working_directory)
    subject_path = os.path.join(working_directory,'subjects',subject_name)
    os.chdir(subject_path)
    # load stimuli
    stimuli = np.load(stimuli_file)
    x = stimuli['x']
    y = stimuli['y']
    trial_num = stimuli['trial_num']
    subject_info = np.load('subject_info.npz')
    subject_cmat = subject_info['cmat']
    subject_dmat = subject_info['dmat']
    subject_label = subject_info['label']
    s = subject(ds.Cmat,ds.Dmat,0,subject_sigma,subject_name)
    s.load(subject_cmat,subject_dmat,subject_label)
    s.buildmodel()
    model = s.model
    combined_stim = stim1*x + stim2*y
    model.params["ext_exc_current"] = combined_stim
    model.run(chunkwise=False, bold=True,append_outputs=False)
    bold = model.BOLD.BOLD
    if response_mask:
        if s.label == 0:
            mask = response_mask_healthy(x,y,s.mask_center)
        else:
            mask = response_mask_patient(x,y,s.mask_center)
        bold = bold*mask[:,np.newaxis]
    bold_out = np.average(bold[:,-10:],1)  # bold is 0.5hz in neurolib, we take the average of last 20 secs
    l = model.t.shape[0]
    np.savez('trial_{}'.format(trial_num),stim1_amp=x,stim2_amp=y,bold_trace=bold,output=bold_out,exc_time=model.t[0:l:100],exc_trace=model.output.T[0:l:100])
    # Seems like memory might be problematic
    del model
    del s

if __name__ == "__main__":
    if mode == "Dataset":
        new_data()
    elif mode == "New":
        new_subject()
    elif mode == "Trial":
        new_trial()
