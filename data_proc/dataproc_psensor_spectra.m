%% Compute pressure spectra from pressure sensors in Smart Moorings
% (this script is similar to dataproc_buoy_spectra.m, but the current
% script must be run after dataproc_buoy_spectra.m to make calculations
% consistent).

clear
close all


%% List of moorings to process

list_moorings = ["E01"; "E02"; "E05"; ...
                 "E07"; "E08"; "E09"; ...
                 "E11"; "E13"];



%% Sampling rate of pressure sensors

datasampling_rate = 1/0.5;    % Hz


%% Loop over moorings and compute spectra

for i = 1:length(list_moorings)
    
	%%
    
    %
    dataL1 = load(fullfile(paper_directory(), 'data', 'level_1', ['roxsi_L1_' char(list_moorings(i)) '.mat']));
    dataL1 = dataL1.dataL1;
    
    
    %% Load dataL2 that already exists (created by dataproc_buoy_spectra.m)
    
    %
    dataL2 = load(fullfile(paper_directory(), 'data', 'level_2', ['roxsi_L2_' char(list_moorings(i)) '.mat']));
    dataL2 = dataL2.dataL2;
    
    %
    dtime_grid = dataL2.dtime;
    

    %% Get parameters from existing L2 data structure
    
    % Here converts from seconds format to double variable
    windowavg = seconds(dataL2.fftparameters.windowavg);
    
    %
    Npts_fft = datasampling_rate * seconds(dataL2.fftparameters.windowfft);
    Npts_1hour = datasampling_rate * windowavg;

    
    %% Find first and last grid points where spectra can be computed

    %
    ind_fill_1 = find((dtime_grid - (seconds(windowavg)/2)) >= dataL1.psensor.dtime(1), 1, 'first');
    ind_fill_2 = find((dtime_grid + (seconds(windowavg)/2)) < dataL1.psensor.dtime(end), 1, 'last');
    %
    inds_fill = ind_fill_1 : 1 : ind_fill_2;
    
    
    %% Find indices in the data to compute spectra
    
    %
    ind_1 = find(dataL1.psensor.dtime >= (dtime_grid(ind_fill_1) - (seconds(windowavg)/2)), 1, 'first');
    ind_2 = find(dataL1.psensor.dtime  < (dtime_grid(ind_fill_2) + (seconds(windowavg)/2)), 1, 'last');
    %
    ind_total = ind_1 : 1 : ind_2;
    
    %
    Nrows = Npts_1hour;
    Ncols = length(ind_total)/Npts_1hour;
    

    %% Compute spectra
    
    %
    p_array = reshape(dataL1.psensor.pressure(ind_total), [Nrows, Ncols]);

    % Convert from dbar to m
    p_array = 1e4*p_array./(dataL2.rho0*dataL2.g);
    
    
    % Check columns that have no NaNs
    lgood = ~any(isnan(p_array), 1);

    %
    [spec_aux, frequency_aux] = cpsd(p_array(:, lgood), p_array(:, lgood), ...
                                     hanning(Npts_fft), (Npts_fft/2), Npts_fft, ...
                                     datasampling_rate);

    % cpsd results are contaminated in first few low
    % frequency bins. Also make this consistent at
    % with spectra from the wave buoy.
    % Just get frequencies above a threshold.
    lkeepaboveTH = (frequency_aux >= 0.02);

    
    %% Add spectra to L2 data structure
    
    %
    dataL2.psensor.zhab = dataL1.psensor.zhab;
    
    %
    dataL2.psensor.bottomdepth = NaN(length(dataL2.dtime), 1);
    dataL2.psensor.bottomdepth(inds_fill) = mean(p_array, 1) + dataL2.psensor.zhab;
    
    %
    dataL2.psensor.df = diff(frequency_aux(1:2));
    dataL2.psensor.frequency = frequency_aux(lkeepaboveTH);
    
    %
    dataL2.psensor.Spp = NaN(length(dataL2.dtime), length(dataL2.psensor.frequency));
    %
    dataL2.psensor.Spp(inds_fill(lgood), :) = spec_aux(lkeepaboveTH, :).';
    

    %% Save/update L2 data file
    
    save(fullfile(paper_directory(), 'data', 'level_2', ['roxsi_L2_' char(list_moorings(i)) '.mat']), 'dataL2')

    
    %%

    %
    disp(['Done computing pressure spectra from ' char(list_moorings(i))])

    %
    clear dataL1 dataL2

end


