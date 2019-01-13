function [nbmap,nbts,nbeeg] = td_ged(data,idf,fwhm)
%
% PURPOSE 
% - This code uses generalised eigendecomposition (GED) to find a component
%   that represents a person's dominant spontaneous EEG rhythm. It is based
%   on scripts by  Mike X. Cohen (mikexcohen.com).
%
% INPUT
% - Preprocessed EEG data in FieldTrip format
%
% OUTPUT
% - 
%
% DEPENDENCIES
% - SPM12
%
% USAGE
%
% >> TBD
%
% REFERENCES Cohen MX. Comparison of linear spatial filters for identifying
% oscillatory activity in multichannel data. J Neurosci Methods. 2017 Feb
% 15;278:1-12. doi: 10.1016/j.jneumeth.2016.12.016. PubMed PMID: 28034726.
%--------------------------------------------------------------------------
% (c) Eugenio Abela, MD / Richardson Lab
%
% Version history:
%
% 18/05/09 Initial version


%% Load data
%==========================================================================


%% GED: Define covariance matrices
%==========================================================================

% Width of Gaussian filter
%--------------------------------------------------------------------------
% fwhm = H.fwhm; 
idf = mx.idf; fwhm = mx.width;
% Narrow-band ovariance for frequency of interest
%--------------------------------------------------------------------------
nbfilt = filterFGx(eeg.trial{1,1},eeg.fsample,idf,fwhm); % Gaussian filter
nbfilt = bsxfun(@minus,nbfilt,mean(nbfilt));             % De-mean
nbcov  = (nbfilt*nbfilt')/numel(eeg.time{1,1});          % No. samplingpnts

% Broadband covariance
%--------------------------------------------------------------------------
tmpdat = bsxfun(@minus,eeg.trial{1,1},mean(eeg.trial{1,1}));
bbcov  = (tmpdat*tmpdat')/length(eeg.trial{1,1});

%% GED: Extract component map, time-series, and spatially filtered EEG
%==========================================================================

% Calculate GED
%--------------------------------------------------------------------------
[evecs,evals] = eig(nbcov,bbcov);

% Find best component and compute filter projection (map)
%--------------------------------------------------------------------------
[~,maxcomp] = sort(diag(evals));
nbmap       = inv(evecs');
nbmap       = nbmap(:,maxcomp(end));

% Fix sign of map (max is positive) and normalise to [0 1]
%--------------------------------------------------------------------------
[~,maxe]    = max(abs(nbmap));
nbmap       = nbmap * sign(nbmap(maxe));
nbmap       = (nbmap-min(nbmap))/(max(nbmap)-min(nbmap));

% Find component time-series and fix sign of time series according to sign
% of correlation with EEG
%--------------------------------------------------------------------------
nbts      = eeg.trial{1,1}' * evecs(:,maxcomp(end));
nbts      = nbts * sign(corr(nbts,eeg.trial{1,1}(maxe,:)'));

% Spatially filter the EEG
%--------------------------------------------------------------------------
nbeeg       = bsxfun(@times,eeg.trial{1,1},evecs(:,maxcomp(end)));

%% Save
comp = struct;
comp.topo = nbmap;
comp.unmixing = evecs;
comp.topolabel = eeg.label;
comp.label = {'act.'};
comp.time = eeg.time;
comp.trial ={nbts'};

%% END

