%% Compute correlations, regressions, and find the best depth
% factpr based on the pressure and Spotter data

clear
close all


%% List of moorings to process

list_moorings = ["E01"; "E02"; "E05"; ...
                 "E07"; "E08"; "E09"; ...
                 "E11"; "E13"];


%%

for i = 1:length(list_moorings)
    
    
    %% Load dataL2

    %
    dataL2 = load(fullfile(paper_directory(), 'data', 'level_2', ['roxsi_L2_' char(list_moorings(i)) '.mat']));
    dataL2 = dataL2.dataL2;

    
    %%
    
    %
    prealloc_aux = NaN(length(dataL2.hfactors), 1);
    
    
    %
    dataL2.datacorrection.r2 = prealloc_aux;
    dataL2.datacorrection.acoef = prealloc_aux;
    dataL2.datacorrection.bcoef = prealloc_aux;
    %
    dataL2.datacorrection.abounds = [prealloc_aux, prealloc_aux];
    dataL2.datacorrection.bbounds = [prealloc_aux, prealloc_aux];
    
    
    %%

    %
    Hs_buoy = dataL2.wavebuoy.Hs;
    Hs_pres = dataL2.psensor.Hs;
    
    %
    x_var = Hs_buoy;
    
    %%
    
    %
    for ind_factor = 1:length(dataL2.hfactors)
        
        %
        y_var = Hs_pres(:, ind_factor);
        
        % Correlation
        r_aux = corr(x_var, y_var, 'rows', 'complete'); 
        
        % Regression
        [coefs_aux, ...
         coefs_bounds_aux] = regress(y_var, [ones(size(x_var)), x_var]);
     
        %
        dataL2.datacorrection.r2(ind_factor) = r_aux.^2;
        dataL2.datacorrection.acoef(ind_factor) = coefs_aux(1);
        dataL2.datacorrection.bcoef(ind_factor) = coefs_aux(2);
        %
        dataL2.datacorrection.abounds(ind_factor, :) = coefs_bounds_aux(1, :);
        dataL2.datacorrection.bbounds(ind_factor, :) = coefs_bounds_aux(2, :);
     
    end
    
    
    %% Compute MSE
    
    % Error squared for wave height
    misfit_aux = (Hs_pres - repmat(Hs_buoy, 1, length(dataL2.hfactors))).^2;

    %
    dataL2.datacorrection.MSE = mean(misfit_aux, 1, 'omitnan');
    dataL2.datacorrection.MSE = dataL2.datacorrection.MSE(:);
        
    
    %% Find minimum of MSE and get the correspondent hfactor
    
    %
    [~, ind_minMSE] = min(dataL2.datacorrection.MSE);
    
    %
    dataL2.datacorrection.ind_minMSE = ind_minMSE;
    %
    dataL2.datacorrection.hfactorbest = dataL2.hfactors(ind_minMSE);
    
    
    %% Compute error
    
    %
    ind_nocorrection = dsearchn(dataL2.hfactors, 0);
    
    %
    MSE_norm = dataL2.datacorrection.MSE ./ dataL2.datacorrection.MSE(ind_minMSE);
    
    %
    difff_MSE_around = diff(MSE_norm((ind_minMSE-1):(ind_minMSE+1)));
    difff_MSE_1 = difff_MSE_around(1);
    difff_MSE_2 = difff_MSE_around(2);
    %
    dh_vec = diff(dataL2.hfactors(1:2));
    
    %
    dMSEdh_1 = difff_MSE_1./dh_vec;
    dMSEdh_2 = difff_MSE_2./dh_vec;
    %
    d2MSEdh2_aux = (dMSEdh_2 - dMSEdh_1) ./ dh_vec;
    
    %
    dataL2.datacorrection.hfactor_error = sqrt(1./(2*d2MSEdh2_aux));


    %% Save/update L2 data file
    
    save(fullfile(paper_directory(), 'data', 'level_2', ['roxsi_L2_' char(list_moorings(i)) '.mat']), 'dataL2')
    
    
    %%

    %
    disp(['Done finding the best hfactor from data for ' char(list_moorings(i))])

    %
    clear dataL2

end
    

