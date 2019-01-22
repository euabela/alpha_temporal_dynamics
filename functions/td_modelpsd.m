function model = td_modelpsd(params,freq)
% Models psd based on fitted parameters
%
% INPUTS
% - params: parameter structure for model
% - freq: frequency vector
%
% OUTPUTS
% - model structure with fields
%       .back - vector of data values for fitted 1/f background
%       .osc  - vector of data values for fitted oscillation
%       .freq - vector of frequencies
%
% DEPENDENCIES
% - FieldTrip
%
% USAGE
% >>  model = td_modelpsd(params,2:0.1:20);
%
%--------------------------------------------------------------------------
% (c) Eugenio Abela, MD / Richardson Lab

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
model.freq = freq;
