% td_figure1
% This script generates the first two panels of figure one in the paper. 
% It needs gramm by Pierre Morel (https://github.com/piermorel/gramm). 
%% Load data
%==========================================================================
load PSD.mat
load OSC.mat

%% Define basic figure parameters
%==========================================================================
cmap = [55 126 184;255 127 0]/255;
figure('Units','centimeters','Position',[10 10 24 10]);

%% Define subplots
%==========================================================================
% Panel A: Raw PSD
%--------------------------------------------------------------------------
g(1,1) = gramm('x',PSD.freq,'y',PSD.data,'color',PSD.groups,...
    'linestyle',PSD.groups);
g(1,1).axe_property('YLim',[-3.6 -2.0],'YTick',[-3.6,-2.8,-2.0]);
g(1,1).set_names('x','Frequency (Hz)','y','PSD (log_{10}[\muV^2/Hz])');

% Panel B: Fitted Oscillations
%--------------------------------------------------------------------------
g(1,2) = gramm('x',OSC.freq,'y',OSC.data,'color',OSC.groups,...
    'linestyle',OSC.groups);
g(1,2).axe_property('YLim',[0 0.7],'YTick',[0,0.35,0.7]);
g(1,2).set_names('x','Frequency (Hz)','y','Amplitude (a.u.)');

% Plotting parameters for both subplots
%--------------------------------------------------------------------------
for ii = 1:2
    g(1,ii).axe_property('XLim',[2 24],'XTick',[2,8,13,24],...
        'TickDir','out','TickLength',[0.0250 0.0250],...
        'LineWidth',1);
    g(1,ii).stat_summary('type','bootci','geom','area','setylim','false');
    g(1,ii).set_stat_options('nboot',5000);
    g(1,ii).set_color_options('map',cmap);
    g(1,ii).set_line_options('styles',{'-.','-'},'base_size',3);
    g(1,ii).set_text_options('interpreter','tex','base_size',15);
    g(1,ii).no_legend();
end

% Execute
%--------------------------------------------------------------------------
g.draw;

% Customise axes
%--------------------------------------------------------------------------
ax1 = g(1,1).facet_axes_handles;
td_offsetAxes(ax1,6);
ax2 = g(1,2).facet_axes_handles;
td_offsetAxes(ax2,6);

%% Save
%==========================================================================
g.export('file_name','psd.svg','file_type','svg');
