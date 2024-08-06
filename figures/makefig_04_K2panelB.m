%% Make panel (b) of Figure 4

clear
close all


%% Set directories

%
dir_data = fullfile(paper_directory(), 'data', 'level_2');

%
dir_output = fullfile(paper_directory(), 'figures');


%% Pick instrument site and load L2 data

%
list_moorings = "E05";

%
dataHs = load(fullfile(dir_data, ['roxsi_L2_' char(list_moorings) '.mat']));
dataHs = dataHs.dataL2;


%% Get mean spectra

%
ind_localdepth = find(dataHs.hfactors == 0);

%
lok_spec = ~isnan(dataHs.wavebuoy.See(:, 6)) & ...    % 6 is just a sort of dummy variablea frequency
           ~isnan(dataHs.psensor.See(:, 6, 1));


%% Set frequency ticks and calculate kh ticks

%
frequency_ticks = [5e-2, 0.1, 0.15, 0.2, 0.3];

%
h_ref = mean(dataHs.psensor.bottomdepth, 'omitnan');

%
kh_ticks = wave_freqtok(frequency_ticks, h_ref).*h_ref;

%
kh_label = cell(1, length(kh_ticks));
%
for i = 1:length(kh_ticks)
    %
    kh_label{i} = num2str(kh_ticks(i), '%.2f');
end


%% Plot figure -- just the transfer function

%
axs_pos = [0.15, 0.15, 0.79, 0.675];
xaxs_xlims = [0.08, 0.22];

%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.4086    0.1583    0.2123    0.375];

    % ------------------------------------------
    % The axis with x axis firt, so it goes beneath the main axes
    haxs_kh = axes('Position', axs_pos, 'XAxisLocation', 'top');
        haxs_kh.FontSize = 12;
        haxs_kh.YColor = 'none';

        
	% ------------------------------------------
    %
    haxs = axes('Position', axs_pos);

    %
    hold(haxs, 'on')
    
	% ------------------------------------------
    % Plot transfer function

    % Average transfer function at hp
    K2_hp_avg = mean(dataHs.psensor.TF_Spp_to_See(lok_spec, :, ind_localdepth), 1);
	%
    K2_dh_1_avg = mean(dataHs.psensor.TF_Spp_to_See(lok_spec, :, 23), 1);
    
    
    % Average observed transfer function
    %
    ind_f_common = 1:100;
    %
    K2_obs_avg = mean(dataHs.wavebuoy.See(lok_spec, ind_f_common) ./ ...
                      dataHs.psensor.Spp(lok_spec, ind_f_common), 1);
    %
    hp_K2_A = plot(haxs, dataHs.psensor.frequency, K2_hp_avg, '-r', 'LineWidth', 3);
    %
    hp_dh_A = plot(haxs, dataHs.psensor.frequency, K2_dh_1_avg, '-', 'Color', [0.4660    0.6740    0.1880], 'LineWidth', 3);

    
    %
    text(haxs, 0.08125, 7.5, idfield_to_idpaper({'E05'}), 'Interpreter', 'Latex', 'FontSize', 38)
    text(haxs, 0.145, 1.2, ['$\overline{h}_p = ' num2str(h_ref, '%.1f') ' ~\mathrm{m}$'], 'Interpreter', 'Latex', 'FontSize', 22)
    


% ------------------------------------------
hleg = legend([hp_K2_A,  hp_dh_A],  '$\overline{K^2(h_p)}$', ...
                                    '$\overline{K^2(h_p - 1)}$', ...
                                    'Interpreter', 'Latex', 'Location', 'North');                                  
hleg.FontSize = 18;

        
% ----------- DO kh AXIS -----------
%
set([haxs, haxs_kh], 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
%
set(haxs, 'XScale', 'log', 'XLim', xaxs_xlims)
set(haxs, 'YLim', [1, 10])
set(haxs, 'YScale', 'log', 'YTick', [1, 2:2:10])

%
% Both x axes have to be the same, ...
set([haxs, haxs_kh], 'XScale', 'log', 'YScale', 'log', ...
                      'XLim', xaxs_xlims, 'XTick', frequency_ticks)
% ..., but they have different labels
set(haxs_kh, 'XTickLabel', kh_label)
    
%
ylabel(haxs, '$K^2$', 'Interpreter', 'Latex', 'FontSize', 18)
%
xlabel(haxs, 'Frequency [Hz]', 'Interpreter', 'Latex', 'FontSize', 18)
%
xlabel(haxs_kh, '$k \overline{h}_p$', 'Interpreter', 'Latex', 'FontSize', 24)



%% Save figure

%
exportgraphics(hfig, fullfile(dir_output, 'figure04_panel_B.pdf'), 'Resolution', 300)