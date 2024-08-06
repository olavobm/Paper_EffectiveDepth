%% Run all data processing and make all figure

%
disp(['Start time of processing: ' datestr(now())])

run(fullfile(paper_directory(), 'data_proc', 'run_alldataproc.m'))

%
% % addpath(genpath('~/MATLAB/cmocean'))

%
run(fullfile(paper_directory(), 'figures', 'run_allfigures.m'))

%
disp(['End time of processing: ' datestr(now())])