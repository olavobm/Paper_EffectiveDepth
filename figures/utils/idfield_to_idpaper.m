function [idout] = idfield_to_idpaper(idin)
%% [idout] = IDFIELD_TO_IDPAPER(idin)
%
%   inputs
%       - idin: instrument ID for Smart Moorings in ROXSI2022 experiment.
%
%   outputs
%       - idout: instrument ID for Smart Moorings in paper dealing with
%                transfer function over rough rocky bottom.
%
%
%
% Olavo Badaro Marques


%% Define the correspondence of instrument IDs

matchID.E01 = 'S1';
matchID.E02 = 'S2';
matchID.E05 = 'S3';
matchID.E07 = 'S4';
matchID.E08 = 'S5';
matchID.E09 = 'S6';
% % matchID.E01 = 'S1';
matchID.E11 = 'S7';
matchID.E13 = 'S8';


%% Assign ID output

%
if ischar(idin)
    
    % --------------------
    %
    idout = matchID.(idin);
    
else
    
    % --------------------
    %
    if isstring(idin)
        %
        idout = strings(size(idin));
        %
        for i = 1:length(idin)
            idout(i) = matchID.(idin(i));
        end
    end
    
    % --------------------
    %
    if iscell(idin)
        %
        idout = cell(size(idin));
        %
        for i = 1:length(idin)
            idout{i} = matchID.(idin{i});
        end
    end
    
end

