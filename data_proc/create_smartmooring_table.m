%% Create simplified mooring table with just the Smart Moorings.

%
clear
close all


%%

%
mooringID = ["E01"; "E02"; "E05"; "E07"; "E08"; "E09"; "E11"; "E13"];
roxsiarray = repmat("ChinaRock", [length(mooringID), 1]);
instrument = repmat("smartspotter", [length(mooringID), 1]);

%
latitude = NaN(length(mooringID), 1);
longitude = latitude;
X = latitude;
Y = latitude;
%
h_mean = latitude;


%%


%
for i = 1:length(mooringID)
    %
    dataL1 = load(fullfile(paper_directory(), 'data', 'level_1', ...
                                 ['roxsi_L1_' char(mooringID(i)) '.mat']));
    dataL1 = dataL1.dataL1;
    
    %
    latitude(i) = dataL1.latitude;
    longitude(i) = dataL1.longitude;
    %
    X(i) = dataL1.X;
    Y(i) = dataL1.Y;
    %
    h_mean(i) = dataL1.psensor.zhab + ...
                mean(dataL1.psensor.pressure, 'omitnan')*(1e4/(dataL1.rho0*dataL1.g));
    
    %
    clear dataL1
end


%% Create table and save file

%
mooringtable = table(mooringID, roxsiarray, instrument, ...
                     latitude, longitude, X, Y, h_mean);

%
save(fullfile(paper_directory(), 'data_proc', 'smartmooring_table.mat'), 'mooringtable')
