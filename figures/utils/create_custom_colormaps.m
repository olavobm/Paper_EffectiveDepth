%% Create colormaps used in the paper

clear
close all


%% Qualitative colors for 8 Smart Moorings

%
indmoorplt = [1:6, 8, 9];

%
figure;
cmapplt = colormap('jet');
ind_clrs = round(linspace(1, (size(cmapplt, 1)), 9));
close(gcf)

%
cmap_new = cmapplt(ind_clrs(indmoorplt), :);

%
cmap_locs = cmap_new;


%% Create red, green, and blue used in the paper for hp, dhopt, and dhbathy

%
cmap_dh = [0.8,   0.05,  0.05; ...
           0.466, 0.674, 0.188; ...
           0,     0.447, 0.741];
       

%% Put all colormaps in a structure variable

%
allcmaps.cmap_locs = cmap_locs;
allcmaps.cmap_dh = cmap_dh;
       

%% Save colormaps created above

%
dir_output = fullfile(paper_directory(), 'figures', 'utils');

%
save(fullfile(dir_output, 'paper_colormaps.mat'), 'allcmaps')

