%% Make Figure 03 -- plot time-averaged observed spectrum from Spotter and
%  from pressure sensor (using the local depth).

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

%
See_buoy = mean(dataHs.wavebuoy.See(lok_spec, :), 1);
See_pres = mean(dataHs.psensor.See(lok_spec, :, ind_localdepth), 1);


%% Calculate decorrelation scale

%
Hs_sub = dataHs.wavebuoy.Hs(10:718);
Hs_sub = Hs_sub(:);
%
Hs_sub = Hs_sub - mean(Hs_sub);

%
[lagcof, lags] = xcorr(Hs_sub, Hs_sub, 24*4, 'coeff');

%
ind_decorrelation_scale = dsearchn(lagcof(:), 1/exp(1));


% % % Plot autocorrelation
% % hfig = figure;
% % hold on
% %     %
% %     plot(lags, lagcof, '-k', 'LineWidth', 2)
% %     plot(max(lags).*[-1, 1], [0, 0], '-k')
% % %
% % set(gca, 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
% % xlim([-5, max(lags)])
% % ylim([-0.1, 1])
% % 
% % %
% % xlabel('Lags [hours]', 'Interpreter', 'Latex', 'FontSize', 20)
% % ylabel('$r$', 'Interpreter', 'Latex', 'FontSize', 20)
% % %
% % title('Lagged correlation of $H_s$ at S03', 'Interpreter', 'Latex', 'FontSize', 20)

                          

%% Calculate error bar for spectra

%
dof = 118;
%
p = 0.05;

% Calculate effective number of degrees of freedom
specerror.Ntimesamples = length(find(lok_spec)) ./ ...
                         (abs(lags(ind_decorrelation_scale)));

%
dof = dof * specerror.Ntimesamples;
dof = round(dof);

%
specerror.spectrum_upper_bound = dof ./ chi2inv(p/2, dof);
specerror.spectrum_lower_bound = dof ./ chi2inv(1 - (p/2), dof);
%
specerror.avgspectrum_upper_bound = specerror.spectrum_upper_bound;
specerror.avgspectrum_lower_bound = specerror.spectrum_lower_bound;


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



%% Plot figure


%
axs_pos = [0.15, 0.125, 0.79, 0.72];
xaxs_xlims = [0.08, 0.22];

%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.4086    0.2583    0.2123    0.4025];

    % ------------------------------------------
    % The axis with x axis firt, so it goes beneath the main axes
    haxs_2 = axes('Position', axs_pos, 'XAxisLocation', 'top');
        haxs_2.FontSize = 12;
        haxs_2.YColor = 'none';

        
	% ------------------------------------------
    % Plot science
    haxs_1 = axes('Position', axs_pos);
    
    %
    hold(haxs_1, 'on')
    
    %
    hp_buoy = plot(haxs_1, dataHs.wavebuoy.frequency, See_buoy, '-k', 'LineWidth', 2);
    hp_pres = plot(haxs_1, dataHs.psensor.frequency, See_pres, '-r', 'LineWidth', 2);
    
    %
    text(0.08125, 0.85, idfield_to_idpaper({'E05'}), 'Interpreter', 'Latex', 'FontSize', 38)
    text(0.145, 0.9, ['$\overline{h}_p = ' num2str(h_ref, '%.1f') ' ~\mathrm{m}$'], 'Interpreter', 'Latex', 'FontSize', 22)
    
    % ------------------------------------------
	% Plot error bar
       
    %
    X0plt = 0.175;
    %
    Y0plt = 0.6;
	
    %
    yvec_errbar = Y0plt.*[specerror.avgspectrum_lower_bound, ...
                          specerror.avgspectrum_upper_bound];
    
    %
    herb = errorbar(X0plt, Y0plt, yvec_errbar(1) - Y0plt, yvec_errbar(2) - Y0plt);
        %
        herb.Color = 0.7.*[1, 1, 1];
        herb.LineWidth = 4;
        
	%
    text(X0plt + 0.01, Y0plt, '95\%', 'Interpreter', 'Latex', 'FontSize', 22)
        
    % ------------------------------------------
    hleg = legend([hp_buoy, hp_pres], '$\overline{S}_{\eta}$ from spotter', '$\overline{K^2(h_p) S_{p}}$', 'Interpreter', 'Latex', 'Location', 'South');
        hleg.FontSize = 18;
        

    
% ----------- DO kh AXIS -----------
%
set([haxs_1, haxs_2], 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
%
% Both x axes have to be the same, ...
set([haxs_1, haxs_2], 'XScale', 'log', 'YScale', 'log', ...
                      'XLim', xaxs_xlims, 'XTick', frequency_ticks, ...
                      'YLim', [0.2, 1.1], ...
                      'YTick', [0.01, 0.1, 0.2, 0.3, 0.5, 1, 10])
% ..., but they have different labels
set(haxs_2, 'XTickLabel', kh_label)
    
%
xlabel(haxs_1, 'Frequency [Hz]', 'Interpreter', 'Latex', 'FontSize', 18)
ylabel(haxs_1, '$S_\eta$ [m$^2$ Hz$^{-1}$]', 'Interpreter', 'Latex', 'FontSize', 18)
%
xlabel(haxs_2, '$k \overline{h}_p$', 'Interpreter', 'Latex', 'FontSize', 24)


%% Save figure

%
exportgraphics(hfig, fullfile(dir_output, 'figure03.pdf'), 'Resolution', 300)


