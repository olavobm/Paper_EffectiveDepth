%% Compute bathymetry statistics around smart moorings

clear
close all


%% Load mooring table

%
mooringtable = load(fullfile(paper_directory(), 'data_proc', 'smartmooring_table.mat'));
mooringtable = mooringtable.mooringtable;


%% List of moorings to process

list_moorings = ["E01"; "E02"; "E05"; ...
                 "E07"; "E08"; "E09"; ...
                 "E11"; "E13"];
             

%% Radii for statistics

%
dr = 1;
rvec = 2:dr:30;


%% Parameters for statistics

%
quantiles_fraction = [1/3, 2/3];


%%

%
Nlocs = length(list_moorings);
Nr = length(rvec);

%
bathystats.mooringID = list_moorings(:).';

%
bathystats.latitude0 = NaN(Nlocs, 1);
bathystats.longitude0 = NaN(Nlocs, 1);
bathystats.X0 = NaN(Nlocs, 1);
bathystats.Y0 = NaN(Nlocs, 1);
%
bathystats.h_obs = NaN(Nlocs, 1);

%
bathystats.dr = dr;
bathystats.r = rvec;

%
bathystats.quantiles = quantiles_fraction;


%%

prealloc_aux = NaN(length(rvec), Nlocs);
%
bathystats.Npts = prealloc_aux;
bathystats.zmsl_avg = prealloc_aux;
bathystats.zmsl_median = prealloc_aux;
%
bathystats.zmsl_stddev = prealloc_aux;
bathystats.zmsl_stddev_deplaned = prealloc_aux;
%
bathystats.zmsl_skewness = prealloc_aux;
bathystats.zmsl_skewness_deplaned = prealloc_aux;
%
bathystats.z_lower_quantile = prealloc_aux;
bathystats.z_upper_quantile = prealloc_aux;


%% Loop over moorings calculate bathymetry statistics around each mooring

%
for i = 1:length(list_moorings)
    
    %% Load files with bathymetry
    
    %
    elevroxsi = load(fullfile(paper_directory(), 'data', 'bathymetry', ...
                               ['roxsi_pointcloud_' char(list_moorings(i)) '.mat']));
    elevroxsi = elevroxsi.elevroxsi;
    
    
    
    %%
    
    bathystats.latitude0(i) = elevroxsi.latitude0;
    bathystats.longitude0(i) = elevroxsi.longitude0;
    %
    bathystats.X0(i) = elevroxsi.X0;
    bathystats.Y0(i) = elevroxsi.Y0;
    %
    bathystats.h_obs(i) = elevroxsi.h_obs;
    
    
    %% Loop over radii and compute statistics
 
    %
    for ind_r = 1:length(rvec)
    
        %%  Get bathymetry only within one radius
    
        %
        linradius = (elevroxsi.dist_frommooring <= bathystats.r(ind_r));
        %
        z_sub_aux = elevroxsi.z_msl(linradius);
        
        
        %% Compute statistics
        
        %
        bathystats.Npts(ind_r, i) = length(z_sub_aux);
        %
        bathystats.zmsl_avg(ind_r, i) = mean(z_sub_aux);
        bathystats.zmsl_median(ind_r, i) = median(z_sub_aux);
        %
        bathystats.zmsl_stddev(ind_r, i) = std(z_sub_aux);
        %
        bathystats.zmsl_skewness(ind_r, i) = skewness(z_sub_aux);
        %
        bathystats.z_lower_quantile(ind_r, i) = quantile(z_sub_aux, bathystats.quantiles(1));
        bathystats.z_upper_quantile(ind_r, i) = quantile(z_sub_aux, bathystats.quantiles(2));
          
        
        %% Deplane bottom depth and calculate
        % standard deviation in the anomaly
        
        %
        x_sub_aux = elevroxsi.x(linradius);
        y_sub_aux = elevroxsi.y(linradius);
        
        %
        x_rel_aux = x_sub_aux - mean(x_sub_aux);
        y_rel_aux = y_sub_aux - mean(y_sub_aux);
        
        %
        planefitcoefs = regress(z_sub_aux, [ones(bathystats.Npts(ind_r, i), 1), ...
                                            x_rel_aux, y_rel_aux]);
        
        %
        zmsl_planefit = planefitcoefs(1) + ...
                        planefitcoefs(2).*x_rel_aux + ...
                        planefitcoefs(3).*y_rel_aux;
        
        %
        bathystats.zmsl_stddev_deplaned(ind_r, i) = sqrt(mean((z_sub_aux - zmsl_planefit).^2));
        
        %
        bathystats.zmsl_skewness_deplaned(ind_r, i) = skewness(z_sub_aux - zmsl_planefit);
        
        
    end
    

    
    %%

    %
    disp(['Done with bathymetry statistics around mooring ' char(list_moorings(i))])

    
    %%
    
    clear elevroxsi
    
end

    
%% Compute differences between mean (or median) bathymetry at
% different radii and the mean local depth at the pressure sensor

%
bathystats.hdiff_mean = -bathystats.zmsl_avg - bathystats.h_obs(:).';
bathystats.hdiff_median = -bathystats.zmsl_median - bathystats.h_obs(:).';


%% Save file with bathymetry statistics


save(fullfile(paper_directory(), 'data', 'level_3', 'roxsi_bathystats.mat'), 'bathystats')


%
disp('--- done with bathymetry statistics at all smart mooring sites ---')

