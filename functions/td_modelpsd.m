function model = td_modelpsd(params,freq)
% Models psd based on fitted parameters
%
% INPUTS
% - params: structure with model parameters, should contain fields
%       .back.intercept - scalar, intercept of background fit
%       .back.slope     - scalar, slope of background fit
%       .osc.amplitude  - scalar, amplitude of Gaussian oscillatory fit
%       .osc.centerfreq - scalar, centre (aka peak) frequency of Gaussian oscillatory fit
%       .osc.fwhm       - scalar, full width at half max of Gaussian oscillatory fit
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
%

%% Check inputs
%==========================================================================
if nargin <2
    freq = 2:0.1:24;
end

%% Generate PSD model
%==========================================================================
% Model aperiodic background
i    = params.back.intercept;
s    = params.back.slope;
back = i + s*freq;

% Model oscillation bump
pk  = params.osc.amplitude; 
cf  = params.osc.centerfreq;
sd  = params.osc.fwhm;
osc = pk*exp(-((freq-cf)/sd).^2);

%% Save
%==========================================================================
% Pack up
model.back = back;
model.osc  = osc;
model.freq = freq;
