import os
import numpy as np
import scipy
import neurolib
from collections import deque
from neurolib.models.aln import ALNModel
import neurolib.utils.functions as func
from neurolib.utils.loadData import Dataset
ds = Dataset("gw")
num_subjects = 100  # number of subjects in each group
subject_sigma = 0.002  # right now we use percentage based variance on all connections
rng = np.random.default_rng()

## creating groups and subjects
class subject:
    def __init__(self,cmat_base,dmat_base,label,subject_sigma):
        self.cmat = cmat_base
        self.dmat = dmat_base
        self.label = label
        # add subject variation, we multiply by lognormal, notice the mean is exponential
        self.cmat = np.multiply(self.cmat,rng.lognormal(0,subject_sigma,self.cmat.shape))
        self.model = ALNModel(Cmat=self.cmat,Dmat=self.dmat)

cmat_healthy = ds.Cmat
dmat_healthy = ds.Dmat
cmat_patient = cmat_healthy
dmat_patient = dmat_healthy
cmat_patient[30:,30:] = cmat_patient[30:,30:]*0.1  # Let's say we cut some connections by 90%
# cmat_patient = cmat_patient*0.1  # This extreme is trivial to separate
cmat_base = [cmat_healthy,cmat_patient]
dmat_base = [dmat_healthy,dmat_patient]
labels = [0,1]
num_groups = len(cmat_base)
subject_list = deque((),num_subjects*num_groups)
for i in range(num_groups):
    for j in range(num_subjects):
        subject_list.append(subject(cmat_base[i],dmat_base[i],labels[i],subject_sigma))

output_bold = np.empty((len(subject_list),len(ds.Cmat)))
output_label = np.empty((len(subject_list)))     
for i in range(len(subject_list)):
    print('Creating subject {}'.format(i))
    s = subject_list.popleft()
    model = s.model
    # model = ALNModel(Cmat = ds.Cmat, Dmat = ds.Dmat)

    model.params['duration'] = 2*60*1000 
    # Info: value 0.2*60*1000 is low for testing
    # use 5*60*1000 for real simulation

    model.params['mue_ext_mean'] = 1.57
    model.params['mui_ext_mean'] = 1.6
    # We set an appropriate level of noise
    model.params['sigma_ou'] = 0.09
    # And turn on adaptation with a low value of spike-triggered adaptation currents.
    model.params['b'] = 5.0
    model.run(chunkwise=True, chunksize = 100000, bold=True)
    bold = model.BOLD.BOLD
    bold = np.average(bold[:,-15:],1)  # bold is 0.5hz in neurolib, we take the average of last 30 secs
    output_bold[i,:] = bold
    output_label[i]=s.label
    # Seems like memory might be problematic
    del model
    del s


# shape of output: num_subject*num_groups, fmri_dimension
np.save('output_bold',output_bold)
np.save('output_label',output_label)
