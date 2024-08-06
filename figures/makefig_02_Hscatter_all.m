%% Make Figure 02 -- scatter plot at all sites of Hs
% from wave buoy and pressure sensors

clear
close all


%% Define variables

% Set directories
dir_data = fullfile(paper_directory(), 'data', 'level_2');
%
dir_output = fullfile(paper_directory(), 'figures');

% List of locations sites
list_moorings = ["E01", "E02", "E05", "E07", ...
                 "E08", "E09", "E11", "E13"];


%% Make figure

%
mkSZ = 10;

%
hfig = figure;
hfig.PaperUnits = 'centimeters';
hfig.PaperPosition = [0, 0, 9, 12];
hfig.Units = 'normalized';
hfig.Position = [0.2614    0.2492    0.4050    0.4067];
%
haxs = makeSubPlots(0.065, 0.02, 0.015, ...
                    0.02, 0.12, 0.015, 4, 2);
hold(haxs, 'on')
    

% Loop over moorings
for i = 1:8

    %
    dataHs = load(fullfile(dir_data, ['roxsi_L2_' char(list_moorings(i)) '.mat']));
    dataHs = dataHs.dataL2;

    % Indice where local depth is used in trasnfer function (the
    % same for all moorings)
    if i==1
        ind_localdepth = find(dataHs.hfactors==0);
    end
    
    %
    plot(haxs(i), dataHs.wavebuoy.Hs.^2, ...
                  dataHs.psensor.Hs(:, ind_localdepth).^2, ...
                  '.k', 'MarkerSize', mkSZ)

	% ------------------------------------
              
    %
    plot(haxs(i), [0, 3].^2, [0, 3].^2, '--k', 'LineWidth', 2)
    
    %
    x_limplt = [0, 3];
    plot(haxs(i), x_limplt.^2, ...
                  (dataHs.datacorrection.acoef(ind_localdepth) + ...
                   dataHs.datacorrection.bcoef(ind_localdepth).*x_limplt).^2, ...
                  'r', 'LineWidth', 2)
   
    % Error for Hs
    mean_error = mean((dataHs.psensor.Hs(:, ind_localdepth) - dataHs.wavebuoy.Hs).^2, 'omitnan');
    
	%
    bcoef_reg = dataHs.datacorrection.bbounds(ind_localdepth, :).^2;
    %
    best_b = mean(bcoef_reg);
    erro_b = diff(bcoef_reg)/2;
    
    %
    corr(dataHs.wavebuoy.Hs(:).^2, dataHs.psensor.Hs(:, ind_localdepth).^2, 'rows', 'complete').^2;

    %
    bla = dataHs.wavebuoy.Hs(:);
    ble = dataHs.psensor.Hs(:, ind_localdepth);
    %
    lok_aux = ~isnan(bla) & ~isnan(ble);
    %
    bla = bla(lok_aux);
    ble = ble(lok_aux);
        
    
    % --------------------------------------------

	%
	xpos = 1.275; ypos = 0.78;
    text(haxs(i), xpos, ypos, ...
                  ['$\epsilon^2_0 = ' num2str(10000*mean_error, '%.0f') '~\mathrm{cm}^2$'], ...
                  'Interpreter', 'Latex', 'FontSize', 18)
	%
    text(haxs(i), 0.5, 0.2, ...
                  ['slope $= ' num2str(best_b, '%.2f') ' \pm ' num2str(erro_b, '%.2f') '$'], ...
                  'Color', [1, 0, 0], 'Interpreter', 'Latex', 'FontSize', 15)
	%
    text(haxs(i), 0.1, 3.6, idfield_to_idpaper(dataHs.mooringID), 'Interpreter', 'Latex', 'FontSize', 30)
end
    
%
set(haxs, 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
set(haxs, 'DataAspectRatio', [1, 1, 1])
set(haxs, 'XLim', [0, 4.1], 'YLim', [0, 4.1])
%
set(haxs, 'XTick', 0:1:4, 'YTick', 0:1:4)
set(haxs(1:4), 'XTickLabel', [])
set(haxs([2, 3, 4, 6, 7, 8]), 'YTickLabel', [])

%
for i = 5:8
    xlabel(haxs(i), '$H_{\mathrm{sp}}^{2}$ [m$^2$]', 'Interpreter', 'Latex', 'FontSize', 16)
end

%
for i = [1, 5]
    ylabel(haxs(i), '$H_{\mathrm{p}}^{2}$ [m$^2$]', 'Interpreter', 'Latex', 'FontSize', 16)
end


%%

exportgraphics(hfig, fullfile(dir_output, 'figure02.pdf'), 'Resolution', 300)


