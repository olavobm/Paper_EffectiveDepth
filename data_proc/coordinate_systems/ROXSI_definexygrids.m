%% Define reference coordinates and direction
% for the different cartesian grids in ROXSI

%
clear


%% Coordinates and angles of reference for each array
%
% The angle is the arc (in clockwise degrees) from the
% geographical north to the offshore direction.

% ------------
% China Rock
%
roxsigrid.ChinaRock.latref = 36 +  (36/60) + (15.8927651999/3600);
roxsigrid.ChinaRock.lonref = -121 -(57/60) - (33.8133851999/3600);
%
roxsigrid.ChinaRock.angleref = 285;


%% Save roxsiGrid structure in the same folder as this script

%
fullnamepath = mfilename('fullpath');

% % %
% % indslash = strfind(fullnamepath, '/');
% % %
% % save(fullfile(fullnamepath(1:indslash(end)), 'ROXSI_xygrids.mat'), 'roxsigrid')

%
dirpath = fileparts(fullnamepath);

%
save(fullfile(dirpath, 'ROXSI_xygrids.mat'), 'roxsigrid')

