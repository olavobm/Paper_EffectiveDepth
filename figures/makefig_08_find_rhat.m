%% Make Figure 08 -- average error to find minimum of error and optimal radius

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


%% Make figure

%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.3786, 0.3533, 0.2355, 0.3842];
%
haxs = makeSubPlots(0.15, 0.04, 0.1, ...
                    0.1, 0.15, 0.1, 1, 1);
%
hold(haxs, 'on')

    %
    plot(dataL3.bathycorr.radii, dataL3.bathycorr.hfactor_MSEmean_avg, ...
                        '.-', 'LineWidth', 2, 'MarkerSize', 20)
    plot(dataL3.bathycorr.radii, dataL3.bathycorr.hfactor_MSEmedian_avg, ...
                        '.-', 'LineWidth', 2, 'MarkerSize', 20)
    
%
hleg = legend('$\left[ h \right] = $ mean depth', ...
              '$\left[ h \right] = $ median depth', 'Location', 'NorthWest');
    hleg.Interpreter = 'Latex';
    hleg.FontSize = 20;

%
set(gca, 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')

%
xlim([0, 30])
ylim([0, 0.8])
%
set(haxs, 'XTick', [2, 5:5:30])


%
xlabel('$r$ [m]', 'Interpreter', 'Latex', 'FontSize', 22)
ylabel('$\mathcal{E}^2$ [m$^2$]', 'Interpreter', 'Latex', 'FontSize', 22)
    

%% Save figure

%
exportgraphics(hfig, fullfile(dir_output, 'figure08.pdf'), 'Resolution', 300)


