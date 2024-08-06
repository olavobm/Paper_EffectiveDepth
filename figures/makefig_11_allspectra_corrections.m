%% Make Figure 11 -- plot spectra at all sites. 

clear
close all


%%

%
freq_lims = [0.05, 0.3];
freq_lims_axs = [0.08, 0.22];


%% Load processed results

%
dataL3 = load(fullfile(paper_directory(), 'data', 'level_3', 'roxsi_dataL3.mat'));
dataL3 = dataL3.dataL3;

  
%%
% ----------------------------------------
% ------ GRAB SPECTRA AT ALL SITES -------
% ----------------------------------------
%
% the spectra corrected by dh_bathy is calculated here.
% (though a very good approximation could be taken from dataL2)


%%

%
allspectra.locID = ["E01"; "E02"; "E05"; ...
                    "E07"; "E08"; "E09"; ...
                    "E11"; "E13"];    
%
allspectra.hp_mean = NaN(length(allspectra.locID), 1);


%%

%
for i = 1:length(allspectra.locID)

    
    %% Load L2 data (with h factor correction and statistics of bathymetry)
    
    %
    dataL2 = load(fullfile(paper_directory(), 'data', 'level_2', ...
                           ['roxsi_L2_' char(allspectra.locID(i)) '.mat']));
    dataL2 = dataL2.dataL2;
    
    
    %%
    
    linfreqlims_spotter = (dataL2.wavebuoy.frequency >= freq_lims(1)) & ...
                          (dataL2.wavebuoy.frequency <= freq_lims(2));
                      
    linfreqlims_psensor = (dataL2.psensor.frequency >= freq_lims(1)) & ...
                          (dataL2.psensor.frequency <= freq_lims(2));
                      
    
	%%      
    
    %
    if i==1
        
        %
        allspectra.dtime = dataL2.dtime;
        %
        allspectra.frequency = dataL2.wavebuoy.frequency(linfreqlims_spotter);
        
        %
        Nfreq = length(allspectra.frequency);
        
        %
        allspectra.Szz_spotter = NaN(length(allspectra.dtime), Nfreq, length(allspectra.locID));

        %
        allspectra.Szz_hp = allspectra.Szz_spotter;
        allspectra.Szz_heff_data = allspectra.Szz_spotter;
        allspectra.Szz_heff_bathy = allspectra.Szz_spotter;
        
    end
    
    
    %% Get mean water depth at the pressure sensor
    
    allspectra.hp_mean(i) = mean(dataL2.psensor.bottomdepth, 'omitnan');
    

    %% Get Spotter spectra
    
    allspectra.Szz_spotter(:, :, i) = dataL2.wavebuoy.See(:, linfreqlims_spotter);
                      
    
    %% Get spectra from pressure sensor using hp
    
    allspectra.Szz_hp(:, :, i) = dataL2.psensor.See(:, linfreqlims_psensor, dataL2.ind_hp);
    
    
    %% Get spectra from pressure sensor using hp + dh_data
    
    %
    ind_dhdata = find(dataL2.hfactors == dataL2.datacorrection.hfactorbest);
    
    %
    allspectra.Szz_heff_data(:, :, i) = dataL2.psensor.See(:, linfreqlims_psensor, ind_dhdata);
    
    
    %% Get dh_bathy
    
    %
    dhbathy_aux = dataL3.bathycorr.hfactor(i);
    
    %
    heff_bathy = dataL2.psensor.bottomdepth + dhbathy_aux;
    
    
    %% Compute wavenumber
    
    %
    k_array = NaN(length(allspectra.dtime), length(allspectra.frequency));
    
    %
    for i2 = 1:length(allspectra.dtime)
        
        %
        k_array(i2, :) = wave_freqtok(allspectra.frequency, heff_bathy(i2));
        
    end
    
    
    %% Compute transfer function
    
    %
    h_array = repmat(heff_bathy, 1, length(allspectra.frequency));
    
    %
    K2 = cosh(k_array .* h_array) ./ cosh(k_array .* 0);
    K2 = K2.^2;


    
    %% Compute spectra from pressure sensor using hp + dh_bathy
    
    %
    allspectra.Szz_heff_bathy(:, :, i) = K2 .* dataL2.psensor.Spp(:, linfreqlims_psensor);

end



%% Compute time-averaged spectra

%
ind_f_aux = 2;

%
prealloc_aux = NaN(length(allspectra.frequency), length(allspectra.locID));

%
list_fields_aux = ["Szz_spotter", "Szz_hp", "Szz_heff_data", "Szz_heff_bathy"];
%
for i = 1:length(list_fields_aux)
    allspectra.timemean.(list_fields_aux(i)) = prealloc_aux;
end


% Loop over locations, get times with data from both the spotter
% and the pressure sensor, and compute time average
for i1 = 1:length(allspectra.locID)
    
    %
    lok_common = ~isnan(allspectra.Szz_spotter(:, ind_f_aux, i1)) & ...
                 ~isnan(allspectra.Szz_hp(:, ind_f_aux, i1));

    %
    for i2 = 1:length(list_fields_aux)
        %
        Szz_aux = allspectra.(list_fields_aux(i2))(lok_common, :, i1);
        %
        allspectra.timemean.(list_fields_aux(i2))(:, i1) = mean(Szz_aux, 1);
    end
    
end



%%
% -------------------------------------------------------------------
% -------------------------------------------------------------------
% --------------------------- MAKE FIGURE ---------------------------
% -------------------------------------------------------------------
% -------------------------------------------------------------------  


%% Load colormap


%
allcmaps = load(fullfile(paper_directory(), 'figures', 'utils', ...
                                            'paper_colormaps.mat'));
allcmaps = allcmaps.allcmaps;



%% Start figure and axes for spectra (and axes for kh)

%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.27, 0.2, 0.34, 0.6];

% Create these first
haxs_kh = makeSubPlots(0.12, 0.04, 0.01, ...
                       0.1, 0.08, 0.15, 4, 2);
%
for i = 1:length(haxs_kh)
    haxs_kh(i).YColor = 'none';
    haxs_kh(i).XAxisLocation = 'top';
end

%
haxs_spec = makeSubPlots(0.12, 0.04, 0.01, ...
                         0.1, 0.08, 0.15, 4, 2);
%
hold(haxs_spec, 'on')

%
set(haxs_spec([2:4, 6:end]), 'YTickLabel', [])


% Loop over locations and plot spectra
for i = 1:length(haxs_spec)
    
    % ----------- Plot the time-averaged averaged spectra ----------- 

    %
    hp_buoy = plot(haxs_spec(i), allspectra.frequency, ...
                                 allspectra.timemean.Szz_spotter(:, i), ...
                                 '-k', 'LineWidth', 2);
    %
    hp_pres = plot(haxs_spec(i), allspectra.frequency, ...
                                 allspectra.timemean.Szz_hp(:, i), ...
                                 '-', 'Color', allcmaps.cmap_dh(1, :), 'LineWidth', 2);
    %
    hp_datacorr = plot(haxs_spec(i), allspectra.frequency, ...
                                     allspectra.timemean.Szz_heff_data(:, i), ...
                                     '-', 'Color', allcmaps.cmap_dh(2, :), 'LineWidth', 2);
    %
    hp_bathycorr = plot(haxs_spec(i), allspectra.frequency, ...
                                      allspectra.timemean.Szz_heff_bathy(:, i), ...
                                      '-', 'Color', allcmaps.cmap_dh(3, :), 'LineWidth', 2);


    % ------------------------------------
    % Plot error bar
    %
    dof_hourly = 118;
    %
    p = 0.05;

    % 37 hours was calculated in a different script
    length_independent = length(find(lok_common)) ./ 37;

    %
    dof = dof_hourly * length_independent;
    dof = round(dof);

    %
    errbar_upper_bound = dof ./ chi2inv(p/2, dof);
    errbar_lower_bound = dof ./ chi2inv(1 - (p/2), dof);

    %
    X0plt = 0.15;
    %
    Y0plt = 0.9;

    %
    yvec_errbar = Y0plt.*[errbar_lower_bound, errbar_upper_bound];

    %
    herb = errorbar(haxs_spec(i), X0plt, Y0plt, yvec_errbar(1) - Y0plt, yvec_errbar(2) - Y0plt);
        %
        herb.Color = 0.7.*[1, 1, 1];
        herb.LineWidth = 4;


end

% ------------------------------------------
% Do a pretty legend
%
factordisp = 0.83;
%
y1 = 0.38;
%
y2 = y1*factordisp;
y3 = y1*(factordisp^2);
y4 = y1*(factordisp^3);

%
xdrawline = [0.081, 0.092];
%
plot(haxs_spec(1), xdrawline, y1.*[1, 1], 'Color', hp_buoy.Color, 'LineWidth', 3.5);
plot(haxs_spec(1), xdrawline, y2.*[1, 1], 'Color', hp_pres.Color, 'LineWidth', 3.5);
plot(haxs_spec(1), xdrawline, y3.*[1, 1], 'Color', hp_datacorr.Color, 'LineWidth', 3.5);
plot(haxs_spec(1), xdrawline, y4.*[1, 1], 'Color', hp_bathycorr.Color, 'LineWidth', 3.5);


%
xtxt = xdrawline(2) + 0.002;
txtFS = 11.5;
%
text(haxs_spec(1), xtxt, y1, '$\overline{S}_{\eta}$ (spotter)', 'Interpreter', 'Latex', 'FontSize', txtFS);
text(haxs_spec(1), xtxt, y2, '$\overline{K^2(h_p) S_{p}}$', 'Interpreter', 'Latex', 'FontSize', txtFS);
text(haxs_spec(1), xtxt, y3, '$\overline{K^2(h_p + \delta h_{\mathrm{opt}}) S_{p}}$', 'Interpreter', 'Latex', 'FontSize', txtFS);
text(haxs_spec(1), xtxt, y4, '$\overline{K^2(h_p + \delta h_{\mathrm{bathy}}) S_{p}}$', 'Interpreter', 'Latex', 'FontSize', txtFS);


% ------------------------------------------
% Edit axes
        
%
set(haxs_spec, 'FontSize', 12, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
set(haxs_spec, 'XLim', freq_lims_axs)
%
set(haxs_spec, 'XScale', 'log')
set(haxs_spec, 'YScale', 'log')
%
set(haxs_spec, 'YLim', [0.2, 1.1])

%
ylabel(haxs_spec(1), '$S_{\eta}$ [m$^2$ Hz$^{-1}$]', 'Interpreter', 'Latex', 'FontSize', 16)
ylabel(haxs_spec(5), '$S_{\eta}$ [m$^2$ Hz$^{-1}$]', 'Interpreter', 'Latex', 'FontSize', 16)
%
for i = 1:8
    xlabel(haxs_spec(i), 'Frequency [Hz]', 'Interpreter', 'Latex', 'FontSize', 14)
end


% ------------------------------------------
% Add location ID and mean hp on the subplot
%
for i = 1:8
    text(haxs_spec(i), 0.165, 0.9, idfield_to_idpaper(allspectra.locID(i)), ...
                                  'Interpreter', 'Latex', 'FontSize', 24)
                              
            
	%
    if i==1
        %
        text(haxs_spec(1), 0.18, 0.7, {'$\overline{h}_p =$'; ...
                                       ['$' num2str(dataL3.h_obs(i), '%.1f') ' ~\mathrm{m}$']}, ...
                                       'HorizontalAlignment', 'center', 'Interpreter', 'Latex', 'FontSize', 14)        
    else
        
        %
        text(haxs_spec(i), 0.0975, 0.225, ['$\overline{h}_p = ' num2str(dataL3.h_obs(i), '%.1f') ' ~\mathrm{m}$'], ...
                                       'Interpreter', 'Latex', 'FontSize', 14)
    end                      
end


% ---------------------------------------------------------------------
% Add kh as top x axis for each (and set frequency x ticks)

%
frequency_ticks = [0.1, 0.15, 0.2];

%
set(haxs_spec, 'XTick', frequency_ticks)

%
set(haxs_kh, 'FontSize', 12, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')

%
for i = 1:8
    
    %
    h_ref = dataL3.h_obs(i);

    %
    kh_ticks = wave_freqtok(frequency_ticks, h_ref).*h_ref;

    %
    kh_label = cell(1, length(kh_ticks));
    %
    for i2 = 1:length(kh_ticks)
        %
        kh_label{i2} = num2str(kh_ticks(i2), '%.2f');
    end    
    
    
    % ------------------------------------------    

    % Both x axes have to be the same, ...
    set(haxs_kh(i), 'XScale', 'log', 'YScale', 'log', ...
                    'XLim', freq_lims_axs, 'XTick', frequency_ticks, ...
                    'YLim', [0.2, 1.1], ...
                    'YTick', [0.01, 0.2:0.2:1, 10])
    % ..., but they have different labels
    set(haxs_kh(i), 'XTickLabel', kh_label)
    
    %
    xlabel(haxs_kh(i), '$k \overline{h}_p$', 'Interpreter', 'Latex', 'FontSize', 14)
    
end


%% Save figure

%
dir_output = fullfile(paper_directory(), 'figures');

%
exportgraphics(hfig, fullfile(dir_output, 'figure11.pdf'), 'Resolution', 300)

