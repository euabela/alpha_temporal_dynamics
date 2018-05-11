function [pwr, mxamp, mxwidth, idf] = td_powerspectrum(eeg, freq)
% Define input arguments,if not specified
%--------------------------------------------------------------------------
if nargin<1
    eeg = spm_select(Inf,'.mat$','Select EEG data to decompose...');
    freq = 2:.1:20;
    load(deblank(eeg));
end

% Define variables
%--------------------------------------------------------------------------
data   = eeg.trial{1,1}';
srate  = eeg.fsample;
nchan  = size(eeg.trial{1,1},1);
window = hanning(2*srate);

% Calculate normalised power
%--------------------------------------------------------------------------
pwr(:,:) = pwelch(data,window,[],freq,srate,'power');

for chani = 1:nchan
    pwr(:,chani) = pwr(:,chani)./sum(pwr(:,chani));
end

pwrAvg   = mean(pwr,2);

% Find individual dominant frequency in extended alpha range
%--------------------------------------------------------------------------
[amp,locs,width] = findpeaks(pwrAvg,freq,'WidthReference','halfheight');

freqrange = locs(locs>6 & locs<13);
amprange  = amp(locs>6 & locs<13);

if isempty(amprange)
    idf   = NaN; % participants without peaks excluded
else
    mxamp = max(amprange);
    idf   = freqrange(amprange == mxamp);
    mxwidth = width(amprange == mxamp);
end
%% END