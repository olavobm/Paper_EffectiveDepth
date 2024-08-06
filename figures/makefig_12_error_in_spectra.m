%% Make Figure 12 -- plot spectral errors, with different dh corrections

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


%%

%
allspectra.timemean.error_hp = NaN(31, 8);
allspectra.timemean.error_hdata = NaN(31, 8);
allspectra.timemean.error_hbathy = NaN(31, 8);

% Compute time-mean errors
for i = 1:8
    %
    lok_aux = ~isnan(allspectra.Szz_spotter(:, 3, i)) & ...
              ~isnan(allspectra.Szz_hp(:, 3, i));
	%
    error_hp = mean(allspectra.Szz_hp(lok_aux, :, i), 1) - mean(allspectra.Szz_spotter(lok_aux, :, i), 1);
    error_hdata = mean(allspectra.Szz_heff_data(lok_aux, :, i), 1) - mean(allspectra.Szz_spotter(lok_aux, :, i), 1);
    error_hbathy = mean(allspectra.Szz_heff_bathy(lok_aux, :, i), 1) - mean(allspectra.Szz_spotter(lok_aux, :, i), 1);
    %
    allspectra.timemean.error_hp(:, i) = error_hp;
    allspectra.timemean.error_hdata(:, i) = error_hdata;
    allspectra.timemean.error_hbathy(:, i) = error_hbathy;
end


%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.27, 0.2, 0.25, 0.6];

% Create these first
haxs = makeSubPlots(0.2, 0.04, 0.01, ...
                    0.1, 0.08, 0.02, 1, 3);
hold(haxs, 'on')

    %
    lnWd_A = 1.5;
    lnWd_B = 3.5;

    %
    for i = 1:8
        %
        plot(haxs(1), allspectra.frequency, ...
                      allspectra.timemean.error_hp(:, i), ...
                      '-', 'Color', allcmaps.cmap_locs(i, :), 'LineWidth', lnWd_A);
        %
        plot(haxs(2), allspectra.frequency, ...
                      allspectra.timemean.error_hdata(:, i), ...
                      '-', 'Color', allcmaps.cmap_locs(i, :), 'LineWidth', lnWd_A);
        %
        plot(haxs(3), allspectra.frequency, ...
                      allspectra.timemean.error_hbathy(:, i), ...
                      '-', 'Color', allcmaps.cmap_locs(i, :), 'LineWidth', lnWd_A);
    end

	%
    for i = 1:length(haxs)
        plot(haxs(i), allspectra.frequency([1, end]), [0, 0], '-k')
    end
    
    %
    plot(haxs(1), allspectra.frequency, ...
                  mean(allspectra.timemean.error_hp, 2), ...
                 '-', 'Color', 'k', 'LineWidth', lnWd_B);
    %
    plot(haxs(2), allspectra.frequency, ...
                  mean(allspectra.timemean.error_hdata, 2), ...
                 '-', 'Color', 'k', 'LineWidth', lnWd_B);
    %
    plot(haxs(3), allspectra.frequency, ...
                  mean(allspectra.timemean.error_hbathy, 2), ...
                 '-', 'Color', 'k', 'LineWidth', lnWd_B);
          
             
% -----------------------------------------------------------
             
%
xlbltxt = 0.0805;
ylbltxt = 0.2;
%
txtFS = 16.5;             
%
text(haxs(1), xlbltxt, ylbltxt, 'a) $\hspace{-0.1cm} \overline{K^2(h_p) S_p} - \overline{S}_{\eta}$', 'Interpreter', 'Latex', 'FontSize', txtFS)
text(haxs(2), xlbltxt, ylbltxt, 'b) $\hspace{-0.1cm} \overline{K^2(h_p + \delta h_{\mathrm{opt}}) S_p} - \overline{S}_{\eta}$', 'Interpreter', 'Latex', 'FontSize', txtFS)
text(haxs(3), xlbltxt, ylbltxt, 'c) $\hspace{-0.1cm} \overline{K^2(h_p + \delta h_{\mathrm{bathy}}) S_p} - \overline{S}_{\eta}$', 'Interpreter', 'Latex', 'FontSize', txtFS)
             

% -----------------------------------------------------------
%
haxs_leg = axes('Position', [0.615, 0.59, 0.345, 0.13]);
%
hold(haxs_leg, 'on')
%
set(haxs_leg, 'Box', 'on', 'XLim', [0, 1], 'YLim', [0, 1])
%
set(haxs_leg, 'XTick', [], 'YTick', [])

%
ydisp = 0.125;
y_aux = linspace(ydisp, (1 - 1.5*ydisp), 3);
%
xdisp_left = 0.02;
xdisp_right = 0.36;
x_aux = linspace(xdisp_left, (1 - xdisp_right), 3);

%
[x_grid_aux, y_grid_aux] = meshgrid(x_aux, y_aux);
y_grid_aux = flipud(y_grid_aux);

%
xlen = 0.1;

%
for i = 1:8
    %
    plot(haxs_leg, x_grid_aux(i) + [0, xlen], y_grid_aux(i).*[1, 1], '-', 'Color', allcmaps.cmap_locs(i, :), 'LineWidth', 3)
    %
    text(haxs_leg, x_grid_aux(i) + (xlen + 0.02), y_grid_aux(i), ...
                   idfield_to_idpaper(char(allspectra.locID(i))), ...
                   'Interpreter', 'Latex', 'FontSize', 20, 'VerticalAlignment', 'middle')
end
%
plot(haxs_leg, x_grid_aux(end) + [0, xlen], y_grid_aux(end).*[1, 1], '-k', 'LineWidth', 3)
%
text(haxs_leg, x_grid_aux(end) + (xlen + 0.02), y_grid_aux(end), ...
               'mean', ...
               'Interpreter', 'Latex', 'FontSize', 15, 'VerticalAlignment', 'middle')
               
% -----------------------------------------------------------

%
set(haxs, 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
%
set(haxs, 'XScale', 'log', 'XLim', [0.08, 0.22])
set(haxs(1:end-1), 'XTickLabel', [])
%
set(haxs, 'YLim', [-0.15, 0.25])


%
for i = 1:3
    ylabel(haxs(i), '[m$^2$ Hz$^{-1}$]', 'Interpreter', 'Latex', 'FontSize', 16)
end
%
xlabel(haxs(end), 'Frequency [Hz]', 'Interpreter', 'Latex', 'FontSize', 16)

%
set(haxs, 'Color', 0.85.*[1, 1, 1])
set(haxs_leg, 'Color', 0.85.*[1, 1, 1])


%% Save figure

%
dir_output = fullfile(paper_directory(), 'figures');

%
exportgraphics(hfig, fullfile(dir_output, 'figure12.pdf'), 'Resolution', 300)

