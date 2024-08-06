%% Get hfactor from data and look at bathymetry
% statistics to get a h factor from bathymetry

clear
close all


%% List of moorings to process

list_moorings = ["E01"; "E02"; "E05"; ...
                 "E07"; "E08"; "E09"; ...
                 "E11"; "E13"];

             
%% Start populating L3 data structure

%
dataL3.mooringID = list_moorings;

%
dataL3.h_obs = NaN(length(list_moorings), 1);


%%

%
bathystats = load(fullfile(paper_directory(), 'data', 'level_3', 'roxsi_bathystats.mat'));
bathystats = bathystats.bathystats;


%%

%
for i = 1:length(list_moorings)
    

    %% Load L2 data (with h factor correction and statistics of bathymetry)
    
    %
    dataL2 = load(fullfile(paper_directory(), 'data', 'level_2', ['roxsi_L2_' char(list_moorings(i)) '.mat']));
    %
    dataL2 = dataL2.dataL2;
    
    
    %%
    
    dataL3.h_obs(i) = bathystats.h_obs(i);
    
    %%
    
    if i==1
        
        %
        ind_obs = find(dataL2.hfactors == 0);
        
        % -----------------------------------
        %
        dataL3.datacorr.hfactors = dataL2.hfactors;
        %
        dataL3.datacorr.MSE = NaN(length(dataL3.mooringID), length(dataL3.datacorr.hfactors));
        dataL3.datacorr.ind_minMSE = NaN(length(dataL3.mooringID), 1);
        %
        dataL3.datacorr.MSEobs = NaN(length(dataL3.mooringID), 1);
        dataL3.datacorr.MSEmin = NaN(length(dataL3.mooringID), 1);
        %
        dataL3.datacorr.hfactor = NaN(length(dataL3.mooringID), 1);
        dataL3.datacorr.hfactor_error = NaN(length(dataL3.mooringID), 1);
        
        % -----------------------------------
        %
        dataL3.bathycorr.radii = bathystats.r;
        
        %
        prealloc_aux = NaN(length(dataL3.mooringID), length(dataL3.bathycorr.radii));
        
        %
        dataL3.bathycorr.h_mean = prealloc_aux;
        dataL3.bathycorr.h_median = prealloc_aux;
        
        %
        dataL3.bathycorr.hfactor_MSE_mean = prealloc_aux;
        dataL3.bathycorr.hfactor_MSE_median = prealloc_aux;
        
    end
    
    
    %%
    
    %
    dataL3.datacorr.MSE(i, :) = dataL2.datacorrection.MSE;
    dataL3.datacorr.ind_minMSE(i) = dataL2.datacorrection.ind_minMSE;
    %
    dataL3.datacorr.MSEobs(i) = dataL3.datacorr.MSE(i, ind_obs);
    dataL3.datacorr.MSEmin(i) = dataL3.datacorr.MSE(i, dataL3.datacorr.ind_minMSE(i));
    %
    dataL3.datacorr.hfactor(i) = dataL2.datacorrection.hfactorbest;
    dataL3.datacorr.hfactor_error(i) = dataL2.datacorrection.hfactor_error;
    
    
    %%
    
    %
    dataL3.bathycorr.h_mean(i, :) = bathystats.zmsl_avg(:, i);
    dataL3.bathycorr.h_median(i, :) = bathystats.zmsl_median(:, i);
    %
    dataL3.bathycorr.h_quantile_1(i, :) = bathystats.z_lower_quantile(:, i);
    dataL3.bathycorr.h_quantile_2(i, :) = bathystats.z_upper_quantile(:, i);
    
    %
    hfactors_MSE_mean = (bathystats.hdiff_mean(:, i) - dataL2.datacorrection.hfactorbest).^2;
    hfactors_MSE_median = (bathystats.hdiff_median(:, i) - dataL2.datacorrection.hfactorbest).^2;
    
    %
    dataL3.bathycorr.hfactor_MSE_mean(i, :) = hfactors_MSE_mean;
    dataL3.bathycorr.hfactor_MSE_median(i, :) = hfactors_MSE_median;
    
    
    %%

    %
    disp(['Done with compiling h factors results from mooring ' char(list_moorings(i))])

    %%
    
    clear dataL2
    
    
end


%% Average error across moorings

%
dataL3.bathycorr.hfactor_MSEmean_avg = mean(dataL3.bathycorr.hfactor_MSE_mean, 1);
dataL3.bathycorr.hfactor_MSEmedian_avg = mean(dataL3.bathycorr.hfactor_MSE_median, 1);

%
dataL3.bathycorr.hfactor_MSEmean_avg = dataL3.bathycorr.hfactor_MSEmean_avg(:);
dataL3.bathycorr.hfactor_MSEmedian_avg = dataL3.bathycorr.hfactor_MSEmedian_avg(:);


%% Get radius for hbathy correction and the
% corresponding factor for each mooring

%
% % [~, ind_bestradius] = min(dataL3.bathycorr.hfactor_MSEmean_avg);
[~, ind_bestradius] = min(dataL3.bathycorr.hfactor_MSEmedian_avg);

%
dataL3.bathycorr.radius_hbathy = dataL3.bathycorr.radii(ind_bestradius);
%
dataL3.bathycorr.hfactor = NaN(length(dataL3.mooringID), 1);
%
dataL3.bathycorr.hfactor_quantiles = NaN(length(dataL3.mooringID), 2);
        

%
for i = 1:length(dataL3.mooringID)
    
    %
% %     dataL3.bathycorr.hfactor(i) = -dataL3.h_obs(i) - dataL3.bathycorr.h_mean(i, ind_bestradius);
    dataL3.bathycorr.hfactor(i) = -dataL3.h_obs(i) - dataL3.bathycorr.h_median(i, ind_bestradius);

    %
    dataL3.bathycorr.hfactor_quantiles(i, 1) = -dataL3.h_obs(i) - dataL3.bathycorr.h_quantile_1(i, ind_bestradius);
    dataL3.bathycorr.hfactor_quantiles(i, 2) = -dataL3.h_obs(i) - dataL3.bathycorr.h_quantile_2(i, ind_bestradius);
end

        
%% Save file results

save(fullfile(paper_directory(), 'data', 'level_3', 'roxsi_dataL3.mat'), 'dataL3')
           
    
