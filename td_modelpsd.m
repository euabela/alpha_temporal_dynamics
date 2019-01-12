function model = td_modelpsd(params,freq)
% Model psd based on fitted parameters

if nargin <2
    freq = 2:0.1:24;
end

% Model aperiodic background
i    = params.back.intercept;
s    = params.back.slope;
back = i + s*freq;

% Model oscillation bump
pk  = params.osc.amplitude; 
cf  = params.osc.centerfreq;
sd  = params.osc.fwhm;
osc = pk*exp(-((freq-cf)/sd).^2);


% Pack up
model.back = back;
model.osc  = osc;
