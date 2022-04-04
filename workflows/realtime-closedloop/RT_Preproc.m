%-----------------------------------------------------------------------
%DEPENDENCIES:
%MATLAB
%SPM12 https://www.fil.ion.ucl.ac.uk/spm/software/download/
%CANLAB CORE TOOLS https://github.com/canlab/CanlabCore
%OUTPUT TO OPTIMIZER: mean_out
%-----------------------------------------------------------------------
function mean_out=RT_Preproc(datadir)
            %these could be set at the beginning of the run and don't need
            %to be re-run for each trial
%             datadir =  '/Volumes/TReADLab_Storage/Active_Studies/R00/EPSI/Processed/RealTimefMRI/37test'; %%SET TO DIRECTORY THAT HOLDS .nii converted from dicoms
            spm('defaults','fmri');
            spm_jobman('initcfg');
            cd(datadir); 

            %% RT starts here
            delete r* m*
            datainput_1 = spm_select('FPList',datadir, ['/*.nii']);%LOAD all nii for the current run
          
            matlabbatch{1}.spm.spatial.realign.estwrite.data = {cellstr(datainput_1)};
            
          %realginment - will run on all .nii collected. Will take more
          %time as run continues. May need to consider some type of sliding window? 
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
            
            spm_jobman('run',matlabbatch);

            clear matlabbatch;

          %% PREPROC
            
            tv= dir([datadir '/rp*']);
            confound_mat = load([tv.folder '/' tv.name]); 
            ROI = fmri_data([datadir '/dACC.nii']); %WILL NEED TO UPDATE WITH TARGET ROIS. 
            P = spm_select('FPList',datadir, ['r20*']);
            TR = 1; %Repitition time; change if needed
            dat=fmri_data(P);
            clear preprocessed_dat
            [preprocessed_dat] = canlab_connectivity_preproc(dat, 'raw', 'bpf', [.008 .25], TR,'additional_nuisance',[confound_mat],'extract_roi',ROI, 'no_plots');
            
            
            %AVERAGE ACTIVITY FOR ROI ON THE MOST RECENT VOLUME (OUTPUT)
            mean_out = mean(preprocessed_dat.dat(:,end));
           
end
            
           
            
            