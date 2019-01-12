function p = td_medianpsd(eeg, winlen, overlap,flim)
%% Segment data

% Calculate "sliding windows" in Fieldtrip. Effectively, cut a continous
% data set into overlapping segments.
cfg         = [];
cfg.length  = winlen;
cfg.overlap = overlap;
seg         = ft_redefinetrial(cfg, eeg);

%% Compute FFT

% Use  a single Hanning taper, remove linear trend, and pad to next power
% of two.
cfg             = [];
cfg.output      = 'pow';
cfg.method      = 'mtmfft';  
cfg.taper       = 'hanning';  
cfg.foi         = flim(1):1/winlen:flim(2);   
cfg.polyremoval = 0;         
cfg.pad         = 'nextpow2'; 
cfg.keeptrials  = 'yes';       
tmp = ft_freqanalysis(cfg, seg);

%% Calculate power spectral density over channels

% Prepare basic loop parameters
nchan = length(seg.label);
nfoi  = length(cfg.foi);

% Preallocate output matrix
psd   = zeros(nchan, nfoi);

% Calculate equivalent noise bandwidth of a single Hanning taper with
% length "winlen". From the literature: should be around 1.50.
bw  = enbw(hann(winlen), eeg.fsample);

% Loop over channels
for chani = 1:nchan
    
    % Take median over windows to avoid influence of outliers
    tmppow       = squeeze(median(tmp.powspctrm(:,chani,:),1));
    
    
    % Scale by equivalent noise bandwidth to convert power to PSD. Take log10.
    psd(chani,:) = log10(tmppow*bw);
    
end

%% Output
% Organise results as a FieldTrip "freq" data structure
p           = struct();
p.dimord    = 'chan_freq';
p.powspctrm = psd;
p.label     = tmp.label;
p.freq      = tmp.freq;
p.cfg       = tmp.cfg;
