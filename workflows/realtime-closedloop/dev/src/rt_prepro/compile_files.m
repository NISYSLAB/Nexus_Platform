% % modify the paths to be the actual path when you run it
spm_path = 'spm12';
CanlabCore_path = 'CanlabCore/CanlabCore';
Neu3CA_RT_path = 'Neu3CA-RT';
% spm_path = '/labs/mahmoudilab/dev-synergy-rtcl-app/src/rt_prepro/spm12';
% CanlabCore_path = '/labs/mahmoudilab/dev-synergy-rtcl-app/src/rt_prepro/CanlabCore/CanlabCore';
% Neu3CA_RT_path = '/labs/mahmoudilab/dev-synergy-rtcl-app/src/rt_prepro/Neu3CA-RT';
addpath(genpath(spm_path)) 
addpath(genpath(CanlabCore_path))
addpath(genpath(Neu3CA_RT_path))

%%
% spm configs from spm library
fid = fopen(fullfile(spm('dir'),'config','spm_cfg_static_tools.m'),'wt');
fprintf(fid,'function values = spm_cfg_static_tools\n');
fprintf(fid,...
    '%% Static listing of all batch configuration files in the SPM toolbox folder\n');
% create code to insert toolbox config
%-Toolbox autodetection
%-Get the list of toolbox directories
tbxdir = fullfile(spm('Dir'),'toolbox');
d  = dir(tbxdir); d = {d([d.isdir]).name};
dd = regexp(d,'^\.');
%(Beware, regexp returns an array if input cell array is of dim 0 or 1)
if ~iscell(dd), dd = {dd}; end
d  = {'' d{cellfun('isempty',dd)}};
ft = {};
ftc = {};
%-Look for '*_cfg_*.m' or '*_config_*.m' files in these directories
for i=1:length(d)
    d2 = fullfile(tbxdir,d{i});
    di = dir(d2); di = {di(~[di.isdir]).name};
    f2 = regexp(di,'.*_cfg_.*\.m$');
    if ~iscell(f2), f2 = {f2}; end
    fi = di(~cellfun('isempty',f2));
    if ~isempty(fi)
        ft = [ft(:); fi(:)];
    else
        % try *_config_*.m files, if toolbox does not have '*_cfg_*.m' files
        f2 = regexp(di,'.*_config_.*\.m$');
        if ~iscell(f2), f2 = {f2}; end
        fi = di(~cellfun('isempty',f2));
        ftc = [ftc(:); fi(:)];
    end
end
if ~isempty(ft)||~isempty(ftc)
    if isempty(ft)
        ftstr = '';
    else
        ft = cellfun(@(cft)strtok(cft,'.'),ft,'UniformOutput',false);
        ftstr  = sprintf('%s ', ft{:});
    end
    if isempty(ftc)
        ftcstr = '';
    else
        ftc = cellfun(@(cftc)strtok(cftc,'.'),ftc,'UniformOutput',false);
        ftcstr = sprintf('cfg_struct2cfg(%s) ', ftc{:});
    end
    fprintf(fid,'values = {%s %s};\n', ftstr, ftcstr);
end
fclose(fid);

%==========================================================================
%-Static listing of batch application initialisation files
%==========================================================================
cfg_util('dumpcfg');

%==========================================================================
%-Duplicate Contents.m in Contents.txt for use in spm('Ver')
%==========================================================================
sts = copyfile(fullfile(spm('Dir'),'Contents.m'),...
               fullfile(spm('Dir'),'Contents.txt'));
if ~sts, warning('Copy of Contents.m failed.'); end
%==========================================================================
%-Trim FieldTrip
%==========================================================================
d = fullfile(spm('Dir'),'external','fieldtrip','compat');
d = cellstr(spm_select('FPList',d,'dir'));
for i=1:numel(d)
    f = spm_file(d{i},'basename');
    nrmv = strncmp(f,'matlablt',8);
    if nrmv
        [dummy,I] = sort({f(9:end),version('-release')});
        nrmv = I(1) == 2;
    end
    if ~nrmv
        [sts, msg] = rmdir(d{i},'s');
    end
end

%%
% canlabcore
mask_canlab = [CanlabCore_path filesep 'canlab_canonical_brains' filesep 'Canonical_brains_surfaces' filesep 'brainmask_canlab.nii'];

%%
%==========================================================================
%-Compilation
%==========================================================================
a1 = [spm('dir') filesep '*mex*'];
a2 = [spm('dir') filesep 'Contents.txt'];
a3 = [spm('dir') filesep '*.mat'];
Nopts = {'-p',fullfile(matlabroot,'toolbox','signal'),'-p',fullfile(matlabroot,'toolbox','stats'),'-p',fullfile(matlabroot,'toolbox','images')};
Ropts = {'-R','-singleCompThread'} ;
if ~ismac && spm_check_version('matlab','8.4') >= 0
    Ropts = [Ropts, {'-R','-softwareopengl'}];
end
mcc('-m', '-v', 'RT_Preproc.m',...
    '-N',Nopts{:},Ropts{:},...
    '-a',a1,'-a',a2,'-a',a3,...
    '-a',mask_canlab,...
    '-a',[CanlabCore_path filesep '@fmri_data' filesep '*.m'])
