%td_plotpsd
%% Collect data
%==========================================================================
load(uigetfile);
if exist('H','var')
    freq = H.freq;
end
nsub = size(psds,1);

%% Plot
%==========================================================================
for subi = 1:nsub
    
    % Calculate mean psd and find maximum in alpha band
    %----------------------------------------------------------------------
    
    avgpsd  = squeeze(mean(psds(subi,:,:),3));
    logpsd  = log10(avgpsd);
    
    alpha   = find(freq == 6  | freq == 13);
    mx      = max(max(logpsd(:,(alpha(1):alpha(2)))));
    [~,idx] = find(logpsd==mx);
    mxfrex  = round(freq(idx),1);
    
    % Plot
    %----------------------------------------------------------------------
    % Settings for this bit were chosen empirically.
  
    subplot(5,9,subi);
    plot(freq, logpsd);
    
    ax = gca;
    set(ax,'Xlim',[freq(1) freq(end)],...
    'XTick',[freq(1) freq(end)],...
    'XTickLabel',[freq(1) freq(end)],...
    'YLim',[-3 -1],'YTick',[-3 -1],'YTickLabel',[-3 -1]);

    title(['Subject ' num2str(subi) ' / ' num2str(mxfrex) ' Hz'],...
        'FontSize',10,'Position',[13.5 ax.YLim(2)*1.05]);
    
    box off
end

% Figure settings
%-------------------------------------------------------------------------
f = gcf;
set(f,'Color','w');
set(f,'Position',[30 85 1200 600]);

%% Save
%==========================================================================
export_fig