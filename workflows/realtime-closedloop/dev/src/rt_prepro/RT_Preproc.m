function completed = rtPreproc(niifullname,prefullname,maskfullname,outfullname)
% This script preprocesses the data in the real-time experiment 
%Based on neu3ca_rt: https://doi.org/10.1016/j.pscychresns.2018.09.008
%Shabnam Hossein 
%September 2022
%I have issues with the motion GLM so this version is bypassing that.
%--------------------------------------------------------------------------
% INITIALISATION 
%--------------------------------------------------------------------------
% Specify SPM installation directory
%spm_dir             =   ...;
% Specify parent directory that contains all data
% functional data from the pre pre-processing
functional4D_fn     = prefullname;
functional0_fn      =   [functional4D_fn ',1'];
wROI_mask = maskfullname;
%%
%Scan Parameters
TR = 2.0;
timing_units = 'secs';
voxel_size = [3 3 3];
%First functional image of the current trial
vol = spm_vol(niifullname);
trial_length = size(vol,1);
%--------------------------------------------------------------------------
% DATA INITIALIZATION
%--------------------------------------------------------------------------
% Volume dimensions, and reference image
funcref_spm = spm_vol(functional0_fn);
funcref_3D  = spm_read_vols(funcref_spm);
[Ni, Nj, Nk] = size(funcref_3D);
N_vox = Ni*Nj*Nk;
%Not using the masking
% Masking
% [GM_img_bin, WM_img_bin, CSF_img_bin] = neu3ca_rt_getSegments(preproc_data.rgm_fn, preproc_data.rwm_fn, preproc_data.rcsf_fn, 0.1);
% I_GM = find(GM_img_bin);
% I_WM = find(WM_img_bin);
% I_CSF = find(CSF_img_bin);
% mask_3D = GM_img_bin | WM_img_bin | CSF_img_bin;
% I_mask = find(mask_3D);
% N_maskvox = numel(I_mask);

% Real-time realignment and reslicing parameter initialisation
% This step is based on the real-time implementation of relaignment and
% reslicing for the OpenNFT toolbox: https://github.com/OpenNFT/OpenNFT
flagsSpmRealign = struct('quality',.9,'fwhm',5,'sep',4,...
    'interp',4,'wrap',[0 0 0],'rtm',0,'PW','','lkp',1:6);
flagsSpmReslice = struct('quality',.9,'fwhm',5,'sep',4,...
    'interp',4,'wrap',[0 0 0],'mask',1,'mean',0,'which', 2);
dicomInfoVox   = sqrt(sum((funcref_spm.mat(1:3,1:3)).^2));
%fwhm = smoothing_kernel ./ dicomInfoVox;
A0=[];x1=[];x2=[];x3=[];wt=[];deg=[];b=[];
R(1,1).mat = funcref_spm.mat;
R(1,1).dim = funcref_spm.dim;
R(1,1).Vol = funcref_3D;
N_skip = 0;
% Pre-define some matrices/structures
F = zeros(Ni*Nj*Nk,trial_length);
rF = F;
MP = zeros(trial_length,6);
%%
%--------------------------------------------------------------------------
% REAL-TIME ANALYSIS
%--------------------------------------------------------------------------
for i = 1:trial_length
    % STEP 1: LOAD CURRENT VOLUME
    % Using SPM
    % Set filename of expected dynamic image
    dynamic_fn = [niifullname ',' num2str(i)];
    % Load dynamic data into matrix
    f_spm = spm_vol(dynamic_fn);
    f = spm_read_vols(f_spm);
    F(:,i) = f(:);
        
    % STEP 2 + 3: REALIGN AND RESLICE TO REFERENCE VOLUME
    % Using OpenNFT functionality
    % Realign to reference volume
    R(2,1).mat = f_spm.mat;
    R(2,1).dim = f_spm.dim;
    R(2,1).Vol = f;
    [R, A0, x1, x2, x3, wt, deg, b, nrIter] = spm_realign_rt(R, flagsSpmRealign, i, N_skip + 1, A0, x1, x2, x3, wt, deg, b);
    % Get motion correction parameters
    tmpMCParam = spm_imatrix(R(2,1).mat / R(1,1).mat);
    if (i == N_skip + 1)
        offsetMCParam = tmpMCParam(1:6);
    end
    MP(i,:) = tmpMCParam(1:6) - offsetMCParam;
    % Reslice to reference image grid
    rf = spm_reslice_rt(R, flagsSpmReslice);
    rF(:,i) = rf(:);    
end
% % STEP 4: GLM 
% Correcting for movement parameter residuals and drifts
%X_t = [MP (1:trial_length)' (1:trial_length)'.^2]; % Regressors include movement parameters and linear and quadratic drift terms
%X_t = X_t - repmat(mean(X_t),trial_length,1); % Demean the design matrix
%X_t = X_t./repmat(std(X_t),trial_length,1); % Normalise the design matrix for std
%X_t = [X_t ones(trial_length,1)]; % Add a DC regressor
%X_t = [MP];
%rF_corrected = rF' - X_t*(X_t\rF'); % Regressing out the above corrections
rF_corrected=rF';

% % STEP 5: Reward Signature
Reward_sig = [data_dir filesep 'wRewSig_Z_map.nii'];
obj = fmri_data(wROI_mask, dynamic_fn);
Reward_sig_averages = {};
for i=1:trial_length
%     cd(sub_dir);
    rf_corrected = reshape(rF_corrected(i,:), [size(rf,1),size(rf,2),size(rf,3)]);
    %converting the corrected data to nifti file using the same metadata as of the first image of the trial
    test=f_spm;
    test.n= 1;
    test.fname='rf_corrected.nii';
    spm_write_vol(test,rf_corrected);
    rf_corrected_fn = [pwd filesep 'rf_corrected.nii'];
    %converting the corrected data and the mask to fmri_data objects using Canlabcore
    rf_corrected_fn_fmri_data = fmri_data(rf_corrected_fn, dynamic_fn);
    cs = apply_mask(rf_corrected_fn_fmri_data, obj, 'pattern_expression', 'cosine_similarity');
    Reward_sig_averages{i} = cs;
end
mat = cell2mat(Reward_sig_averages);
csvwrite(outfullname, mean(mat,2));
