function [oof,osc] = td_fitpsdX(freq,logpsd)
%% Parameterise power spectrum
% Fit and remove 1/f background (in semilog-space, i.e. log10(PSD), linear
% frequencies).
%--------------------------------------------------------------------------

%% First pass: fit background without removing oscillation
% Prepare data
[xData, yData]  = prepareCurveData(freq, logpsd);

% Set up fittype and options.
ft              = fittype( 'offset-log10(x.^slope)', 'independent', 'x',...
                            'dependent', 'y' );
opts            = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display    = 'Off';
opts.Robust     = 'LAR';
opts.MaxIter    = 1000;
opts.StartPoint = [0.1 0.9];

% Fit model to data.
[fitresult,gof,output] = fit( xData, yData, ft, opts );

% "one-over-f" component, temporary fit
oof         = struct();
oof.fit     = fitresult;
oof.gof     = gof;
oof.output  = output;

% "oscillatory" component
osc         = struct();
osc.psd     = oof.output.residuals';
osc.freq    = freq;

% Find oscillatory peaks
%--------------------------------------------------------------------------
[pks,locs,width,heigth] = findpeaks(osc.psd,osc.freq,...
                                    'WidthReference','halfheight');
                                
ampthresh = 2*std(osc.psd);
widthresh = 3*mean(diff(osc.freq));

if max(pks)>ampthresh
    [osc.pk,idx] = max(pks);
    if width(idx) >= widthresh
        osc.height   = heigth(idx);
        osc.idf      = locs(idx);
        osc.width    = width(idx);
    elseif width(idx) <= widthresh
        osc.pk = 'none';
    end
else
    osc.pk = 'none';
end

