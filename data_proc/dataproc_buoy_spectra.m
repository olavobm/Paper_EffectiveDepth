%% Compute spectra (and bulk statistics) from Spotter buoy

clear
close all


%% List of moorings to process

list_moorings = ["E01"; "E02"; "E05"; ...
                 "E07"; "E08"; "E09"; ...
                 "E11"; "E13"];


%% Time grid for computing spectra

%
dtime_grid = datetime(2022, 06, 17, 12, 00, 00) : hours(1) : datetime(2022, 07, 20, 04, 00, 00);
dtime_grid.TimeZone = 'America/Los_Angeles';


%% FFT parameters

%
windowfft = 2*60;
windowavg = 3600;

%
datasampling_rate = 1/0.4;    % Hz

%
Npts_fft = datasampling_rate * windowfft;
%
Npts_1hour = windowavg * datasampling_rate;


%% Bulk statistics parameters (used throughout the paper)

%
frequency_limits = [0.1, 0.2];    % in Hz


%% Loop over moorings and compute spectra

for i = 1:length(list_moorings)
    
	%%
    
    %
    dataL1 = load(fullfile(paper_directory(), 'data', 'level_1', ['roxsi_L1_' char(list_moorings(i)) '.mat']));
    dataL1 = dataL1.dataL1;
    

    %% Start filling L2 data structure

    %
    dataL2.mooringID = char(list_moorings(i));
    %
    dataL2.latitude = dataL1.latitude;
    dataL2.longitude = dataL1.longitude;
    dataL2.X = dataL1.X;
    dataL2.Y = dataL1.Y;    
    %
    dataL2.rho0 = dataL1.rho0;
    dataL2.g = dataL1.g;
    
    %
    dataL2.fftparameters.windowfft = seconds(windowfft);
    dataL2.fftparameters.windowavg = seconds(windowavg);
    %
    dataL2.fftparameters.fftoverlap = '50%';
    %
    dataL2.fftparameters.window = 'Hanning';
 
    %
    dataL2.dtime = dtime_grid(:);

    
    %% Find first and last grid points where spectra can be computed

    %
    ind_fill_1 = find((dtime_grid - (seconds(windowavg)/2)) >= dataL1.displacement.dtime(1), 1, 'first');
    ind_fill_2 = find((dtime_grid + (seconds(windowavg)/2)) < dataL1.displacement.dtime(end), 1, 'last');
    %
    inds_fill = ind_fill_1 : 1 : ind_fill_2;
    
    
    %% Find indices in the data to compute spectra
    
    %
    ind_1 = find(dataL1.displacement.dtime >= (dtime_grid(ind_fill_1) - (seconds(windowavg)/2)), 1, 'first');
    ind_2 = find(dataL1.displacement.dtime  < (dtime_grid(ind_fill_2) + (seconds(windowavg)/2)), 1, 'last');
    %
    ind_total = ind_1 : 1 : ind_2;
    
    %
    Nrows = Npts_1hour;
    Ncols = length(ind_total)/Npts_1hour;
    

    %% Compute spectra
    
    %
    z_array = reshape(dataL1.displacement.z(ind_total), [Nrows, Ncols]);

    % Check columns that have no NaNs
    lgood = ~any(isnan(z_array), 1);

    %
    [spec_aux, frequency_aux] = cpsd(z_array(:, lgood), z_array(:, lgood), ...
                                     hanning(Npts_fft), (Npts_fft/2), Npts_fft, ...
                                     datasampling_rate);

    % cpsd results are contaminated in first few low
    % frequency bins. Also quality of Spotter data starts
    % to degrade towards frequencies lower than 0.05 Hz.
    % Just get frequencies above a threshold.
    lkeepaboveTH = (frequency_aux >= 0.02);

    
    %% Add spectra to L2 data structure
    
    %
    dataL2.wavebuoy.df = diff(frequency_aux(1:2));
    dataL2.wavebuoy.frequency = frequency_aux(lkeepaboveTH);
    
    %
    dataL2.wavebuoy.See = NaN(length(dataL2.dtime), length(dataL2.wavebuoy.frequency));
    %
    dataL2.wavebuoy.See(inds_fill(lgood), :) = spec_aux(lkeepaboveTH, :).';
    

    %% Compute bulk statistics
    
    %
    dataL2.wavebuoy.frequencybulkstats = frequency_limits;
    
    %
    linfreqlims = (dataL2.wavebuoy.frequency >= frequency_limits(1)) & ...
                  (dataL2.wavebuoy.frequency <= frequency_limits(2));
    
    %
    dataL2.wavebuoy.Hs = 4*sqrt(trapz(dataL2.wavebuoy.frequency(linfreqlims), ...
                                      dataL2.wavebuoy.See(:, linfreqlims), 2));


    %% Save L2 data file
    
    save(fullfile(paper_directory(), 'data', 'level_2', ['roxsi_L2_' char(list_moorings(i)) '.mat']), 'dataL2')

    
    %%

    %
    disp(['Done computing spectra from Spotter buoy from ' char(list_moorings(i))])

    %
    clear dataL1 dataL2

end


