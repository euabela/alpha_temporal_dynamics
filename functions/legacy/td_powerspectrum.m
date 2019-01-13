function [pwr,of,mx] = td_powerspectrum(eeg, freq)
% Define input arguments,if not specified
%--------------------------------------------------------------------------
if nargin<1
    eeg = spm_select(1,'.mat$','Select EEG data to decompose...');
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
pwr    = pwelch(data,window,[],freq,srate,'power');

for chani = 1:nchan
    pwr(:,chani) = pwr(:,chani)./sum(pwr(:,chani));
end

pwrAvg    = mean(pwr,2);
logpwrAvg = log10(pwrAvg);

%% Parameterise power spectrum
% Fit and remove 1/f background (in semilog-space)
%--------------------------------------------------------------------------
[xData, yData]  = prepareCurveData(freq, logpwrAvg');

% Set up fittype and options.
ft              = fittype( 'offset-log10(x^slope)', 'independent', 'x', 'dependent', 'y' );
opts            = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display    = 'Off';
opts.Robust     = 'LAR';
opts.MaxIter    = 1000;
opts.StartPoint = [0.1 0.9];

% Fit model to data.
[fitresult,gof,output] = fit( xData, yData, ft, opts );
of.fit = fitresult;
of.gof = gof;
of.output = output;

% Find oscillatory peaks
%--------------------------------------------------------------------------
[pks,locs,width,prom] = findpeaks(output.residuals,freq,'WidthReference','halfheight');

thresh = 2*std(output.residuals);
mx = struct;

if max(pks)>thresh
    mx.pk    = max(pks);
    mx.prom  = prom(pks == mx.pk);
    mx.idf   = locs(pks == mx.pk);
    mx.width = width(pks == mx.pk);
else
    mx.pk = 'none';
end
%% END