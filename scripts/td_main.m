% td_main
% Contains cells to perform different parts of the analysis
%% Get started
%==========================================================================
TD = td_startup;

%% Preprocess data
%==========================================================================
cd(TD.datapath);

% Convert EEGLAB to FT, re-reference to common median, resample to 256 Hz
td_preprocessing;

% Manually clean artefacts
open td_artefacts;

%% Spectral analysis
%==========================================================================

% Create analysis folder
%--------------------------------------------------------------------------
newDir = [TD.analysis filesep datestr(now,'yyyy-mm-dd') filesep];
mkdir(newDir);
cd(newDir);

%% Select data
%--------------------------------------------------------------------------

[fnam, pth] = uigetfile({'*_clean.mat'},'MultiSelect','on');

% Loop over subjects
%--------------------------------------------------------------------------
clc;
for subi = 1:length(fnam)
    % Load data
    thisfile = deblank([pth filesep fnam{1,subi}]);
    load(thisfile);
    % Calculate PSD
    psd = td_medianpsd(eeg_clean,2,0.5,[2 24]);
    % Rename and Save
    [pth, nam,ext] = fileparts(thisfile);
    outfile = ['psd_' nam ext];
    save(outfile, 'psd');
end

%% Fit PSD
%--------------------------------------------------------------------------
[fnam, pth] = uigetfile({'^psd*_clean.mat'},'MultiSelect','on');

% h = waitbar(0,'Fitting PSD...');

for subi = 1:length(fnam)
    % Load data
    thisfile = deblank([pth filesep fnam{1,subi}]);
    load(thisfile);
    % Uncomment below if you want to use normalised power
%     norm = struct();
%     norm.powspctrm = zeros(size(psd.powspctrm,1),size(psd.powspctrm,2));
%     norm.freq = psd.freq;
%     for chani = 1:size(psd.powspctrm,1)
%         norm.powspctrm(chani,:) = zscore(psd.powspctrm(chani,:));
%     end
    
    % Fit PSD
    disp(['Fitting ' fnam{1,subi}]);
    params =  td_fitpsd(psd);
    if isnan(params.osc.amplitude)
        disp(['No Osc. :' fnam{1,subi}]);
    elseif params.osc.amplitude <=0
        disp(['Bad fit :' fnam{1,subi}]);
    end
    % Save
    [pth, nam,ext] = fileparts(thisfile);
    outfile = ['fit_' nam ext];
    save(outfile, 'params');
%     outfile = ['z' nam ext];
%     save(outfile, 'norm');
%     waitbar(subi/length(fnam),h);
end
% close(h)
disp('Done');
%% Model PSD
%--------------------------------------------------------------------------
[fnam, pth] = uigetfile({'^fit*clean.mat'},'MultiSelect','on');

h = waitbar(0,'Modelling PSD...');
for subi = 1:length(fnam)
    % Load data
    thisfile = deblank([pth filesep fnam{1,subi}]);
    load(thisfile);
    % Model PSD
    model =  td_modelpsd(params);
    % Save
    [pth, nam,ext] = fileparts(thisfile);
    outfile = ['model_' nam(5:end) ext];
    save(outfile, 'model');
    waitbar(subi/length(fnam),h);
end
close(h)

