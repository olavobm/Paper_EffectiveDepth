%% Make Figure 07 -- figure with dh and sigma_h as function of radii

clear
close all


%%

%
dir_data = fullfile(paper_directory(), 'data', 'level_2');
    
%
dir_output = fullfile(paper_directory(), 'figures');


%%

list_moorings = ["E01"; "E02"; "E05"; ...
                 "E07"; "E08"; "E09"; ...
                 "E11"; "E13"];
             
          
%%

%
bathystats = load(fullfile(paper_directory(), 'data', 'level_3', 'roxsi_bathystats.mat'));
bathystats = bathystats.bathystats;
    
             
%% Pre-allocate variable

%
allh.radii = 2:1:30;    % (radii must match the L2 data radii)

%
allh.hobs = NaN(1, length(list_moorings));
allh.dh_opt = NaN(1, length(list_moorings));
%
allh.h_mean = NaN(length(allh.radii), length(list_moorings));
%
allh.h_median = NaN(length(allh.radii), length(list_moorings));
%
allh.h_std = NaN(length(allh.radii), length(list_moorings));


%% Load the data and get bathymetry

%
for i = 1:length(list_moorings)

    
    %% Load L2 data (with h factor correction and statistics of bathymetry)
    
    %
    dataL2 = load(fullfile(dir_data, ['roxsi_L2_' char(list_moorings(i)) '.mat']));
    dataL2 = dataL2.dataL2;
    

    %% Get mean depth and optimal dh
    
    %
    allh.hobs(i) = bathystats.h_obs(i);
    
    %
    allh.dh_opt(i) = dataL2.datacorrection.hfactorbest;

    
    %% Get variables as a function of radii
    
    %
    allh.h_mean(:, i) = bathystats.zmsl_avg(:, i);
    allh.h_median(:, i) = bathystats.zmsl_median(:, i);
    
    %
    allh.h_std(:, i) = bathystats.zmsl_stddev(:, i);
    
    
end

% Make h_mean and h_median positive numbers
allh.h_mean = -allh.h_mean;
allh.h_median = -allh.h_median;


%%
% -------------------------------------------------------------------
% --------------------------- MAKE FIGURE ---------------------------
% -------------------------------------------------------------------

%%

%
allcmaps = load(fullfile(paper_directory(), 'figures', 'utils', ...
                                            'paper_colormaps.mat'));
allcmaps = allcmaps.allcmaps;


%
var_plt = "h_mean";
% var_plt = "h_median";    % similar results


%% Make figure

%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.4, 0.15, 0.21, 0.55];
%
haxs = makeSubPlots(0.18, 0.25, 0.05, ...
                    0.1, 0.15, 0.02, 1, 2);
%
hold(haxs, 'on')


    % ------------------------------------------
    %
    plot(haxs(1), [0, allh.radii(end)], [0, 0], '-k')
    %
    hp_each = plot(haxs(1), allh.radii, allh.(var_plt) - allh.hobs, ...
                            '.-', 'LineWidth', 2, 'MarkerSize', 12);
    %
    plot(haxs(1), allh.radii, mean(allh.(var_plt) - allh.hobs, 2, 'omitnan'), ...
                     '-k', 'LineWidth', 4)
    
	%
    for i = 1:length(hp_each)
        hp_each(i).Color = allcmaps.cmap_locs(i, :);
    end

    
    % ------------------------------------------
    %
    for i = 1:8
        plot(haxs(2), allh.radii, allh.h_std(:, i), '.-', ...
                                  'LineWidth', 2, 'MarkerSize', 12, ...
                                  'Color', allcmaps.cmap_locs(i, :));
    end
    plot(haxs(2), allh.radii, mean(allh.h_std, 2), '-k', 'LineWidth', 4);

    
% ------------------------------------------
% Add customized legend
%
haxs_leg = axes('Position', [0.77, 0.2, 0.2, 0.6]);
hold(haxs_leg, 'on')
%
haxs_leg.XLim = [0, 1];
haxs_leg.YLim = [0, 1];
haxs_leg.Box = 'on';
%
set(haxs_leg, 'XTick', [], 'YTick', [], 'XTickLabel', [], 'YTickLabel', [])

%
ylegvec = linspace(0.05, 0.95, length(list_moorings)+1);
ylegvec = fliplr(ylegvec);
%
ydisp_m = -0.015;
%
for i = 1:length(list_moorings)

    %
    plot([0.05, 0.42], ylegvec(i).*[1, 1] + ydisp_m, '-', 'LineWidth', 3, 'Color', allcmaps.cmap_locs(i, :))
    plot(mean([0.05, 0.42]), ylegvec(i) + ydisp_m, '.', 'MarkerSize', 40, 'Color', allcmaps.cmap_locs(i, :))
    
    %
    text(haxs_leg, 0.525, ylegvec(i) + ydisp_m, ...
                   idfield_to_idpaper(list_moorings(i)), ...
                   'Interpreter', 'Latex', 'FontSize', 24)
    
end
plot(haxs_leg, [0.05, 0.42], ylegvec(end).*[1, 1], '-k', 'LineWidth', 4)
%
text(haxs_leg, 0.45, ylegvec(end), 'mean', ...
               'Interpreter', 'Latex', 'FontSize', 16)
               
           
% ------------------------------------------
%
set(haxs, 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
set(haxs, 'XLim', [1, 30], 'XTick', [2, 5:5:30])
set(haxs(1), 'XTickLabel', [])
%
set(haxs(1), 'YDir', 'reverse', 'YLim', [-2.7, 0.2])
set(haxs(2), 'YLim', [0, 2], 'YScale', 'linear')
%
set(haxs, 'Color', 0.85.*[1, 1, 1])
set(haxs_leg, 'Color', 0.85.*[1, 1, 1])


% ------------------------------------------
%
xlabel(haxs(2), '$r$ [m]', 'Interpreter', 'Latex', 'FontSize', 20)
ylabel(haxs(1), '$\delta h$ [m]', 'Interpreter', 'Latex', 'FontSize', 20)
ylabel(haxs(2), '$\sigma_h$ [m]', 'Interpreter', 'Latex', 'FontSize', 20)

%
lblFS = 26;
%
text(haxs(1), 1.4, -2.45, 'a)', 'Interpreter', 'Latex', 'FontSize', 24)
text(haxs(2), 1.4, 1.8, 'b)', 'Interpreter', 'Latex', 'FontSize', 24)


%% Save figure

%
exportgraphics(hfig, ...
               fullfile(paper_directory(), 'figures', 'figure07.pdf'), ...
               'Resolution', 300)






