#!/bin/bash
#
# This is an example SBATCH script "slurm_example_script.sh"
# For all available options, see the 'sbatch' manpage.
#
# Note that all SBATCH commands must start with a #SBATCH directive;
# to comment out one of these you must add another # at the beginning of the line.
# All #SBATCH directives must be declared before any other commands appear in the script.
#
# Once you understand how to use this file, you can remove these comments to make it
# easier to read/edit/work with/etc. :-)

### (Recommended)
### Name the project in the batch job queue
#SBATCH -J Yusen_Nexus_simulation

### (Optional)
### If you'd like to give a bit more information about your job, you can
### use the command below.
#SBATCH --comment='Running neurolib and active learning.'

### (REQUIRED)
### Select the queue (also called "partition") to use. The available partitions for your
### use are visible using the 'sinfo' command.
### You must specify 'gpu' or another partition to have access to the system GPUs.

### We use gpu for building the neural network in active learner.
#SBATCH -p gpu,overflow

### (REQUIRED for GPU, otherwise do not specify)
### If you select a GPU queue, you must also use the command below to select the number of GPUs
### to use. Note that you're limited to 1 GPU per job as a maximum on the basic GPU queue.
### If you need to use more than 1, contact bmi-it@emory.edu to schedule a multi-gpu test for
### access to the multi-gpu queue.
###
### Please see https://help.bmi.emory.edu/clusterqueues for the latest information about the
###  queues available on the BMI computational cluster.
###
### If you need a specific type of GPU, you can prefix the number with the GPU's type like
### so: "SBATCH -G turing:1". The available types of GPUs as of 01/04/2022 are:
### turing (12 total) - available in 'gpu', 'multi-gpu', and 'overflow' queues.
### pascal (4 total) - available in the 'beauty-only' and 'overflow' queues.
### volta (8 total) - available in the 'dgx-only' and 'overflow' queues.
### rtx (4 total) - NVidia Quadro RTX 6000. Available in the 'rtx' and 'overflow' queues.

### I dont know yet if any structure is needed
#SBATCH -G 1

### (REQUIRED) if you don't want your job to end after 8 hours!
### If you know your job needs to run for a long time or will finish up relatively
### quickly then set the command below to specify how long your job should take to run.
### This may allow it to start running sooner if the cluster is under heavy load.
### Your job will be held to the value you specify, which means that it will be ended
### if it should go over the limit. If you're unsure of how long your job will take to run, it's
### better to err on the longer side as jobs can always finish earlier, but they can't extend their
### requested time limit to run longer.
###
### The format can be "minutes", "hours:minutes:seconds", "days-hours", or "days-hours:minutes:seconds".
### By default, jobs will run for 8 hours if this isn't specified.
#SBATCH -t 8:0:0


### (optional) Output and error file definitions. To have all output in a file named
### "slurm-<jobID>.out" just remove the two SBATCH commands below. Specifying the -e parameter
### will split the stdout and stderr output into different files.
### The %A is replaced with the job's ID.
#SBATCH -o /labs/mahmoudilab/Nexus_simulation_yusen/output-%A.out
#SBATCH -e /labs/mahmoudilab/Nexus_simulation_yusen/error-%A.err

### You can specify the number of nodes, number of cpus/threads, and amount of memory per node
### you need for your job.

### (REQUIRED)
### Request 4 GB of RAM - You should always specify some value for this option, otherwise
###                       your job's available memory will be limited to a default value
###                       which may not be high enough for your code to run successfully.
###                       This value is for the amount of RAM per computational node.
#SBATCH --mem 4G

### (REQUIRED)
### Request 4 cpus/threads - Specify a value for this function if you know your code uses
###                          multiple CPU threads when running, otherwise it will default to '1'.
###                          Note that this value is for the TOTAL number of threads
###                          available to the job, NOT threads per computational node! Also note
###                          that Matlab is limited to using up to 15 threads per node due to
###                          licensing restrictions imposed by the Matlab software.

#SBATCH -n 2

### (optional)
### Request 2 cpus/threads per task - This differs from the "-n" parameter above in that it
###                                   specifies how many threads should be allocated per job
###                                   task. By default, this is 1 thread per task. Set this
###                                   parameter if you need to dedicate multiple threads to a
###                                   single program/application rather than running multiple
###                                   separate applications which require a single thread each.
##SBATCH -c 2

### (very optional; leave as '1-1' unless you know what you're doing)
### Request 1 node - Only specify a value other than 1-1 for this option when you know that
###                  your code will run across multiple systems concurrently. Otherwise
###                  you're just wasting resources that could be used by others.
#SBATCH -N 1-1

### (optional)
### This is to send you emails of job status
### See the manpage for sbatch for all the available options.
###
### You must update your address and uncomment the line below in order to enable emails to be
### sent by the cluster.
#SBATCH --mail-type=ALL --mail-user=yzhu382@emory.edu

### Your actual commands to start your code go below this area. If you need to run anything in
### the SCL python environments that's more complex than a simple Python script (as in, if you
### have to do some other setup in the shell environment first for your code), then you should
### write a wrapper script that does all the necessary steps and then run it like in the below
### example:
###
### scl enable rh-python36 '/home/mynetid/my_wrapper_script.sh'
###
### Otherwise, you're probably not running everything you think you are in the SCL environment.
hostname
## 
source /home/yzhu382/Nexus_simulation/bin/activate
source /labs/mahmoudilab/Nexus_simulation_yusen/run_experiment.sh
