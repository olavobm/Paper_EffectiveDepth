%%  Make Figure 10 -- plot scatter plots of Hs with different corrections

clear
close all

%% Set directories

%
dir_data = fullfile(paper_directory(), 'data');

%
dir_output = fullfile(paper_directory(), 'figures');


%%

%
dataL2_A = load(fullfile(dir_data, 'level_2', 'roxsi_L2_E05.mat'));
dataL2_B = load(fullfile(dir_data, 'level_2', 'roxsi_L2_E07.mat'));
%
dataL2_A = dataL2_A.dataL2;
dataL2_B = dataL2_B.dataL2;

%
load(fullfile(dir_data, 'level_3', 'roxsi_dataL3.mat'))


%%

ind_matchL3_A = find(strcmp(dataL3.mooringID, "E05"));
ind_matchL3_B = find(strcmp(dataL3.mooringID, "E07"));


%% Compute statistics for each subplot

%
indsplt = 1:1:length(dataL2_A.wavebuoy.Hs);

%
dotsMS = 14;

% ------------------------------
%
ind_nocorrection_A = dataL2_A.ind_hp;
ind_datacorrecton_A = dataL2_A.datacorrection.ind_minMSE;
ind_bathycorrecton_A = dsearchn(dataL2_A.hfactors, dataL3.bathycorr.hfactor(ind_matchL3_A));
%
a_nocorr_A = dataL2_A.datacorrection.acoef(ind_nocorrection_A);
b_nocorr_A = dataL2_A.datacorrection.bcoef(ind_nocorrection_A);
%
a_datacorr_A = dataL2_A.datacorrection.acoef(ind_datacorrecton_A);
b_datacorr_A = dataL2_A.datacorrection.bcoef(ind_datacorrecton_A);
%
a_bacorr_A = dataL2_A.datacorrection.acoef(ind_bathycorrecton_A);
b_bacorr_A = dataL2_A.datacorrection.bcoef(ind_bathycorrecton_A);

% ------------------------------
%
ind_nocorrection_B = dataL2_B.ind_hp;
ind_datacorrecton_B = dataL2_B.datacorrection.ind_minMSE;
ind_bathycorrecton_B = dsearchn(dataL2_B.hfactors, dataL3.bathycorr.hfactor(ind_matchL3_B));
%
a_nocorr_B = dataL2_B.datacorrection.acoef(ind_nocorrection_B);
b_nocorr_B = dataL2_B.datacorrection.bcoef(ind_nocorrection_B);
%
a_datacorr_B = dataL2_B.datacorrection.acoef(ind_datacorrecton_B);
b_datacorr_B = dataL2_B.datacorrection.bcoef(ind_datacorrecton_B);
%
a_bacorr_B = dataL2_B.datacorrection.acoef(ind_bathycorrecton_B);
b_bacorr_B = dataL2_B.datacorrection.bcoef(ind_bathycorrecton_B);


%%
% -----------------------------------------------------------
% -----------------------------------------------------------
% ----------------------- MAKE FIGURE -----------------------
% -----------------------------------------------------------
% -----------------------------------------------------------


%% Load colormaps

%
allcmaps = load(fullfile(paper_directory(), 'figures', 'utils', ...
                                            'paper_colormaps.mat'));
allcmaps = allcmaps.allcmaps;

              

%% Make figure

%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.42, 0.1, 0.2, 0.5];
%
haxs_all = makeSubPlots(0.16, 0.01, 0.06, ...
                        0.0015, 0.11, 0.015, 2, 3);
%
hold(haxs_all, 'on')

    %
    xlims_plt = [0, 3];
    
    % ---------------------------------------------------------------

    %
    plot(haxs_all(1), dataL2_A.wavebuoy.Hs(indsplt).^2, dataL2_A.psensor.Hs(indsplt, ind_nocorrection_A).^2, '.', 'Color', allcmaps.cmap_dh(1, :), 'MarkerSize', dotsMS)
    plot(haxs_all(3), dataL2_A.wavebuoy.Hs(indsplt).^2, dataL2_A.psensor.Hs(indsplt, dataL2_A.datacorrection.ind_minMSE).^2, '.', 'Color', allcmaps.cmap_dh(2, :), 'MarkerSize', dotsMS)
    plot(haxs_all(5), dataL2_A.wavebuoy.Hs(indsplt).^2, dataL2_A.psensor.Hs(indsplt, ind_bathycorrecton_A).^2, '.', 'Color', allcmaps.cmap_dh(3, :), 'MarkerSize', dotsMS)
    %
    plot(haxs_all(1), xlims_plt.^2, (a_nocorr_A + b_nocorr_A.*xlims_plt).^2, '-k', 'LineWidth', 2)
    plot(haxs_all(3), xlims_plt.^2, (a_datacorr_A + b_datacorr_A.*xlims_plt).^2, '-k', 'LineWidth', 2)
    plot(haxs_all(5), xlims_plt.^2, (a_bacorr_A + b_bacorr_A.*xlims_plt).^2, '-k', 'LineWidth', 2)

    
    % ---------------------------------------------------------------
    %
    plot(haxs_all(2), dataL2_B.wavebuoy.Hs(indsplt).^2, dataL2_B.psensor.Hs(indsplt, ind_nocorrection_B).^2, '.', 'Color', allcmaps.cmap_dh(1, :), 'MarkerSize', dotsMS)
    plot(haxs_all(4), dataL2_B.wavebuoy.Hs(indsplt).^2, dataL2_B.psensor.Hs(indsplt, dataL2_B.datacorrection.ind_minMSE).^2, '.', 'Color', allcmaps.cmap_dh(2, :), 'MarkerSize', dotsMS)
    plot(haxs_all(6), dataL2_B.wavebuoy.Hs(indsplt).^2, dataL2_B.psensor.Hs(indsplt, ind_bathycorrecton_B).^2, '.', 'Color', allcmaps.cmap_dh(3, :), 'MarkerSize', dotsMS)
    %
    plot(haxs_all(2), xlims_plt.^2, (a_nocorr_B + b_nocorr_B.*xlims_plt).^2, '-k', 'LineWidth', 2)
    plot(haxs_all(4), xlims_plt.^2, (a_datacorr_B + b_datacorr_B.*xlims_plt).^2, '-k', 'LineWidth', 2)
    plot(haxs_all(6), xlims_plt.^2, (a_bacorr_B + b_bacorr_B.*xlims_plt).^2, '-k', 'LineWidth', 2)

    
    % ---------------------------------------------------------------
    
    %
    for i = 1:length(haxs_all)
    	plot(haxs_all(i), xlims_plt, xlims_plt, '-.', 'Color', 0.3.*[1, 1, 1], 'LineWidth', 3)
    end
    
    %
    txtFS = 18;
    xplttxt = 0.875;
    yplttxt = 0.6;

    %
    htxt_aux = text(haxs_all(1), 1.6, 1.4, '1:1', 'Color', 0.3.*[1, 1, 1], 'FontSize', txtFS-4);
    
    % -----------------------------------------------------------------
    
    %
    error_1_A = 10000*mean((dataL2_A.psensor.Hs(indsplt, ind_nocorrection_A) - dataL2_A.wavebuoy.Hs(indsplt)).^2, 'omitnan');
    error_2_A = 10000*mean((dataL2_A.psensor.Hs(indsplt, dataL2_A.datacorrection.ind_minMSE) - dataL2_A.wavebuoy.Hs(indsplt)).^2, 'omitnan');
    error_3_A = 10000*mean((dataL2_A.psensor.Hs(indsplt, ind_bathycorrecton_A) - dataL2_A.wavebuoy.Hs(indsplt)).^2, 'omitnan');
    
    %
    error_1_B = 10000*mean((dataL2_B.psensor.Hs(indsplt, ind_nocorrection_B) - dataL2_B.wavebuoy.Hs(indsplt)).^2, 'omitnan');
    error_2_B = 10000*mean((dataL2_B.psensor.Hs(indsplt, dataL2_B.datacorrection.ind_minMSE) - dataL2_B.wavebuoy.Hs(indsplt)).^2, 'omitnan');
    error_3_B = 10000*mean((dataL2_B.psensor.Hs(indsplt, ind_bathycorrecton_B) - dataL2_B.wavebuoy.Hs(indsplt)).^2, 'omitnan');
    
    
    % -----------------------------------------------------------------
    %
    txtdhFS = 16;
    %
    xdhtxt = 0.04;
%     ydhtxt = 2.35;
    ydhtxt = 2.42;
    
    
    % -----------------------------------------------------------------
    % site ID
    for i = 1:length(haxs_all)
        if mod(i, 2)~=0
            text(haxs_all(i), 0.4, 2.275, 'S3', 'Interpreter', 'Latex', 'FontSize', 20)
        else
            text(haxs_all(i), 0.4, 2.275, 'S4', 'Interpreter', 'Latex', 'FontSize', 20)
        end
    end
    
    
    % -----------------------------------------------------------------
    % add dh's
    
    FS_aux = 13;
    yp_aux = 2.05;
    %
    text(haxs_all(1), 0.03, yp_aux, '$\delta h = 0$', 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(1, :), 'FontSize', FS_aux);
    text(haxs_all(2), 0.03, yp_aux, '$\delta h = 0$', 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(1, :), 'FontSize', FS_aux);
    %
    text(haxs_all(3), 0.03, yp_aux, ['$\delta h_{\mathrm{opt}} = ' num2str(dataL2_A.hfactors(ind_datacorrecton_A), '%.1f')  '~\mathrm{m}$'], 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(2, :), 'FontSize', FS_aux);
    text(haxs_all(4), 0.03, yp_aux, ['$\delta h_{\mathrm{opt}} = ' num2str(dataL2_B.hfactors(ind_datacorrecton_B), '%.1f') '~\mathrm{m}$'], 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(2, :), 'FontSize', FS_aux);
    %
    text(haxs_all(5), 0.03, yp_aux, ['$\delta h_{\mathrm{bathy}} = ' num2str(dataL2_A.hfactors(ind_bathycorrecton_A), '%.1f')  '~\mathrm{m}$'], 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(3, :), 'FontSize', FS_aux);
    text(haxs_all(6), 0.03, yp_aux, ['$\delta h_{\mathrm{bathy}} = ' num2str(dataL2_B.hfactors(ind_bathycorrecton_B), '%.1f') '~\mathrm{m}$'], 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(3, :), 'FontSize', FS_aux);

    
    % -----------------------------------------------------------------
    % Add slope
    
	%
    FS_aux = 14;
    xp_aux = 0.9;
    yp_aux = 0.6;
    %
    text(haxs_all(1), xp_aux, yp_aux, ['slope = ' num2str(b_nocorr_A.^2, '%.2f')], 'Interpreter', 'Latex', 'FontSize', FS_aux);
    text(haxs_all(2), xp_aux, yp_aux, ['slope = ' num2str(b_nocorr_B.^2, '%.2f')], 'Interpreter', 'Latex', 'FontSize', FS_aux);
    %
    text(haxs_all(3), xp_aux, yp_aux, ['slope = ' num2str(b_datacorr_A.^2, '%.2f')], 'Interpreter', 'Latex', 'FontSize', FS_aux);
    text(haxs_all(4), xp_aux, yp_aux, ['slope = ' num2str(b_datacorr_B.^2, '%.2f')], 'Interpreter', 'Latex', 'FontSize', FS_aux);
    %
    text(haxs_all(5), xp_aux, yp_aux, ['slope = ' num2str(b_bacorr_A.^2, '%.2f')], 'Interpreter', 'Latex', 'FontSize', FS_aux);
    text(haxs_all(6), xp_aux, yp_aux, ['slope = ' num2str(b_bacorr_B.^2, '%.2f')], 'Interpreter', 'Latex', 'FontSize', FS_aux);
    
    
    
    % -----------------------------------------------------------------
    % add epsilon^2
     
	%
    FS_aux = 16;
    xp_aux = 0.875;
    yp_aux = 0.6;
    %
    text(haxs_all(1), xp_aux, 0.15, ['$\epsilon^2 = ' num2str(error_1_A, '%.0f') '~\mathrm{cm}^2$'], 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(1, :), 'FontSize', FS_aux);
    text(haxs_all(2), xp_aux, 0.15, ['$\epsilon^2 = ' num2str(error_1_B, '%.0f') '~\mathrm{cm}^2$'], 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(1, :), 'FontSize', FS_aux);
    %
    text(haxs_all(3), xp_aux, 0.15, ['$\epsilon^2 = ' num2str(error_2_A, '%.0f') '~\mathrm{cm}^2$'], 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(2, :), 'FontSize', FS_aux);
    text(haxs_all(4), xp_aux, 0.15, ['$\epsilon^2 = ' num2str(error_2_B, '%.0f') '~\mathrm{cm}^2$'], 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(2, :), 'FontSize', FS_aux);
    %
    text(haxs_all(5), xp_aux, 0.15, ['$\epsilon^2 = ' num2str(error_3_A, '%.0f') '~\mathrm{cm}^2$'], 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(3, :), 'FontSize', FS_aux);
    text(haxs_all(6), xp_aux, 0.15, ['$\epsilon^2 = ' num2str(error_3_B, '%.0f') '~\mathrm{cm}^2$'], 'Interpreter', 'Latex', 'Color', allcmaps.cmap_dh(3, :), 'FontSize', FS_aux);


% -----------------------------------------------------------------
%
text(haxs_all(1), 0.045, 2.33, 'a)', 'FontSize', 16);
text(haxs_all(2), 0.045, 2.33, 'b)', 'FontSize', 16);
text(haxs_all(3), 0.045, 2.33, 'c)', 'FontSize', 16);
text(haxs_all(4), 0.045, 2.33, 'd)', 'FontSize', 16);
text(haxs_all(5), 0.045, 2.33, 'e)', 'FontSize', 16);
text(haxs_all(6), 0.045, 2.33, 'f)', 'FontSize', 16);
    

% -----------------------------------------------------------------
    
%
set(haxs_all, 'DataAspectRatio', [1, 1, 1])
set(haxs_all, 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
set(haxs_all, 'XLim', [0, 2.5], 'YLim', [0, 2.5])
set(haxs_all(1:end-2), 'XTickLabel', [])
set(haxs_all, 'YTick', 0:0.5:2)
set(haxs_all(1:2:end), 'YTickLabel', {'0', '0.5', '1', '1.5', '2'})
set(haxs_all(2:2:end), 'YTickLabel', [])
%
set(haxs_all, 'Color', 0.9*[1, 1, 1])

%
for i = 1:2:length(haxs_all)
    haxs_all(i).Position(1) = haxs_all(i).Position(1) + 0.02;
end

%
xlabel(haxs_all(end-1), '$H_{\mathrm{sp}}^2$ [m$^2$]', 'Interpreter', 'Latex', 'FontSize', 18)
xlabel(haxs_all(end), '$H_{\mathrm{sp}}^2$ [m$^2$]', 'Interpreter', 'Latex', 'FontSize', 18)
%
for i = 1:2:5
    ylabel(haxs_all(i), '$H_\mathrm{p}^2$ [m$^2$]', 'Interpreter', 'Latex', 'FontSize', 18)
end
    

%% Save figure

%
exportgraphics(hfig, fullfile(dir_output, 'figure10.pdf'), 'Resolution', 300)




