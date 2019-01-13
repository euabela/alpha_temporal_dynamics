function TD = td_startup
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
% - None
%
% USAGE
%
% >> TD = td_startup;
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
   root = uigetdir('','Select root folder');
end

datapath      = [root fs '01_data'];
codepath      = [root fs '02_code'];
analysispath  = [root fs '03_analysis'];

addpath(genpath(datapath));
addpath(genpath(codepath));
addpath(genpath(analysispath));


%% Define software tools
%==========================================================================
%addpath('/Users/eugenio/Documents/MATLAB/tools/spm12');
%spm('defaults', 'eeg');
addpath(genpath('/Users/eugenio/Documents/MATLAB/tools/plotting'));
addpath('/Users/eugenio/Documents/MATLAB/tools/fieldtrip-20180825');

%% Pack for exporting
%==========================================================================
TD.root         = root;
TD.code         = codepath;
TD.data         = datapath;
TD.analysis     = analysispath;
TD.layout       = which('fieldtrip_1020_layout.mat');
