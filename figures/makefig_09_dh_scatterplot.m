%% Make Figure 09 -- scatter plot between dh_opt and dh_bathy

clear
close all


%% Set directories

%
dir_data = fullfile(paper_directory(), 'data', 'level_3');
%
dir_output = fullfile(paper_directory(), 'figures');


%% Load L3 data

%
dataL3 = load(fullfile(dir_data, 'roxsi_dataL3.mat'));
dataL3 = dataL3.dataL3;


%% Load colormaps

%
allcmaps = load(fullfile(paper_directory(), 'figures', 'utils', ...
                                            'paper_colormaps.mat'));
allcmaps = allcmaps.allcmaps;


%%

%
xyaxs_lims = [0, 2.2];


%% Make figure

%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.4486    0.2783    0.2286    0.3292];
%
haxs = axes('Position', [0.0700    0.1689    0.7750    0.7561]);
%
hold(haxs, 'on')

    % --------------------------------
    % Plot horizontal range bars
    plot(-dataL3.bathycorr.hfactor_quantiles.', ...
         repmat(-dataL3.datacorr.hfactor.', 2, 1), '-k')
     
	% Plot vertical error bars
    plot(repmat(-dataL3.bathycorr.hfactor.', 2, 1), ...
         (-dataL3.datacorr.hfactor + [-dataL3.datacorr.hfactor_error, dataL3.datacorr.hfactor_error]).', ...
          '-k')
    
	% --------------------------------
    % Plot dh's
    
    plot(-dataL3.bathycorr.hfactor, -dataL3.datacorr.hfactor, '.k', 'MarkerSize', 72)
    %
    scatter(-dataL3.bathycorr.hfactor, -dataL3.datacorr.hfactor, 320, allcmaps.cmap_locs, 'filled')
        
	% --------------------------------
    % Plot 1:1 line
    
    plot(xyaxs_lims, xyaxs_lims, '--k', 'LineWidth', 2)

% --------------------------------
%
set(gca, 'FontSize', 16, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
set(gca, 'DataAspectRatio', [1, 1, 1])
set(gca, 'XLim', xyaxs_lims, 'YLim', xyaxs_lims)

%
xlabel('$- \delta h_{\mathrm{bathy}}~[\mathrm{m}]$', 'Interpreter', 'Latex', 'FontSize', 20)
ylabel('$- \delta h_{\mathrm{opt}}~[\mathrm{m}]$', 'Interpreter', 'Latex', 'FontSize', 20)
%
title(['With median bathymetry: $\hat{r} = ' num2str(dataL3.bathycorr.radius_hbathy) ' ~\mathrm{m}$'], 'Interpreter', 'Latex', 'FontSize', 14)


% ----------------------
% Create legend
%
haxs_leg = axes('Position', [0.76, haxs.Position(2), 0.13, haxs.Position(4)]);
hold(haxs_leg, 'on')
%
haxs_leg.XLim = [0, 1];
haxs_leg.YLim = [0, 1];

%
ymargin = 0.05;
ypos = linspace((0+ymargin), (1-ymargin), 8);
ypos = ypos(:);
ypos = flipud(ypos);
%
for i = 1:8
    plot(haxs_leg, 0.2, ypos(i), '.k', 'MarkerSize', 58)
    plot(haxs_leg, 0.2, ypos(i), '.', 'Color', allcmaps.cmap_locs(i, :), 'MarkerSize', 50)
    %
    htxt_aux = text(0.5, ypos(i), idfield_to_idpaper(dataL3.mooringID(i)), 'Interpreter', 'Latex', 'FontSize', 20);
end

set(haxs_leg, 'Box', 'on', 'XTick', [], 'YTick', [])
%     haxs_leg.Visible = 'off';
    

%% Save figure

exportgraphics(hfig, fullfile(dir_output, 'figure09.pdf'), 'Resolution', 300)








