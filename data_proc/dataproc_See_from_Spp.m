%% Compute transfer functions for a range of adjustments of bottom
% depth (relative to the local water depth at the pressure
% sensor), and compute elevation spectra for all these transfer functions.

clear
close all


%% List of moorings to process

list_moorings = ["E01"; "E02"; "E05"; ...
                 "E07"; "E08"; "E09"; ...
                 "E11"; "E13"];

             
%% Range of depth adjustment factors

%
hfactors = -3.2 : 0.1 : 1.5;

%
ind_hp = find(hfactors == 0);


%% Set a a high frequency threshold so that
% transfer functions are only computed for
% lower frequencies

highfreqTH = 0.4;


%% Loop over moorings, compute local bottom depth, compute
% wavenumbers, transfer function, elevation spectra and
% significant wave height

%
for i = 1:length(list_moorings)
    
    
    %% Load L2 data
        
    %
    dataL2 = load(fullfile(paper_directory(), 'data', 'level_2', ['roxsi_L2_' char(list_moorings(i)) '.mat']));
    dataL2 = dataL2.dataL2;
    
    %%
    
    %
    all_array = [length(dataL2.dtime), length(dataL2.psensor.frequency), length(hfactors)];
    
    %
    dataL2.psensor.highfrequencyTH = highfreqTH;
    
    %
    dataL2.hfactors = hfactors(:);
    dataL2.ind_hp = ind_hp;
    
    %
    dataL2.psensor.k = NaN(all_array);
    %
    dataL2.psensor.zhab_withhfactor = NaN([length(hfactors), 1]);
    %
    dataL2.psensor.TF_Spp_to_See = NaN(all_array);
    dataL2.psensor.See = NaN(all_array);

    
    %% Loop over depth adjustment factors and comput elevation spectra
    
    %
    llowerfreq = (dataL2.psensor.frequency <= highfreqTH);
    
    % Loop over factors
    for i2 = 1:length(hfactors)
    
        %% Adjust bottomdepth
        
        h_withfactor = dataL2.psensor.bottomdepth + hfactors(i2);
        
        
        %% Compute wavenumber

        % Loop over time
        for i3 = 1:length(dataL2.dtime)

            %
            k_aux = wave_freqtok(dataL2.psensor.frequency(llowerfreq), h_withfactor(i3));
            k_aux = k_aux(:);
            
            %
            dataL2.psensor.k(i3, llowerfreq, i2) = k_aux;

        end


        
        %% Set adjusted height above the bottom
        
        %
        zhab_aux = (dataL2.psensor.zhab + hfactors(i2));
        %
        if zhab_aux < 0
            zhab_aux = 0;
        end
        %
        dataL2.psensor.zhab_withhfactor(i2) = zhab_aux;
        
        
        %% Compute transfer function -- (cosh(k*h)/cosh(k*zhab))^2

        %
        Tfcn = cosh(dataL2.psensor.k(:, :, i2) .* repmat(h_withfactor, 1, length(dataL2.psensor.frequency))) ./ ...
               cosh(dataL2.psensor.k(:, :, i2) * zhab_aux);
        Tfcn = Tfcn.^2;

        %
        dataL2.psensor.TF_Spp_to_See(:, :, i2) = Tfcn;


        %% Compute elevation spectra from Spp
        
        dataL2.psensor.See(:, :, i2) = dataL2.psensor.TF_Spp_to_See(:, :, i2) .* dataL2.psensor.Spp;
        
        %%
        
% %         %
% %         disp(['done with ' num2str(i2) ' out of ' num2str(length(hfactors)) ''])
        
    end
    

    %% Compute significant wave height
    
    %
    dataL2.psensor.frequencybulkstats = dataL2.wavebuoy.frequencybulkstats;
    %
    linfreqlims = (dataL2.psensor.frequency >= dataL2.psensor.frequencybulkstats(1)) & ...
                  (dataL2.psensor.frequency <= dataL2.psensor.frequencybulkstats(2));
    
    %
    dataL2.psensor.Hs = 4*sqrt(trapz(dataL2.psensor.frequency(linfreqlims), ...
                                     dataL2.psensor.See(:, linfreqlims, :), 2));
	dataL2.psensor.Hs = squeeze(dataL2.psensor.Hs);
    
    
    %% Save/update L2 data file
    
    save(fullfile(paper_directory(), 'data', 'level_2', ['roxsi_L2_' char(list_moorings(i)) '.mat']), 'dataL2')

    %%
    
    %
    disp(['Done computing elevation spectra from pressure for ' char(list_moorings(i))])

    %
    clear dataL2
    
end

