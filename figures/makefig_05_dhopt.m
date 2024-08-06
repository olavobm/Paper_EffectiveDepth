%% Make Figure 05 -- error with dh factor

clear
close all


%% Load processed data

dataL3 = load(fullfile(paper_directory(), 'data', 'level_3', 'roxsi_dataL3.mat'));
dataL3 = dataL3.dataL3;


%% Choose instrument site to plot

chooseID = "E05";

ind_ID = find(strcmp(dataL3.mooringID, chooseID));


%% Make figure

%
yaxs_lims = [0, 0.015].*10000;

%
hfig = figure;
hfig.PaperUnits = 'centimeters';
hfig.PaperPosition = [0, 0, 9, 12];
hfig.Units = 'normalized';
hfig.Position = [0.3636    0.1967    0.2391    0.3625];

    %
    error_plt = 10000*dataL3.datacorr.MSE(ind_ID, :);

    %
    plot(dataL3.datacorr.hfactors, error_plt, '.-k', 'LineWidth', 2, 'MarkerSize', 22)
    hold on
    %
    plot([0, 0], yaxs_lims, '-k')

    %
    htxt = text(dataL3.datacorr.hfactor(ind_ID), 0.9*yaxs_lims(2), ...
         ['$\delta h_{\mathrm{opt}} = ' num2str(dataL3.datacorr.hfactor(ind_ID)) '~\mathrm{m}$'], ...
         'Interpreter', 'Latex', 'FontSize', 26);
        htxt.HorizontalAlignment = 'center';
      
        
	%
    ind_epsi0 = dsearchn(dataL3.datacorr.hfactors, 0);
    %
    plot(dataL3.datacorr.hfactors(ind_epsi0), error_plt(ind_epsi0), '.r', 'MarkerSize', 42)
    %
    text(-0.4, 90, '$\epsilon^2_0$', 'Interpreter', 'Latex', 'FontSize', 38, 'Color', [1, 0, 0])
    
        
    %
    x0 = dataL3.datacorr.hfactor(ind_ID);

    %
    hw = 0.04;
    xcoords = [(x0 - hw), (x0 + hw), (x0 + hw), (x0 + 3*hw), x0, (x0 - 3*hw), (x0 - hw), (x0 - hw)];
    ycoords = 10000.*[0.012, 0.012, 0.004, 0.004, 0.003, 0.004, 0.004, 0.012];
    fill(xcoords, ycoords, [0, 0, 0])
    
    %
    htxt = text(-2.9, 0.0769*yaxs_lims(2), idfield_to_idpaper(chooseID), 'Interpreter', 'Latex', 'FontSize', 44);
        
    %
    xlim([-3, 0])
    set(gca, 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on', ...
             'XTick', -3:0.5:0.5, 'YLim', yaxs_lims, 'YTick', 0:25:150)
    %
    xlabel('$\delta h$ [m]', 'Interpreter', 'Latex', 'FontSize', 26)
    ylabel('$\epsilon^2$ [cm$^2$]', 'Interpreter', 'Latex', 'FontSize', 26)



%% Save figure

%
dir_output = fullfile(paper_directory(), 'figures');

%
exportgraphics(hfig, fullfile(dir_output, 'figure05.pdf'), 'Resolution', 300)
        
        