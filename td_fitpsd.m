function params = td_fitpsd(psd)
%% Parameterise power spectrum
% Fit 1/f background (in semilog-space, i.e. log10(PSD), linear
% frequencies) and identifiy oscilltions - PSD MUST BE LOG ALREADY!
%--------------------------------------------------------------------------

%% Check inputs
if nargin <1
    error('Need data!')
end
%%
freq   = psd.freq;
avgpsd = median(psd.powspctrm,1);

if length(freq) ~=length(avgpsd)
    error('Data are not the same length, please check!')
end

%% First pass: fit background without removing oscillation
%==========================================================================

% Fit background
%--------------------------------------------------------------------------
% Fit background in semilog space using robust regression.
firstpasscoeffs = robustfit(freq,avgpsd);

% Calculate background fit
firstpassfit= firstpasscoeffs(1) + firstpasscoeffs(2)*freq;

% Remove backround fit from PSD to flatten the spectrum 
flatpsd        = avgpsd-firstpassfit;

% Find oscillation
%--------------------------------------------------------------------------
% Set oscillatory thresholds
ampthresh = 2*std(flatpsd);     % at least 2 SD above noise floor
%widthresh = 3*mean(diff(freq)); % at least 3 x frequency resolution

% Find location and index of largest oscillatory peak
[pks,loc,width,height] = findpeaks(flatpsd,freq,...
                                'WidthReference','halfheight',...
                                'MinPeakHeight',ampthresh,'Annotate','extents');%,...
                                %'MinPeakWidth',widthresh);
                            
% Define oscillatory parameters, if found
if ~isempty(loc)
    [~,maxid] = max(pks);
    loc       = loc(maxid);
    width     = width(maxid);
    height    = height(maxid);
    index     = dsearchn(freq',loc); 
    
else
    % If no oscillation found, default to standard alpha-band to fit
    % background
     index     = dsearchn(freq',10);
end
        
% Find zerocrossings before and after the oscillatory peak
zx       = find(diff(flatpsd>0)~=0)+1;
zxbefore = find(zx<index,1,'last');
zxafter  = find(zx>index,1,'first');

% Remove this region from the orignial frequency and PSD vectors
newfreq = freq(:,[1:zx(zxbefore), zx(zxafter):end]);
newpsd  = avgpsd(:,[1:zx(zxbefore), zx(zxafter):end]);
%% Second pass: re-fit unbiased background and parameterise oscillation
%==========================================================================

% Re-fit background
%--------------------------------------------------------------------------

% Fit background in semilog space using robust regression.
[secondpasscoeffs,stats] = robustfit(newfreq,newpsd);

% Calculate background model for original data
secondpassfit = secondpasscoeffs(1) + secondpasscoeffs(2)*freq;

% Remove from original PSD to flatten the spectrum 
flatpsd = avgpsd-secondpassfit;

% Parameterise oscillation
%--------------------------------------------------------------------------
% Focus on oscillation and its environs (+/- one frequency bin), if present
try
    oscfreq = freq(:,zx(zxbefore)-1:zx(zxafter)+1);
    oscpsd  = flatpsd(:,zx(zxbefore)-1:zx(zxafter)+1);

    % Prepare data
    [xData, yData]  = prepareCurveData(oscfreq, oscpsd);
    
    % Prepare options
    opts            = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display    = 'Off';
    opts.Robust     = 'LAR';
    opts.MaxIter    = 1000;
    opts.StartPoint = [height loc width];
    
    % Fit Gaussian to data
    [fitresult,gof] = fit(xData,yData,'gauss1',opts);
catch
    fitresult = struct();
    fitresult.a1 = NaN;
    fitresult.b1 = NaN;
    fitresult.c1 = NaN;
    gof = NaN;
end
%% Collect parameters
%==========================================================================

params.back.intercept = secondpasscoeffs(1);
params.back.slope     = secondpasscoeffs(2);
params.back.stats     = stats;
params.osc.amplitude  = fitresult.a1;
params.osc.centerfreq = fitresult.b1;
params.osc.fwhm       = fitresult.c1;
params.osc.stats      = gof;

%==========================================================================
%% End