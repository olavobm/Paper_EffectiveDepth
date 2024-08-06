%% Run all scripts saving figures

clear
close all


%% Add parent directory to Matlab's path

%
script_fullpath = mfilename('fullpath');
this_dir = fileparts(script_fullpath);

% Take parent directory
dir_paper = fileparts(this_dir);

% % %
% % parent_dir = fileparts(this_dir);
% % %
% % addpath(genpath(parent_dir))

%
addpath(fullfile(dir_paper))
addpath(genpath(fullfile(dir_paper, 'data_proc')))
addpath(genpath(fullfile(dir_paper, 'figures')))


%% Fig. 1: map

run(fullfile(paper_directory(), 'figures', 'makefig_01_mapsite.m'))


%% Fig. 2: - scatter plots of Hs from pressure vs. Spotter

run(fullfile(paper_directory(), 'figures', 'makefig_02_Hscatter_all.m'))


%% Fig. 3: - mean spectru from Spotter and mean from pressure sensor,
% with transfer function evaluated at the local depth

run(fullfile(paper_directory(), 'figures', 'makefig_03_spectra_example.m'))


%% Fig. 4: - this is the combination of a diagram (panel A) I made
% on Keynote, and the figure create here (panel B). I manually combined
% these two panels on Keynote.

%
run(fullfile(paper_directory(), 'figures', 'makefig_04_K2panelB.m'))


%% Fig. 5: error in Hs from pressure relative to Spotter,
% for different delta h's in the data

run(fullfile(paper_directory(), 'figures', 'makefig_05_dhopt.m'))


%% Fig. 6: pdf of bathymetry

run(fullfile(paper_directory(), 'figures', 'makefig_06_pdf_of_bathy.m'))


%% Fig. 7: plot dh from averaged bathymetry and the standard deviation
% of bottom depth (sigma_h) as a function of the radius r

run(fullfile(paper_directory(), 'figures', 'makefig_07_bathy_with_r.m'))


%% Fig. 8: plot average error to get optimal scale

run(fullfile(paper_directory(), 'figures', 'makefig_08_find_rhat.m'))


%% Fig. 9: scatter plot comparing dh_opt and dh_bathy

run(fullfile(paper_directory(), 'figures', 'makefig_09_dh_scatterplot.m'))


%% Fig. 10: scatter plot of Hs with corrections

run(fullfile(paper_directory(), 'figures', 'makefig_10_Hscatter_corrections.m'))


%% Fig. 11: plot spectra with corections at all sites

run(fullfile(paper_directory(), 'figures', 'makefig_11_allspectra_corrections.m'))


%% Fig. 12: time-mean error of spectra

run(fullfile(paper_directory(), 'figures', 'makefig_12_error_in_spectra.m'))


%% Fig. 13: make bar chart with MSE reduction

run(fullfile(paper_directory(), 'figures', 'makefig_13_error_reduction.m'))



%% Fig. 14: plot R (ratio), an estimate of the overestimate

run(fullfile(paper_directory(), 'figures', 'makefig_14_error_R.m'))




