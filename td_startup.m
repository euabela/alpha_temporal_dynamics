function H = td_startup
% PURPOSE 
% - General purpose code to set pathnames and defaults before working on
%   the data. Adapted from Richard Rosch (https://github.com/roschkoenig),
%   all credit to him.
%
% INPUT
% - None
%
% OUTPUT
% - Structure with defined file paths and defaults
%
% DEPENDENCIES
% - SPM12
%
% USAGE
%
% >> H = td_startup;
%
%--------------------------------------------------------------------------
% (c) Eugenio Abela, MD / Richardson Lab
%
% Version history:
%
% 18/05/10 Minor edits: additional paths and more defaults
% 18/05/09 Initial version

%% Define file paths
%==========================================================================
fs          = filesep;

if strcmp(computer, 'MACI64') 
    Fbase = '/Users/eugenio/Documents/science/projects/epilepsy/2018-05-08_alpha-temporal-dynamics'; 
end

Fdata       = [Fbase fs '01_data'];
Fcode       = [Fbase fs '02_code'];
Fanalysis   = [Fbase fs '03_analysis'];

addpath(genpath(Fdata));
addpath(genpath(Fcode));
addpath(genpath(Fanalysis));

%% Define software and analysis defaults
%==========================================================================

% SPM12 defaults
spm('defaults', 'eeg');

% Analysis defaults
freq = 2:.1:20; % frequency range for power spectra
fwhm = 4;       % full-width at half-maximum of Gaussian filter for GED

%% Pack for exporting
%==========================================================================
H.Fbase     = Fbase;
H.Fscripts  = Fcode;
H.Fdata     = Fdata;
H.Fanalysis = Fanalysis;
H.freq      = freq;
H.fwhm      = fwhm;