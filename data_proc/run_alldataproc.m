%% Script that does all data processing

clear
close all


%% Add directory/subdirectories to Matlab path

%
dir_thisscript = mfilename('fullpath');
dir_thisscript = fileparts(dir_thisscript);

% Take parent directory
dir_paper = fileparts(dir_thisscript);

%
addpath(fullfile(dir_paper))
addpath(genpath(fullfile(dir_paper, 'data_proc')))
addpath(genpath(fullfile(dir_paper, 'figures')))

%
% % addpath(genpath(fullfile(dir_paper)))


%% Create simplified table for smart moorings

run(fullfile(paper_directory(), 'data_proc', 'create_smartmooring_table.m'))


%% Compute sea surface elevation spectra and Hs from buoy

%
run(fullfile(paper_directory(), 'data_proc', 'dataproc_buoy_spectra.m'))


%% Compute pressure spectra -- update L2 files

%
run(fullfile(paper_directory(), 'data_proc', 'dataproc_psensor_spectra.m'))


%% Compute elevation spectra from pressure (and bulk statistics),
% using a range of different depth corrections -- update L2 files

%
run(fullfile(paper_directory(), 'data_proc', 'dataproc_See_from_Spp.m'))


%% Compare results of Hs from above and find
% the best depth correction from data

%
run(fullfile(paper_directory(), 'data_proc', 'dataproc_hfactor_data.m'))


%% Compute bathymetry statistics for different radii

%
run(fullfile(paper_directory(), 'data_proc', 'dataproc_bathystats.m'))


%% Find best bathymetry correction from bathymetry

%
run(fullfile(paper_directory(), 'data_proc', 'dataproc_compile_hfactors.m'))


%%

disp('----- DONE WITH ALL THE DATA PROCESSING -----')



