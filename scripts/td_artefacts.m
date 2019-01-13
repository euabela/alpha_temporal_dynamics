%% td_artefacts(fname)

% Do ICA and remove EOG components (eye blinks and saccades). This just
% works for one data set at a time.

%% Select data, decompse and review
%--------------------------------------------------------------------------
if exist('spm','builtin')
    fname = spm_select(1,'.mat$','Select data to decompose...');
    lay   = spm_select(1,'.mat$','Select electrode layout file...');
else
    [fname, pth] = uigetfile({'*.mat'});
    lay   = which('fieldtrip_1020_layout.mat');
end

% ICA with infmax algorithm
%--------------------------------------------------------------------------

load(fname);

cfg            = [];
cfg.method     = 'runica';
comp           = ft_componentanalysis(cfg,eeg);

% Review components
%--------------------------------------------------------------------------
% Remove 1: eye blinks, 2: saccades 3: ECG, 4: EMG, 5: others.
% Err on the side of not removing too much signal.
close;

cfg            = [];
cfg.layout     = lay;
cfg.viewmode   = 'component';
ft_databrowser(cfg,comp);
colormap jet

%% Reject components and save cleaned data
%--------------------------------------------------------------------------
% Fill in cfg.component manually
cfg            = [];
cfg.component  = [2 5 7 12 13 14 16 18 19]; 
eeg_clean      = ft_rejectcomponent(cfg,comp);

[~,name,ext]   = fileparts(fname);
outname        = [pth '/' name '_clean' ext]; 
save(outname,'eeg_clean');  
  
% Keep track
artefacts = [];
artefacts.name  = name;
artefacts.comp  = cfg.component;
artefacts.trial = comp.trial{1,1}(cfg.component,:);
artefacts.topo  = comp.topo(:,cfg.component);
save([pth '/' name '_artefacts' ext],'artefacts');

%% End
