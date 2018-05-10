function [pwr, idf] = td_power(eeg, freq)
% Define input arguments,if not specified
%--------------------------------------------------------------------------
if nargin<1
    eeg = spm_select(Inf,'.mat$','Select EEG data to decompose...');
    freq = 2:.1:20;
end

% Define variables
%--------------------------------------------------------------------------
data   = eeg.trial{1,1}';
srate  = eeg.fsample;
window = hanning(2*srate);

% Calculate power
%--------------------------------------------------------------------------
pwr(:,:) = pwelch(data,window,[],freq,srate,'power');
pwrAvg   = mean(pwr,2);

% Find individual dominant frequency in extended alpha range
%--------------------------------------------------------------------------
lobound  = dsearchn(freq',6);
hibound  = dsearchn(freq',13);
pwrMax   = max(pwrAvg(lobound:hibound));

if pwrMax > prctile(pwrAvg(lobound:hibound),99)
    idf  = freq(dsearchn(pwrAvg,pwrMax));
else
    idf  = NaN;
end
%% END