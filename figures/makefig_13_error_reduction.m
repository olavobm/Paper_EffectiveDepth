%% Make Figure 13 -- bar chart with MSE reduction for different choices of dh

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


%% Plot bar chart for only one mooring

%
list_mooring = ["E01", "E02", "E05", "E07", "E08", "E09", "E11", "E13"];
    
%
ind_hobs = find(dataL3.datacorr.hfactors==0);

%
vec_bars = NaN(length(list_mooring), 3);

b_bars = NaN(length(list_mooring), 2);


%
for i = 1:length(list_mooring)
    
    %
    ind_mooring = find(strcmp(dataL3.mooringID, list_mooring(i)));

    %
    ind_factor_bathy = dsearchn(dataL3.datacorr.hfactors, dataL3.bathycorr.hfactor(ind_mooring));

    %
    MSE_bathyfactor = dataL3.datacorr.MSE(ind_mooring, ind_factor_bathy);

    %
    vec_bars(i, :) = [dataL3.datacorr.MSEobs(ind_mooring), ...
                      dataL3.datacorr.MSEmin(ind_mooring), ...
                      MSE_bathyfactor];
                  
	% -----------------------------------
    %
    load(fullfile(paper_directory(), 'data', 'level_2', ['roxsi_L2_' char(list_mooring(i)) '.mat']))
    
    %
    ind_nocorrection = dataL2.ind_hp;
    %
    ind_bathycorrection = dsearchn(dataL2.hfactors, dataL3.bathycorr.hfactor(i));
    %
    ind_get = [ind_nocorrection, ind_bathycorrection];
    
    %
    b_bars(i, :) = dataL2.datacorrection.bcoef(ind_get);
    
    
end

%
vec_bars = 10000.*vec_bars;


%% Make figure
    
%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.2045    0.2508    0.4177    0.3150];

    %
    hpbar = bar(1:length(list_mooring), vec_bars);
        %
        hpbar(1).FaceColor = allcmaps.cmap_dh(1, :);
        hpbar(2).FaceColor = allcmaps.cmap_dh(2, :);
        hpbar(3).FaceColor = allcmaps.cmap_dh(3, :);
        %
        hpbar(1).BarWidth = 1;
        hpbar(2).BarWidth = 1;
        hpbar(3).BarWidth = 1;

    %
    hleg = legend('$\;\epsilon^2(0) = \epsilon_0^2$', ...
                  '$\;\epsilon^2(\delta h_{\mathrm{opt}})$', ...
                  '$\;\epsilon^2(\delta h_{\mathrm{bathy}})$');
        hleg.Interpreter = 'Latex';
        hleg.FontSize = 30;
        hleg.Position = [0.3898    0.4984    0.2585    0.4092];

%
set(gca, 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
set(gca, 'XTickLabel', idfield_to_idpaper(list_mooring), 'FontSize', 22)
set(gca, 'YTick', 0:25:100)

%
ylabel('$\epsilon^2(\delta h)~[\mathrm{cm}^2]$', 'Interpreter', 'Latex', 'FontSize', 26)


%% Save figure

%
exportgraphics(gcf, fullfile(dir_output, 'figure13.pdf'), 'Resolution', 300)


