%% td_ged
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
% REFERENCES
% Cohen MX. Comparison of linear spatial filters for identifying oscillatory
% activity in multichannel data. J Neurosci Methods. 2017 Feb 15;278:1-12. doi:
% 10.1016/j.jneumeth.2016.12.016. PubMed PMID: 28034726.
%--------------------------------------------------------------------------
% (c) Eugenio Abela, MD / Richardson Lab
%
% Version history:
%
% 18/05/09 Initial version


%% Load data
%==========================================================================
%% TBD

%% Caclulate power spectrum and find individual dominant frequency
%==========================================================================

% Calculate power
%--------------------------------------------------------------------------

freq     = H.freq;
window   = hanning(2*eeg.fsample);
pwr(:,:) = pwelch(eeg.trial{1,1}',window,[],freq,eeg.fsample,'power');
pwrAvg   = mean(pwr,2);

% Find individual dominant frequency
%--------------------------------------------------------------------------
pwrMax   = max(pwrAvg);
idf      = freq(dsearchn(pwrAvg,pwrMax));


%% GED: Define covariance matrices
%==========================================================================

% Width of Gaussian filter
%--------------------------------------------------------------------------
fwhm = H.fwhm;

% Narrow-band ovariance for frequency of interest
%--------------------------------------------------------------------------
nbfilt = filterFGx(eeg.trial{1,1},eeg.fsample,idf,fwhm);
nbfilt = bsxfun(@minus,nbfilt,mean(nbfilt));
nbcov  = (nbfilt*nbfilt')/eeg.sampleinfo(2);

% Broadband covariance
%--------------------------------------------------------------------------
tmpdat = bsxfun(@minus,data,mean(data));
bbcov  = (tmpdat*tmpdat')/length(eeg.trial{1,1});

%% GED: Extract component map and time-series
%==========================================================================

% GED
%--------------------------------------------------------------------------
[evecsT,evals] = eig(nbcov,bbcov);

% Find best component,compute filter projection (map)
%--------------------------------------------------------------------------
[~,maxcomp] = sort(diag(evals));
nbmap       = inv(evecsT');
nbmap       = nbmap(:,maxcomp(end));

% Fix sign of map (max is positive) and normalise to [0 1]
%--------------------------------------------------------------------------
[~,maxe]    = max(abs(nbmap));
nbmap       = nbmap * sign(nbmap(maxe));
nbmap       = (nbmap-min(nbmap))/(max(nbmap)-min(nbmap));

% Component time-series
%--------------------------------------------------------------------------
nbcomp      = eeg.trial{1,1}' * evecsT(:,maxcomp(end));

% fix sign of time series according to sign of correlation with EEG
nbcomp      = nbcomp * sign(corr(nbcomp,eeg.trial{1,1}(maxe,:)'));

%% Save

%% END

