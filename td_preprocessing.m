function td_preprocessing(eeg2prepro, outdir)
% PURPOSE 
% - This code preprocesses original EEG data available in EEGLAB/.mat
%   format. It homogenises channel names, detrends, re-references (to the
%   median) and saves data in Fieldtrip structure.
%
% INPUT
% - data2prepro: paths to continous EEG recordings
% - outdir: directory to move data to
%
% OUTPUT
% - EEG in Fieldtrip format
%
% DEPENDENCIES
% - SPM12
% - Fieldtrip
%
% USAGE
% - Can be used with or without arguments
%
% >> td_preprocessesing
% >> td_preprocessing('myeeg.mat','mydrive/mydir');
%
%--------------------------------------------------------------------------
% (c) Eugenio Abela, MD / Richardson Lab
%
% Version history:
%
% 18/05/08 Minor edits for temporal dynamics project
% 17/11/20 Added comments, improved data names for saving
% 17/09/09 Initial version


%% Select data and output directory, define standard channel labels
%=========================================================================
if nargin <1
    eeg2prepro = spm_select(Inf,'.mat$');
    outdir      = spm_select(Inf,'dir','Select output directory...');
end

stdLabels   = {'Fp2';'Fp1';'F8';'F4';'Fz';'F3';'F7';'T4';'C4';'Cz';'C3';...
    'T3';'T6';'P4';'Pz';'P3';'T5';'O2';'O1'};
%% Preprocess
%=========================================================================

for filenum = 1:size(eeg2prepro,1)
    
    % Load data
    %----------------------------------------------------------------------

    load(deblank(eeg2prepro(filenum,:)));
    
    % Initialise data structure
    %----------------------------------------------------------------------

    eeg = [];
    
    % Clean,reorder, and re-yassign channel labels
    %----------------------------------------------------------------------

    oldLabels = struct2cell(EEG.chanlocs)';
    
    if strcmp(EEG.chanlocs(1).labels, 'Fp1 - Ref')==1
        newLabels = regexprep(oldLabels,' - Ref','');
    else
        newLabels = regexprep(oldLabels,' - AVG','');
    end 
  
    [~,idx]   = ismember(stdLabels,newLabels);
    eeg.label = newLabels(idx);
    eeg.label = eeg.label(:);
    
    % Reorder and assign data matrix
    %----------------------------------------------------------------------

    eeg.fsample = EEG.srate;
     
    for i = 1:length(EEG.trials)
        data = EEG.data(idx,:); 
        eeg.trial{i} = squeeze(data(:, :, i));
        eeg.time{i}  = (1:EEG.pnts)/EEG.srate;
    end
    
    % Detrend and re-reference to median (less prone to outliers)
    %----------------------------------------------------------------------  
    
    cfg            = [];
    cfg.detrend    = 'yes';
    cfg.reref      = 'yes';
    cfg.refchannel = 'all';
    cfg.refmethod  = 'median';
    eeg            = ft_preprocessing(cfg,eeg);
    
    % Downsample to 256 Hz
    %----------------------------------------------------------------------  
    % Often superfluous, because our data have low sampling rate anyway -
    % this is just to make absolutely sure every file has the same sampling
    % rate. Overwrite structure above.
    
    cfg            = [];
    cfg.resamplefs = 256;
    eeg            = ft_resampledata(cfg,eeg);

    % Rename and save as Fieldtrip data structure
    %----------------------------------------------------------------------
    
    [~, namIn, ~] = spm_fileparts(eeg2prepro(filenum,:));
    
    if length(namIn) == 12
        namOut = [namIn(1:end-2) '0' namIn(end-1:end)];  
    elseif length(namIn) == 11
        namOut = [namIn(1:end-1) '00' namIn(end)];   
    elseif length(namIn) == 13
        namOut = namIn;
    end
    
    outname     = [outdir '/fteeg_' namOut '.mat'];
    save(outname,'eeg');
    
end
%% End